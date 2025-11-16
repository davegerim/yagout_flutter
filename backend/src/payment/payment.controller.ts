import { Controller, Post, Body, HttpException, HttpStatus } from '@nestjs/common';
import { PaymentService } from './payment.service';

@Controller('api/payment')
export class PaymentController {
  constructor(private readonly paymentService: PaymentService) {}

  @Post('yagoutpay')
  async processYagoutPayPayment(@Body() requestBody: any) {
    try {
      console.log('📥 Received payment request from Flutter');
      console.log('   Merchant ID:', requestBody.merchantId);
      console.log('   Has encrypted data:', !!requestBody.merchantRequest);

      if (!requestBody.merchantId || !requestBody.merchantRequest) {
        throw new HttpException(
          'Missing required fields: merchantId and merchantRequest',
          HttpStatus.BAD_REQUEST,
        );
      }

      const result = await this.paymentService.processPayment(requestBody);

      return {
        success: true,
        status: result.status,
        data: result.data,
        message: 'Payment processed successfully',
      };
    } catch (error: any) {
      console.error('❌ Payment processing error:', error);
      
      return {
        success: false,
        status: error.status || HttpStatus.INTERNAL_SERVER_ERROR,
        error: error.message || 'Payment processing failed',
        data: error.data || null,
      };
    }
  }
}

