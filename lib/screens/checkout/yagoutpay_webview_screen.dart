import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../payment/yagoutpay_success_screen.dart';
import '../payment/yagoutpay_failure_screen.dart';

class YagoutPayWebViewScreen extends StatefulWidget {
  final String htmlContent;
  final String successUrl;
  final String failureUrl;
  final String? orderId;
  final String? amount;
  final String? currency;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? paymentMethod;

  const YagoutPayWebViewScreen({
    super.key,
    required this.htmlContent,
    required this.successUrl,
    required this.failureUrl,
    this.orderId,
    this.amount,
    this.currency,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.paymentMethod,
  });

  @override
  State<YagoutPayWebViewScreen> createState() => _YagoutPayWebViewScreenState();
}

class _YagoutPayWebViewScreenState extends State<YagoutPayWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    // On non-web platforms, explicitly enable JS. On web, skip to avoid
    // UnimplementedError from some plugin versions (JS is enabled by default).
    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    _controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('=== WebView Navigation Debug ===');
            print('Current URL: $url');
            print('Success URL: ${widget.successUrl}');
            print('Failure URL: ${widget.failureUrl}');
            print('===============================');

            // Check for YagoutPay success patterns
            if (_isSuccessUrl(url)) {
              print('✅ Detected SUCCESS URL pattern');
              _navigateToSuccessPage(url);
            }
            // Check for YagoutPay failure patterns
            else if (_isFailureUrl(url)) {
              print('❌ Detected FAILURE URL pattern');
              _navigateToFailurePage(url);
            }
            // Check for custom success/failure URLs
            else if (url.startsWith(widget.successUrl)) {
              print('✅ Detected custom SUCCESS URL');
              _navigateToSuccessPage(url);
            } else if (url.startsWith(widget.failureUrl)) {
              print('❌ Detected custom FAILURE URL');
              _navigateToFailurePage(url);
            }
          },
          onPageFinished: (url) {
            setState(() => _loading = false);
            print('=== Page Finished ===');
            print('Final URL: $url');
            print('====================');

            // If we haven't detected success/failure yet, check for payment completion
            // This handles cases where YagoutPay redirects to a different domain
            _checkForPaymentCompletion(url);
          },
        ),
      )
      ..loadRequest(Uri.dataFromString(
        widget.htmlContent,
        mimeType: 'text/html',
        encoding: utf8,
      ));
  }

  bool _isSuccessUrl(String url) {
    // Check for YagoutPay success patterns
    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    final queryParams = uri.queryParameters;

    // YagoutPay success indicators
    if (host.contains('yagoutpay.com') || host.contains('yagout')) {
      // Check for success status in query parameters
      final status = queryParams['status']?.toLowerCase() ?? '';
      final paymentStatus = queryParams['payment_status']?.toLowerCase() ?? '';
      final txnStatus = queryParams['txn_status']?.toLowerCase() ?? '';

      if (status.contains('success') ||
          paymentStatus.contains('success') ||
          txnStatus.contains('success') ||
          status.contains('completed') ||
          paymentStatus.contains('completed') ||
          txnStatus.contains('completed')) {
        return true;
      }

      // Check for success in path
      if (path.contains('success') || path.contains('completed')) {
        return true;
      }
    }

    // Check for common success patterns
    if (queryParams['result']?.toLowerCase() == 'success' ||
        queryParams['response']?.toLowerCase() == 'success' ||
        queryParams['code']?.toLowerCase() == 'success') {
      return true;
    }

    return false;
  }

  bool _isFailureUrl(String url) {
    // Check for YagoutPay failure patterns
    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    final queryParams = uri.queryParameters;

    // YagoutPay failure indicators
    if (host.contains('yagoutpay.com') || host.contains('yagout')) {
      // Check for failure status in query parameters
      final status = queryParams['status']?.toLowerCase() ?? '';
      final paymentStatus = queryParams['payment_status']?.toLowerCase() ?? '';
      final txnStatus = queryParams['txn_status']?.toLowerCase() ?? '';

      if (status.contains('failure') ||
          status.contains('failed') ||
          status.contains('error') ||
          paymentStatus.contains('failure') ||
          paymentStatus.contains('failed') ||
          paymentStatus.contains('error') ||
          txnStatus.contains('failure') ||
          txnStatus.contains('failed') ||
          txnStatus.contains('error')) {
        return true;
      }

      // Check for failure in path
      if (path.contains('failure') ||
          path.contains('failed') ||
          path.contains('error')) {
        return true;
      }
    }

    // Check for common failure patterns
    if (queryParams['result']?.toLowerCase() == 'failure' ||
        queryParams['result']?.toLowerCase() == 'failed' ||
        queryParams['response']?.toLowerCase() == 'failure' ||
        queryParams['response']?.toLowerCase() == 'failed' ||
        queryParams['code']?.toLowerCase() == 'failure' ||
        queryParams['code']?.toLowerCase() == 'failed') {
      return true;
    }

    return false;
  }

  void _navigateToSuccessPage(String url) {
    // Parse URL parameters to extract transaction details
    final uri = Uri.parse(url);
    final queryParams = uri.queryParameters;

    print('=== Navigating to SUCCESS Page ===');
    print('URL: $url');
    print('Query Params: $queryParams');
    print('==================================');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => YagoutPaySuccessScreen(
          orderId: widget.orderId ??
              queryParams['order_id'] ??
              queryParams['orderNo'] ??
              queryParams['order_no'],
          transactionId: queryParams['transaction_id'] ??
              queryParams['txn_id'] ??
              queryParams['transactionId'],
          amount: widget.amount ?? queryParams['amount'],
          currency: widget.currency ?? queryParams['currency'] ?? 'ETB',
          customerName: widget.customerName ??
              queryParams['customer_name'] ??
              queryParams['customerName'],
          customerEmail: widget.customerEmail ??
              queryParams['email'] ??
              queryParams['emailId'],
          customerPhone: widget.customerPhone ??
              queryParams['phone'] ??
              queryParams['mobileNumber'] ??
              queryParams['mobile_no'],
          paymentMethod: widget.paymentMethod ?? 'YagoutPay',
          timestamp: queryParams['timestamp'] ??
              queryParams['date'] ??
              DateTime.now().toIso8601String(),
          additionalData: queryParams.isNotEmpty ? queryParams : null,
        ),
      ),
    );
  }

  void _navigateToFailurePage(String url) {
    // Parse URL parameters to extract error details
    final uri = Uri.parse(url);
    final queryParams = uri.queryParameters;

    print('=== Navigating to FAILURE Page ===');
    print('URL: $url');
    print('Query Params: $queryParams');
    print('==================================');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => YagoutPayFailureScreen(
          orderId: widget.orderId ??
              queryParams['order_id'] ??
              queryParams['orderNo'] ??
              queryParams['order_no'],
          errorCode: queryParams['error_code'] ??
              queryParams['errorCode'] ??
              queryParams['status'],
          errorMessage: queryParams['error_message'] ??
              queryParams['message'] ??
              queryParams['errorMessage'] ??
              queryParams['statusMessage'],
          amount: widget.amount ?? queryParams['amount'],
          currency: widget.currency ?? queryParams['currency'] ?? 'ETB',
          customerName: widget.customerName ??
              queryParams['customer_name'] ??
              queryParams['customerName'],
          customerEmail: widget.customerEmail ??
              queryParams['email'] ??
              queryParams['emailId'],
          customerPhone: widget.customerPhone ??
              queryParams['phone'] ??
              queryParams['mobileNumber'] ??
              queryParams['mobile_no'],
          paymentMethod: widget.paymentMethod ?? 'YagoutPay',
          timestamp: queryParams['timestamp'] ??
              queryParams['date'] ??
              DateTime.now().toIso8601String(),
          additionalData: queryParams.isNotEmpty ? queryParams : null,
          onRetry: () {
            // Navigate back to checkout for retry
            Navigator.pushNamedAndRemoveUntil(
                context, '/checkout', (route) => false);
          },
        ),
      ),
    );
  }

  void _checkForPaymentCompletion(String url) {
    // This method checks if the payment has been completed
    // by looking for common success indicators in the page content
    // or by checking if we're no longer on the YagoutPay domain

    print('=== Checking for Payment Completion ===');
    print('URL: $url');

    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();

    // If we're no longer on YagoutPay domain and not on our custom URLs,
    // it might indicate payment completion
    if (!host.contains('yagoutpay.com') &&
        !host.contains('yagout') &&
        !url.startsWith(widget.successUrl) &&
        !url.startsWith(widget.failureUrl) &&
        !host.contains('localhost') &&
        !host.contains('127.0.0.1')) {
      print('🔄 Payment appears to be completed - redirecting to success page');

      // Wait a moment to see if there are any more redirects
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Navigate to success page with available data
          _navigateToSuccessPage(url);
        }
      });
    }

    print('=======================================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YagoutPay'),
        actions: [
          // Add a manual override button for testing
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'success') {
                _navigateToSuccessPage('manual://success');
              } else if (value == 'failure') {
                _navigateToFailurePage('manual://failure');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'success',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Mark as Success'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'failure',
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Mark as Failure'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
