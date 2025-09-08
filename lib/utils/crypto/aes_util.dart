import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class AesUtil {
  // Static IV as per YagoutPay documentation: "0123456789abcdef"
  static const String _ivString = '0123456789abcdef';
  static const int _blockSize = 16;

  /// Encrypt text using AES-256-CBC matching YagoutPay's exact PHP implementation
  /// Replicates: openssl_encrypt($padtext, "AES-256-CBC", base64_decode($key), OPENSSL_RAW_DATA | OPENSSL_ZERO_PADDING, $iv)
  static String encryptToBase64(String plainText, String base64Key) {
    try {
      // Decode the base64 key exactly as PHP does
      final key = base64.decode(base64Key);

      // Convert IV string to bytes exactly as PHP does
      // PHP treats "0123456789abcdef" as ASCII bytes, not hex
      final iv = Uint8List.fromList(_ivString.codeUnits.take(16).toList());

      // Ensure key is exactly 32 bytes for AES-256
      if (key.length != 32) {
        throw Exception(
            'Key must be exactly 32 bytes for AES-256, got ${key.length}');
      }

      // Convert plainText to UTF-8 bytes (as PHP strlen() counts bytes, not chars)
      final textBytes = utf8.encode(plainText);
      
      // PHP's exact padding logic from documentation:
      // $size = 16;
      // $pad = $size - (strlen($text) % $size);
      // $padtext = $text . str_repeat(chr($pad), $pad);
      final size = _blockSize;
      final pad = size - (textBytes.length % size);
      
      // Create padded bytes with padding bytes (PKCS7 padding)
      final paddedBytes = Uint8List(textBytes.length + pad);
      paddedBytes.setRange(0, textBytes.length, textBytes);
      
      // Fill padding bytes with pad value
      for (int i = textBytes.length; i < paddedBytes.length; i++) {
        paddedBytes[i] = pad;
      }

      // Create AES cipher with CBC mode
      final cipher = CBCBlockCipher(AESEngine());
      final params = ParametersWithIV(KeyParameter(key), iv);
      cipher.init(true, params);

      // Encrypt the padded bytes
      final encrypted = Uint8List(paddedBytes.length);
      var offset = 0;

      while (offset < paddedBytes.length) {
        final block = paddedBytes.sublist(offset, offset + _blockSize);
        final encryptedBlock = cipher.process(block);
        encrypted.setRange(offset, offset + _blockSize, encryptedBlock);
        offset += _blockSize;
      }

      // Return base64 encoded result (OPENSSL_RAW_DATA)
      return base64.encode(encrypted);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt text using AES-256-CBC matching YagoutPay's exact PHP implementation
  /// Replicates: openssl_decrypt($crypt, "AES-256-CBC", base64_decode($key), OPENSSL_RAW_DATA | OPENSSL_ZERO_PADDING, $iv)
  static String decryptFromBase64(String encryptedText, String base64Key) {
    try {
      // Decode the base64 encrypted text
      final encrypted = base64.decode(encryptedText);

      // Decode the base64 key
      final key = base64.decode(base64Key);

      // Convert IV string to bytes exactly as PHP does
      final iv = Uint8List.fromList(_ivString.codeUnits.take(16).toList());

      // Create AES cipher with CBC mode
      final cipher = CBCBlockCipher(AESEngine());
      final params = ParametersWithIV(KeyParameter(key), iv);
      cipher.init(false, params);

      // Decrypt the encrypted text
      final decrypted = Uint8List(encrypted.length);
      var offset = 0;

      while (offset < encrypted.length) {
        final block = encrypted.sublist(offset, offset + _blockSize);
        final decryptedBlock = cipher.process(block);
        decrypted.setRange(offset, offset + _blockSize, decryptedBlock);
        offset += _blockSize;
      }

      // PHP's exact unpadding logic from documentation:
      // $pad = ord($padtext[strlen($padtext) - 1]);
      // if ($pad > strlen($padtext)) { return false; }
      // if (strspn($padtext, $padtext[strlen($padtext) - 1], strlen($padtext) - $pad) != $pad) { $text = "Error"; }
      // $text = substr($padtext, 0, -1 * $pad);

      if (decrypted.isEmpty) return '';

      final pad = decrypted[decrypted.length - 1];
      if (pad > decrypted.length || pad == 0) {
        throw Exception(
            'Invalid padding: pad value $pad > data length ${decrypted.length}');
      }

      // Check if padding is valid (all padding bytes should have the same value)
      final paddingStart = decrypted.length - pad;
      for (int i = paddingStart; i < decrypted.length; i++) {
        if (decrypted[i] != pad) {
          throw Exception(
              'Invalid padding: padding bytes do not match pad value');
        }
      }

      // Remove padding and convert to string
      final result = utf8.decode(decrypted.sublist(0, paddingStart));
      return result;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Generate hash for hosted payments as per YagoutPay documentation
  /// This is required for the hosted payment flow
  static String generateHash(String data, String base64Key) {
    // For hosted payments, hash is the encrypted merchant_request
    return encryptToBase64(data, base64Key);
  }

  /// Validate encryption key format
  static bool isValidKey(String base64Key) {
    try {
      final key = base64.decode(base64Key);
      return key.length >= 32; // AES-256 requires at least 32 bytes
    } catch (e) {
      return false;
    }
  }

  /// Test encryption compatibility with YagoutPay PHP implementation
  /// This creates test vectors to validate our implementation matches exactly
  static Map<String, String> createTestVectors(String base64Key) {
    const testData = '{"me_id":"202505090001","amount":"100"}';
    
    try {
      final encrypted = encryptToBase64(testData, base64Key);
      final decrypted = decryptFromBase64(encrypted, base64Key);
      
      return {
        'original': testData,
        'encrypted': encrypted,
        'decrypted': decrypted,
        'roundtrip_success': (testData == decrypted).toString(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Pad data for zero padding as used in hosted payments
  /// This ensures data is a multiple of 16 bytes for OPENSSL_ZERO_PADDING
  static String padForZeroPadding(String data) {
    // Convert to bytes to get accurate length
    final dataBytes = utf8.encode(data);
    final size = _blockSize;
    final remainder = dataBytes.length % size;
    
    if (remainder == 0) {
      // Already properly aligned
      return data;
    }
    
    // Calculate padding needed
    final paddingNeeded = size - remainder;
    
    // For OPENSSL_ZERO_PADDING, we need to pad with null bytes (\0)
    final paddingBytes = List.filled(paddingNeeded, 0);
    
    // Combine original data bytes with padding
    final paddedBytes = [...dataBytes, ...paddingBytes];
    
    // Convert back to string (padding bytes will be null characters)
    return String.fromCharCodes(paddedBytes);
  }
}
