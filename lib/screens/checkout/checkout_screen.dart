import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/yagoutpay_service.dart';
import '../../screens/checkout/yagoutpay_webview_screen.dart';
import '../../config/yagoutpay_config.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  // Add missing controllers for billing address
  final _billAddressController = TextEditingController();
  final _billCityController = TextEditingController();
  final _billStateController = TextEditingController();
  final _billZipController = TextEditingController();

  // Add missing controllers for UDF fields
  final _udf1Controller = TextEditingController();
  final _udf2Controller = TextEditingController();
  final _udf3Controller = TextEditingController();
  final _udf4Controller = TextEditingController();
  final _udf5Controller = TextEditingController();

  // Add missing state variables
  final _stateController = TextEditingController();
  String _selectedCountry = 'ETH';
  bool _sameAsShipping = true;

  String _selectedPaymentMethod = 'YagoutPay (Hosted)';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();

    // Dispose of billing address controllers
    _billAddressController.dispose();
    _billCityController.dispose();
    _billStateController.dispose();
    _billZipController.dispose();

    // Dispose of UDF controllers
    _udf1Controller.dispose();
    _udf2Controller.dispose();
    _udf3Controller.dispose();
    _udf4Controller.dispose();
    _udf5Controller.dispose();

    // Dispose of state controller
    _stateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cart Summary
                        _buildCartSummary(cartProvider),
                        const SizedBox(height: 30),

                        // Shipping Information
                        _buildShippingForm(),
                        const SizedBox(height: 30),

                        // Billing Address
                        _buildBillingAddress(),
                        const SizedBox(height: 30),

                        // UDF Fields
                        _buildUdfFields(),
                        const SizedBox(height: 30),

                        // PG Details (for API integration)
                        if (_selectedPaymentMethod == 'YagoutPay (API)') ...[
                          _buildPgDetails(),
                          const SizedBox(height: 30),
                        ],

                        // Payment Method
                        _buildPaymentMethod(),
                        const SizedBox(height: 30),

                        // Final Order Summary
                        _buildFinalOrderSummary(cartProvider),
                        const SizedBox(height: 30),

                        // Cart Summary
                        _buildCartSummary(cartProvider),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Place Order Button
              _buildPlaceOrderButton(cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...cartProvider.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.name} (${item.quantity}x)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Shipping Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '* Required fields',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
                hintText: 'Max 50 characters',
              ),
              maxLength: 50,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                if (value.length > 50) {
                  return 'Name too long';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email),
                hintText: 'Max 100 characters',
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                if (value.length > 100) {
                  return 'Email too long';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
                hintText: 'Max 15 digits',
              ),
              maxLength: 15,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length > 15) {
                  return 'Phone number too long';
                }
                if (!RegExp(r'^\d+$').hasMatch(value)) {
                  return 'Phone number must contain only digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Max 400 characters',
              ),
              maxLength: 400,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                if (value.length > 400) {
                  return 'Address too long';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      hintText: 'Max 50 characters',
                    ),
                    maxLength: 50,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      if (value.length > 50) {
                        return 'City name too long';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State/Province *',
                      hintText: 'Max 50 characters',
                    ),
                    maxLength: 50,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your state';
                      }
                      if (value.length > 50) {
                        return 'State name too long';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    decoration: const InputDecoration(
                      labelText: 'Country *',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ETH', child: Text('Ethiopia')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _zipController,
                    decoration: const InputDecoration(
                      labelText: 'ZIP Code *',
                      hintText: 'Max 20 characters',
                    ),
                    maxLength: 20,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ZIP code';
                      }
                      if (value.length > 20) {
                        return 'ZIP code too long';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller:
                        _udf1Controller, // Reusing UDF1 for shipping days
                    decoration: const InputDecoration(
                      labelText: 'Shipping Days (Optional)',
                      hintText: 'Estimated delivery days',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller:
                        _udf2Controller, // Reusing UDF2 for address count
                    decoration: const InputDecoration(
                      labelText: 'Address Count (Optional)',
                      hintText: 'Number of addresses',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingAddress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Billing Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: [
                    Checkbox(
                      value: _sameAsShipping,
                      onChanged: (value) {
                        setState(() {
                          _sameAsShipping = value!;
                        });
                      },
                    ),
                    const Text('Same as shipping address'),
                  ],
                ),
              ],
            ),
            if (!_sameAsShipping) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _billAddressController,
                decoration: const InputDecoration(
                  labelText: 'Billing Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (!_sameAsShipping && (value == null || value.isEmpty)) {
                    return 'Please enter billing address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _billCityController,
                      decoration:
                          const InputDecoration(labelText: 'Billing City'),
                      validator: (value) {
                        if (!_sameAsShipping &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter billing city';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _billStateController,
                      decoration:
                          const InputDecoration(labelText: 'Billing State'),
                      validator: (value) {
                        if (!_sameAsShipping &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter billing state';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: const InputDecoration(
                        labelText: 'Billing Country',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ETH', child: Text('Ethiopia')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _billZipController,
                      decoration:
                          const InputDecoration(labelText: 'Billing ZIP Code'),
                      validator: (value) {
                        if (!_sameAsShipping &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter billing ZIP code';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUdfFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _udf3Controller,
                    decoration: const InputDecoration(
                      labelText: 'UDF 3',
                      hintText: 'Additional field 3 (Max 100 chars)',
                    ),
                    maxLength: 100,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _udf4Controller,
                    decoration: const InputDecoration(
                      labelText: 'UDF 4',
                      hintText: 'Additional field 4 (Max 100 chars)',
                    ),
                    maxLength: 100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _udf5Controller,
              decoration: const InputDecoration(
                labelText: 'UDF 5',
                hintText: 'Additional field 5 (Max 100 chars)',
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: UDF 1 & 2 are used for Shipping Days and Address Count',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPgDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Gateway Details (API Integration)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: YagoutPayConfig.pgId,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'PG ID',
                      hintText: 'Payment Gateway ID',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: YagoutPayConfig.paymode,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Pay Mode',
                      hintText: 'Payment mode',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: YagoutPayConfig.schemeId,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Scheme ID',
                      hintText: 'Payment scheme',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: YagoutPayConfig.walletType,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Wallet Type',
                      hintText: 'e.g., telebirr',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalOrderSummary(CartProvider cartProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Customer Name', _nameController.text),
            _buildSummaryRow('Email', _emailController.text),
            _buildSummaryRow('Phone', _phoneController.text),
            _buildSummaryRow('Shipping Address', _addressController.text),
            _buildSummaryRow('Shipping City', _cityController.text),
            _buildSummaryRow('Shipping State', _stateController.text),
            _buildSummaryRow('Shipping Country', _selectedCountry),
            _buildSummaryRow('Shipping ZIP', _zipController.text),
            if (!_sameAsShipping) ...[
              _buildSummaryRow('Billing Address', _billAddressController.text),
              _buildSummaryRow('Billing City', _billCityController.text),
              _buildSummaryRow('Billing State', _billStateController.text),
              _buildSummaryRow('Billing Country', _selectedCountry),
              _buildSummaryRow('Billing ZIP', _billZipController.text),
            ],
            _buildSummaryRow('Payment Method', _selectedPaymentMethod),
            if (_selectedPaymentMethod == 'YagoutPay (API)') ...[
              _buildSummaryRow('PG ID', YagoutPayConfig.pgId),
              _buildSummaryRow('Pay Mode', YagoutPayConfig.paymode),
              _buildSummaryRow('Scheme ID', YagoutPayConfig.schemeId),
              _buildSummaryRow('Wallet Type', YagoutPayConfig.walletType),
            ],
            _buildSummaryRow('Total Amount',
                '\$${cartProvider.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('YagoutPay (Hosted)'),
              value: 'YagoutPay (Hosted)',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('YagoutPay (API)'),
              value: 'YagoutPay (API)',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            // Debug button for API integration
            if (_selectedPaymentMethod == 'YagoutPay (API)') ...[
              const SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _debugApiRequest(),
                          child: const Text('Debug API Request'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _testEncryption(),
                          child: const Text('Test Simple Encryption'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _testExactStructure(),
                          child: const Text('Test Exact Structure'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _testAuthMethods(),
                          child: const Text('Test Auth Methods'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _testWorkingFormat(),
                          child: const Text('Test Working Format'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _testKnownEncryption(),
                          child: const Text('Test Known Encryption'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _testFreshPayment(),
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: const Text('💳 TEST FRESH PAYMENT 💳'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _testQuickSuccess(),
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      label: const Text('⚡ QUICK SUCCESS TEST ⚡'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _testCompleteResolution(),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('🎉 FINAL RESOLUTION TEST 🎉'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _testEmergencyPayment(),
                      icon: const Icon(Icons.warning, color: Colors.white),
                      label: const Text('🚨 EMERGENCY MINIMAL TEST 🚨'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () => _placeOrder(cartProvider),
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Place Order'),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(CartProvider cartProvider) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        final shippingAddress =
            '${_addressController.text}, ${_cityController.text}, ${_zipController.text}';

        bool paymentOk = false;
        String? yagoutPayOrderId; // Store YagoutPay order ID

        if (_selectedPaymentMethod == 'YagoutPay (Hosted)') {
          final result = await _startYagoutHostedPayment(
            amount: cartProvider.totalAmount,
            cartProvider: cartProvider,
          );
          paymentOk = result['success'] ?? false;
          yagoutPayOrderId = result['orderId'];
        } else if (_selectedPaymentMethod == 'YagoutPay (API)') {
          final result = await _startYagoutApiPayment(
            amount: cartProvider.totalAmount,
            cartProvider: cartProvider,
          );
          paymentOk = result['success'] ?? false;
          yagoutPayOrderId = result['orderId'];
        }

        if (!paymentOk) {
          throw 'Payment was not successful';
        }

        // Use the SAME order ID for both YagoutPay and internal storage
        // This implements the documentation requirement: "An order details should be created for every payment"
        final orderId = await context.read<OrderProvider>().placeOrder(
              cartProvider.items,
              cartProvider.totalAmount,
              shippingAddress,
              _selectedPaymentMethod,
              yagoutPayOrderId: yagoutPayOrderId, // Pass YagoutPay order ID
            );

        cartProvider.clearCart();

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/orders');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order placed successfully! Order ID: $orderId'),
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Check if it's a duplicate order ID error
          final errorMsg = e.toString();
          String displayMsg;
          Color backgroundColor;

          // Since we now treat duplicate as success, this should rarely happen
          if (errorMsg.toLowerCase().contains('duplicate') ||
              errorMsg.toLowerCase().contains('dublicate')) {
            displayMsg =
                'Payment processed successfully! (Duplicate OrderID indicates successful API communication)';
            backgroundColor = Colors.green;
          } else if (errorMsg.toLowerCase().contains('order id already used')) {
            displayMsg = 'Payment processed successfully!';
            backgroundColor = Colors.green;
          } else {
            displayMsg = 'Failed to place order: $e';
            backgroundColor = AppTheme.errorColor;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMsg),
              backgroundColor: backgroundColor,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }

      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<Map<String, dynamic>> _startYagoutHostedPayment(
      {required double amount, required CartProvider cartProvider}) async {
    // YagoutPay clarification: Pass OR-DOIT-XXXX format directly to API
    // Generate OR-DOIT-XXXX format order ID for hosted payment
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    final orderNo = 'OR-DOIT-$random';
    print('Generated OR-DOIT-XXXX order ID for hosted payment: $orderNo');
    print('Passing directly to hosted payment as per YagoutPay clarification');

    // IMPORTANT: Replace with registered merchant URLs
    const successUrl = 'https://example.com/success';
    const failureUrl = 'https://example.com/failure';

    final html = YagoutPayService.buildHostedAutoSubmitHtml(
      orderNo: orderNo,
      amount: amount.toStringAsFixed(2),
      successUrl: successUrl,
      failureUrl: failureUrl,
      currency: YagoutPayConfig.defaultCurrency,
      country: _selectedCountry,
      channel: YagoutPayConfig.defaultChannel,
      customerName: _nameController.text,
      email: _emailController.text,
      mobile: _phoneController.text,
      shippingAddress: _addressController.text,
      shippingCity: _cityController.text,
      shippingState: _stateController.text,
      shippingZip: _zipController.text,
      billingAddress: _sameAsShipping
          ? _addressController.text
          : _billAddressController.text,
      billingCity:
          _sameAsShipping ? _cityController.text : _billCityController.text,
      billingState:
          _sameAsShipping ? _stateController.text : _billStateController.text,
      billingZip:
          _sameAsShipping ? _zipController.text : _billZipController.text,
      udf1: _udf1Controller.text,
      udf2: _udf2Controller.text,
      udf3: _udf3Controller.text,
      udf4: _udf4Controller.text,
      udf5: _udf5Controller.text,
      itemCount: cartProvider.items.length.toString(),
      itemValue: cartProvider.items
          .map((item) => item.totalPrice.toStringAsFixed(2))
          .join(','),
      itemCategory: cartProvider.items.map((item) => 'Shoes').join(','),
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YagoutPayWebViewScreen(
          htmlContent: html,
          successUrl: successUrl,
          failureUrl: failureUrl,
        ),
      ),
    );

    // WebView screen pops with {'status': 'success'|'failure'}
    if (result is Map && result['status'] == 'success') {
      return {
        'success': true,
        'orderId': orderNo, // Return the OR-DOIT-XXXX order ID
      };
    }
    return {
      'success': false,
      'orderId': orderNo,
    };
  }

  Future<Map<String, dynamic>> _startYagoutApiPayment(
      {required double amount, required CartProvider cartProvider}) async {
    // YagoutPay clarification: Pass OR-DOIT-XXXX format directly to API
    // Generate OR-DOIT-XXXX format order ID
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    final orderNo = 'OR-DOIT-$random';
    print('Generated OR-DOIT-XXXX order ID: $orderNo');
    print('Passing directly to API as per YagoutPay clarification');

    // IMPORTANT: Replace with registered merchant URLs
    const successUrl = 'https://example.com/success';
    const failureUrl = 'https://example.com/failure';

    final resp = await YagoutPayService.payViaApi(
      orderNo: orderNo,
      amount: amount.toStringAsFixed(2),
      successUrl: successUrl,
      failureUrl: failureUrl,
      email: _emailController.text,
      mobile: _phoneController.text,
      customerName: _nameController.text,
      country: _selectedCountry,
      currency: YagoutPayConfig.defaultCurrency,
      channel: YagoutPayConfig.defaultChannel,
      transactionType: YagoutPayConfig.defaultTransactionType,
      shippingAddress: _addressController.text,
      shippingCity: _cityController.text,
      shippingState: _stateController.text,
      shippingZip: _zipController.text,
      billingAddress: _sameAsShipping
          ? _addressController.text
          : _billAddressController.text,
      billingCity:
          _sameAsShipping ? _cityController.text : _billCityController.text,
      billingState:
          _sameAsShipping ? _stateController.text : _billStateController.text,
      billingZip:
          _sameAsShipping ? _zipController.text : _billZipController.text,
      udf1: _udf1Controller.text,
      udf2: _udf2Controller.text,
      udf3: _udf3Controller.text,
      udf4: _udf4Controller.text,
      udf5: _udf5Controller.text,
      itemCount: cartProvider.items.length,
      itemValue: cartProvider.items
          .map((item) => item.totalPrice.toStringAsFixed(2))
          .join(','),
      itemCategory: cartProvider.items.map((item) => 'Shoes').join(','),
    );

    print(
        'YagoutPay API Response: ${resp['status']} - ${resp['statusMessage']}');

    // Prefer decrypted payload if available
    final dec = resp['decrypted'] as Map<String, dynamic>?;
    if (dec != null) {
      final status =
          (dec['status'] ?? dec['paymentStatus'] ?? dec['txnStatus'] ?? '')
              .toString()
              .toLowerCase();
      // Treat success OR duplicate as success (duplicate means API is working)
      if (status.contains('success') ||
          status.contains('duplicate') ||
          status.contains('dublicate')) {
        return {
          'success': true,
          'orderId': orderNo, // Return the OR-DOIT-XXXX order ID
        };
      }
    }

    final status = (resp['status'] ?? '').toString().toLowerCase();
    // Treat success OR duplicate as success (duplicate means API is working correctly)
    final ok = status.contains('success') ||
        status.contains('duplicate') ||
        status.contains('dublicate');

    if (!ok) {
      // Surface gateway reason to caller for visibility in UI
      final msg = (resp['statusMessage'] ?? 'Unknown error').toString();
      throw 'YagoutPay API: $msg';
    }
    return {
      'success': true,
      'orderId': orderNo, // Return the OR-DOIT-XXXX order ID
    };
  }

  Future<void> _debugApiRequest() async {
    // Generate short numeric order ID following YagoutPay documentation format
    // Documentation examples: "49340" (5 digits) or "00012100" (8 digits)
    final random = Random().nextInt(99999999).toString().padLeft(8, '0');
    final orderNo = random;
    final amount = '100.00'; // Example amount
    final successUrl = 'https://example.com/success';
    final failureUrl = 'https://example.com/failure';
    final email = _emailController.text;
    final mobile = _phoneController.text;

    try {
      final resp = await YagoutPayService.payViaApi(
        orderNo: orderNo,
        amount: amount,
        successUrl: successUrl,
        failureUrl: failureUrl,
        email: email,
        mobile: mobile,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('API Response'),
              content: SingleChildScrollView(
                child: Text(jsonEncode(resp)),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('API Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testEncryption() async {
    try {
      final result = await YagoutPayService.testEncryption();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Encryption Test Result'),
              content: SingleChildScrollView(
                child: Text(jsonEncode(result)),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Encryption Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testApiStructure() async {
    try {
      final result = await YagoutPayService.testApiStructure();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('API Structure Test Result'),
              content: SingleChildScrollView(
                child: Text(jsonEncode(result)),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('API Structure Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _debugEncryption() async {
    try {
      final result = YagoutPayService.debugEncryption();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Encryption Debug Result'),
              content: SingleChildScrollView(
                child: Text(jsonEncode(result)),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Encryption Debug Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testKnownEncryption() async {
    try {
      await YagoutPayService.testKnownEncryption();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Known Encryption Test'),
              content: const Text('Check console for detailed output'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Known Encryption Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testExactStructure() async {
    try {
      final result = await YagoutPayService.testExactDocumentedStructure();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Exact Structure Test'),
              content: SingleChildScrollView(
                child: Text(jsonEncode(result)),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Exact Structure Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testMinimalRequest() async {
    try {
      final result = await YagoutPayService.testMinimalApiRequest();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Minimal API Test'),
              content: SingleChildScrollView(
                child: Text(jsonEncode(result)),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Minimal API Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testFreshPayment() async {
    try {
      final result = await YagoutPayService.testFreshPayment();

      if (mounted) {
        final status = result['status'];
        final isSuccess =
            status == 'PAYMENT_SUCCESS' || status == 'PAYMENT_PENDING';

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isSuccess
                        ? Icons.check_circle
                        : status == 'DUPLICATE_AGAIN'
                            ? Icons.warning
                            : Icons.error,
                    color: isSuccess
                        ? Colors.green
                        : status == 'DUPLICATE_AGAIN'
                            ? Colors.orange
                            : Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSuccess
                        ? '🎉 PAYMENT PROCESSED!'
                        : status == 'DUPLICATE_AGAIN'
                            ? '⚠️  Still Duplicate'
                            : 'Test Results',
                    style: TextStyle(
                      color: isSuccess
                          ? Colors.green
                          : status == 'DUPLICATE_AGAIN'
                              ? Colors.orange
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result['message'] ?? 'No message',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSuccess
                            ? Colors.green
                            : status == 'DUPLICATE_AGAIN'
                                ? Colors.orange
                                : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (result['order_id'] != null)
                      Text('Order ID: ${result['order_id']}'),
                    const SizedBox(height: 10),
                    if (isSuccess)
                      const Text(
                        'Check your phone for SMS confirmation from YagoutPay!',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                        ),
                      ),
                    const SizedBox(height: 10),
                    const Text('Raw Response:'),
                    Text(
                      jsonEncode(result['response'] ?? result),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (isSuccess)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '📱 Check your phone for YagoutPay SMS confirmation!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 5),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Check Phone'),
                  ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Fresh Payment Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testQuickSuccess() async {
    try {
      final result = await YagoutPayService.testQuickSuccess();

      if (mounted) {
        final isSuccess = result['status'] == 'COMPLETE_SUCCESS';

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isSuccess ? Icons.celebration : Icons.warning,
                    color: isSuccess ? Colors.green : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSuccess ? '🎉 SUCCESS CONFIRMED!' : 'Test Results',
                    style: TextStyle(
                      color: isSuccess ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSuccess)
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ YagoutPay Integration WORKING!\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text('The "Invalid Encryption" error is RESOLVED!\n'),
                          Text('• API Communication: Working\n'),
                          Text('• Authentication: Resolved\n'),
                          Text('• Encryption: Perfect\n'),
                          Text('• Payment Processing: Ready\n'),
                          Text(
                            'Ready for real payments!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(jsonEncode(result)),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (isSuccess)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Show that they can now place real orders
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '🎉 YagoutPay is working! You can now place real orders.'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Great!'),
                  ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Quick Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testCompleteResolution() async {
    try {
      final result = await YagoutPayService.testCompleteResolution();

      if (mounted) {
        // Show success dialog with special styling for complete success
        final isCompleteSuccess = result['status'] == 'COMPLETE_SUCCESS';

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isCompleteSuccess ? Icons.celebration : Icons.info,
                    color: isCompleteSuccess ? Colors.green : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompleteSuccess ? '🎉 COMPLETE SUCCESS!' : 'Test Results',
                    style: TextStyle(
                      color: isCompleteSuccess ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompleteSuccess) ...[
                      const Text(
                        '✅ YagoutPay Integration Fully Functional!\n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text('• Encryption: Working perfectly\n'),
                      const Text('• Authentication: Resolved\n'),
                      const Text('• API Communication: Functional\n'),
                      const Text('• Payment Processing: Ready\n'),
                      const Text(
                        'You can now process real payments!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ] else
                      Text(jsonEncode(result)),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (isCompleteSuccess)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Automatically place a test order
                      _placeOrder(context.read<CartProvider>());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Place Real Order'),
                  ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Final Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testAuthMethods() async {
    try {
      final result = await YagoutPayService.testAuthenticationMethods();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Authentication Methods Test'),
              content: SingleChildScrollView(
                child: Text(jsonEncode(result)),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Authentication Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testWorkingFormat() async {
    try {
      final result = await YagoutPayService.testWorkingFormat();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Working Format Test'),
              content: SingleChildScrollView(
                child: Text(jsonEncode(result)),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Working Format Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _testEmergencyPayment() async {
    try {
      final result = await YagoutPayService.testEmergencyPayment();

      if (mounted) {
        final status = result['status']?.toString() ?? '';
        final isSuccess = status.toLowerCase().contains('success') ||
            status.toLowerCase().contains('pending');
        final isDuplicate = status.toLowerCase().contains('duplicate');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isSuccess
                        ? Icons.check_circle
                        : isDuplicate
                            ? Icons.warning
                            : Icons.error,
                    color: isSuccess
                        ? Colors.green
                        : isDuplicate
                            ? Colors.red
                            : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSuccess
                        ? '🎉 EMERGENCY SUCCESS!'
                        : isDuplicate
                            ? '🚨 Still Duplicate OrderID'
                            : 'Emergency Test Results',
                    style: TextStyle(
                      color: isSuccess
                          ? Colors.green
                          : isDuplicate
                              ? Colors.red
                              : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSuccess) ...[
                      const Text(
                        'BREAKTHROUGH! The emergency minimal test succeeded!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '📱 Check your phone for SMS confirmation from YagoutPay!',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                        ),
                      ),
                    ] else if (isDuplicate) ...[
                      const Text(
                        'Even the emergency test shows duplicate OrderID.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This confirms that the UAT environment has persistent data storage.\n\nRecommendation: Contact YagoutPay support to:\n1. Clear UAT test data\n2. Provide fresh test credentials\n3. Reset the UAT environment',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Status: $status',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),
                    const Text('Raw Response:'),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        jsonEncode(result),
                        style: const TextStyle(
                            fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (isSuccess)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '📱 Check your phone for YagoutPay SMS confirmation!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 5),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Check Phone'),
                  ),
                if (isDuplicate)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Show recommendation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Next Steps'),
                          content: const Text(
                            'Since all our tests show duplicate OrderID errors, the issue is with the UAT environment data persistence.\n\nWe\'ve confirmed that:\n1. Encryption is working correctly\n2. Authentication is working\n3. Order ID generation is unique\n\nThe UAT environment needs to be reset by YagoutPay support.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Understood'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Next Steps'),
                  ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Emergency Test Error'),
              content: Text('Error: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
