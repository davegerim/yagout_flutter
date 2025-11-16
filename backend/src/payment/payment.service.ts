import { Injectable } from '@nestjs/common';
import axios from 'axios';
import * as https from 'https';

@Injectable()
export class PaymentService {
  private readonly yagoutPayApiUrl =
    'https://uatcheckout.yagoutpay.com/ms-transaction-core-1-0/apiRedirection/apiIntegration';

  async processPayment(requestBody: any): Promise<any> {
    try {
      console.log('📡 Proxying payment request to YagoutPay API');
      console.log('   URL:', this.yagoutPayApiUrl);
      console.log('   Request body length:', JSON.stringify(requestBody).length);

      // Create HTTPS agent that doesn't reject unauthorized certificates (for UAT)
      // In production, you should use proper certificate validation
      const httpsAgent = new https.Agent({
        rejectUnauthorized: false, // Disable SSL verification for UAT environment
      });

      const response = await axios.post(this.yagoutPayApiUrl, requestBody, {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        timeout: 30000, // 30 seconds timeout
        httpsAgent: httpsAgent, // Use custom HTTPS agent
      });

      console.log('✅ YagoutPay API response received');
      console.log('   Status:', response.status);
      console.log('   Response data keys:', Object.keys(response.data || {}));

      return {
        status: response.status,
        data: response.data,
        headers: response.headers,
      };
    } catch (error: any) {
      console.error('❌ YagoutPay API error:', error.message);
      
      // If axios error, extract response if available
      if (error.response) {
        return {
          status: error.response.status,
          data: error.response.data,
          headers: error.response.headers,
          error: error.message,
        };
      }

      // Network or other errors
      throw {
        status: 500,
        message: error.message || 'Payment API request failed',
        error: 'NETWORK_ERROR',
      };
    }
  }
}

