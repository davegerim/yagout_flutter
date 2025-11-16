import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:convert';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/yagoutpay_service.dart';
import '../../screens/payment/yagoutpay_success_screen.dart';
import '../../screens/payment/yagoutpay_failure_screen.dart';
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

  String _selectedPaymentMethod = 'YagoutPay (API)';
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
                      '${item.totalPrice.toStringAsFixed(2)} Birr',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${cartProvider.totalAmount.toStringAsFixed(2)} Birr',
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
                '${cartProvider.totalAmount.toStringAsFixed(2)} Birr'),
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
              title: const Text('YagoutPay (Direct API)'),
              value: 'YagoutPay (API)',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
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

        // Only support YagoutPay Direct API integration
        if (_selectedPaymentMethod == 'YagoutPay' ||
            _selectedPaymentMethod == 'YagoutPay (API)') {
          final result = await _startYagoutApiPayment(
            amount: cartProvider.totalAmount,
            cartProvider: cartProvider,
          );
          paymentOk = result['success'] ?? false;
          yagoutPayOrderId = result['orderId'];
          
          // If payment failed, navigation to failure page already happened
          // Just return early - don't show error banner
          if (!paymentOk) {
            setState(() {
              _isProcessing = false;
            });
            return; // Exit early - failure page is already shown
          }
        }

        // Only proceed with order creation if payment was successful
        // (Success page navigation already happened in _startYagoutApiPayment)
        if (!paymentOk) {
          setState(() {
            _isProcessing = false;
          });
          return; // Exit early
        }

        // Payment was successful - success page navigation already happened
        // Create order in background (for records) but don't navigate again
        // The success page is already showing
        try {
          final orderId = await context.read<OrderProvider>().placeOrder(
                cartProvider.items,
                cartProvider.totalAmount,
                shippingAddress,
                _selectedPaymentMethod,
                yagoutPayOrderId: yagoutPayOrderId, // Pass YagoutPay order ID
              );
          cartProvider.clearCart();
          print('✅ Order created in background: $orderId');
        } catch (e) {
          // Order creation failed, but payment was successful
          // Don't show error - success page is already showing
          print('⚠️ Failed to create order record: $e');
        }
      } catch (e) {
        // Only show error if we're still on the checkout page
        // (Navigation to success/failure pages already happened for payment errors)
        if (mounted && Navigator.canPop(context)) {
          final errorMsg = e.toString();
          
          // Check if this is a payment-related error that already navigated
          if (errorMsg.toLowerCase().contains('yagoutpay api') ||
              errorMsg.toLowerCase().contains('payment') ||
              errorMsg.toLowerCase().contains('declined') ||
              errorMsg.toLowerCase().contains('failed')) {
            // Payment error - navigation should have already happened
            // Don't show error banner
            print('⚠️ Payment error caught, but navigation already happened: $e');
            return;
          }
          
          // For other unexpected errors, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: $e'),
              backgroundColor: AppTheme.errorColor,
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

  Future<Map<String, dynamic>> _startYagoutApiPayment(
      {required double amount, required CartProvider cartProvider}) async {
    // YagoutPay clarification: Pass OR-DOIT-XXXX format directly to API
    // Generate OR-DOIT-XXXX format order ID (12 characters: OR-DOIT-1234)
    final orderNo = YagoutPayService.generateUniqueOrderId('CHECKOUT');
    print('Generated OR-DOIT-XXXX order ID: $orderNo');
    print('Format: ${orderNo.length} characters (expected: 12)');
    print('Passing directly to API as per YagoutPay clarification');

    // For Direct API: Use empty URLs (matching working JavaScript implementation)
    // YagoutPay handles payment status internally without callback URLs for Direct API
    const successUrl = ''; // Empty string like JavaScript
    const failureUrl = ''; // Empty string like JavaScript

    Map<String, dynamic> resp;
    try {
      resp = await YagoutPayService.payViaApi(
      orderNo: orderNo,
      amount: amount.toStringAsFixed(2),
      successUrl: successUrl,
      failureUrl: failureUrl,
      email: _emailController.text,
      mobile: _phoneController.text,
      customerName: _nameController.text.isEmpty ? 'Customer' : _nameController.text,
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
    } catch (e) {
      // If service throws an exception, try to extract response from error message
      // This handles cases where backend returns 201 but old code throws exception
      final errorStr = e.toString();
      print('⚠️ Service threw exception: $e');
      
      // Try to parse JSON from error message if it contains backend response
      if (errorStr.contains('{') && errorStr.contains('"data"')) {
        try {
          // Extract JSON from error message
          final jsonStart = errorStr.indexOf('{');
          final jsonEnd = errorStr.lastIndexOf('}') + 1;
          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            final jsonStr = errorStr.substring(jsonStart, jsonEnd);
            final errorResponse = json.decode(jsonStr) as Map<String, dynamic>;
            if (errorResponse['data'] != null) {
              // We have the response data, use it
              print('✅ Extracted response from error message');
              resp = {
                'status': errorResponse['data']['status'] ?? 'Error',
                'statusMessage': errorResponse['data']['statusMessage'] ?? 'Payment failed',
                'decrypted': null,
                'raw': errorResponse['data'],
              };
            } else {
              rethrow;
            }
          } else {
            rethrow;
          }
        } catch (parseError) {
          // Couldn't parse, rethrow original error
          print('❌ Could not parse error response: $parseError');
          rethrow;
        }
      } else {
        // No JSON in error, rethrow
        rethrow;
      }
    }

    print(
        'YagoutPay API Response: ${resp['status']} - ${resp['statusMessage']}');

    // Get the status from response (this is the YagoutPay payment status)
    final status = (resp['status'] ?? '').toString().toLowerCase();
    final statusMessage = (resp['statusMessage'] ?? '').toString();

    // Prefer decrypted payload if available
    final dec = resp['decrypted'] as Map<String, dynamic>?;
    String? decryptedStatus;
    if (dec != null) {
      decryptedStatus =
          (dec['status'] ?? dec['paymentStatus'] ?? dec['txnStatus'] ?? '')
              .toString()
              .toLowerCase();
    }

    // Determine if payment was successful
    // Success indicators: "success", "approved", "completed"
    // Failure indicators: "declined", "failed", "error", "cancelled", "rejected"
    final isSuccess = (status.contains('success') ||
            status.contains('approved') ||
            status.contains('completed') ||
            status.contains('duplicate') ||
            status.contains('dublicate')) &&
        !status.contains('declined') &&
        !status.contains('failed') &&
        !status.contains('error') &&
        !status.contains('cancelled') &&
        !status.contains('rejected');

    // Also check decrypted status if available
    final isDecryptedSuccess = decryptedStatus != null &&
        (decryptedStatus.contains('success') ||
            decryptedStatus.contains('approved') ||
            decryptedStatus.contains('completed')) &&
        !decryptedStatus.contains('declined') &&
        !decryptedStatus.contains('failed') &&
        !decryptedStatus.contains('error');

    // Use decrypted status if available, otherwise use main status
    final finalIsSuccess = decryptedStatus != null ? isDecryptedSuccess : isSuccess;

    print('💰 Payment Status Check:');
    print('   Status: $status');
    print('   Decrypted Status: $decryptedStatus');
    print('   Is Success: $finalIsSuccess');

    if (finalIsSuccess) {
      // Navigate to success page for API payments
      print('✅ Payment successful - navigating to success page');
      _navigateToApiSuccessPage(orderNo, resp, dec, amount);
      return {
        'success': true,
        'orderId': orderNo, // Return the OR-DOIT-XXXX order ID
      };
    } else {
      // Navigate to failure page for API payments
      final msg = statusMessage.isNotEmpty
          ? statusMessage
          : (status.isNotEmpty ? 'Payment $status' : 'Payment failed');
      print('❌ Payment failed - navigating to failure page');
      print('   Error message: $msg');
      // Navigate to failure page - don't throw exception, just return failure
      // The navigation will handle showing the failure UI
      _navigateToApiFailurePage(orderNo, resp, msg, amount);
      return {
        'success': false,
        'orderId': orderNo,
        'error': msg,
      };
    }
  }

  void _navigateToApiSuccessPage(String orderNo, Map<String, dynamic> resp,
      Map<String, dynamic>? dec, double amount) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => YagoutPaySuccessScreen(
          orderId: orderNo,
          transactionId:
              dec?['transactionId'] ?? dec?['txnId'] ?? resp['transactionId'],
          amount: amount.toStringAsFixed(2),
          currency: YagoutPayConfig.defaultCurrency,
          customerName: _nameController.text,
          customerEmail: _emailController.text,
          customerPhone: _phoneController.text,
          paymentMethod: 'YagoutPay (API)',
          timestamp: DateTime.now().toIso8601String(),
          additionalData: {
            'api_response': resp,
            'decrypted_response': dec,
            'status': resp['status'],
            'status_message': resp['statusMessage'],
          },
        ),
      ),
    );
  }

  void _navigateToApiFailurePage(String orderNo, Map<String, dynamic> resp,
      String errorMessage, double amount) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => YagoutPayFailureScreen(
          orderId: orderNo,
          errorCode: resp['status'] ?? 'API_ERROR',
          errorMessage: errorMessage,
          amount: amount.toStringAsFixed(2),
          currency: YagoutPayConfig.defaultCurrency,
          customerName: _nameController.text,
          customerEmail: _emailController.text,
          customerPhone: _phoneController.text,
          paymentMethod: 'YagoutPay (API)',
          timestamp: DateTime.now().toIso8601String(),
          additionalData: {
            'api_response': resp,
            'status': resp['status'],
            'status_message': resp['statusMessage'],
          },
          onRetry: () {
            // Navigate back to checkout for retry
            Navigator.pushNamedAndRemoveUntil(
                context, '/checkout', (route) => false);
          },
        ),
      ),
    );
  }
}
