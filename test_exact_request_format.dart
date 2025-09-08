import 'lib/services/yagoutpay_service.dart';
import 'lib/utils/crypto/aes_util.dart';
import 'lib/config/yagoutpay_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== TESTING EXACT REQUEST FORMAT ===');
  print('Testing the exact same request format that works');
  print('');

  final meId = YagoutPayConfig.apiMerchantId;
  final key = YagoutPayConfig.apiKey;

  // Use the exact same data structure that worked in the previous test
  final nestedData = {
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
      'shipCountry': 'ETH',
      'shipZip': '',
      'shipDays': '',
      'addressCount': ''
    },
    'txn_details': {
      'agId': YagoutPayConfig.aggregatorId,
      'meId': meId,
      'orderNo': 'OR-DOIT-1234',
      'amount': '100.00',
      'country': 'ETH',
      'currency': 'ETB',
      'transactionType': 'SALE',
      'sucessUrl': 'https://example.com/success',
      'failureUrl': 'https://example.com/failure',
      'channel': 'MOBILE',
    },
    'item_details': {
      'itemCount': '1',
      'itemValue': '100.00',
      'itemCategory': 'Shoes'
    },
    'cust_details': {
      'customerName': 'Test Customer',
      'emailId': 'test@example.com',
      'mobileNumber': '0912345678',
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
      'billCountry': 'ETH',
      'billZip': ''
    }
  };

  final nestedJsonString = jsonEncode(nestedData);
  final nestedEncrypted = AesUtil.encryptToBase64(nestedJsonString, key);

  print('Testing with exact same format that worked...');
  print('Order ID: OR-DOIT-1234');
  print('Encrypted length: ${nestedEncrypted.length}');

  // Test with the exact same request format
  final body = jsonEncode({
    'merchantId': meId,
    'merchantRequest': nestedEncrypted,
  });

  try {
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
        print('🎉 SUCCESS! Exact format works!');
      } else if (status.contains('duplicate') || status.contains('dublicate')) {
        print('✅ API is working (duplicate means processing)');
        print('✅ The exact format is being processed correctly');
      } else if (status.contains('invalid encryption')) {
        print('❌ Still getting Invalid Encryption with exact format');
        print(
            'This suggests there might be an issue with the API endpoint or keys');
      } else {
        print('📝 Got response: $status');
      }
    }
  } catch (e) {
    print('Request failed: $e');
  }

  print('');
  print('=== Now testing the main service method ===');

  try {
    final result = await YagoutPayService.payViaApi(
      orderNo: 'OR-DOIT-1234', // Use the same order ID
      amount: "100.00",
      successUrl: "https://example.com/success",
      failureUrl: "https://example.com/failure",
      email: "test@example.com",
      mobile: "0912345678",
      customerName: "Test Customer",
      country: "ETH",
      currency: "ETB",
      channel: "MOBILE",
      transactionType: "SALE",
    );

    print('Main service method result:');
    print('  Status: ${result['status']}');
    print('  Message: ${result['statusMessage']}');

    if (result['status']?.toString().toLowerCase().contains('success') ==
        true) {
      print('  ✅ SUCCESS! Main service method works!');
    } else if (result['status']
            ?.toString()
            .toLowerCase()
            .contains('duplicate') ==
        true) {
      print('  ✅ Main service method is working (duplicate means processing)');
    } else if (result['status']
            ?.toString()
            .toLowerCase()
            .contains('invalid encryption') ==
        true) {
      print('  ❌ Main service method still getting Invalid Encryption');
    } else {
      print('  📝 Main service method response: ${result['status']}');
    }
  } catch (e) {
    print('  ❌ Main service method failed: $e');
  }

  print('');
  print('=== Summary ===');
  print('If both tests work, the integration is fixed.');
  print(
      'If only the direct test works, there might be a difference in the service method.');
}
