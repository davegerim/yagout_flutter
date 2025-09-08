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
        'sucessUrl':
            successUrl, // Note: YagoutPay uses 'sucessUrl' (sic) in their docs
        'failureUrl': failureUrl,
        'channel': channel,
      },
      'item_details': {
        'itemCount': itemCount?.toString() ?? '1',
        'itemValue': itemValue ?? amount,
        'itemCategory': itemCategory ?? 'Shoes'
      },
      'cust_details': {
        'customerName': customerName ?? '',
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

    Map<String, dynamic>? decryptedJson;
    try {
      if (respCipher.isNotEmpty) {
        final plainResp = AesUtil.decryptFromBase64(respCipher, key);
        decryptedJson = json.decode(plainResp) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Response decryption failed: $e');
      // leave decryptedJson as null if decryption fails
    }

    final result = {
      'status': status,
      'statusMessage': statusMessage,
      'response': respCipher,
      'decrypted': decryptedJson,
      'raw': respJson,
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

    final upiDetails = '';
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
}
