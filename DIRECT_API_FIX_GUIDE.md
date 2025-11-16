# YagoutPay Direct API "Something went worng." Error - Fix Guide

## 🔴 Problem

Getting this error response from YagoutPay Direct API integration:

```json
{
  "merchantId": null,
  "status": "Failure",
  "statusMessage": "Something went worng.",
  "response": null
}
```

**Note:** The typo "worng" is from YagoutPay's backend error message.

## 🔍 Root Cause Analysis

The "Something went worng." error from YagoutPay API typically indicates one of these issues:

1. **Missing or Invalid Required Fields** - The payload structure is missing required fields or has invalid values
2. **Incorrect Channel Field** - Using wrong channel value for Direct API (should always be 'API')
3. **Malformed Payload Structure** - The nested JSON structure doesn't match YagoutPay's expected format
4. **Invalid Customer Data** - Empty or malformed customer name, email, or mobile number
5. **Order ID Format Issues** - Order ID not properly formatted or already used
6. **Success/Failure URL Issues** - Invalid or unreachable callback URLs

## ✅ Fixes Applied

### 1. **Enhanced Order ID Generation**

**Before:**

```dart
final random = Random().nextInt(9999).toString().padLeft(4, '0');
final orderNo = 'OR-DOIT-$random';
```

**After:**

```dart
final timestamp = DateTime.now().millisecondsSinceEpoch;
final random = Random().nextInt(9999).toString().padLeft(4, '0');
final orderNo = 'OR-DOIT-$timestamp-$random';  // Truly unique
```

**Why:** Ensures absolutely unique order IDs by combining timestamp with random number.

---

### 2. **Fixed Channel Field**

**Before:**

```dart
'channel': channel, // Could be 'MOBILE' or other values
```

**After:**

```dart
'channel': 'API', // ALWAYS 'API' for Direct API integration
```

**Why:** Direct API integration must use 'API' channel, not 'MOBILE' or others.

---

### 3. **Ensured Non-Empty Customer Name**

**Before:**

```dart
'customerName': customerName ?? '',  // Could be empty
```

**After:**

```dart
'customerName': customerName ?? 'Customer',  // Always has value
```

**Why:** YagoutPay backend validation may reject empty customer names.

---

### 4. **Updated Success/Failure URLs**

**Before:**

```dart
const successUrl = 'https://example.com/success';
const failureUrl = 'https://example.com/failure';
```

**After:**

```dart
const successUrl = 'https://webhook.site/success';  // Or your webhook URL
const failureUrl = 'https://webhook.site/failure';
```

**Why:** For Direct API, these are webhook callback URLs. Using example.com might cause validation issues. Better to use:

- Real webhook URLs (if you have a backend)
- Webhook.site for testing
- Or keep example.com if YagoutPay accepts it for UAT

---

### 5. **Enhanced Debug Logging**

Added comprehensive logging to diagnose issues:

```dart
print('=== Plain Payload Before Encryption ===');
print('Order ID: $orderNo');
print('Amount: $amount');
print('Customer Email: $email');
print('Customer Mobile: $mobile');
print('Customer Name: ${customerName ?? 'Customer'}');
print('Success URL: $successUrl');
print('Failure URL: $failureUrl');
print('Channel: API');
print('PG ID: ${YagoutPayConfig.pgId}');
print('Paymode: ${YagoutPayConfig.paymode}');
print('Wallet Type: ${YagoutPayConfig.walletType}');
```

**Why:** Helps identify exactly what data is being sent to YagoutPay.

---

### 6. **Enhanced Error Detection**

Added specific handling for "Something went worng." error:

```dart
if (statusMessage.toLowerCase().contains('something went worng') ||
    statusMessage.toLowerCase().contains('something went wrong')) {
  print('⚠️  DETECTED "Something went wrong" ERROR');
  print('   This typically indicates:');
  print('   1. Missing or invalid required fields in payload');
  print('   2. Invalid merchant credentials');
  print('   3. Malformed payload structure');
  print('   4. Backend validation failure');
  // ... detailed diagnostic info
}
```

**Why:** Provides actionable debugging information when this error occurs.

---

## 🧪 Testing the Fix

### Step 1: Check Debug Console

When you make a payment, check the console for:

```
=== Plain Payload Before Encryption ===
Order ID: OR-DOIT-1704123456789-1234
Amount: 100.00
Customer Email: test@example.com
Customer Mobile: 0912345678
Customer Name: John Doe
Success URL: https://webhook.site/success
Failure URL: https://webhook.site/failure
Channel: API
PG ID: 67ee846571e740418d688c3f
Paymode: WA
Wallet Type: telebirr
======================================
```

**Verify:**

- ✅ Order ID has unique timestamp
- ✅ Channel is 'API'
- ✅ Customer Name is not empty
- ✅ All required fields have values

### Step 2: Check API Response

Look for the response debug output:

```
=== API Response Debug ===
HTTP Status: 200
Response body: {"merchantId":"202508080001","status":"Success",...}
=========================
```

**If you still see "Something went worng."**, check the diagnostic output that will appear:

```
⚠️  DETECTED "Something went wrong" ERROR
   This typically indicates:
   1. Missing or invalid required fields in payload
   2. Invalid merchant credentials
   3. Malformed payload structure
   4. Backend validation failure

   Current payload info:
   - Order ID: OR-DOIT-1704123456789-1234
   - Merchant ID: 202508080001
   - Response Merchant ID: null
   - Amount: 100.00
   - Email: test@example.com
   - Mobile: 0912345678
```

---

## 🚨 If Error Persists

If you still get "Something went worng." after these fixes, it likely means:

### 1. **YagoutPay Backend Validation Issue**

The UAT environment may have stricter validation rules. Contact YagoutPay support with:

```
Error: "Something went worng."
Merchant ID: 202508080001
Order ID Format: OR-DOIT-1704123456789-1234
Channel: API
Amount: 100.00

Request: All required fields are populated correctly.
Please verify:
1. Are there any additional required fields not in the documentation?
2. Is there specific format required for success/failure URLs?
3. Are there any backend validation rules we should know about?
```

### 2. **Success/Failure URL Validation**

Try different URL formats:

**Option A: Use webhook.site**

```dart
const successUrl = 'https://webhook.site/<your-unique-id>/success';
const failureUrl = 'https://webhook.site/<your-unique-id>/failure';
```

**Option B: Use HTTPS URLs**

```dart
const successUrl = 'https://yourapp.com/api/yagoutpay/success';
const failureUrl = 'https://yourapp.com/api/yagoutpay/failure';
```

**Option C: Keep example.com but ensure HTTPS**

```dart
const successUrl = 'https://example.com/success';  // Not http://
const failureUrl = 'https://example.com/failure';
```

### 3. **Check Merchant Credentials**

Verify in `lib/config/yagoutpay_config.dart`:

```dart
static const String apiTestMerchantId = '202508080001';  // ✅ Correct
static const String apiTestKey = 'IG3CNW5uNrUO2mU2htUOWb9rgXCF7XMAXmL63d7wNZo=';  // ✅ Correct
static const String apiPgId = '67ee846571e740418d688c3f';  // ✅ Correct
static const String apiPaymode = 'WA';  // ✅ Correct (Wallet)
static const String apiWalletType = 'telebirr';  // ✅ Correct
```

---

## 📋 Complete Payload Structure

Here's the exact payload structure being sent (after fixes):

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
    "shipAddress": "123 Main St",
    "shipCity": "Addis Ababa",
    "shipState": "Addis Ababa",
    "shipCountry": "ETH",
    "shipZip": "1000",
    "shipDays": "",
    "addressCount": ""
  },
  "txn_details": {
    "agId": "yagout",
    "meId": "202508080001",
    "orderNo": "OR-DOIT-1704123456789-1234",
    "amount": "100.00",
    "country": "ETH",
    "currency": "ETB",
    "transactionType": "SALE",
    "sucessUrl": "https://webhook.site/success",
    "failureUrl": "https://webhook.site/failure",
    "channel": "API"
  },
  "item_details": {
    "itemCount": "1",
    "itemValue": "100.00",
    "itemCategory": "Shoes"
  },
  "cust_details": {
    "customerName": "John Doe",
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
    "billAddress": "123 Main St",
    "billCity": "Addis Ababa",
    "billState": "Addis Ababa",
    "billCountry": "ETH",
    "billZip": "1000"
  }
}
```

This JSON is then:

1. Converted to string
2. Encrypted with AES-256-CBC
3. Base64 encoded
4. Sent in request body as:
   ```json
   {
     "merchantId": "202508080001",
     "merchantRequest": "<base64_encrypted_payload>"
   }
   ```

---

## 🎯 Next Steps

1. **Run the app** and make a test payment
2. **Check console logs** for the new debug output
3. **Verify** all payload fields have correct values
4. **If error persists**, contact YagoutPay support with console logs
5. **Try different URL formats** for success/failure callbacks

---

## 📞 Contact YagoutPay Support

If issue continues after applying all fixes, provide them with:

1. Complete debug console output
2. Order ID format being used
3. Confirmation that all required fields are populated
4. This error: `{"status":"Failure","statusMessage":"Something went worng.","response":null}`
5. Request clarification on any additional validation rules

---

**Files Modified:**

- `lib/screens/checkout/checkout_screen.dart` - Order ID generation and URL updates
- `lib/services/yagoutpay_service.dart` - Channel fix, customer name validation, enhanced logging

**Test the changes and monitor the debug console output!**








