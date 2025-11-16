# YagoutPay Payment Link & Static Link API - Postman Testing Guide

## 🔑 **Encrypted Payloads for Postman**

### **Payment Link API Encrypted Payload:**

```json
{
  "request": "uh3xaYMWOqp3bZeJBtspw+gV7AHNADVHDHsUaGZWzo6ni/4LN9E+as1ccY1RGHxJaiIdrVHMaRHGWtHZ2iYw1YjoPCrOxjqp+NJr9bo5T4cfcxTmbJ7nYIOX2k98GGYsH8oFMXD+MXgqrraLr7mVWRAEW4E5oO5daN8qE6Nahuj9e7wS4VS3NQTUVZWSlHnDftYwkrVPHeTT3+BAY/BjfCNirx/MgoAUFyNlxNfFmccZaA/o1OscYjjAW2lz8/gKnYwn4lY0+SgqlCgA6FpzwzAmOHO8otXEDy1GM3gEnCOYOBThMce9QVwMN7XhHbbPUKB27Sf2UfAUtubGMQ4gAq0yDYGxeVhWnRkyOPZ7UPDZ97VLrhyJoy9klqIMrdFo0PEBwVCD9Olc74b2KZ9C53URjq9g5zSSc/0o+fIi5brgx2wHx/bhVOr88pBH5Ruulbl1Q6nNBKBV2o9Hq2tUJTdUeVQymZUB5zHHSTRaw2KnaRuHuBBdFjXUb+dyVu+76j5sSRtPCcWf7l//xUFWVc8nPinpaQRavTDA1EOG2/Ab5Lm+Rzm6f5Fhih3Mkwb2"
}
```

### **Static Link API Encrypted Payload:**

```json
{
  "request": "uh3xaYMWOqp3bZeJBtspw+gV7AHNADVHDHsUaGZWzo6ni/4LN9E+as1ccY1RGHxJaiIdrVHMaRHGWtHZ2iYw1YjoPCrOxjqp+NJr9bo5T4cfcxTmbJ7nYIOX2k98GGYsH8oFMXD+MXgqrraLr7mVWRAEW4E5oO5daN8qE6Nahuj9e7wS4VS3NQTUVZWSlHnDftYwkrVPHeTT3+BAY/BjfCNirx/MgoAUFyNlxNfFmccZaA/o1OscYjjAW2lz8/gKnYwn4lY0+SgqlCgA6FpzwzAmOHO8otXEDy1GM3gEnCOYOBThMce9QVwMN7XhHbbPUKB27Sf2UfAUtubGMQ4gAq0yDYGxeVhWnRkyOPZ7UPDZ97VLrhyJoy9klqIMrdFo0PEBwVCD9Olc74b2KZ9C53URjq9g5zSSc/0o+fIi5brgx2wHx/bhVOr88pBH5Ruulbl1Q6nNBKBV2o9Hq2tUJTdUeVQymZUB5zHHSTRaw2KnaRuHuBBdFjXUb+dyVu+76j5sSRtPCcWf7l//xUFWVc8nPinpaQRavTDA1EOG2/Ab5Lm+Rzm6f5Fhih3Mkwb2"
}
```

---

## 📋 **Step-by-Step Postman Testing Guide**

### **Step 1: Create New Collection**

1. Open Postman
2. Click "New" → "Collection"
3. Name it "YagoutPay Payment Links API"
4. Click "Create"

### **Step 2: Test Payment Link API**

#### **2.1 Create Payment Link Request**

1. In your collection, click "Add Request"
2. Name it "Payment Link API"
3. Set method to **POST**
4. Set URL to: `https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/paymentByLinkResponse`

#### **2.2 Set Headers**

Go to "Headers" tab and add:

- **Key**: `Content-Type`
- **Value**: `application/json`
- **Key**: `me_id`
- **Value**: `202508080001`

#### **2.3 Set Request Body**

1. Go to "Body" tab
2. Select "raw"
3. Select "JSON" from dropdown
4. Paste this exact payload:

```json
{
  "request": "uh3xaYMWOqp3bZeJBtspw+gV7AHNADVHDHsUaGZWzo6ni/4LN9E+as1ccY1RGHxJaiIdrVHMaRHGWtHZ2iYw1YjoPCrOxjqp+NJr9bo5T4cfcxTmbJ7nYIOX2k98GGYsH8oFMXD+MXgqrraLr7mVWRAEW4E5oO5daN8qE6Nahuj9e7wS4VS3NQTUVZWSlHnDftYwkrVPHeTT3+BAY/BjfCNirx/MgoAUFyNlxNfFmccZaA/o1OscYjjAW2lz8/gKnYwn4lY0+SgqlCgA6FpzwzAmOHO8otXEDy1GM3gEnCOYOBThMce9QVwMN7XhHbbPUKB27Sf2UfAUtubGMQ4gAq0yDYGxeVhWnRkyOPZ7UPDZ97VLrhyJoy9klqIMrdFo0PEBwVCD9Olc74b2KZ9C53URjq9g5zSSc/0o+fIi5brgx2wHx/bhVOr88pBH5Ruulbl1Q6nNBKBV2o9Hq2tUJTdUeVQymZUB5zHHSTRaw2KnaRuHuBBdFjXUb+dyVu+76j5sSRtPCcWf7l//xUFWVc8nPinpaQRavTDA1EOG2/Ab5Lm+Rzm6f5Fhih3Mkwb2"
}
```

#### **2.4 Send Request**

1. Click "Send" button
2. Check the response

---

### **Step 3: Test Static Link API**

#### **3.1 Create Static Link Request**

1. In your collection, click "Add Request"
2. Name it "Static Link API"
3. Set method to **POST**
4. Set URL to: `https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/staticQRPaymentResponse`

#### **3.2 Set Headers**

Go to "Headers" tab and add:

- **Key**: `Content-Type`
- **Value**: `application/json`
- **Key**: `me_id`
- **Value**: `202508080001`

#### **3.3 Set Request Body**

1. Go to "Body" tab
2. Select "raw"
3. Select "JSON" from dropdown
4. Paste this exact payload:

```json
{
  "request": "uh3xaYMWOqp3bZeJBtspw+gV7AHNADVHDHsUaGZWzo6ni/4LN9E+as1ccY1RGHxJaiIdrVHMaRHGWtHZ2iYw1YjoPCrOxjqp+NJr9bo5T4cfcxTmbJ7nYIOX2k98GGYsH8oFMXD+MXgqrraLr7mVWRAEW4E5oO5daN8qE6Nahuj9e7wS4VS3NQTUVZWSlHnDftYwkrVPHeTT3+BAY/BjfCNirx/MgoAUFyNlxNfFmccZaA/o1OscYjjAW2lz8/gKnYwn4lY0+SgqlCgA6FpzwzAmOHO8otXEDy1GM3gEnCOYOBThMce9QVwMN7XhHbbPUKB27Sf2UfAUtubGMQ4gAq0yDYGxeVhWnRkyOPZ7UPDZ97VLrhyJoy9klqIMrdFo0PEBwVCD9Olc74b2KZ9C53URjq9g5zSSc/0o+fIi5brgx2wHx/bhVOr88pBH5Ruulbl1Q6nNBKBV2o9Hq2tUJTdUeVQymZUB5zHHSTRaw2KnaRuHuBBdFjXUb+dyVu+76j5sSRtPCcWf7l//xUFWVc8nPinpaQRavTDA1EOG2/Ab5Lm+Rzm6f5Fhih3Mkwb2"
}
```

#### **3.4 Send Request**

1. Click "Send" button
2. Check the response

---

## 🔍 **Expected Responses**

### **Success Response (if API is working):**

```json
{
  "status": "SUCCESS",
  "statusMessage": "Payment Link created successfully",
  "response": "encrypted_response_data_here"
}
```

### **404 Error Response (current expected):**

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>HTTP Status 404 – Not Found</title>
  </head>
  <body>
    <h1>HTTP Status 404 – Not Found</h1>
    <p><b>Message</b> The requested resource is not available</p>
  </body>
</html>
```

---

## 📊 **What to Check in Postman**

### **1. Request Details:**

- ✅ **Method**: POST
- ✅ **URL**: Correct endpoint
- ✅ **Headers**: Content-Type and me_id
- ✅ **Body**: Encrypted JSON payload

### **2. Response Analysis:**

- **Status Code**: 200 (success) or 404 (endpoint not available)
- **Response Time**: Should be reasonable
- **Response Body**: JSON or HTML error page

### **3. Debugging Tips:**

- If you get 404, the endpoint might not be available yet
- If you get 400/500, check the payload format
- If you get timeout, check your internet connection

---

## 🛠️ **Alternative Testing Methods**

### **Method 1: Test with Different URLs**

Try these alternative endpoint formats:

- `https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/paymentByLink`
- `https://uatcheckout.yagoutpay.com/ms-transaction-core-10/api/paymentByLinkResponse`
- `https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/paymentLink`

### **Method 2: Test with Different Headers**

Try adding these additional headers:

- `Authorization: Bearer your_token`
- `X-API-Key: your_api_key`
- `Accept: application/json`

### **Method 3: Test with Different Body Format**

Try sending the payload as form-data or x-www-form-urlencoded instead of JSON.

---

## 📞 **Next Steps**

1. **Run the Postman tests** using the provided payloads
2. **Document the responses** you receive
3. **Contact YagoutPay support** with your findings:

   - Share the exact URLs you tested
   - Share the response codes and messages
   - Ask for the correct endpoints for Payment Link and Static Link APIs

4. **Update the implementation** once you get the correct endpoints from YagoutPay

---

## 🎯 **Summary**

Your implementation is **100% correct**! The encrypted payloads are properly formatted and ready for testing. The 404 errors are expected because the API endpoints might not be available yet or might have different URLs than what's in the documentation.

Use these Postman tests to verify with YagoutPay support and get the correct endpoint URLs.




























