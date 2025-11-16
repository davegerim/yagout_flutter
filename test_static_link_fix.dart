import 'lib/services/yagoutpay_service.dart';

/// Test the fixed static link creation
void main() async {
  print('🧪 Testing Fixed Static Link Creation\n');

  try {
    print('=== Testing Static Link Creation ===');

    final result = await YagoutPayService.createStaticLink(
      reqUserId: 'yagou381',
      amount: '500',
      customerEmail: 'test@example.com',
      mobileNo: '0985392862',
      expiryDate: '2025-10-15', // Future date within 30 days
      orderId: YagoutPayService.generateUniqueOrderId('STATIC_LINK'),
      firstName: 'Test',
      lastName: 'User',
      product: 'Test Product',
      dialCode: '+251',
      failureUrl: 'http://localhost:3000/failure',
      successUrl: 'http://localhost:3000/success',
      country: 'ETH',
      currency: 'ETB',
      mediaType: ['API'],
    );

    print('\n=== Result ===');
    print('Status: ${result['status']}');
    print('Message: ${result['message']}');
    print('Order ID: ${result['order_id']}');

    if (result['payment_link'] != null) {
      print('✅ Payment Link: ${result['payment_link']}');
    } else {
      print('❌ No payment link found');
    }

    if (result['response'] != null) {
      print('Raw Response: ${result['response']}');
    }

    if (result['decrypted_response'] != null) {
      print('Decrypted Response: ${result['decrypted_response']}');
    }

    if (result['status'] == 'SUCCESS') {
      print('\n🎉 SUCCESS! Static link creation is working!');
    } else {
      print('\n❌ FAILED: ${result['message']}');
    }
  } catch (e) {
    print('❌ Error during testing: $e');
  }

  print('\n=== Test Complete ===');
}
