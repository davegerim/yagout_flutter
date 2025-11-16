import 'lib/services/yagoutpay_service.dart';

void main() async {
  print('=== YagoutPay Integration Test ===');
  print('Testing the complete integration...');

  try {
    // Test the complete integration
    final result = await YagoutPayService.testCompleteIntegration();

    print('\n=== FINAL RESULT ===');
    print('Status: ${result['status']}');
    print('Message: ${result['message']}');

    if (result['status'] == 'COMPLETE_SUCCESS' ||
        result['status'] == 'SUCCESS') {
      print('\n🎉🎉🎉 INTEGRATION SUCCESSFUL! 🎉🎉🎉');
      print('✅ YagoutPay is working perfectly!');
      print('✅ You can now process real payments!');
    } else {
      print('\n❌ Integration test failed');
      print('Response: ${result['response']}');
    }
  } catch (e) {
    print('\n❌ Test error: $e');
  }
}




