# YagoutPay API Testing in Postman - Step by Step Guide

## Overview

This guide will help you test the exact same request that your Flutter app sends to YagoutPay API using Postman.

## Prerequisites

- Postman installed
- YagoutPay test credentials
- AES encryption tool (we'll use an online tool)

## Step 1: Prepare the Plain Text JSON

### 1.1 Create the Request Body

Copy this exact JSON structure:

```json
{
  "card_details": {
    "cardNumber": "",
    "expiryMonth": "",
    "expiryYear": "",
    "cvv": "",
    "cardName": ""
  },
  "other_details": {
    "udf1": "",
    "udf2": "",
    "udf3": "",
    "udf4": "",
    "udf5": "",
    "udf6": "",
    "udf7": ""
  },
  "ship_details": {
    "shipAddress": "",
    "shipCity": "",
    "shipState": "",
    "shipCountry": "ETH",
    "shipZip": "",
    "shipDays": "",
    "addressCount": ""
  },
  "txn_details": {
    "agId": "yagout",
    "meId": "202505090001",
    "orderNo": "OR-DOIT-1234",
    "amount": "100.00",
    "country": "ETH",
    "currency": "ETB",
    "transactionType": "SALE",
    "sucessUrl": "https://example.com/success",
    "failureUrl": "https://example.com/failure",
    "channel": "MOBILE"
  },
  "item_details": {
    "itemCount": "1",
    "itemValue": "100.00",
    "itemCategory": "Shoes"
  },
  "cust_details": {
    "customerName": "Test Customer",
    "emailId": "test@example.com",
    "mobileNumber": "0912345678",
    "uniqueId": "",
    "isLoggedIn": "Y"
  },
  "pg_details": {
    "pg_Id": "67ee846571e740418d688c3f",
    "paymode": "WA",
    "scheme_Id": "7",
    "wallet_type": "telebirr"
  },
  "bill_details": {
    "billAddress": "",
    "billCity": "",
    "billState": "",
    "billCountry": "ETH",
    "billZip": ""
  }
}
```

### 1.2 Convert to Single Line

Remove all spaces and line breaks to get the single-line version:

```json
{
  "card_details": {
    "cardNumber": "",
    "expiryMonth": "",
    "expiryYear": "",
    "cvv": "",
    "cardName": ""
  },
  "other_details": {
    "udf1": "",
    "udf2": "",
    "udf3": "",
    "udf4": "",
    "udf5": "",
    "udf6": "",
    "udf7": ""
  },
  "ship_details": {
    "shipAddress": "",
    "shipCity": "",
    "shipState": "",
    "shipCountry": "ETH",
    "shipZip": "",
    "shipDays": "",
    "addressCount": ""
  },
  "txn_details": {
    "agId": "yagout",
    "meId": "202505090001",
    "orderNo": "OR-DOIT-1234",
    "amount": "100.00",
    "country": "ETH",
    "currency": "ETB",
    "transactionType": "SALE",
    "sucessUrl": "https://example.com/success",
    "failureUrl": "https://example.com/failure",
    "channel": "MOBILE"
  },
  "item_details": {
    "itemCount": "1",
    "itemValue": "100.00",
    "itemCategory": "Shoes"
  },
  "cust_details": {
    "customerName": "Test Customer",
    "emailId": "test@example.com",
    "mobileNumber": "0912345678",
    "uniqueId": "",
    "isLoggedIn": "Y"
  },
  "pg_details": {
    "pg_Id": "67ee846571e740418d688c3f",
    "paymode": "WA",
    "scheme_Id": "7",
    "wallet_type": "telebirr"
  },
  "bill_details": {
    "billAddress": "",
    "billCity": "",
    "billState": "",
    "billCountry": "ETH",
    "billZip": ""
  }
}
```

## Step 2: Encrypt the JSON

### 2.1 Use Online AES Encryption Tool

1. Go to: https://www.devglan.com/online-tools/aes-encryption-decryption
2. Or use: https://cryptii.com/pipes/aes-encryption

### 2.2 Encryption Settings

- **Algorithm**: AES-256-CBC
- **Key**: `6eUzH0ZdoVVBMTHrgdA0sqOFyKm54zojV4/faiSirkE=`
- **IV**: `0123456789abcdef`
- **Input**: The single-line JSON from Step 1.2
- **Output Format**: Base64

### 2.3 Copy the Encrypted Result

You'll get a long base64 string like: `VueAaFgKrAMO1sA+p8YKdC0r5vIdTBmRzJr/tmLSx+5Kmw6lup47Q3wm2z3kKZJdbHmO3i+5ww0nzcqo1vRIiKNqCJCPrk/nVLMnf0ehrUexFICmhuGL+qzsL24Rv3Ugs2rZHLlrRDCUeSqeHiE87zeqxWlvGJEAqKE34DfKT7cjeNztZEDpzsfVQn0As22obQzrxVMOFulnd3LKB07JBfJmOZKB+87Yg72iYY11KA/QPWwTJ3RqXCJxBaogz8Lm`

## Step 3: Setup Postman Request

### 3.1 Create New Request

1. Open Postman
2. Click "New" → "Request"
3. Name it "YagoutPay API Test"

### 3.2 Configure Request

- **Method**: POST
- **URL**: `https://uatcheckout.yagoutpay.com/ms-transaction-core-1-0/apiRedirection/apiIntegration`

### 3.3 Set Headers

```
Content-Type: application/json
```

### 3.4 Disable SSL Verification

1. Go to Postman Settings (gear icon)
2. Go to "General" tab
3. Turn OFF "SSL certificate verification"

## Step 4: Create Request Body

### 4.1 Set Body Type

1. Go to "Body" tab
2. Select "raw"
3. Choose "JSON" from dropdown

### 4.2 Request Body Structure

```json
{
  "merchantId": "202505090001",
  "merchantRequest": "YOUR_ENCRYPTED_STRING_HERE"
}
```

Replace `YOUR_ENCRYPTED_STRING_HERE` with the encrypted result from Step 2.3.

### 4.3 Complete Example

```json
{
  "merchantId": "202505090001",
  "merchantRequest": "VueAaFgKrAMO1sA+p8YKdC0r5vIdTBmRzJr/tmLSx+5Kmw6lup47Q3wm2z3kKZJdbHmO3i+5ww0nzcqo1vRIiKNqCJCPrk/nVLMnf0ehrUexFICmhuGL+qzsL24Rv3Ugs2rZHLlrRDCUeSqeHiE87zeqxWlvGJEAqKE34DfKT7cjeNztZEDpzsfVQn0As22obQzrxVMOFulnd3LKB07JBfJmOZKB+87Yg72iYY11KA/QPWwTJ3RqXCJxBaogz8Lm"
}
```

## Step 5: Send Request

### 5.1 Send the Request

1. Click "Send" button
2. Wait for response

### 5.2 Expected Responses

#### Success Response:

```json
{
  "status": "success",
  "message": "Transaction initiated",
  "transactionId": "TXN123456789"
}
```

#### Error Responses:

- **"Invalid token"**: Authentication issue
- **"Dublicate OrderID"**: Order ID already used
- **"Invalid Encryption"**: Encryption/decryption issue

## Step 6: Test Different Scenarios

### 6.1 Test with Different Order IDs

Change the `orderNo` in the JSON to test different scenarios:

- `OR-DOIT-1234` (current)
- `OR-DOIT-5678` (new)
- `OR-DOIT-9999` (another new)

### 6.2 Test with Different Amounts

Change the `amount` field:

- `"50.00"`
- `"200.00"`
- `"1.00"`

## Step 7: Debugging Tips

### 7.1 If You Get "Invalid token"

- Check if `merchantId` is correct: `202505090001`
- Verify the encryption key: `6eUzH0ZdoVVBMTHrgdA0sqOFyKm54zojV4/faiSirkE=`

### 7.2 If You Get "Dublicate OrderID"

- Change the `orderNo` to a new value
- Use format: `OR-DOIT-XXXX` where XXXX is 4 digits

### 7.3 If You Get "Invalid Encryption"

- Double-check the IV: `0123456789abcdef`
- Ensure you're using AES-256-CBC
- Verify the key is base64 decoded properly

## Step 8: Compare with Flutter App

### 8.1 Check Flutter App Logs

Run your Flutter app and check the console output for:

- The plain text JSON being sent
- The encrypted string
- The API response

### 8.2 Verify Consistency

Make sure the Postman request matches exactly what your Flutter app sends.

## Troubleshooting

### Common Issues:

1. **SSL Certificate Error**: Disable SSL verification in Postman
2. **CORS Error**: This is normal for API testing
3. **Timeout**: Check your internet connection
4. **Invalid JSON**: Use a JSON validator to check your request body

### Success Indicators:

- Status code 200
- Valid JSON response
- No error messages in response body

## Notes:

- This is for TEST environment only
- Use test credentials provided by YagoutPay
- The UAT environment may have limitations
- Always test with small amounts first

---

**Ready to test! Follow these steps and you'll be able to replicate exactly what your Flutter app sends to YagoutPay.**


