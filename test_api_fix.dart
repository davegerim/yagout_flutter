import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/services/yagoutpay_service.dart';
import 'lib/config/yagoutpay_config.dart';

void main() async {
  print('=== Testing YagoutPay API Fix ===\n');

  try {
    // Test the fixed API call
    print('Testing API integration with fixed Content-Type...');

    final result = await YagoutPayService.payViaApi(
      orderNo: 'TEST_FIX_${DateTime.now().millisecondsSinceEpoch}',
      amount: '1.00',
      successUrl: 'https://example.com/success',
      failureUrl: 'https://example.com/failure',
      email: 'test@example.com',
      mobile: '1234567890',
      customerName: 'Test User',
    );

    print('\n✅ API call successful!');
    print('Status: ${result['status']}');
    print('Message: ${result['statusMessage']}');

    if (result['status']?.toString().toLowerCase().contains('duplicate') ==
        true) {
      print('\n🎉 SUCCESS! Getting "duplicate" means the API is working!');
      print('The encryption and Content-Type issues are RESOLVED!');
    } else if (result['status']?.toString().toLowerCase().contains('success') ==
        true) {
      print('\n🎉 SUCCESS! Payment processed successfully!');
    } else {
      print('\n📝 Response: ${result['status']} - ${result['statusMessage']}');
    }
  } catch (e) {
    print('\n❌ API call failed: $e');

    if (e.toString().contains('415')) {
      print('\n🔍 The 415 error is still happening.');
      print('This means the Content-Type fix didn\'t work as expected.');
    } else if (e.toString().contains('Invalid Encryption')) {
      print('\n🔍 Still getting "Invalid Encryption" error.');
      print('This means the encryption fix didn\'t work as expected.');
    } else {
      print('\n🔍 Different error occurred. Check the logs above.');
    }
  }

  print('\n=== Test Complete ===');
}

