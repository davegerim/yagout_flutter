import 'lib/services/yagoutpay_service.dart';
import 'lib/utils/crypto/aes_util.dart';
import 'lib/config/yagoutpay_config.dart';
import 'dart:convert';

void main() async {
  print('=== ENCRYPTION DEBUG TEST ===');
  print('Testing encryption with the new flat JSON structure');
  print('');

  final meId = YagoutPayConfig.apiMerchantId;
  final key = YagoutPayConfig.apiKey;

  print('Merchant ID: $meId');
  print('Key: $key');
  print('Key length: ${base64.decode(key).length} bytes');
  print('');

  // Test 1: Simple encryption test (like the working test endpoint)
  print('=== Test 1: Simple Encryption Test ===');
  final simpleData = jsonEncode({'me_id': meId, 'amount': '100'});
  print('Simple data: $simpleData');
  
  try {
    final simpleEncrypted = AesUtil.encryptToBase64(simpleData, key);
    print('Simple encrypted: $simpleEncrypted');
    
    // Test round-trip
    final simpleDecrypted = AesUtil.decryptFromBase64(simpleEncrypted, key);
    print('Simple decrypted: $simpleDecrypted');
    print('Round-trip success: ${simpleData == simpleDecrypted}');
  } catch (e) {
    print('Simple encryption failed: $e');
  }

  print('');
  
  // Test 2: New flat JSON structure encryption
  print('=== Test 2: New Flat JSON Structure ===');
  final flatJsonData = {
    "order_no": "OR-DOIT-1234",
    "amount": "100.00",
    "country": "ETH",
    "currency": "ETB",
    "txn_type": "SALE",
    "success_url": "https://example.com/success",
    "failure_url": "https://example.com/failure",
    "channel": "MOBILE",
    "ag_id": YagoutPayConfig.aggregatorId,
    "me_id": meId,
    "customer_name": "Test Customer",
    "email_id": "test@example.com",
    "mobile_no": "0912345678",
    "is_logged_in": "Y",
    "unique_id": "",
    "bill_address": "",
    "bill_city": "",
    "bill_state": "",
    "bill_country": "ETH",
    "bill_zip": "",
    "ship_address": "",
    "ship_city": "",
    "ship_state": "",
    "ship_country": "ETH",
    "ship_zip": "",
    "ship_days": "",
    "address_count": "",
    "item_count": "1",
    "item_value": "100.00",
    "item_category": "Shoes",
    "paymode": YagoutPayConfig.paymode,
    "pg_id": YagoutPayConfig.pgId,
    "scheme_id": YagoutPayConfig.schemeId,
    "wallet_type": YagoutPayConfig.walletType,
    "card_number": "",
    "expiry_month": "",
    "expiry_year": "",
    "cvv": "",
    "card_name": "",
    "udf1": "",
    "udf2": "",
    "udf3": "",
    "udf4": "",
    "udf5": "",
    "udf6": "",
    "udf7": ""
  };

  final flatJsonString = jsonEncode(flatJsonData);
  print('Flat JSON data: $flatJsonString');
  print('Flat JSON length: ${flatJsonString.length} characters');
  
  try {
    final flatEncrypted = AesUtil.encryptToBase64(flatJsonString, key);
    print('Flat JSON encrypted: $flatEncrypted');
    print('Encrypted length: ${flatEncrypted.length} characters');
    
    // Test round-trip
    final flatDecrypted = AesUtil.decryptFromBase64(flatEncrypted, key);
    print('Flat JSON decrypted: $flatDecrypted');
    print('Round-trip success: ${flatJsonString == flatDecrypted}');
  } catch (e) {
    print('Flat JSON encryption failed: $e');
  }

  print('');
  
  // Test 3: Test with YagoutPay encryption test endpoint
  print('=== Test 3: YagoutPay Encryption Test Endpoint ===');
  try {
    final result = await YagoutPayService.testEncryption();
    print('Encryption test result: $result');
  } catch (e) {
    print('Encryption test failed: $e');
  }

  print('');
  print('=== Summary ===');
  print('If all tests pass, the encryption is working correctly.');
  print('If the flat JSON test fails, we need to adjust the structure.');
  print('If the YagoutPay test fails, there might be a key or endpoint issue.');
}
