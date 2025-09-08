import 'dart:convert';
import 'lib/config/yagoutpay_config.dart';

void main() {
  print('=== YagoutPay Plain Text Request ===');
  print('This is the EXACT plain text JSON that gets encrypted and sent to YagoutPay API');
  print('');

  // Sample order ID in OR-DOIT-XXXX format
  const orderNo = 'OR-DOIT-1234';
  
  // Sample values
  const amount = '100.00';
  const country = 'ETH';
  const currency = 'ETB';
  const transactionType = 'SALE';
  const successUrl = 'https://example.com/success';
  const failureUrl = 'https://example.com/failure';
  const channel = 'MOBILE';
  const email = 'test@example.com';
  const mobile = '0912345678';
  const customerName = 'Test Customer';

  // Build the EXACT plain text JSON that gets encrypted
  final Map<String, dynamic> plain = {
    'card_details': {
      'cardNumber': '',
      'expiryMonth': '',
      'expiryYear': '',
      'cvv': '',
      'cardName': ''
    },
    'other_details': {
      'udf1': '',
      'udf2': '',
      'udf3': '',
      'udf4': '',
      'udf5': '',
      'udf6': '',
      'udf7': ''
    },
    'ship_details': {
      'shipAddress': '',
      'shipCity': '',
      'shipState': '',
      'shipCountry': country,
      'shipZip': '',
      'shipDays': '',
      'addressCount': ''
    },
    'txn_details': {
      'agId': YagoutPayConfig.aggregatorId,
      'meId': YagoutPayConfig.apiMerchantId,
      'orderNo': orderNo, // This is the OR-DOIT-XXXX format
      'amount': amount,
      'country': country,
      'currency': currency,
      'transactionType': transactionType,
      'sucessUrl': successUrl, // Note: YagoutPay uses 'sucessUrl' (sic)
      'failureUrl': failureUrl,
      'channel': channel,
    },
    'item_details': {
      'itemCount': '1',
      'itemValue': amount,
      'itemCategory': 'Shoes'
    },
    'cust_details': {
      'customerName': customerName,
      'emailId': email,
      'mobileNumber': mobile,
      'uniqueId': '',
      'isLoggedIn': 'Y'
    },
    'pg_details': {
      'pg_Id': YagoutPayConfig.pgId,
      'paymode': YagoutPayConfig.paymode,
      'scheme_Id': YagoutPayConfig.schemeId,
      'wallet_type': YagoutPayConfig.walletType,
    },
    'bill_details': {
      'billAddress': '',
      'billCity': '',
      'billState': '',
      'billCountry': country,
      'billZip': ''
    }
  };

  // Convert to JSON string (this is what gets encrypted)
  final plainTextJson = jsonEncode(plain);
  
  print('PLAIN TEXT JSON (before encryption):');
  print('=====================================');
  print(plainTextJson);
  print('');
  
  print('FORMATTED JSON (for readability):');
  print('=================================');
  const encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert(plain));
  print('');
  
  print('KEY VALUES:');
  print('===========');
  print('Order ID: $orderNo');
  print('Amount: $amount');
  print('Merchant ID: ${YagoutPayConfig.apiMerchantId}');
  print('Aggregator ID: ${YagoutPayConfig.aggregatorId}');
  print('Country: $country');
  print('Currency: $currency');
  print('Transaction Type: $transactionType');
  print('Channel: $channel');
  print('');
  
  print('This plain text JSON is then encrypted using AES-256-CBC');
  print('and sent in the merchantRequest field to YagoutPay API.');
}


