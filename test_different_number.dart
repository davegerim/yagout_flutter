import 'lib/services/yagoutpay_service.dart';

void main() async {
  print('=== Testing with Different Order Number ===');
  print(
      'YagoutPay said: "Am sure it works, but you pass on request, but not in the api"');
  print('Testing with a completely different OR-DOIT-XXXX number');
  print('');

  // Test with a different order number
  final orderNumber = 'OR-DOIT-9999';

  print('Testing with: $orderNumber');
  print('This should be a fresh number that hasn\'t been used');
  print('');

  try {
    final result = await YagoutPayService.payViaApi(
      orderNo: orderNumber, // Pass directly without regeneration
      amount: '1.00',
      successUrl: 'https://example.com/success',
      failureUrl: 'https://example.com/failure',
      email: 'test@example.com',
      mobile: '965680964',
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



