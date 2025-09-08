import 'lib/services/yagoutpay_service.dart';
import 'lib/utils/crypto/aes_util.dart';
import 'lib/config/yagoutpay_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('=== MAIN API FIX TEST ===');
  print('Testing different request formats to fix the "Invalid Encryption" error');
  print('');

  final meId = YagoutPayConfig.apiMerchantId;
  final key = YagoutPayConfig.apiKey;

  // Test 1: Use the exact same format that works with encryption test endpoint
  print('=== Test 1: Simple Format (like encryption test) ===');
  final simpleData = jsonEncode({'me_id': meId, 'amount': '100'});
  final simpleEncrypted = AesUtil.encryptToBase64(simpleData, key);
  
  print('Simple data: $simpleData');
  print('Simple encrypted: $simpleEncrypted');
  
  try {
    // Try sending just the encrypted data directly (like encryption test endpoint)
    final resp1 = await http.post(
      Uri.parse(YagoutPayConfig.apiUrl),
      headers: {
        'Content-Type': 'text/plain',
        'me_id': meId,
      },
      body: simpleEncrypted,
    );
    
    print('HTTP Status: ${resp1.statusCode}');
    print('Response: ${resp1.body}');
  } catch (e) {
    print('Test 1 failed: $e');
  }

  print('');
  
  // Test 2: Use JSON wrapper with simple data
  print('=== Test 2: JSON Wrapper with Simple Data ===');
  try {
    final body2 = jsonEncode({
      'merchantId': meId,
      'merchantRequest': simpleEncrypted,
    });
    
    final resp2 = await http.post(
      Uri.parse(YagoutPayConfig.apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body2,
    );
    
    print('HTTP Status: ${resp2.statusCode}');
    print('Response: ${resp2.body}');
  } catch (e) {
    print('Test 2 failed: $e');
  }

  print('');
  
  // Test 3: Use the new flat JSON structure
  print('=== Test 3: New Flat JSON Structure ===');
  final flatJsonData = {
    "order_no": "OR-DOIT-1234",
    "amount": "100.00",
    "country": "ETH",
    "currency": "ETB",
    "txn_type": "SALE",
    "success_url": "https://example.com/success",
    "failure_url": "https://example.com/failure",
    "channel": "MOBILE",
    "ag_id": YagoutPayConfig.aggregatorId,
    "me_id": meId,
    "customer_name": "Test Customer",
    "email_id": "test@example.com",
    "mobile_no": "0912345678",
    "is_logged_in": "Y",
    "unique_id": "",
    "bill_address": "",
    "bill_city": "",
    "bill_state": "",
    "bill_country": "ETH",
    "bill_zip": "",
    "ship_address": "",
    "ship_city": "",
    "ship_state": "",
    "ship_country": "ETH",
    "ship_zip": "",
    "ship_days": "",
    "address_count": "",
    "item_count": "1",
    "item_value": "100.00",
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

  final flatJsonString = jsonEncode(flatJsonData);
  final flatEncrypted = AesUtil.encryptToBase64(flatJsonString, key);
  
  try {
    final body3 = jsonEncode({
      'merchantId': meId,
      'merchantRequest': flatEncrypted,
    });
    
    final resp3 = await http.post(
      Uri.parse(YagoutPayConfig.apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body3,
    );
    
    print('HTTP Status: ${resp3.statusCode}');
    print('Response: ${resp3.body}');
  } catch (e) {
    print('Test 3 failed: $e');
  }

  print('');
  
  // Test 4: Try with me_id header
  print('=== Test 4: With me_id Header ===');
  try {
    final body4 = jsonEncode({
      'merchantId': meId,
      'merchantRequest': flatEncrypted,
    });
    
    final resp4 = await http.post(
      Uri.parse(YagoutPayConfig.apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'me_id': meId,
      },
      body: body4,
    );
    
    print('HTTP Status: ${resp4.statusCode}');
    print('Response: ${resp4.body}');
  } catch (e) {
    print('Test 4 failed: $e');
  }

  print('');
  print('=== Summary ===');
  print('Check which test gives a successful response (not "Invalid Encryption")');
  print('The working format should be used in the main API method.');
}
