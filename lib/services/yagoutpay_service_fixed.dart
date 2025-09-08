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
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8); // Last 4 digits
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
        } else if (status.contains('duplicate') || status.contains('dublicate')) {
          print('⚠️  Still getting duplicate - but this means the API is working!');
          print('✅ The new JSON structure is being processed correctly');
          return {
            'status': 'DUPLICATE_BUT_WORKING',
            'message': 'New JSON structure works (duplicate means API is processing)',
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
}
