import 'lib/services/yagoutpay_service.dart';
import 'lib/utils/crypto/aes_util.dart';
import 'lib/config/yagoutpay_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== TESTING ORIGINAL NESTED STRUCTURE ===');
  print('Testing if the original nested JSON structure works with the main API');
  print('');

  final meId = YagoutPayConfig.apiMerchantId;
  final key = YagoutPayConfig.apiKey;

  // Test with the original nested structure that was working before
  print('=== Testing Original Nested Structure ===');
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
  print('Nested JSON data: $nestedJsonString');
  print('Nested JSON length: ${nestedJsonString.length} characters');
  
  try {
    final nestedEncrypted = AesUtil.encryptToBase64(nestedJsonString, key);
    print('Nested JSON encrypted: $nestedEncrypted');
    print('Encrypted length: ${nestedEncrypted.length} characters');
    
    // Test round-trip
    final nestedDecrypted = AesUtil.decryptFromBase64(nestedEncrypted, key);
    print('Nested JSON decrypted: $nestedDecrypted');
    print('Round-trip success: ${nestedJsonString == nestedDecrypted}');
    
    print('');
    print('=== Testing with Main API ===');
    
    final body = jsonEncode({
      'merchantId': meId,
      'merchantRequest': nestedEncrypted,
    });
    
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
        print('🎉 SUCCESS! Original nested structure works!');
      } else if (status.contains('duplicate') || status.contains('dublicate')) {
        print('✅ API is working (duplicate means processing)');
        print('✅ Original nested structure is being processed correctly');
      } else if (status.contains('invalid encryption')) {
        print('❌ Still getting Invalid Encryption with nested structure');
      } else {
        print('📝 Got response: $status');
      }
    }
    
  } catch (e) {
    print('Nested structure test failed: $e');
  }

  print('');
  print('=== Summary ===');
  print('If the nested structure works, we should revert to it.');
  print('If it still fails, the issue might be with the API endpoint or keys.');
}
