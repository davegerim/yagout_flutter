import 'lib/services/yagoutpay_service.dart';

void main() async {
  print('=== YagoutPay Manual Order Number Testing ===');
  print('Testing with different OR-DOIT-XXXX order numbers as requested');
  print('');

  try {
    final results = await YagoutPayService.testManualOrderNumbers(
      amount: '1.00',
      successUrl: 'https://example.com/success',
      failureUrl: 'https://example.com/failure',
      email: 'test@example.com',
      mobile: '985392862',
      customerName: 'Test User',
    );

    print('\n=== Final Results ===');
    for (final entry in results.entries) {
      final orderNo = entry.key;
      final result = entry.value;

      if (result.containsKey('error')) {
        print('$orderNo: ❌ ERROR - ${result['error']}');
      } else {
        final status = result['status'] ?? 'Unknown';
        final message = result['statusMessage'] ?? 'No message';
        print('$orderNo: $status - $message');
      }
    }

    print('\n=== Analysis ===');
    final duplicateCount = results.values
        .where((r) =>
            r['status']?.toString().toLowerCase().contains('dublicate') == true)
        .length;

    final successCount = results.values
        .where((r) =>
            r['status']?.toString().toLowerCase().contains('success') == true)
        .length;

    print('Total tests: ${results.length}');
    print('Duplicate responses: $duplicateCount');
    print('Success responses: $successCount');

    if (successCount > 0) {
      print('🎉 SUCCESS! Found working order number(s)!');
    } else if (duplicateCount < results.length) {
      print('✅ PROGRESS! Some order numbers gave different responses!');
    } else {
      print('⚠️  All order numbers still giving duplicate responses');
    }
  } catch (e) {
    print('❌ Test failed: $e');
  }
}



