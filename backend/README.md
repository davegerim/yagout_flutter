# YagoutPay Proxy Backend

NestJS backend to proxy YagoutPay API calls and avoid CORS issues in Flutter Web.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Start development server:
```bash
npm run start:dev
```

The backend will run on `http://localhost:3001`

## API Endpoint

**POST** `/api/payment/yagoutpay`

### Request Body:
```json
{
  "merchantId": "202508080001",
  "merchantRequest": "encrypted_data_here"
}
```

### Response:
```json
{
  "success": true,
  "status": 200,
  "data": { ... },
  "message": "Payment processed successfully"
}
```

## CORS Configuration

The backend is configured to allow requests from:
- `http://localhost:*` (any port)
- Common Flutter web ports (3000, 5000, 8080, etc.)

## Why This Solves CORS

- Flutter Web calls your NestJS backend (same origin or allowed CORS)
- NestJS backend calls YagoutPay API (server-to-server, no CORS)
- Response is returned to Flutter Web without CORS issues

