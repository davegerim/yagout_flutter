import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/utils/crypto/aes_util.dart';
import 'lib/config/yagoutpay_config.dart';

void main() async {
  print('=== Testing Both YagoutPay Test Keys ===\n');

  // Test both keys from configuration
  const hostedKey = 'neTdYIKd87JEj4C6ZoYjaeBiCoeOr40ZKBEI8EU/8lo=';
  const apiKey = '6eUzH0ZdoVVBMTHrgdA0sqOFyKm54zojV4/faiSirkE=';

  const hostedMeId = '202504290002';
  const apiMeId = '202505090001';

  print('Hosted Key: $hostedKey');
  print('API Key: $apiKey\n');

  // Test 1: Test hosted key with encryption endpoint
  print('1. Testing Hosted Key with encryption endpoint...');
  await testKeyWithEndpoint(hostedKey, hostedMeId, 'HOSTED');

  print('\n2. Testing API Key with encryption endpoint...');
  await testKeyWithEndpoint(apiKey, apiMeId, 'API');

  print('\n3. Testing both keys with main API...');
  await testBothKeysWithMainApi();

  print('\n=== Test Complete ===');
}

Future<void> testKeyWithEndpoint(
    String key, String meId, String keyType) async {
  try {
    final testData = {'me_id': meId, 'amount': '100'};
    final plainText = jsonEncode(testData);
    final encrypted = AesUtil.encryptToBase64(plainText, key);

    print('$keyType Key Test:');
    print('  Plain text: $plainText');
    print('  Encrypted: ${encrypted.substring(0, 50)}...');

    // Test with encryption endpoint
    final resp = await http.post(
      Uri.parse(YagoutPayConfig.encryptionTestUrl),
      headers: {'Content-Type': 'text/plain'},
      body: encrypted,
    );

    print('  HTTP Status: ${resp.statusCode}');
    print('  Response: ${resp.body}');

    if (resp.statusCode == 200) {
      try {
        final result = json.decode(resp.body);
        final status = result['Status']?.toString().toLowerCase() ?? '';

        if (status == 'success') {
          print('  ✅ $keyType Key: SUCCESS with encryption endpoint!');
        } else if (status.contains('duplicate')) {
          print('  ✅ $keyType Key: SUCCESS (duplicate means working)');
        } else {
          print('  ⚠️  $keyType Key: Status: $status');
        }
      } catch (e) {
        print('  ❌ $keyType Key: Failed to parse response: $e');
      }
    } else {
      print('  ❌ $keyType Key: HTTP Error ${resp.statusCode}');
    }
  } catch (e) {
    print('  ❌ $keyType Key: Error: $e');
  }
}

Future<void> testBothKeysWithMainApi() async {
  final testOrderId = 'BOTH_KEYS_${DateTime.now().millisecondsSinceEpoch}';

  // Test payload
  final testPayload = {
    'txn_details': {
      'agId': 'yagout',
      'meId': '202505090001', // Use API merchant ID
      'orderNo': testOrderId,
      'amount': '1.00',
      'country': 'ETH',
      'currency': 'ETB',
      'transactionType': 'SALE',
      'sucessUrl': 'https://example.com/success',
      'failureUrl': 'https://example.com/failure',
      'channel': 'API'
    }
  };

  final plainText = jsonEncode(testPayload);

  print('Testing both keys with main API...');
  print('Test order ID: $testOrderId');

  // Test with hosted key
  print('\n--- Testing with HOSTED key ---');
  try {
    final hostedEncrypted = AesUtil.encryptToBase64(
        plainText, 'neTdYIKd87JEj4C6ZoYjaeBiCoeOr40ZKBEI8EU/8lo=');
    final hostedBody = jsonEncode({
      'merchantId': '202504290002',
      'merchantRequest': hostedEncrypted,
    });

    final hostedResp = await http.post(
      Uri.parse(YagoutPayConfig.apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: hostedBody,
    );

    print('Hosted Key - HTTP Status: ${hostedResp.statusCode}');
    print('Hosted Key - Response: ${hostedResp.body}');

    if (hostedResp.statusCode == 200) {
      final result = json.decode(hostedResp.body);
      final status = result['status']?.toString().toLowerCase() ?? '';
      if (status.contains('duplicate') || status.contains('success')) {
        print('✅ Hosted Key: SUCCESS with main API!');
      } else {
        print('⚠️  Hosted Key: Status: $status');
      }
    }
  } catch (e) {
    print('❌ Hosted Key Error: $e');
  }

  // Test with API key
  print('\n--- Testing with API key ---');
  try {
    final apiEncrypted = AesUtil.encryptToBase64(
        plainText, '6eUzH0ZdoVVBMTHrgdA0sqOFyKm54zojV4/faiSirkE=');
    final apiBody = jsonEncode({
      'merchantId': '202505090001',
      'merchantRequest': apiEncrypted,
    });

    final apiResp = await http.post(
      Uri.parse(YagoutPayConfig.apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: apiBody,
    );

    print('API Key - HTTP Status: ${apiResp.statusCode}');
    print('API Key - Response: ${apiResp.body}');

    if (apiResp.statusCode == 200) {
      final result = json.decode(apiResp.body);
      final status = result['status']?.toString().toLowerCase() ?? '';
      if (status.contains('duplicate') || status.contains('success')) {
        print('✅ API Key: SUCCESS with main API!');
      } else {
        print('⚠️  API Key: Status: $status');
      }
    }
  } catch (e) {
    print('❌ API Key Error: $e');
  }
}
