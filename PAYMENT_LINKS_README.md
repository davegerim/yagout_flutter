# YagoutPay Payment Link & Static Link API Implementation

This implementation provides the YagoutPay Payment Link and Static Link APIs as specified in the official documentation.

## Features Implemented

### 1. Payment Link API

- **Endpoint**: `https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/paymentByLinkResponse`
- **Purpose**: Create dynamic payment links for customers
- **Method**: `YagoutPayService.createPaymentLink()`

### 2. Static Link API

- **Endpoint**: `https://uatcheckout.yagoutpay.com/ms-transaction-core-10/sdk/staticQRPaymentResponse`
- **Purpose**: Create static links for QR code payments
- **Method**: `YagoutPayService.createStaticLink()`

### 3. Encryption/Decryption

- Uses the same AES-256-CBC encryption as the existing YagoutPay implementation
- Automatic payload encryption before sending to API
- Automatic response decryption when available

## Usage Examples

### Payment Link Creation

```dart
import 'lib/services/yagoutpay_service.dart';

// Create a payment link
final result = await YagoutPayService.createPaymentLink(
  reqUserId: 'yagou381',
  amount: '500',
  customerEmail: 'customer@example.com',
  mobileNo: '0985392862',
  expiryDate: '2025-12-31',
  orderId: YagoutPayService.generateUniqueOrderId('PAYMENT_LINK'),
  firstName: 'John',
  lastName: 'Doe',
  product: 'Product Purchase',
  dialCode: '+251',
  failureUrl: 'https://yourapp.com/payment/failure',
  successUrl: 'https://yourapp.com/payment/success',
  country: 'ETH',
  currency: 'ETB',
  mediaType: ['API'],
);

if (result['status'] == 'SUCCESS') {
  print('Payment Link created: ${result['order_id']}');
  // Use the payment link URL from the response
}
```

### Static Link Creation

```dart
// Create a static link for QR code
final result = await YagoutPayService.createStaticLink(
  reqUserId: 'yagou381',
  amount: '500',
  customerEmail: 'customer@example.com',
  mobileNo: '0985392862',
  expiryDate: '2025-12-31',
  orderId: YagoutPayService.generateUniqueOrderId('STATIC_LINK'),
  firstName: 'Jane',
  lastName: 'Smith',
  product: 'Service Payment',
  dialCode: '+251',
  failureUrl: 'https://yourapp.com/payment/failure',
  successUrl: 'https://yourapp.com/payment/success',
  country: 'ETH',
  currency: 'ETB',
  mediaType: ['API'],
);

if (result['status'] == 'SUCCESS') {
  print('Static Link created: ${result['order_id']}');
  // Use the static link data for QR code generation
}
```

## API Request Structure

Both APIs use the same payload structure as specified in the documentation:

```json
{
  "req_user_id": "yagou381",
  "me_id": "202508080001",
  "amount": "500",
  "customer_email": "",
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
}
```

## Request Headers

Both APIs require the following headers:

- `Content-Type: application/json`
- `me_id: 202508080001` (merchant ID)

## Response Structure

```json
{
  "status": "SUCCESS",
  "message": "Payment Link created successfully",
  "order_id": "ORDER_STATIC_001",
  "response": {
    // Raw API response
  },
  "decrypted_response": {
    // Decrypted response data (if available)
  }
}
```

## Error Handling

The implementation includes comprehensive error handling:

- **HTTP Errors**: Network and server errors
- **Encryption Errors**: Payload encryption/decryption failures
- **API Errors**: YagoutPay API-specific errors
- **Validation Errors**: Missing or invalid parameters

## Testing

Run the test files to verify the implementation:

```bash
# Test Payment Links
dart test_payment_links.dart

# Run comprehensive examples
dart payment_links_example.dart
```

## Configuration

The implementation uses the existing YagoutPay configuration:

- **Merchant ID**: `202508080001` (UAT)
- **Encryption Key**: From `YagoutPayConfig.apiKey`
- **Environment**: UAT (configurable in `YagoutPayConfig`)

## Files Added/Modified

### New Files

- `lib/models/payment_link_request.dart` - Payment Link request model
- `lib/models/static_link_request.dart` - Static Link request model
- `test_payment_links.dart` - Basic test file
- `payment_links_example.dart` - Comprehensive usage examples
- `PAYMENT_LINKS_README.md` - This documentation

### Modified Files

- `lib/services/yagoutpay_service.dart` - Added Payment Link and Static Link methods

## Implementation Notes

1. **Encryption**: Uses the same AES-256-CBC encryption as the existing YagoutPay implementation
2. **Order IDs**: Generates unique order IDs using timestamp and random numbers
3. **Error Handling**: Comprehensive error handling with detailed logging
4. **Documentation Compliance**: Follows the exact API structure from the YagoutPay documentation
5. **Response Processing**: Automatically decrypts responses when possible

## Next Steps

1. Test with actual YagoutPay UAT environment
2. Implement production environment configuration
3. Add webhook handling for payment status updates
4. Integrate with your Flutter app's UI components
5. Add unit tests for the new functionality

## Support

For issues or questions regarding this implementation, refer to:

- YagoutPay official documentation
- Existing YagoutPay service implementation
- Test files for usage examples




























