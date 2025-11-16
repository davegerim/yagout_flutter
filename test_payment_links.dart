import 'lib/services/yagoutpay_service.dart';

void main() async {
  print('=== YagoutPay Payment Link & Static Link API Test ===\n');

  // Test Payment Link API
  print('1. Testing Payment Link API...');
  final paymentLinkResult = await YagoutPayService.createPaymentLink(
    reqUserId: 'yagou381',
    amount: '500',
    customerEmail: 'test@example.com',
    mobileNo: '0985392862',
    expiryDate: '2025-12-31',
    orderId: YagoutPayService.generateUniqueOrderId('ORDER_STATIC_001'),
    firstName: 'YagoutPay',
    lastName: 'StaticLink',
    product: 'Premium Subscription',
    dialCode: '+251',
    failureUrl: 'https://httpbin.org/status/200',
    successUrl: 'https://httpbin.org/status/200',
    country: 'ETH',
    currency: 'ETB',
    mediaType: ['API'],
  );

  print('Payment Link Result:');
  print('Status: ${paymentLinkResult['status']}');
  print('Message: ${paymentLinkResult['message']}');
  print('Order ID: ${paymentLinkResult['order_id']}');
  if (paymentLinkResult['response'] != null) {
    print('Response: ${paymentLinkResult['response']}');
  }
  if (paymentLinkResult['decrypted_response'] != null) {
    print('Decrypted Response: ${paymentLinkResult['decrypted_response']}');
  }
  print('');

  // Test Static Link API
  print('2. Testing Static Link API...');
  final staticLinkResult = await YagoutPayService.createStaticLink(
    reqUserId: 'yagou381',
    amount: '500',
    customerEmail: 'test@example.com',
    mobileNo: '0985392862',
    expiryDate: '2025-12-31',
    orderId: YagoutPayService.generateUniqueOrderId('ORDER_STATIC_002'),
    firstName: 'YagoutPay',
    lastName: 'StaticLink',
    product: 'Premium Subscription',
    dialCode: '+251',
    failureUrl: 'https://httpbin.org/status/200',
    successUrl: 'https://httpbin.org/status/200',
    country: 'ETH',
    currency: 'ETB',
    mediaType: ['API'],
  );

  print('Static Link Result:');
  print('Status: ${staticLinkResult['status']}');
  print('Message: ${staticLinkResult['message']}');
  print('Order ID: ${staticLinkResult['order_id']}');
  if (staticLinkResult['response'] != null) {
    print('Response: ${staticLinkResult['response']}');
  }
  if (staticLinkResult['decrypted_response'] != null) {
    print('Decrypted Response: ${staticLinkResult['decrypted_response']}');
  }
  print('');

  print('=== Test Complete ===');
}
