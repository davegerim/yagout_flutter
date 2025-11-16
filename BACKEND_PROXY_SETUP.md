# Backend Proxy Setup - CORS Solution

## Overview

This setup creates a NestJS backend that acts as a proxy between your Flutter Web app and the YagoutPay API. This solves the CORS issue because:

- **Flutter Web** → Calls your NestJS backend (same origin or allowed CORS)
- **NestJS Backend** → Calls YagoutPay API (server-to-server, no CORS restrictions)
- **Response** → Returns to Flutter Web without CORS issues

## Project Structure

```
yagout_flutter/
├── backend/                    # NestJS backend
│   ├── src/
│   │   ├── main.ts            # Backend entry point with CORS config
│   │   ├── app.module.ts      # Main module
│   │   └── payment/
│   │       ├── payment.controller.ts  # Payment endpoint
│   │       └── payment.service.ts     # YagoutPay API proxy
│   ├── package.json
│   └── README.md
└── lib/
    ├── config/
    │   └── yagoutpay_config.dart  # Updated with backend URL
    └── services/
        └── yagoutpay_service.dart  # Updated to use backend proxy
```

## Setup Instructions

### 1. Start the NestJS Backend

```bash
cd backend
npm install          # Already done
npm run start:dev    # Start development server
```

The backend will run on `http://localhost:3001`

### 2. Verify Backend is Running

You should see:
```
🚀 NestJS Backend running on http://localhost:3001
📡 Proxy endpoint: http://localhost:3001/api/payment/yagoutpay
```

### 3. Run Flutter App

```bash
flutter run -d chrome
```

The Flutter app will now call the NestJS backend instead of YagoutPay directly.

## Configuration

### Backend URL

The backend URL is configured in `lib/config/yagoutpay_config.dart`:

```dart
static const String backendUrl = 'http://localhost:3001';
static const String backendPaymentEndpoint = '$backendUrl/api/payment/yagoutpay';
static bool get useBackendProxy => true; // Set to false to use direct API
```

### CORS Configuration

The backend allows requests from any localhost port. This is configured in `backend/src/main.ts`:

```typescript
app.enableCors({
  origin: [
    'http://localhost:3000',
    'http://localhost:5000',
    'http://localhost:8080',
    'http://localhost:*', // Any localhost port
  ],
  // ...
});
```

## How It Works

### Request Flow

1. **Flutter Web** creates payment request with encrypted data
2. **Flutter** sends POST to `http://localhost:3001/api/payment/yagoutpay`
3. **NestJS Backend** receives request and forwards to YagoutPay API
4. **YagoutPay** processes payment and returns response
5. **NestJS Backend** returns response to Flutter
6. **Flutter** processes response and navigates to success/failure page

### Response Format

The backend wraps the YagoutPay response:

```json
{
  "success": true,
  "status": 200,
  "data": {
    // Original YagoutPay response here
    "status": "SUCCESS",
    "statusMessage": "...",
    "response": "encrypted_data",
    // ...
  },
  "message": "Payment processed successfully"
}
```

The Flutter service automatically extracts the `data` field when using the backend proxy.

## Troubleshooting

### Backend Not Starting

- Check Node.js is installed: `node --version` (should be 18+)
- Delete `node_modules` and `package-lock.json`, then `npm install` again
- Check if port 3001 is already in use

### CORS Still Happening

- Make sure backend is running on `http://localhost:3001`
- Verify Flutter is calling the backend URL (check console logs)
- Check `useBackendProxy` is set to `true` in `yagoutpay_config.dart`

### API Not Hitting

- Check backend console for incoming requests
- Verify Flutter logs show "Using: NestJS Backend Proxy"
- Check network tab in browser DevTools

## Switching Back to Direct API

If you want to use the direct YagoutPay API (for mobile apps or testing):

1. Set `useBackendProxy` to `false` in `lib/config/yagoutpay_config.dart`
2. The Flutter app will call YagoutPay API directly (CORS will occur on web)

## Production Deployment

For production:

1. Deploy NestJS backend to a server (e.g., Heroku, AWS, DigitalOcean)
2. Update `backendUrl` in `yagoutpay_config.dart` to production URL
3. Update CORS origin in `backend/src/main.ts` to allow your production domain

Example:
```dart
static const String backendUrl = 'https://api.yourdomain.com';
```

```typescript
app.enableCors({
  origin: ['https://yourdomain.com', 'https://www.yourdomain.com'],
  // ...
});
```

