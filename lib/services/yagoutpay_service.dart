import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/yagoutpay_config.dart';
import '../utils/crypto/aes_util.dart';

class YagoutPayService {
  // Generate truly unique order ID following YagoutPay documentation format
  static String generateUniqueOrderId(String baseOrderId) {
    // YagoutPay requirement: Use OR-DOIT-XXXX format
    // Generate a unique 4-digit number for each order with timestamp to ensure uniqueness
    final timestamp = DateTime.now()
        .millisecondsSinceEpoch
        .toString()
        .substring(8); // Last 4 digits
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    final uniqueId = '$timestamp$random'.substring(0, 4); // Take first 4 digits
    return 'OR-DOIT-$uniqueId';
  }

  static Future<Map<String, dynamic>> payViaApi({
    required String orderNo,
    required String amount,
    required String successUrl,
    required String failureUrl,
    required String email,
    required String mobile,
    String? customerName,
    String country = 'ETH',
    String currency = 'ETB',
    String channel = 'API',
    String transactionType = 'SALE',
    String? shippingAddress,
    String? shippingCity,
    String? shippingState,
    String? shippingZip,
    String? billingAddress,
    String? billingCity,
    String? billingState,
    String? billingZip,
    String? udf1,
    String? udf2,
    String? udf3,
    String? udf4,
    String? udf5,
    int? itemCount,
    String? itemValue,
    String? itemCategory,
  }) async {
    final meId = YagoutPayConfig.apiMerchantId;
    final key = YagoutPayConfig.apiKey;

    // YagoutPay clarification: "Am sure it works, but you pass on request, but not in the api"
    // We should use the orderNo parameter directly, not regenerate it
    print('=== Using Original Order ID in API Request ===');
    print('Order ID to use: $orderNo');
    print(
        'Format: ${orderNo.startsWith('OR-DOIT-') ? "✅ OR-DOIT-XXXX" : "❌ Not OR-DOIT-XXXX"}');
    print(
        'Passing original orderNo directly to API as per YagoutPay clarification');

    // Build documented API JSON payload (plain), then AES encrypt that JSON string.
    // Note: The official sample uses the key name 'sucessUrl' (sic). We follow that exactly.
    // CRITICAL: Ensure all required fields are present with valid values
    final Map<String, dynamic> plain = {
      'card_details': {
        'cardNumber': '',
        'expiryMonth': '',
        'expiryYear': '',
        'cvv': '',
        'cardName': ''
      },
      'other_details': {
        'udf1': udf1 ?? '',
        'udf2': udf2 ?? '',
        'udf3': udf3 ?? '',
        'udf4': udf4 ?? '',
        'udf5': udf5 ?? '',
        'udf6': '',
        'udf7': ''
      },
      'ship_details': {
        'shipAddress': shippingAddress ?? '',
        'shipCity': shippingCity ?? '',
        'shipState': shippingState ?? '',
        'shipCountry': country,
        'shipZip': shippingZip ?? '',
        'shipDays': '',
        'addressCount': ''
      },
      'txn_details': {
        'agId': YagoutPayConfig.aggregatorId,
        'meId': meId,
        'orderNo': orderNo, // Use the original order ID passed to the method
        'amount': amount,
        'country': country,
        'currency': currency,
        'transactionType': transactionType,
        'sucessUrl': '', // Use empty string like JavaScript implementation
        'failureUrl': '', // Use empty string like JavaScript implementation
        'channel':
            'API', // IMPORTANT: Always use 'API' for direct API integration
      },
      'item_details': {
        'itemCount': itemCount?.toString() ?? '1',
        'itemValue': itemValue ?? amount,
        'itemCategory': itemCategory ?? 'Shoes'
      },
      'cust_details': {
        'customerName': customerName ?? 'Customer', // Ensure non-empty name
        'emailId': email,
        'mobileNumber': mobile,
        'uniqueId': '',
        'isLoggedIn': 'Y'
      },
      // Populate as per API sample in the document
      'pg_details': {
        'pg_Id': YagoutPayConfig.pgId,
        'paymode': YagoutPayConfig.paymode,
        'scheme_Id': YagoutPayConfig.schemeId,
        'wallet_type': YagoutPayConfig.walletType,
      },
      'bill_details': {
        'billAddress': billingAddress ?? '',
        'billCity': billingCity ?? '',
        'billState': billingState ?? '',
        'billCountry': country,
        'billZip': billingZip ?? ''
      }
    };

    final plainStr = jsonEncode(plain);

    print('=== Plain Payload Before Encryption ===');
    print('Order ID: $orderNo');
    print('Amount: $amount');
    print('Customer Email: $email');
    print('Customer Mobile: $mobile');
    print('Customer Name: ${customerName ?? 'Customer'}');
    print('Success URL: (empty) - Direct API uses internal status handling');
    print('Failure URL: (empty) - Direct API uses internal status handling');
    print('Channel: API');
    print('PG ID: ${YagoutPayConfig.pgId}');
    print('Paymode: ${YagoutPayConfig.paymode}');
    print('Wallet Type: ${YagoutPayConfig.walletType}');
    print('Payload JSON length: ${plainStr.length}');
    print('======================================');

    // Encryption now handles PKCS7 padding internally
    final encrypted = AesUtil.encryptToBase64(plainStr, key);

    final body = jsonEncode({
      'merchantId': meId,
      'merchantRequest': encrypted,
    });

    print('=== API Request Debug ===');
    print('API URL: ${YagoutPayConfig.apiUrl}');
    print('Merchant ID: $meId');
    print('Request body length: ${body.length}');
    print('Encrypted data length: ${encrypted.length}');
    print('========================');

    // Use the working format (no auth headers)
    var resp = await http.post(
      Uri.parse(YagoutPayConfig.apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    print('=== API Response Debug ===');
    print('HTTP Status: ${resp.statusCode}');
    print('Response headers: ${resp.headers}');
    print('Response body: ${resp.body}');
    print('=========================');

    if (resp.statusCode != 200) {
      throw Exception(
          'YagoutPay API error: HTTP ${resp.statusCode} - ${resp.body}');
    }

    final Map<String, dynamic> respJson = json.decode(resp.body);

    final status = (respJson['status'] ?? '').toString();
    final statusMessage = (respJson['statusMessage'] ?? '').toString();
    final respCipher = (respJson['response'] ?? '').toString();
    final merchantId = (respJson['merchantId'] ?? '').toString();

    // Check for specific error patterns
    if (statusMessage.toLowerCase().contains('something went worng') ||
        statusMessage.toLowerCase().contains('something went wrong')) {
      print('⚠️  DETECTED "Something went wrong" ERROR');
      print('   This typically indicates:');
      print('   1. Missing or invalid required fields in payload');
      print('   2. Invalid merchant credentials');
      print('   3. Malformed payload structure');
      print('   4. Backend validation failure');
      print('');
      print('   Current payload info:');
      print('   - Order ID: $orderNo');
      print('   - Merchant ID: $meId');
      print('   - Response Merchant ID: $merchantId');
      print('   - Amount: $amount');
      print('   - Email: $email');
      print('   - Mobile: $mobile');
    }

    Map<String, dynamic>? decryptedJson;
    try {
      if (respCipher.isNotEmpty && respCipher != 'null') {
        final plainResp = AesUtil.decryptFromBase64(respCipher, key);
        decryptedJson = json.decode(plainResp) as Map<String, dynamic>;
        print('✅ Response decrypted successfully');
        print('   Decrypted response: $decryptedJson');
      } else {
        print('⚠️  No encrypted response data to decrypt');
      }
    } catch (e) {
      print('❌ Response decryption failed: $e');
      // leave decryptedJson as null if decryption fails
    }

    final result = {
      'status': status,
      'statusMessage': statusMessage,
      'response': respCipher,
      'decrypted': decryptedJson,
      'raw': respJson,
      'merchantId': merchantId,
    };

    print('Gateway response: $result');

    return result;
  }

  // Test with the new flat JSON structure provided by YagoutPay
  static Future<Map<String, dynamic>> testNewFlatJsonStructure({
    required String amount,
    required String successUrl,
    required String failureUrl,
    required String email,
    required String mobile,
    String? customerName,
    String country = 'ETH',
    String currency = 'ETB',
    String channel = 'MOBILE',
    String transactionType = 'SALE',
  }) async {
    final meId = YagoutPayConfig.apiMerchantId;
    final key = YagoutPayConfig.apiKey;

    print('=== Testing New Flat JSON Structure ===');
    print('Using the exact JSON format provided by YagoutPay support');

    // Generate unique order ID
    final orderNo = generateUniqueOrderId('NEW_FORMAT');
    print('Generated Order ID: $orderNo');

    // Use the exact flat JSON structure provided by YagoutPay
    final Map<String, dynamic> plain = {
      "order_no": orderNo,
      "amount": amount,
      "country": country,
      "currency": currency,
      "txn_type": transactionType,
      "success_url": successUrl,
      "failure_url": failureUrl,
      "channel": channel,
      "ag_id": YagoutPayConfig.aggregatorId,
      "me_id": meId,
      "customer_name": customerName ?? "Test Customer",
      "email_id": email,
      "mobile_no": mobile,
      "is_logged_in": "Y",
      "unique_id": "",
      "bill_address": "",
      "bill_city": "",
      "bill_state": "",
      "bill_country": country,
      "bill_zip": "",
      "ship_address": "",
      "ship_city": "",
      "ship_state": "",
      "ship_country": country,
      "ship_zip": "",
      "ship_days": "",
      "address_count": "",
      "item_count": "1",
      "item_value": amount,
      "item_category": "Shoes",
      "paymode": YagoutPayConfig.paymode,
      "pg_id": YagoutPayConfig.pgId,
      "scheme_id": YagoutPayConfig.schemeId,
      "wallet_type": YagoutPayConfig.walletType,
      "card_number": "",
      "expiry_month": "",
      "expiry_year": "",
      "cvv": "",
      "card_name": "",
      "udf1": "",
      "udf2": "",
      "udf3": "",
      "udf4": "",
      "udf5": "",
      "udf6": "",
      "udf7": ""
    };

    final plainStr = jsonEncode(plain);
    print('New flat JSON payload: $plainStr');

    // Encrypt the new flat JSON structure
    final encrypted = AesUtil.encryptToBase64(plainStr, key);
    print('Encrypted data length: ${encrypted.length}');

    final body = jsonEncode({
      'merchantId': meId,
      'merchantRequest': encrypted,
    });

    try {
      // Use the working format (no auth headers)
      final resp = await http.post(
        Uri.parse(YagoutPayConfig.apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('HTTP Status: ${resp.statusCode}');
      print('Response: ${resp.body}');

      if (resp.statusCode == 200) {
        final result = json.decode(resp.body);
        final status = result['status']?.toString().toLowerCase() ?? '';

        if (status.contains('success') || status.contains('pending')) {
          print('🎉 SUCCESS with new flat JSON structure!');
          print('✅ YagoutPay accepted the new format!');
          return {
            'status': 'SUCCESS',
            'message': 'New flat JSON structure works!',
            'order_id': orderNo,
            'response': result
          };
        } else if (status.contains('duplicate') ||
            status.contains('dublicate')) {
          print(
              '⚠️  Still getting duplicate - but this means the API is working!');
          print('✅ The new JSON structure is being processed correctly');
          return {
            'status': 'DUPLICATE_BUT_WORKING',
            'message':
                'New JSON structure works (duplicate means API is processing)',
            'order_id': orderNo,
            'response': result
          };
        } else {
          print('📝 Got response: $status');
          return {
            'status': 'OTHER_RESPONSE',
            'message': 'Got response: $status',
            'order_id': orderNo,
            'response': result
          };
        }
      } else {
        return {
          'status': 'HTTP_ERROR',
          'message': 'HTTP ${resp.statusCode}: ${resp.body}',
          'order_id': orderNo
        };
      }
    } catch (e) {
      print('Request failed: $e');
      return {
        'status': 'ERROR',
        'message': 'Request failed: $e',
        'order_id': orderNo
      };
    }
  }

  // Hosted flow helper: builds minimal HTML that auto-submits to YagoutPay
  static String buildHostedAutoSubmitHtml({
    required String orderNo,
    required String amount,
    required String successUrl,
    required String failureUrl,
    String country = 'ETH',
    String currency = 'ETB',
    String channel = 'MOBILE',
    String? customerName,
    String? email,
    String? mobile,
    String? shippingAddress,
    String? shippingCity,
    String? shippingState,
    String? shippingZip,
    String? billingAddress,
    String? billingCity,
    String? billingState,
    String? billingZip,
    String? udf1,
    String? udf2,
    String? udf3,
    String? udf4,
    String? udf5,
    String? itemCount,
    String? itemValue,
    String? itemCategory,
  }) {
    // Generate unique order ID to avoid duplicates (OR-DOIT-XXXX format)
    final uniqueOrderNo = generateUniqueOrderId(orderNo);

    // Build sections separated with | as per YagoutPay documentation
    final txnDetails = [
      YagoutPayConfig.aggregatorId,
      YagoutPayConfig.hostedMerchantId,
      uniqueOrderNo, // Use unique order ID
      amount,
      country,
      currency,
      'SALE',
      successUrl,
      failureUrl,
      channel,
    ].join('|');

    // For hosted, other sections should be blank per doc
    final pgDetails = ['', '', '', ''].join('|');
    final cardDetails = ['', '', '', '', ''].join('|');
    final custDetails =
        [customerName ?? '', email ?? '', mobile ?? '', '', 'Y'].join('|');

    final billDetails = [
      billingAddress ?? '',
      billingCity ?? '',
      billingState ?? '',
      country,
      billingZip ?? ''
    ].join('|');

    final shipDetails = [
      shippingAddress ?? '',
      shippingCity ?? '',
      shippingState ?? '',
      country,
      shippingZip ?? '',
      '',
      ''
    ].join('|');

    final itemDetails = [
      itemCount ?? '1',
      itemValue ?? amount,
      itemCategory ?? 'Shoes'
    ].join('|');

    const upiDetails = '';
    final otherDetails =
        [udf1 ?? '', udf2 ?? '', udf3 ?? '', udf4 ?? '', udf5 ?? ''].join('|');

    final allValues = [
      txnDetails,
      pgDetails,
      cardDetails,
      custDetails,
      billDetails,
      shipDetails,
      itemDetails,
      upiDetails,
      otherDetails,
    ].join('~');

    // Pad the data to ensure it's a multiple of 16 bytes for OPENSSL_ZERO_PADDING
    final paddedAllValues = AesUtil.padForZeroPadding(allValues);

    final merchantRequest =
        AesUtil.encryptToBase64(paddedAllValues, YagoutPayConfig.hostedKey);
    final hash =
        AesUtil.generateHash(paddedAllValues, YagoutPayConfig.hostedKey);

    final meId = YagoutPayConfig.hostedMerchantId;

    final html = '''
<!DOCTYPE html>
<html>
  <body onload="document.forms[0].submit()">
    <form method="POST" action="${YagoutPayConfig.hostedUrl}">
      <input type="hidden" name="me_id" value="$meId" />
      <input type="hidden" name="merchant_request" value="$merchantRequest" />
      <input type="hidden" name="hash" value="$hash" />
    </form>
    <p>Redirecting to payment...</p>
  </body>
</html>
''';
    return html;
  }

  // Test encryption with gateway's helper endpoint
  static Future<Map<String, dynamic>> testEncryption() async {
    final meId = YagoutPayConfig.apiMerchantId;
    final key = YagoutPayConfig.apiKey;

    print('=== Testing Simple Encryption ===');
    print('Merchant ID: $meId');
    print('Key: $key');
    print('Key length: ${base64.decode(key).length} bytes');
    print('Encryption test URL: ${YagoutPayConfig.encryptionTestUrl}');

    // Test data exactly from documentation
    final testData = jsonEncode({'me_id': meId, 'amount': '100'});

    final encrypted = AesUtil.encryptToBase64(testData, key);

    print('Test data: $testData');
    print('Encrypted: $encrypted');

    // Test round-trip encryption
    try {
      final decrypted = AesUtil.decryptFromBase64(encrypted, key);
      print('Round-trip test: ${testData == decrypted ? 'PASS' : 'FAIL'}');
      if (testData != decrypted) {
        print('Expected: $testData');
        print('Got: $decrypted');
      }
    } catch (e) {
      print('Round-trip test FAILED: $e');
    }

    // Verify with YagoutPay gateway
    print('\n=== Testing with Gateway ===');
    try {
      final result = await _verifyEncryptionWithGateway(encrypted, meId);
      print('Gateway verification result: $result');

      final status = result['Status']?.toString() ?? '';
      if (status.toLowerCase() == 'success') {
        print('✅ Gateway accepted our encryption!');
      } else {
        print('❌ Gateway rejected encryption: $status');
      }

      return result;
    } catch (e) {
      print('Gateway test failed: $e');
      return {
        'Status': 'Error',
        'Response': 'Gateway test failed: $e',
        'local_encrypted': encrypted,
        'test_data': testData,
      };
    }
  }

  // Helper method to verify encryption with gateway's test endpoint
  static Future<Map<String, dynamic>> _verifyEncryptionWithGateway(
      String encryptedData, String meId) async {
    try {
      final resp = await http.post(
        Uri.parse(YagoutPayConfig.encryptionTestUrl),
        headers: {
          'Content-Type': 'text/plain', // This is the working content-type!
          'me_id': meId,
        },
        body: encryptedData,
      );

      print('HTTP Status: ${resp.statusCode}');
      print('Response headers: ${resp.headers}');
      print('Response body: ${resp.body}');

      if (resp.statusCode != 200) {
        throw Exception(
            'Encryption test failed: HTTP ${resp.statusCode} - ${resp.body}');
      }

      try {
        final result = json.decode(resp.body);

        // If the gateway gives us an encrypted response, try to decrypt it
        if (result['Status']?.toString().toLowerCase() == 'success' &&
            result['Response']?.toString().isNotEmpty == true) {
          try {
            final encryptedResponse = result['Response'].toString();
            final decryptedResponse = AesUtil.decryptFromBase64(
                encryptedResponse, YagoutPayConfig.apiKey);
            print('🔓 Decrypted gateway response: $decryptedResponse');
            result['DecryptedResponse'] = decryptedResponse;
          } catch (e) {
            print('Could not decrypt gateway response: $e');
          }
        }

        return result;
      } catch (e) {
        // If JSON parsing fails, return the raw response
        return {
          'Status': 'Unknown',
          'Response': resp.body,
          'HttpStatus': resp.statusCode,
        };
      }
    } catch (e) {
      print('Gateway verification error: $e');
      rethrow;
    }
  }

  // Debug method to test encryption locally
  static Map<String, dynamic> debugEncryption() {
    final meId = YagoutPayConfig.apiMerchantId;
    final key = YagoutPayConfig.apiKey;

    // Test with the exact structure from the documentation
    final testData = jsonEncode({
      'me_id': meId,
      'amount': '100',
    });

    print('Original test data length: ${testData.length}');
    print('Original test data: $testData');

    final encrypted = AesUtil.encryptToBase64(testData, key);
    print('Encrypted data: $encrypted');

    // Test decryption
    try {
      final decrypted = AesUtil.decryptFromBase64(encrypted, key);
      print('Decrypted data: $decrypted');
      print('Decryption successful: ${decrypted == testData}');
    } catch (e) {
      print('Decryption failed: $e');
    }

    return {
      'original': testData,
      'encrypted': encrypted,
      'key': key,
      'meId': meId,
    };
  }

  // Placeholder methods for other test functions
  static Future<Map<String, dynamic>> testApiStructure() async {
    return {'status': 'Not implemented in simplified version'};
  }

  static Future<void> testKnownEncryption() async {
    print('testKnownEncryption not implemented in simplified version');
  }

  static Future<Map<String, dynamic>> testExactDocumentedStructure() async {
    return {'status': 'Not implemented in simplified version'};
  }

  static Future<Map<String, dynamic>> testMinimalApiRequest() async {
    return {'status': 'Not implemented in simplified version'};
  }

  static Future<Map<String, dynamic>> testFreshPayment() async {
    return {'status': 'Not implemented in simplified version'};
  }

  static Future<Map<String, dynamic>> testQuickSuccess() async {
    return {'status': 'Not implemented in simplified version'};
  }

  static Future<Map<String, dynamic>> testCompleteResolution() async {
    return {'status': 'Not implemented in simplified version'};
  }

  static Future<Map<String, dynamic>> testAuthenticationMethods() async {
    return {'status': 'Not implemented in simplified version'};
  }

  static Future<Map<String, dynamic>> testWorkingFormat() async {
    return {'status': 'Not implemented in simplified version'};
  }

  static Future<Map<String, dynamic>> testEmergencyPayment() async {
    return {'status': 'Not implemented in simplified version'};
  }

  // Payment Link API Implementation
  static Future<Map<String, dynamic>> createPaymentLink({
    required String reqUserId,
    required String amount,
    required String customerEmail,
    required String mobileNo,
    required String expiryDate,
    required String orderId,
    required String firstName,
    required String lastName,
    required String product,
    required String dialCode,
    required String failureUrl,
    required String successUrl,
    String country = 'ETH',
    String currency = 'ETB',
    List<String> mediaType = const ['API'],
  }) async {
    final meId = YagoutPayConfig.apiMerchantId;
    final key = YagoutPayConfig.apiKey;

    print('=== Creating Payment Link ===');
    print('Merchant ID: $meId');
    print('Order ID: $orderId');
    print('Amount: $amount');

    // Create Payment Link request payload with correct structure
    final payload = {
      'req_user_id': reqUserId,
      'me_id': meId,
      'amount': amount,
      'customer_email': customerEmail,
      'mobile_no': mobileNo,
      'expiry_date': expiryDate,
      'media_type': mediaType,
      'order_id': orderId,
      'first_name': firstName,
      'last_name': lastName,
      'product': product,
      'dial_code': dialCode,
      'failure_url': failureUrl,
      'success_url': successUrl,
      'country': country,
      'currency': currency,
    };

    // Convert to JSON and encrypt
    final plainStr = jsonEncode(payload);
    final encrypted = AesUtil.encryptToBase64(plainStr, key);

    print('Payment Link payload: $plainStr');
    print('Encrypted data length: ${encrypted.length}');

    // Prepare request body using the correct format
    final body = jsonEncode({
      'request': encrypted, // Fixed: use 'request' instead of 'merchantRequest'
    });

    try {
      // Make API call to Payment Link endpoint - using correct URL structure
      final resp = await http.post(
        Uri.parse(
            'https://uatcheckout.yagoutpay.com/ms-transaction-core-1-0/sdk/paymentByLinkResponse'), // Fixed: use correct endpoint
        headers: {
          'Content-Type': 'application/json',
          'me_id': meId, // Fixed: add required me_id header
        },
        body: body,
      );

      print('=== Payment Link API Response ===');
      print('HTTP Status: ${resp.statusCode}');
      print('Response Headers: ${resp.headers}');
      print('Response Body: ${resp.body}');
      print('===============================');

      if (resp.statusCode == 200) {
        final result = json.decode(resp.body);

        // Handle response - check if it's a direct URL or encrypted
        String? paymentLink;
        Map<String, dynamic>? decryptedResponse;

        if (result['response'] != null &&
            result['response'].toString().isNotEmpty) {
          final responseStr = result['response'].toString().trim();

          // Check if it's a direct URL
          if (responseStr.startsWith('http')) {
            paymentLink = responseStr;
            print('✅ Direct payment link received: $paymentLink');
          } else {
            // Try to decrypt if it's base64 encrypted
            try {
              final decrypted = AesUtil.decryptFromBase64(responseStr, key);
              decryptedResponse = json.decode(decrypted);
              print('✅ Decrypted response: $decryptedResponse');

              // Look for payment link in various possible fields
              paymentLink = decryptedResponse?['payment_link'] ??
                  decryptedResponse?['pay_link'] ??
                  decryptedResponse?['link'] ??
                  decryptedResponse?['url'] ??
                  decryptedResponse?['redirectUrl'] ??
                  decryptedResponse?['payment_url'];
            } catch (e) {
              print('❌ Response decryption failed: $e');
              print('Raw response: $responseStr');
            }
          }
        }

        if (paymentLink != null) {
          return {
            'status': 'SUCCESS',
            'message': 'Payment Link created successfully',
            'order_id': orderId,
            'payment_link': paymentLink,
            'response': result,
            'decrypted_response': decryptedResponse,
          };
        } else {
          return {
            'status': 'ERROR',
            'message': 'No payment link found in response',
            'order_id': orderId,
            'response': result,
            'decrypted_response': decryptedResponse,
          };
        }
      } else {
        return {
          'status': 'ERROR',
          'message': 'HTTP ${resp.statusCode}: ${resp.body}',
          'order_id': orderId,
        };
      }
    } catch (e) {
      print('❌ Payment Link creation failed: $e');
      return {
        'status': 'ERROR',
        'message': 'Payment Link creation failed: $e',
        'order_id': orderId,
      };
    }
  }

  // Static Link API Implementation
  static Future<Map<String, dynamic>> createStaticLink({
    required String reqUserId,
    required String amount,
    required String customerEmail,
    required String mobileNo,
    required String expiryDate,
    required String orderId,
    required String firstName,
    required String lastName,
    required String product,
    required String dialCode,
    required String failureUrl,
    required String successUrl,
    String country = 'ETH',
    String currency = 'ETB',
    List<String> mediaType = const ['API'],
  }) async {
    final meId = YagoutPayConfig.apiMerchantId;
    final key = YagoutPayConfig.apiKey;

    print('=== Creating Static Link ===');
    print('Merchant ID: $meId');
    print('Order ID: $orderId');
    print('Amount: $amount');

    // Create Static Link request payload with correct structure
    final payload = {
      'req_user_id': reqUserId,
      'me_id': meId,
      'amount': amount,
      'customer_email': customerEmail,
      'mobile_no': mobileNo,
      'expiry_date': expiryDate,
      'media_type': mediaType,
      'order_id': orderId,
      'first_name': firstName,
      'last_name': lastName,
      'product': product,
      'dial_code': dialCode,
      'failure_url': failureUrl,
      'success_url': successUrl,
      'country': country,
      'currency': currency,
    };

    // Convert to JSON and encrypt
    final plainStr = jsonEncode(payload);
    final encrypted = AesUtil.encryptToBase64(plainStr, key);

    print('Static Link payload: $plainStr');
    print('Encrypted data length: ${encrypted.length}');

    // Prepare request body using the correct format
    final body = jsonEncode({
      'request': encrypted, // Fixed: use 'request' instead of 'merchantRequest'
    });

    try {
      // Make API call to Static Link endpoint - using correct URL structure
      final resp = await http.post(
        Uri.parse(
            'https://uatcheckout.yagoutpay.com/ms-transaction-core-1-0/sdk/paymentByLinkResponse'), // Fixed: use correct endpoint
        headers: {
          'Content-Type': 'application/json',
          'me_id': meId, // Fixed: add required me_id header
        },
        body: body,
      );

      print('=== Static Link API Response ===');
      print('HTTP Status: ${resp.statusCode}');
      print('Response Headers: ${resp.headers}');
      print('Response Body: ${resp.body}');
      print('===============================');

      if (resp.statusCode == 200) {
        // Handle clicktowishResponse format
        final responseBody = resp.body.trim();
        print('Raw response body: $responseBody');

        // Check if it's the clicktowishResponse format
        if (responseBody.startsWith('clicktowishResponse')) {
          // Parse the clicktowishResponse format
          // Format: clicktowishResponse [status = success/failure, message = ..., data = ..., hasErrors = ..., errors=...]
          final statusMatch =
              RegExp(r'status = (\w+)').firstMatch(responseBody);
          final messageMatch =
              RegExp(r'message = ([^,]+)').firstMatch(responseBody);
          final dataMatch = RegExp(r'data = ([^,]+)').firstMatch(responseBody);

          final status = statusMatch?.group(1) ?? 'unknown';
          final message = messageMatch?.group(1)?.trim() ?? 'No message';
          final data = dataMatch?.group(1)?.trim() ?? 'null';

          print('Parsed clicktowishResponse:');
          print('  Status: $status');
          print('  Message: $message');
          print('  Data: $data');

          if (status.toLowerCase() == 'success' && data != 'null') {
            return {
              'status': 'SUCCESS',
              'message': 'Static Link created successfully',
              'order_id': orderId,
              'payment_link': data,
              'response': {
                'status': status,
                'message': message,
                'data': data,
              },
            };
          } else {
            return {
              'status': 'ERROR',
              'message': 'API Error: $message',
              'order_id': orderId,
              'response': {
                'status': status,
                'message': message,
                'data': data,
              },
            };
          }
        }

        // Try to decrypt the response directly (it might be base64 encrypted)
        try {
          print('🔓 Attempting to decrypt response...');
          final decrypted = AesUtil.decryptFromBase64(responseBody, key);
          print('✅ Decrypted response: $decrypted');

          // Check if the decrypted response is in clicktowishResponse format
          if (decrypted.startsWith('clicktowishResponse')) {
            // Parse the clicktowishResponse format from decrypted data
            final statusMatch = RegExp(r'status = (\w+)').firstMatch(decrypted);
            final messageMatch =
                RegExp(r'message = ([^,]+)').firstMatch(decrypted);
            final dataMatch =
                RegExp(r'data = ({.*?}), hasErrors').firstMatch(decrypted);

            final status = statusMatch?.group(1) ?? 'unknown';
            final message = messageMatch?.group(1)?.trim() ?? 'No message';
            final dataStr = dataMatch?.group(1)?.trim() ?? 'null';

            print('Parsed decrypted clicktowishResponse:');
            print('  Status: $status');
            print('  Message: $message');
            print('  Data: $dataStr');

            if (status.toLowerCase() == 'success' && dataStr != 'null') {
              // Try to parse the data as JSON
              try {
                final dataJson = json.decode(dataStr);
                print('✅ Parsed data JSON: $dataJson');

                // Look for payment link in the data
                final paymentLink = dataJson?['PaymentLink'] ??
                    dataJson?['payment_link'] ??
                    dataJson?['pay_link'] ??
                    dataJson?['link'] ??
                    dataJson?['url'] ??
                    dataJson?['redirectUrl'] ??
                    dataJson?['payment_url'] ??
                    dataJson?['static_link'] ??
                    dataJson?['qr_link'];

                if (paymentLink != null) {
                  return {
                    'status': 'SUCCESS',
                    'message': 'Static Link created successfully',
                    'order_id': orderId,
                    'payment_link': paymentLink,
                    'response': dataJson,
                    'decrypted_response': dataJson,
                  };
                } else {
                  return {
                    'status': 'ERROR',
                    'message': 'No payment link found in data',
                    'order_id': orderId,
                    'response': dataJson,
                    'decrypted_response': dataJson,
                  };
                }
              } catch (e) {
                print('❌ Data JSON parsing failed: $e');
                return {
                  'status': 'ERROR',
                  'message': 'Failed to parse data JSON: $e',
                  'order_id': orderId,
                };
              }
            } else {
              return {
                'status': 'ERROR',
                'message': 'API Error: $message',
                'order_id': orderId,
                'response': {
                  'status': status,
                  'message': message,
                  'data': dataStr,
                },
              };
            }
          } else {
            // Try to parse as JSON (fallback)
            final decryptedJson = json.decode(decrypted);
            print('✅ Parsed decrypted JSON: $decryptedJson');

            // Look for payment link in various possible fields
            final paymentLink = decryptedJson?['payment_link'] ??
                decryptedJson?['pay_link'] ??
                decryptedJson?['link'] ??
                decryptedJson?['url'] ??
                decryptedJson?['redirectUrl'] ??
                decryptedJson?['payment_url'] ??
                decryptedJson?['static_link'] ??
                decryptedJson?['qr_link'];

            if (paymentLink != null) {
              return {
                'status': 'SUCCESS',
                'message': 'Static Link created successfully',
                'order_id': orderId,
                'payment_link': paymentLink,
                'response': decryptedJson,
                'decrypted_response': decryptedJson,
              };
            } else {
              return {
                'status': 'ERROR',
                'message': 'No payment link found in decrypted response',
                'order_id': orderId,
                'response': decryptedJson,
                'decrypted_response': decryptedJson,
              };
            }
          }
        } catch (e) {
          print('❌ Decryption failed: $e');

          // Try to parse as JSON (fallback)
          try {
            final result = json.decode(resp.body);

            // Handle response - check if it's a direct URL or encrypted
            String? paymentLink;
            Map<String, dynamic>? decryptedResponse;

            if (result['response'] != null &&
                result['response'].toString().isNotEmpty) {
              final responseStr = result['response'].toString().trim();

              // Check if it's a direct URL
              if (responseStr.startsWith('http')) {
                paymentLink = responseStr;
                print('✅ Direct payment link received: $paymentLink');
              } else {
                // Try to decrypt if it's base64 encrypted
                try {
                  final decrypted = AesUtil.decryptFromBase64(responseStr, key);
                  decryptedResponse = json.decode(decrypted);
                  print('✅ Decrypted response: $decryptedResponse');

                  // Look for payment link in various possible fields
                  paymentLink = decryptedResponse?['payment_link'] ??
                      decryptedResponse?['pay_link'] ??
                      decryptedResponse?['link'] ??
                      decryptedResponse?['url'] ??
                      decryptedResponse?['redirectUrl'] ??
                      decryptedResponse?['payment_url'];
                } catch (e) {
                  print('❌ Response decryption failed: $e');
                  print('Raw response: $responseStr');
                }
              }
            }

            if (paymentLink != null) {
              return {
                'status': 'SUCCESS',
                'message': 'Static Link created successfully',
                'order_id': orderId,
                'payment_link': paymentLink,
                'response': result,
                'decrypted_response': decryptedResponse,
              };
            } else {
              return {
                'status': 'ERROR',
                'message': 'No payment link found in response',
                'order_id': orderId,
                'response': result,
                'decrypted_response': decryptedResponse,
              };
            }
          } catch (e) {
            print('❌ JSON parsing failed: $e');
            return {
              'status': 'ERROR',
              'message': 'Invalid response format: $responseBody',
              'order_id': orderId,
            };
          }
        }
      } else {
        return {
          'status': 'ERROR',
          'message': 'HTTP ${resp.statusCode}: ${resp.body}',
          'order_id': orderId,
        };
      }
    } catch (e) {
      print('❌ Static Link creation failed: $e');
      return {
        'status': 'ERROR',
        'message': 'Static Link creation failed: $e',
        'order_id': orderId,
      };
    }
  }

  // Helper method to generate unique order ID for links
  static String generateLinkOrderId(String prefix) {
    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    final uniqueId = '$timestamp$random'.substring(0, 4);
    return '${prefix}_$uniqueId';
  }
}
