import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/utils/crypto/aes_util.dart';

void main() async {
  print('=== Testing Multiple YagoutPay Endpoints ===\n');

  // Test payload
  final payload = {
    "req_user_id": "yagou381",
    "me_id": "202508080001",
    "amount": "500",
    "customer_email": "test@example.com",
    "mobile_no": "0985392862",
    "expiry_date": "2025-12-31",
    "media_type": ["API"],
    "order_id": "ORDER_STATIC_001",
    "first_name": "YagoutPay",
    "last_name": "StaticLink",
    "product": "Premium Subscription",
    "dial_code": "+251",
    "failure_url": "http://localhost:3000/failure",
    "success_url": "http://localhost:3000/success",
    "country": "ETH",
    "currency": "ETB"
  };

  final jsonString = jsonEncode(payload);
  final encrypted = AesUtil.encryptToBase64(
      jsonString, 'IG3CNW5uNrUO2mU2htUOWb9rgXCF7XMAXmL63d7wNZo=');

  final requestBody = jsonEncode({"request": encrypted});

  // List of possible endpoints to test
  final endpoints = [
    // Original endpoints from documentation
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/paymentByLinkResponse',
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/staticQRPaymentResponse',

    // Alternative variations
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/paymentByLink',
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/staticQRPayment',
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/paymentLink',
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/staticLink',

    // API variations
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/api/paymentByLinkResponse',
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/api/staticQRPaymentResponse',
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/api/paymentByLink',
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/api/staticQRPayment',

    // Different path structures
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/paymentByLinkResponse',
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/staticQRPaymentResponse',
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/paymentByLink',
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/staticQRPayment',

    // Check if the base URL is accessible
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/',
    'https://uatcheckout.yagoutpay.com/',
  ];

  print('Testing ${endpoints.length} different endpoints...\n');

  for (int i = 0; i < endpoints.length; i++) {
    final endpoint = endpoints[i];
    print('${i + 1}. Testing: $endpoint');

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'me_id': '202508080001',
        },
        body: requestBody,
      );

      print('   Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('   ✅ SUCCESS! This endpoint works!');
        print('   Response: ${response.body}');
      } else if (response.statusCode == 404) {
        print('   ❌ 404 - Not Found');
      } else if (response.statusCode == 400) {
        print('   ⚠️  400 - Bad Request (endpoint exists but payload issue)');
        print('   Response: ${response.body}');
      } else if (response.statusCode == 401) {
        print('   🔐 401 - Unauthorized (endpoint exists but auth issue)');
      } else if (response.statusCode == 500) {
        print('   💥 500 - Server Error (endpoint exists but server issue)');
        print('   Response: ${response.body}');
      } else {
        print('   📝 ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('   ❌ Error: $e');
    }

    print('');
  }

  print('=== Endpoint Testing Complete ===');
  print('\n📋 Summary:');
  print('- If you see 404: Endpoint doesn\'t exist');
  print('- If you see 400: Endpoint exists but payload format issue');
  print('- If you see 401: Endpoint exists but authentication issue');
  print('- If you see 500: Endpoint exists but server error');
  print('- If you see 200: Endpoint works! 🎉');
}




























