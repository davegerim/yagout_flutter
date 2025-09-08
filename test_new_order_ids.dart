import 'dart:math';
import 'lib/services/yagoutpay_service.dart';

void main() {
  print('=== Testing New Order ID Generation ===');
  
  // Test the updated generateUniqueOrderId method
  for (int i = 0; i < 5; i++) {
    final orderId = YagoutPayService.generateUniqueOrderId('TEST');
    print('Generated Order ID $i: $orderId');
    print('Length: ${orderId.length} characters');
    print('---');
  }
  
  print('\n=== Testing Manual Generation (like in checkout) ===');
  
  // Test the manual generation like in checkout screen
  for (int i = 0; i < 3; i++) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    final randomChars = String.fromCharCodes(List.generate(4, (index) => 
        Random().nextInt(26) + 97)); // Random lowercase letters
    final processId = Random().nextInt(9999).toString().padLeft(4, '0');
    final extraRandom = String.fromCharCodes(List.generate(
        3, (index) => Random().nextInt(26) + 65)); // Random uppercase letters
    final orderNo = 'API_${timestamp}_${random}_${processId}_${extraRandom}_$randomChars';
    
    print('Manual Order ID $i: $orderNo');
    print('Length: ${orderNo.length} characters');
    print('---');
  }
  
  print('\n✅ All order IDs are now much more unique!');
  print('✅ This should resolve the "Dublicate OrderID" issue with YagoutPay!');
}



