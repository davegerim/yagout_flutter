import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/utils/crypto/aes_util.dart';
import 'lib/config/yagoutpay_config.dart';

void main() async {
  print('=== Testing Different Authentication Methods ===\n');

  const testKey = '6eUzH0ZdoVVBMTHrgdA0sqOFyKm54zojV4/faiSirkE=';
  const testMeId = '202505090001';

  print('Test Key: $testKey');
  print('Test Merchant ID: $testMeId\n');

  // Test payload
  final testPayload = {
    'txn_details': {
      'agId': 'yagout',
      'meId': testMeId,
      'orderNo': 'AUTH_TEST_${DateTime.now().millisecondsSinceEpoch}',
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
  final encrypted = AesUtil.encryptToBase64(plainText, testKey);

  print('Test payload encrypted successfully');
  print('Encrypted length: ${encrypted.length}');

  // Test different authentication methods
  final authTests = [
    {
      'name': 'Standard JSON with merchantId/merchantRequest',
      'headers': {'Content-Type': 'application/json'},
      'body': jsonEncode({
        'merchantId': testMeId,
        'merchantRequest': encrypted,
      }),
    },
    {
      'name': 'With Authorization header (Bearer)',
      'headers': {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $testKey',
      },
      'body': jsonEncode({
        'merchantId': testMeId,
        'merchantRequest': encrypted,
      }),
    },
    {
      'name': 'With me_id header',
      'headers': {
        'Content-Type': 'application/json',
        'me_id': testMeId,
      },
      'body': jsonEncode({
        'merchantId': testMeId,
        'merchantRequest': encrypted,
      }),
    },
    {
      'name': 'With X-API-Key header',
      'headers': {
        'Content-Type': 'application/json',
        'X-API-Key': testKey,
      },
      'body': jsonEncode({
        'merchantId': testMeId,
        'merchantRequest': encrypted,
      }),
    },
    {
      'name': 'With API-Key header',
      'headers': {
        'Content-Type': 'application/json',
        'API-Key': testKey,
      },
      'body': jsonEncode({
        'merchantId': testMeId,
        'merchantRequest': encrypted,
      }),
    },
    {
      'name': 'With User-Agent and custom headers',
      'headers': {
        'Content-Type': 'application/json',
        'User-Agent': 'YagoutPay-Flutter-SDK/1.0',
        'X-Merchant-ID': testMeId,
        'X-Encryption-Key': testKey,
      },
      'body': jsonEncode({
        'merchantId': testMeId,
        'merchantRequest': encrypted,
      }),
    },
    {
      'name': 'Form data instead of JSON',
      'headers': {'Content-Type': 'application/x-www-form-urlencoded'},
      'body':
          'merchantId=$testMeId&merchantRequest=${Uri.encodeComponent(encrypted)}',
    },
    {
      'name': 'Plain text with headers',
      'headers': {
        'Content-Type': 'text/plain',
        'X-Merchant-ID': testMeId,
        'X-Encryption-Key': testKey,
      },
      'body': encrypted,
    },
  ];

  for (final test in authTests) {
    print('\n--- Testing: ${test['name']} ---');

    try {
      final resp = await http.post(
        Uri.parse(YagoutPayConfig.apiUrl),
        headers: test['headers'] as Map<String, String>,
        body: test['body'] as String,
      );

      print('HTTP Status: ${resp.statusCode}');
      print('Response: ${resp.body}');

      if (resp.statusCode == 200) {
        try {
          final result = json.decode(resp.body);
          final status = result['status']?.toString().toLowerCase() ?? '';
          final message = result['statusMessage']?.toString() ?? '';

          if (status.contains('success') ||
              status.contains('pending') ||
              status.contains('duplicate') ||
              status.contains('dublicate')) {
            print('✅ SUCCESS with ${test['name']}!');
            print('This authentication method works!');
            return;
          } else if (status.contains('invalid token')) {
            print('⚠️  Still getting "Invalid token"');
          } else if (status.contains('merchant not authorized')) {
            print('⚠️  Merchant not authorized');
          } else {
            print('⚠️  Status: $status - $message');
          }
        } catch (e) {
          print('⚠️  Could not parse response: $e');
        }
      } else {
        print('❌ HTTP Error: ${resp.statusCode}');
      }
    } catch (e) {
      print('❌ Request failed: $e');
    }
  }

  print('\n=== All authentication methods tested ===');
  print('If all methods failed, the issue is likely:');
  print('1. Outdated test credentials');
  print('2. UAT environment not properly configured');
  print('3. Missing account activation or permissions');
  print('\nRecommendation: Contact YagoutPay support for fresh credentials');
}

