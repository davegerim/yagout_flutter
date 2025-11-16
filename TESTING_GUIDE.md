# YagoutPay Direct API - Testing Guide

## 🧪 How to Test the Fix

### Prerequisites

- Flutter app built and running
- Test phone with active mobile money account (Telebirr)
- Internet connectivity

### Test Steps

1. **Launch the App**

   ```bash
   flutter run
   ```

2. **Add Items to Cart**

   - Browse products
   - Add at least one item to cart
   - Navigate to cart

3. **Proceed to Checkout**

   - Click "Proceed to Checkout"
   - Fill in customer details:
     - Name: Your name
     - Email: Your email
     - Phone: Your mobile number (e.g., 0912345678)
     - Address, City, State, ZIP

4. **Select Payment Method**

   - You should now see only one option: **"YagoutPay (Direct API)"**
   - It should be selected by default

5. **Place Order**

   - Click "Place Order" button
   - Wait for payment to initiate

6. **Complete Payment on Phone**

   - You should receive SMS with PIN request
   - Enter your PIN to complete payment
   - Wait for confirmation

7. **Check App Response**
   - App should show **Success Page** with:
     - Order ID (format: OR-DOIT-timestamp-XXXX)
     - Transaction ID
     - Amount paid
     - Customer details
   - ✅ If you see success page → **FIX WORKED!**
   - ❌ If you see failure page → **Check console logs**

### Expected Console Output (Success)

```
=== Using Original Order ID in API Request ===
Order ID to use: OR-DOIT-1759922622748-5162
Format: ✅ OR-DOIT-XXXX
Passing original orderNo directly to API as per YagoutPay clarification

=== Plain Payload Before Encryption ===
Order ID: OR-DOIT-1759922622748-5162
Amount: 1.00
Customer Email: davegerim@gmail.com
Customer Mobile: 0985392862
Customer Name: Dawit Gerim
Success URL: (empty) - Direct API uses internal status handling
Failure URL: (empty) - Direct API uses internal status handling
Channel: API
PG ID: 67ee846571e740418d688c3f
Paymode: WA
Wallet Type: telebirr
Payload JSON length: 1058
======================================

=== API Request Debug ===
API URL: https://uatcheckout.yagoutpay.com/ms-transaction-core-1-0/apiRedirection/apiIntegration
Merchant ID: 202508080001
Request body length: 1482
Encrypted data length: 1432
========================

=== API Response Debug ===
HTTP Status: 200
Response headers: {cache-control: no-cache, no-store, max-age=0, must-revalidate, content-type: application/json, expires: 0, pragma: no-cache}
Response body: {"merchantId":"202508080001","status":"Success","response":"<encrypted_data>"}
=========================

✅ Response decrypted successfully
   Decrypted response: {transactionId: TXN123456, status: Success, ...}

YagoutPay API Response: Success - Payment completed successfully
```

## 🔍 Troubleshooting

### Issue 1: Still Getting "Something went worng." Error

**Check:**

1. **Internet connectivity** - Ensure phone has stable internet
2. **YagoutPay UAT status** - Service might be down
3. **Console logs** - Look for specific error messages

**Solution:**

```
If error persists:
1. Check if merchantId in response is "202508080001" or "null"
2. If "null" → Contact YagoutPay support
3. If "202508080001" → Check decrypted response for actual error
```

### Issue 2: Payment Works But App Shows Failure

**Check:**

1. **Response status field** - Look in console logs
2. **Decrypted response** - Check if payment actually succeeded

**Solution:**

```
If payment succeeded but app shows failure:
- This means response parsing issue
- Check lines 1090-1130 in checkout_screen.dart
- Verify status detection logic
```

### Issue 3: No SMS Received

**Check:**

1. **Phone number format** - Should be 10 digits (e.g., 0912345678)
2. **Mobile money account** - Ensure it's active
3. **Network connectivity** - Check phone signal

**Solution:**

```
Try different phone number
Or
Contact YagoutPay support to verify merchant setup
```

### Issue 4: "Merchant is not Authorized" Error

**Check:**

1. **Merchant ID** - Should be "202508080001" for UAT
2. **Encryption key** - Should match config
3. **API URL** - Should be UAT endpoint

**Solution:**

```
This means credentials are incorrect or expired
Contact YagoutPay support to verify:
- Merchant ID is still valid
- Encryption key hasn't changed
- UAT environment is accessible
```

## 📊 Success Criteria

✅ **Fix is successful if:**

1. Payment processes on phone
2. App shows success page
3. Console shows "Status: Success"
4. No "Something went worng." error

❌ **Fix failed if:**

1. Still getting "Something went worng." error
2. App shows failure page despite successful payment
3. merchantId returns as "null" in response

## 🔧 Advanced Debugging

### Enable Detailed Logging

The app already has detailed logging enabled. Check console for:

1. **Plain Payload** - Before encryption
2. **Encrypted Payload** - After encryption
3. **API Request** - Headers and body
4. **API Response** - Status and body
5. **Decrypted Response** - If available

### Compare with JavaScript

If issue persists, compare Flutter request with your working JavaScript:

```javascript
// JavaScript payload structure
{
  "merchantId": "202508080001",
  "merchantRequest": "<encrypted_base64>"
}

// JavaScript headers
{
  "Content-Type": "application/json",
  "Accept": "application/json"
}

// Success/Failure URLs in encrypted payload
{
  "sucessUrl": "",
  "failureUrl": ""
}
```

### Test with Postman

If app still fails, test with Postman:

1. Use `POSTMAN_TESTING_GUIDE.md` for reference
2. Copy exact payload from Flutter console logs
3. Test in Postman
4. Compare Postman response with Flutter response

## 📞 Support Contacts

### YagoutPay Support

- **Email**: support@yagoutpay.com
- **Phone**: Check documentation
- **Provide**:
  - Merchant ID: 202508080001
  - Order ID from console logs
  - Error message
  - Timestamp of transaction

### What to Include in Support Ticket

```
Subject: Direct API Integration - "Something went wrong" Error

Body:
- Merchant ID: 202508080001
- Environment: UAT
- Integration Type: Direct API
- Order ID: [from console logs]
- Error Message: "Something went worng."
- Timestamp: [date and time]
- Additional Info: Payment succeeds on phone but API returns failure

Console Logs:
[Paste relevant console logs]

Request Payload:
[Paste plain payload from console]

Response:
[Paste API response from console]
```

## ✅ Final Checklist

Before declaring success:

- [ ] Payment initiates successfully
- [ ] SMS received on phone
- [ ] Payment completes on phone
- [ ] App shows success page
- [ ] Console shows "Status: Success"
- [ ] Order is saved in app
- [ ] Cart is cleared after successful payment
- [ ] Order appears in order history

## 🎯 Expected Results

### ✅ Success Scenario

```
User clicks "Place Order"
→ API call initiated
→ SMS sent to phone
→ User enters PIN
→ Payment processed
→ API returns success
→ App shows success page
→ Order saved
→ Cart cleared
→ User redirected to orders page
```

### ❌ Failure Scenario (If Fix Didn't Work)

```
User clicks "Place Order"
→ API call initiated
→ SMS sent to phone
→ User enters PIN
→ Payment processed
→ API returns "Something went worng."
→ App shows failure page
→ Order not saved
→ Cart not cleared
→ User stuck on checkout page
```

---

## 🚀 Quick Test Command

To quickly test after running the app:

1. **Run app**: `flutter run`
2. **Monitor logs**: Watch console output
3. **Make payment**: Follow test steps above
4. **Verify**: Check success page appears

**Expected time**: 2-3 minutes per test

---

Good luck with testing! 🎉








