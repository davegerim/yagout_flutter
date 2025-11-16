import 'package:flutter/material.dart';
import 'lib/screens/payment/yagoutpay_success_screen.dart';
import 'lib/screens/payment/yagoutpay_failure_screen.dart';

void main() {
  runApp(const PaymentPagesTestApp());
}

class PaymentPagesTestApp extends StatelessWidget {
  const PaymentPagesTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YagoutPay Payment Pages Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PaymentPagesTestHome(),
    );
  }
}

class PaymentPagesTestHome extends StatelessWidget {
  const PaymentPagesTestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YagoutPay Payment Pages Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test YagoutPay Success and Failure Pages',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const YagoutPaySuccessScreen(
                        orderId: 'OR-DOIT-1234',
                        transactionId: 'TXN-567890',
                        amount: '150.00',
                        currency: 'ETB',
                        customerName: 'John Doe',
                        customerEmail: 'john.doe@example.com',
                        customerPhone: '+251911234567',
                        paymentMethod: 'YagoutPay',
                        timestamp: '2024-01-15T10:30:00Z',
                        additionalData: {
                          'gateway_response': 'SUCCESS',
                          'payment_mode': 'telebirr',
                          'reference_id': 'REF-123456',
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'Test Success Page',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const YagoutPayFailureScreen(
                        orderId: 'OR-DOIT-1234',
                        errorCode: 'INSUFFICIENT_FUNDS',
                        errorMessage:
                            'Your account does not have sufficient balance.',
                        amount: '150.00',
                        currency: 'ETB',
                        customerName: 'John Doe',
                        customerEmail: 'john.doe@example.com',
                        customerPhone: '+251911234567',
                        paymentMethod: 'YagoutPay',
                        timestamp: '2024-01-15T10:30:00Z',
                        additionalData: {
                          'gateway_response': 'FAILED',
                          'error_details': 'Account balance insufficient',
                          'retry_count': '1',
                        },
                        onRetry: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Retry functionality triggered'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.error, color: Colors.white),
                label: const Text(
                  'Test Failure Page',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'This test app allows you to preview the YagoutPay success and failure pages with sample data.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}




















