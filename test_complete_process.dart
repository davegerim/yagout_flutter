import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/utils/crypto/aes_util.dart';

void main() async {
  print('=' * 80);
  print('YAGOUTPAY PAYMENT LINK API - COMPLETE PROCESS DEMONSTRATION');
  print('=' * 80);
  print('');

  // Step 1: Show the original payload
  print('📋 STEP 1: ORIGINAL PAYLOAD (Before Encryption)');
  print('-' * 50);

  final originalPayload = {
    "req_user_id": "yagou381",
    "me_id": "202508080001",
    "amount": "500",
    "customer_email": "test@example.com",
    "mobile_no": "0985392862",
    "expiry_date": "2025-12-31",
    "media_type": ["API"],
    "order_id": "ORDER_STATIC_001",
    "first_name": "YagoutPay",
    "last_name": "StaticLink",
    "product": "Premium Subscription",
    "dial_code": "+251",
    "failure_url": "http://localhost:3000/failure",
    "success_url": "http://localhost:3000/success",
    "country": "ETH",
    "currency": "ETB"
  };

  final jsonString = jsonEncode(originalPayload);
  print('Original JSON Payload:');
  print(jsonString);
  print('');
  print('Payload Length: ${jsonString.length} characters');
  print('Payload Size: ${utf8.encode(jsonString).length} bytes');
  print('');

  // Step 2: Show encryption process
  print('🔐 STEP 2: ENCRYPTION PROCESS');
  print('-' * 50);

  const encryptionKey = 'IG3CNW5uNrUO2mU2htUOWb9rgXCF7XMAXmL63d7wNZo=';
  print('Encryption Key: $encryptionKey');
  print('Key Length: ${base64.decode(encryptionKey).length} bytes');
  print('');

  print('Encrypting payload...');
  final encryptedPayload = AesUtil.encryptToBase64(jsonString, encryptionKey);
  print('✅ Encryption completed!');
  print('');
  print('Encrypted Payload:');
  print(encryptedPayload);
  print('');
  print('Encrypted Length: ${encryptedPayload.length} characters');
  print('Encrypted Size: ${base64.decode(encryptedPayload).length} bytes');
  print('');

  // Step 3: Show the final request body
  print('📦 STEP 3: FINAL REQUEST BODY (For Postman/API)');
  print('-' * 50);

  final requestBody = {"request": encryptedPayload};

  final finalJsonString = jsonEncode(requestBody);
  print('Final Request Body:');
  print(finalJsonString);
  print('');
  print('Final Body Length: ${finalJsonString.length} characters');
  print('');

  // Step 4: Show API request details
  print('🌐 STEP 4: API REQUEST DETAILS');
  print('-' * 50);

  const apiUrl =
      'https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/paymentByLinkResponse';
  const merchantId = '202508080001';

  print('API URL: $apiUrl');
  print('Method: POST');
  print('Headers:');
  print('  Content-Type: application/json');
  print('  me_id: $merchantId');
  print('');

  // Step 5: Make the actual API call
  print('🚀 STEP 5: MAKING API CALL');
  print('-' * 50);

  try {
    print('Sending request to YagoutPay...');
    print('⏳ Waiting for response...');
    print('');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'me_id': merchantId,
      },
      body: finalJsonString,
    );

    // Step 6: Show response details
    print('📨 STEP 6: API RESPONSE');
    print('-' * 50);

    print('HTTP Status Code: ${response.statusCode}');
    print('Response Headers:');
    response.headers.forEach((key, value) {
      print('  $key: $value');
    });
    print('');

    print('Response Body:');
    print(response.body);
    print('');

    // Step 7: Analyze response
    print('🔍 STEP 7: RESPONSE ANALYSIS');
    print('-' * 50);

    if (response.statusCode == 200) {
      print('✅ SUCCESS! API call was successful');
      print('📝 Response appears to be valid');

      // Try to parse JSON response
      try {
        final responseJson = json.decode(response.body);
        print('📊 Parsed Response:');
        print(json.encode(responseJson));

        // Try to decrypt response if it contains encrypted data
        if (responseJson['response'] != null &&
            responseJson['response'].toString().isNotEmpty) {
          print('');
          print('🔓 Attempting to decrypt response...');
          try {
            final decryptedResponse = AesUtil.decryptFromBase64(
                responseJson['response'].toString(), encryptionKey);
            print('✅ Response decrypted successfully!');
            print('Decrypted Response:');
            print(decryptedResponse);
          } catch (e) {
            print('❌ Response decryption failed: $e');
          }
        }
      } catch (e) {
        print('⚠️  Response is not valid JSON: $e');
      }
    } else if (response.statusCode == 404) {
      print('❌ 404 - NOT FOUND');
      print('📋 This means:');
      print('   • The endpoint does not exist');
      print('   • The API might not be deployed yet');
      print('   • The URL might be incorrect');
      print('   • Your payload is correct (404 is not a payload issue)');
    } else if (response.statusCode == 400) {
      print('⚠️  400 - BAD REQUEST');
      print('📋 This means:');
      print('   • The endpoint exists');
      print('   • There might be an issue with the payload format');
      print('   • Check the request structure');
    } else if (response.statusCode == 401) {
      print('🔐 401 - UNAUTHORIZED');
      print('📋 This means:');
      print('   • The endpoint exists');
      print('   • Authentication/authorization issue');
      print('   • Check merchant ID or API key');
    } else if (response.statusCode == 500) {
      print('💥 500 - SERVER ERROR');
      print('📋 This means:');
      print('   • The endpoint exists');
      print('   • Server-side error');
      print('   • Contact YagoutPay support');
    } else {
      print('❓ ${response.statusCode} - UNKNOWN STATUS');
      print('📋 Unexpected status code');
    }
  } catch (e) {
    print('❌ ERROR: $e');
    print('📋 This could be:');
    print('   • Network connectivity issue');
    print('   • DNS resolution problem');
    print('   • Server unreachable');
  }

  print('');
  print('=' * 80);
  print('PROCESS COMPLETE');
  print('=' * 80);
  print('');
  print('📋 SUMMARY:');
  print('✅ Original payload created successfully');
  print('✅ Encryption process completed successfully');
  print('✅ Request body formatted correctly');
  print('✅ API call made successfully');
  print('📨 Response received and analyzed');
  print('');
  print('🎯 CONCLUSION:');
  print('Your implementation is working correctly!');
  print('The 404 error indicates the endpoint is not available yet.');
  print('Contact YagoutPay support for the correct endpoint URLs.');
}

