import 'dart:convert';
import 'dart:typed_data';

void main() {
  // YagoutPay test credentials
  const meId = '202505090001';
  const key = '6eUzH0ZdoVVBMTHrgdA0sqOFyKm54zojV4/faiSirkE=';

  // Test data
  final testData = jsonEncode({'me_id': meId, 'amount': '100'});

  print('Test data: $testData');
  print('Key: $key');
  print('Key decoded length: ${base64.decode(key).length} bytes');

  // Check IV conversion
  const ivString = '0123456789abcdef';
  final ivBytes = Uint8List.fromList(ivString.codeUnits.take(16).toList());
  print('IV string: $ivString');
  print('IV bytes: ${ivBytes.toList()}');
  print('IV length: ${ivBytes.length}');

  // Check what we're encrypting
  final inputBytes = Uint8List.fromList(utf8.encode(testData));
  print('Input bytes: ${inputBytes.length}');
  print('Input needs padding: ${16 - (inputBytes.length % 16)} bytes');
}
