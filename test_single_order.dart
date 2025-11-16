import 'lib/services/yagoutpay_service.dart';

void main() async {
  print('=== Testing Single Order Number ===');
  print('As requested by YagoutPay: "manual give it different number"');
  print('');

  // Test with the specific order number YagoutPay mentioned
  const orderNumber = 'OR-DOIT-1234';

  print('Testing with: $orderNumber');
  print('');

  try {
    final result = await YagoutPayService.testSingleOrderNumber(
      orderNo: orderNumber,
      amount: '1.00',
      successUrl: 'https://example.com/success',
      failureUrl: 'https://example.com/failure',
      email: 'test@example.com',
      mobile: '985392862',
      customerName: 'Test User',
    );

    print('\n=== Final Result ===');
    if (result.containsKey('error')) {
      print('❌ Error: ${result['error']}');
    } else {
      print('Status: ${result['status']}');
      print('Message: ${result['statusMessage']}');

      if (result['status']?.toString().toLowerCase().contains('success') ==
          true) {
        print('🎉 SUCCESS! The OR-DOIT-1234 format worked!');
      } else if (result['status']
              ?.toString()
              .toLowerCase()
              .contains('dublicate') ==
          true) {
        print('⚠️  Still getting duplicate response');
        print(
            'This suggests the format might be correct but the number is already used');
      } else {
        print('✅ Got a different response - this is progress!');
      }
    }
  } catch (e) {
    print('❌ Test failed: $e');
  }
}



