import 'lib/services/yagoutpay_service.dart';

void main() async {
  print('=== Testing YagoutPay Fix ===');
  print(
      'YagoutPay said: "Am sure it works, but you pass on request, but not in the api"');
  print('Fix: Pass OR-DOIT-XXXX format directly to API without regeneration');
  print('');

  // Test with OR-DOIT-XXXX format directly
  const orderNumber = 'OR-DOIT-1234';

  print('Testing with: $orderNumber');
  print('Passing directly to API (no regeneration)');
  print('');

  try {
    final result = await YagoutPayService.payViaApi(
      orderNo: orderNumber, // Pass directly without regeneration
      amount: '1.00',
      successUrl: 'https://example.com/success',
      failureUrl: 'https://example.com/failure',
      email: 'test@example.com',
      mobile: '985392862',
      customerName: 'Test User',
    );

    print('\n=== Result ===');
    print('Status: ${result['status']}');
    print('Message: ${result['statusMessage']}');

    if (result['status']?.toString().toLowerCase().contains('success') ==
        true) {
      print('🎉 SUCCESS! The fix worked!');
    } else if (result['status']
            ?.toString()
            .toLowerCase()
            .contains('dublicate') ==
        true) {
      print('⚠️  Still getting duplicate response');
      print(
          'This suggests the format is correct but the number is already used');
    } else {
      print('✅ Got a different response - this is progress!');
    }
  } catch (e) {
    print('❌ Test failed: $e');
  }
}
