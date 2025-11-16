import 'package:flutter/material.dart';
import '../../services/yagoutpay_service.dart';
import '../../utils/app_theme.dart';

class StaticLinkScreen extends StatefulWidget {
  const StaticLinkScreen({super.key});

  @override
  State<StaticLinkScreen> createState() => _StaticLinkScreenState();
}

class _StaticLinkScreenState extends State<StaticLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reqUserIdController = TextEditingController(text: 'yagou381');
  final _amountController = TextEditingController(text: '500');
  final _customerEmailController =
      TextEditingController(text: 'test@example.com');
  final _mobileNoController = TextEditingController(text: '0985392862');
  final _expiryDateController = TextEditingController(text: '2025-10-15');
  final _orderIdController = TextEditingController();
  final _firstNameController = TextEditingController(text: 'YagoutPay');
  final _lastNameController = TextEditingController(text: 'StaticLink');
  final _productController =
      TextEditingController(text: 'Premium Subscription');
  final _dialCodeController = TextEditingController(text: '+251');
  final _failureUrlController =
      TextEditingController(text: 'http://localhost:3000/failure');
  final _successUrlController =
      TextEditingController(text: 'http://localhost:3000/success');

  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _orderIdController.text =
        YagoutPayService.generateUniqueOrderId('STATIC_LINK');
  }

  @override
  void dispose() {
    _reqUserIdController.dispose();
    _amountController.dispose();
    _customerEmailController.dispose();
    _mobileNoController.dispose();
    _expiryDateController.dispose();
    _orderIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _productController.dispose();
    _dialCodeController.dispose();
    _failureUrlController.dispose();
    _successUrlController.dispose();
    super.dispose();
  }

  Future<void> _createStaticLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await YagoutPayService.createStaticLink(
        reqUserId: _reqUserIdController.text.trim(),
        amount: _amountController.text.trim(),
        customerEmail: _customerEmailController.text.trim(),
        mobileNo: _mobileNoController.text.trim(),
        expiryDate: _expiryDateController.text.trim(),
        orderId: _orderIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        product: _productController.text.trim(),
        dialCode: _dialCodeController.text.trim(),
        failureUrl: _failureUrlController.text.trim(),
        successUrl: _successUrlController.text.trim(),
      );

      setState(() {
        _result = result;
      });

      if (result['status'] == 'SUCCESS') {
        _showSuccessDialog(result);
      } else {
        _showErrorDialog(result['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      setState(() {
        _result = {'status': 'ERROR', 'message': e.toString()};
      });
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Static Link Created!',
            style: TextStyle(color: Colors.green)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${result['order_id']}'),
            const SizedBox(height: 8),
            const Text('Static Link has been created successfully.'),
            if (result['payment_link'] != null) ...[
              const SizedBox(height: 8),
              const Text('Payment Link:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: SelectableText(
                  result['payment_link'].toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            ],
            if (result['decrypted_response'] != null) ...[
              const SizedBox(height: 8),
              const Text('Response:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result['decrypted_response'].toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Link API'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Static Link',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Generate a static link for QR code payments and recurring transactions.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.qr_code, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This will create a static link that can be used for QR code generation.',
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Form Fields
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Row 1: Amount and Order ID
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'Amount (ETB)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter valid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _orderIdController,
                              decoration: const InputDecoration(
                                labelText: 'Order ID',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.receipt),
                              ),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Row 2: Customer Email and Mobile
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _customerEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Customer Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _mobileNoController,
                              decoration: const InputDecoration(
                                labelText: 'Mobile Number',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter mobile number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Row 3: First Name and Last Name
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter first name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter last name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Product and Dial Code
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _productController,
                              decoration: const InputDecoration(
                                labelText: 'Product/Service',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.shopping_bag),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter product/service';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _dialCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Dial Code',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.flag),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter dial code';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Expiry Date
                      TextFormField(
                        controller: _expiryDateController,
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date (YYYY-MM-DD)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter expiry date';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // URLs
                      TextFormField(
                        controller: _successUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Success URL',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.check_circle),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter success URL';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _failureUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Failure URL',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.error),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter failure URL';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Create Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createStaticLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Creating Static Link...'),
                        ],
                      )
                    : const Text(
                        'Create Static Link',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 16),

              // Result Display
              if (_result != null) ...[
                Card(
                  color: _result!['status'] == 'SUCCESS'
                      ? Colors.green[50]
                      : Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _result!['status'] == 'SUCCESS'
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _result!['status'] == 'SUCCESS'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Result: ${_result!['status']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _result!['status'] == 'SUCCESS'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Message: ${_result!['message']}'),
                        if (_result!['order_id'] != null) ...[
                          const SizedBox(height: 4),
                          Text('Order ID: ${_result!['order_id']}'),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
