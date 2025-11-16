import 'lib/services/yagoutpay_service.dart';

void main() async {
  print('=== Testing Fixed Payment Link Implementation ===\n');

  try {
    // Test Payment Link API with fixed URLs and endpoints
    print('1. Testing Payment Link API with fixes...');
    final paymentLinkResult = await YagoutPayService.createPaymentLink(
      reqUserId: 'yagou381',
      amount: '500',
      customerEmail: 'test@example.com',
      mobileNo: '0985392862',
      expiryDate: '2025-12-31',
      orderId: YagoutPayService.generateUniqueOrderId('FIXED_TEST'),
      firstName: 'Test',
      lastName: 'User',
      product: 'Test Product',
      dialCode: '+251',
      failureUrl: 'https://httpbin.org/status/200', // Fixed: Public URL
      successUrl: 'https://httpbin.org/status/200', // Fixed: Public URL
      country: 'ETH',
      currency: 'ETB',
      mediaType: ['API'],
    );

    print('\n=== Payment Link Result ===');
    print('Status: ${paymentLinkResult['status']}');
    print('Message: ${paymentLinkResult['message']}');
    print('Order ID: ${paymentLinkResult['order_id']}');

    if (paymentLinkResult['response'] != null) {
      print('Response: ${paymentLinkResult['response']}');
    }

    if (paymentLinkResult['decrypted_response'] != null) {
      print('Decrypted Response: ${paymentLinkResult['decrypted_response']}');
    }

    // Test Static Link API with fixed URLs and endpoints
    print('\n2. Testing Static Link API with fixes...');
    final staticLinkResult = await YagoutPayService.createStaticLink(
      reqUserId: 'yagou381',
      amount: '500',
      customerEmail: 'test@example.com',
      mobileNo: '0985392862',
      expiryDate: '2025-12-31',
      orderId: YagoutPayService.generateUniqueOrderId('STATIC_FIXED'),
      firstName: 'Test',
      lastName: 'User',
      product: 'Test Product',
      dialCode: '+251',
      failureUrl: 'https://httpbin.org/status/200', // Fixed: Public URL
      successUrl: 'https://httpbin.org/status/200', // Fixed: Public URL
      country: 'ETH',
      currency: 'ETB',
      mediaType: ['API'],
    );

    print('\n=== Static Link Result ===');
    print('Status: ${staticLinkResult['status']}');
    print('Message: ${staticLinkResult['message']}');
    print('Order ID: ${staticLinkResult['order_id']}');

    if (staticLinkResult['response'] != null) {
      print('Response: ${staticLinkResult['response']}');
    }

    if (staticLinkResult['decrypted_response'] != null) {
      print('Decrypted Response: ${staticLinkResult['decrypted_response']}');
    }

    print('\n=== Analysis ===');
    if (paymentLinkResult['status'] == 'SUCCESS' ||
        staticLinkResult['status'] == 'SUCCESS') {
      print('🎉 SUCCESS! Payment links are now working!');
      print('✅ The fixes resolved the issues');
    } else if (paymentLinkResult['status'] == 'ERROR' &&
        paymentLinkResult['message'].contains('404')) {
      print('❌ Still getting 404 - endpoints may not exist');
      print('💡 Contact YagoutPay support for correct endpoints');
    } else if (paymentLinkResult['status'] == 'ERROR' &&
        paymentLinkResult['message'].contains('HTTP')) {
      print(
          '📡 Getting HTTP response - API is reachable but may have other issues');
      print('💡 Check the specific error message for details');
    } else {
      print('📝 Got response: ${paymentLinkResult['status']}');
      print(
          '💡 This indicates the API is working but may have validation issues');
    }
  } catch (e) {
    print('\n❌ Test error: $e');
  }

  print('\n=== Test Complete ===');
}























