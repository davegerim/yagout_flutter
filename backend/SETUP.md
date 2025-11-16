# NestJS Backend Setup Guide

## Quick Start

1. **Install Node.js** (if not already installed)
   - Download from: https://nodejs.org/
   - Verify installation: `node --version` and `npm --version`

2. **Install Dependencies**
   ```bash
   cd backend
   npm install
   ```

3. **Start the Backend**
   ```bash
   npm run start:dev
   ```

   The backend will start on `http://localhost:3001`

4. **Verify it's Running**
   - You should see: `🚀 NestJS Backend running on http://localhost:3001`
   - Open browser: http://localhost:3001/api/payment/yagoutpay (should show error, but confirms server is running)

## How It Works

1. **Flutter Web** → Calls `http://localhost:3001/api/payment/yagoutpay` (no CORS issue)
2. **NestJS Backend** → Calls `https://uatcheckout.yagoutpay.com/...` (server-to-server, no CORS)
3. **Response** → NestJS returns YagoutPay response to Flutter

## Testing

You can test the endpoint with curl:

```bash
curl -X POST http://localhost:3001/api/payment/yagoutpay \
  -H "Content-Type: application/json" \
  -d '{
    "merchantId": "202508080001",
    "merchantRequest": "encrypted_data_here"
  }'
```

## Troubleshooting

- **Port 3001 already in use?** Change the port in `src/main.ts` or set `PORT` environment variable
- **CORS still happening?** Make sure the backend is running and Flutter is calling the backend URL
- **Backend not starting?** Check Node.js version (should be 18+), delete `node_modules` and `package-lock.json`, then `npm install` again

