import 'lib/utils/crypto/aes_util.dart';
import 'dart:convert';

void main() {
  print('=== YagoutPay Postman Test Payloads ===\n');

  // Generate encrypted payloads for Postman testing
  generatePaymentLinkPayload();
  generateStaticLinkPayload();
}

void generatePaymentLinkPayload() {
  print('1. PAYMENT LINK API PAYLOAD');
  print('=' * 50);

  // Create the payload as per documentation
  final payload = {
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

  // Convert to JSON string
  final jsonString = jsonEncode(payload);
  print('Original JSON Payload:');
  print(jsonString);
  print('');

  // Encrypt using the same method as the service
  final encrypted = AesUtil.encryptToBase64(
      jsonString, 'IG3CNW5uNrUO2mU2htUOWb9rgXCF7XMAXmL63d7wNZo=');

  print('Encrypted Payload:');
  print(encrypted);
  print('');

  // Create the final request body
  final requestBody = {"request": encrypted};

  print('Final Request Body for Postman:');
  print(jsonEncode(requestBody));
  print('');
}

void generateStaticLinkPayload() {
  print('2. STATIC LINK API PAYLOAD');
  print('=' * 50);

  // Create the payload as per documentation
  final payload = {
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

  // Convert to JSON string
  final jsonString = jsonEncode(payload);
  print('Original JSON Payload:');
  print(jsonString);
  print('');

  // Encrypt using the same method as the service
  final encrypted = AesUtil.encryptToBase64(
      jsonString, 'IG3CNW5uNrUO2mU2htUOWb9rgXCF7XMAXmL63d7wNZo=');

  print('Encrypted Payload:');
  print(encrypted);
  print('');

  // Create the final request body
  final requestBody = {"request": encrypted};

  print('Final Request Body for Postman:');
  print(jsonEncode(requestBody));
  print('');
}




























