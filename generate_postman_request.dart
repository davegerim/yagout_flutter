import 'dart:convert';
import 'lib/config/yagoutpay_config.dart';
import 'lib/utils/crypto/aes_util.dart';

void main() {
  print('=== YagoutPay Postman Request Generator ===');
  print('This generates the EXACT request body for Postman testing');
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

  print('1. PLAIN TEXT JSON (before encryption):');
  print('=======================================');
  print(plainTextJson);
  print('');

  // Encrypt using the same method as the app
  final key = YagoutPayConfig.apiKey;
  final encrypted = AesUtil.encryptToBase64(plainTextJson, key);

  print('2. ENCRYPTED STRING (for merchantRequest):');
  print('==========================================');
  print(encrypted);
  print('');

  // Create the final Postman request body
  final postmanBody = {
    'merchantId': YagoutPayConfig.apiMerchantId,
    'merchantRequest': encrypted,
  };

  print('3. POSTMAN REQUEST BODY (copy this to Postman):');
  print('===============================================');
  print(jsonEncode(postmanBody));
  print('');

  print('4. POSTMAN SETTINGS:');
  print('===================');
  print('Method: POST');
  print(
      'URL: https://uatcheckout.yagoutpay.com/ms-transaction-core-1-0/apiRedirection/apiIntegration');
  print('Headers: Content-Type: application/json');
  print('Body: raw JSON (use the body from step 3 above)');
  print('');

  print('5. IMPORTANT NOTES:');
  print('==================');
  print('- Disable SSL certificate verification in Postman settings');
  print('- This is for TEST environment only');
  print('- Order ID: $orderNo');
  print('- Amount: $amount');
  print('- Merchant ID: ${YagoutPayConfig.apiMerchantId}');
  print('');

  print('✅ Ready to test in Postman!');
}


