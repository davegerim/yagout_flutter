import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_theme.dart';

class YagoutPayFailureScreen extends StatelessWidget {
  final String? orderId;
  final String? errorCode;
  final String? errorMessage;
  final String? amount;
  final String? currency;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? paymentMethod;
  final String? timestamp;
  final Map<String, dynamic>? additionalData;
  final VoidCallback? onRetry;

  const YagoutPayFailureScreen({
    super.key,
    this.orderId,
    this.errorCode,
    this.errorMessage,
    this.amount,
    this.currency,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.paymentMethod,
    this.timestamp,
    this.additionalData,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('Payment Failed'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Failure Animation/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.error,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Failure Message
              const Text(
                'Payment Failed',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage ?? 'Your payment could not be processed.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Error Details Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Error Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (errorCode != null)
                        _buildDetailRow('Error Code', errorCode!),
                      if (errorMessage != null)
                        _buildDetailRow('Error Message', errorMessage!),
                      _buildDetailRow('Order ID', orderId ?? 'N/A'),
                      _buildDetailRow(
                          'Amount',
                          amount != null && currency != null
                              ? '$amount $currency'
                              : 'N/A'),
                      _buildDetailRow(
                          'Payment Method', paymentMethod ?? 'YagoutPay'),
                      _buildDetailRow('Customer Name', customerName ?? 'N/A'),
                      _buildDetailRow('Email', customerEmail ?? 'N/A'),
                      _buildDetailRow('Phone', customerPhone ?? 'N/A'),
                      _buildDetailRow(
                          'Date & Time',
                          timestamp != null
                              ? _formatTimestamp(timestamp!)
                              : DateTime.now().toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Additional Information
              if (additionalData != null && additionalData!.isNotEmpty) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ...additionalData!.entries.map((entry) =>
                            _buildDetailRow(entry.key, entry.value.toString())),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],

              // Common Error Solutions
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What can you do?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Row(
                        children: [
                          Icon(Icons.refresh, color: Colors.blue, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Try the payment again with the same details',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.credit_card,
                              color: Colors.green, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Use a different payment method',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.account_balance,
                              color: Colors.orange, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Check your account balance or card limit',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.support_agent,
                              color: Colors.purple, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Contact support if the issue persists',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Action Buttons
              Column(
                children: [
                  if (onRetry != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (onRetry != null) const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate back to checkout
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back,
                          color: AppTheme.primaryColor),
                      label: const Text(
                        'Back to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppTheme.primaryColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to home
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home, color: Colors.grey),
                      label: const Text(
                        'Continue Shopping',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (orderId != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Copy order ID to clipboard
                          Clipboard.setData(ClipboardData(text: orderId!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order ID copied to clipboard'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        label: const Text(
                          'Copy Order ID',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Support Information
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.support_agent, color: Colors.blue, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'If you continue to experience payment issues, please contact our support team for assistance.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Open email client
                            // You can implement email functionality here
                          },
                          icon: const Icon(Icons.email, size: 16),
                          label: const Text('Email Support'),
                        ),
                        const SizedBox(width: 20),
                        TextButton.icon(
                          onPressed: () {
                            // Open phone dialer
                            // You can implement phone functionality here
                          },
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Call Support'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Error Code Specific Help
              if (errorCode != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Error Code Help',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getErrorCodeHelp(errorCode!),
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String _getErrorCodeHelp(String errorCode) {
    switch (errorCode.toLowerCase()) {
      case 'insufficient_funds':
        return 'Your account does not have sufficient balance. Please check your account balance or use a different payment method.';
      case 'invalid_card':
        return 'The card information provided is invalid. Please check your card details and try again.';
      case 'expired_card':
        return 'Your card has expired. Please use a different card or update your card information.';
      case 'declined':
        return 'Your payment was declined by your bank. Please contact your bank or use a different payment method.';
      case 'network_error':
        return 'There was a network connectivity issue. Please check your internet connection and try again.';
      case 'timeout':
        return 'The payment request timed out. Please try again.';
      case 'duplicate_transaction':
        return 'A transaction with the same details already exists. Please use a different order ID or wait before retrying.';
      case 'invalid_amount':
        return 'The payment amount is invalid. Please check the amount and try again.';
      case 'merchant_error':
        return 'There was an issue with the merchant configuration. Please contact support.';
      case 'gateway_error':
        return 'There was an issue with the payment gateway. Please try again later or contact support.';
      default:
        return 'Please try the payment again. If the issue persists, contact our support team with this error code.';
    }
  }
}




















