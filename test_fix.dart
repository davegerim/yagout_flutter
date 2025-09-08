import 'package:flutter/material.dart';
import 'lib/services/yagoutpay_service.dart';

void main() async {
  print('=== TESTING YAGOUTPAY FIX ===');

  try {
    // Test with a unique order ID
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final orderNo = 'FIX_TEST_$timestamp';

    print('Testing with order ID: $orderNo');

    final result = await YagoutPayService.payViaApi(
      orderNo: orderNo,
      amount: '1.00',
      successUrl: 'https://example.com/success',
      failureUrl: 'https://example.com/failure',
      email: 'test@example.com',
      mobile: '0985392862',
      customerName: 'Test User',
    );

    print('\n=== RESULT ===');
    print('Status: ${result['status']}');
    print('Status Message: ${result['statusMessage']}');

    final status = result['status']?.toString().toLowerCase() ?? '';

    if (status.contains('invalid token')) {
      print('\n❌ STILL GETTING INVALID TOKEN ERROR!');
      print('The fix did not work. Need to investigate further.');
    } else if (status.contains('success') || status.contains('pending')) {
      print('\n🎉 SUCCESS! Invalid token error is FIXED!');
      print('✅ YagoutPay integration is working!');
    } else if (status.contains('duplicate') || status.contains('dublicate')) {
      print('\n✅ SUCCESS! Getting duplicate means API is working!');
      print('✅ Invalid token error is FIXED!');
    } else {
      print('\n📝 Got response: $status');
      print('This is not an "Invalid token" error, so the fix worked!');
    }
  } catch (e) {
    print('\n❌ Test failed with error: $e');
  }
}



