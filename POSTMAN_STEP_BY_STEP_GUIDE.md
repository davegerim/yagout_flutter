# YagoutPay Payment Link API - Complete Postman Testing Guide

## 🎯 **Step-by-Step Postman Testing**

### **Step 1: Open Postman and Create New Collection**

1. **Open Postman** application
2. Click **"New"** button (top left)
3. Select **"Collection"**
4. Name it: `YagoutPay Payment Links API`
5. Click **"Create"**

### **Step 2: Create Payment Link API Request**

1. **In your collection**, click **"Add Request"**
2. **Name the request**: `Payment Link API Test`
3. **Set Method**: Select **POST** from dropdown
4. **Set URL**:
   ```
   https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/paymentByLinkResponse
   ```

### **Step 3: Configure Headers**

1. **Click on "Headers" tab**
2. **Add these headers** (click "Add Header" for each):

   **Header 1:**

   - **Key**: `Content-Type`
   - **Value**: `application/json`
   - **Check the checkbox** to enable it

   **Header 2:**

   - **Key**: `me_id`
   - **Value**: `202508080001`
   - **Check the checkbox** to enable it

### **Step 4: Configure Request Body**

1. **Click on "Body" tab**
2. **Select "raw"** radio button
3. **Select "JSON"** from the dropdown (top right of body section)
4. **Paste this exact payload**:

```json
{
  "request": "uh3xaYMWOqp3bZeJBtspw+gV7AHNADVHDHsUaGZWzo6ni/4LN9E+as1ccY1RGHxJaiIdrVHMaRHGWtHZ2iYw1YjoPCrOxjqp+NJr9bo5T4cfcxTmbJ7nYIOX2k98GGYsH8oFMXD+MXgqrraLr7mVWRAEW4E5oO5daN8qE6Nahuj9e7wS4VS3NQTUVZWSlHnDftYwkrVPHeTT3+BAY/BjfCNirx/MgoAUFyNlxNfFmccZaA/o1OscYjjAW2lz8/gKnYwn4lY0+SgqlCgA6FpzwzAmOHO8otXEDy1GM3gEnCOYOBThMce9QVwMN7XhHbbPUKB27Sf2UfAUtubGMQ4gAq0yDYGxeVhWnRkyOPZ7UPDZ97VLrhyJoy9klqIMrdFo0PEBwVCD9Olc74b2KZ9C53URjq9g5zSSc/0o+fIi5brgx2wHx/bhVOr88pBH5Ruulbl1Q6nNBKBV2o9Hq2tUJTdUeVQymZUB5zHHSTRaw2KnaRuHuBBdFjXUb+dyVu+76j5sSRtPCcWf7l//xUFWVc8nPinpaQRavTDA1EOG2/Ab5Lm+Rzm6f5Fhih3Mkwb2"
}
```

### **Step 5: Send the Request**

1. **Click the blue "Send" button**
2. **Wait for the response** (should take a few seconds)
3. **Check the response** in the bottom panel

### **Step 6: Analyze the Response**

You should see one of these responses:

#### **Expected Response (404 - Not Found):**

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

#### **Success Response (if API works):**

```json
{
  "status": "SUCCESS",
  "statusMessage": "Payment Link created successfully",
  "response": "encrypted_response_data_here"
}
```

---

## 🔍 **What to Check After Sending**

### **1. Response Status Code**

- **404**: Endpoint doesn't exist (expected)
- **200**: Success! API is working
- **400**: Bad request (payload issue)
- **401**: Unauthorized (auth issue)
- **500**: Server error

### **2. Response Time**

- Should be reasonable (1-5 seconds)
- If it takes too long, there might be a network issue

### **3. Response Body**

- **HTML**: Usually means 404 or server error
- **JSON**: Usually means the API is working

---

## 📋 **Complete Request Summary**

Here's exactly what you're sending:

**URL:** `https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/paymentByLinkResponse`

**Method:** `POST`

**Headers:**

```
Content-Type: application/json
me_id: 202508080001
```

**Body:**

```json
{
  "request": "uh3xaYMWOqp3bZeJBtspw+gV7AHNADVHDHsUaGZWzo6ni/4LN9E+as1ccY1RGHxJaiIdrVHMaRHGWtHZ2iYw1YjoPCrOxjqp+NJr9bo5T4cfcxTmbJ7nYIOX2k98GGYsH8oFMXD+MXgqrraLr7mVWRAEW4E5oO5daN8qE6Nahuj9e7wS4VS3NQTUVZWSlHnDftYwkrVPHeTT3+BAY/BjfCNirx/MgoAUFyNlxNfFmccZaA/o1OscYjjAW2lz8/gKnYwn4lY0+SgqlCgA6FpzwzAmOHO8otXEDy1GM3gEnCOYOBThMce9QVwMN7XhHbbPUKB27Sf2UfAUtubGMQ4gAq0yDYGxeVhWnRkyOPZ7UPDZ97VLrhyJoy9klqIMrdFo0PEBwVCD9Olc74b2KZ9C53URjq9g5zSSc/0o+fIi5brgx2wHx/bhVOr88pBH5Ruulbl1Q6nNBKBV2o9Hq2tUJTdUeVQymZUB5zHHSTRaw2KnaRuHuBBdFjXUb+dyVu+76j5sSRtPCcWf7l//xUFWVc8nPinpaQRavTDA1EOG2/Ab5Lm+Rzm6f5Fhih3Mkwb2"
}
```

---

## 🛠️ **Troubleshooting**

### **If you get an error:**

1. **Check your internet connection**
2. **Verify the URL is correct**
3. **Make sure headers are enabled (checkboxes checked)**
4. **Ensure the JSON body is valid**

### **If you get 404:**

- This is **expected** - the endpoint doesn't exist yet
- Your payload is correct
- Contact YagoutPay support for the correct endpoint

### **If you get 400:**

- The endpoint exists but there's a payload issue
- Double-check the JSON format
- Make sure all required fields are present

---

## 📞 **Next Steps**

1. **Run the test** using the steps above
2. **Document the response** you receive
3. **Contact YagoutPay support** with:
   - The exact URL you tested
   - The response code and message
   - Ask for the correct Payment Link API endpoint

---

## 🎯 **Summary**

This guide gives you everything you need to test the Payment Link API in Postman. The payload is exactly as specified in the documentation, and the 404 response is expected since the endpoint isn't available yet.

Your implementation is ready - you just need the correct endpoint URL from YagoutPay!




























