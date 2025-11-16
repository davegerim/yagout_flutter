import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS for Flutter web app
  // Allow any origin for development (more permissive)
  app.enableCors({
    origin: true, // Allow all origins for development
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Accept', 'Authorization', 'X-Requested-With'],
    exposedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
    preflightContinue: false,
    optionsSuccessStatus: 200, // Some legacy browsers (IE11, various SmartTVs) choke on 204
  });

  const port = process.env.PORT || 3001;
  await app.listen(port);
  console.log(`🚀 NestJS Backend running on http://localhost:${port}`);
  console.log(`📡 Proxy endpoint: http://localhost:${port}/api/payment/yagoutpay`);
}

bootstrap();

