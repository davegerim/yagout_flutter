class YagoutPayConfig {
  // Toggle this to switch between UAT and Production
  static const bool useUat = true;

  // Aggregator Hosted (Non-Seamless) - UAT
  static const String hostedUatUrl =
      'https://uatcheckout.yagoutpay.com/ms-transaction-core-1-0/paymentRedirection/checksumGatewayPage';

  // API Integration - UAT
  static const String apiUatUrl =
      'https://uatcheckout.yagoutpay.com/ms-transaction-core-1-0/apiRedirection/apiIntegration';

  // Encryption test (helper endpoint from docs) - UAT
  static const String encryptionTestUatUrl =
      'https://uatcheckout.yagoutpay.com/ms-transaction-core-1-0/othersRedirection/encryption';

  // Production URLs (to be provided by YagoutPay)
  static const String hostedProductionUrl =
      'https://checkout.yagoutpay.com/ms-transaction-core-1-0/paymentRedirection/checksumGatewayPage';
  static const String apiProductionUrl =
      'https://checkout.yagoutpay.com/ms-transaction-core-1-0/apiRedirection/apiIntegration';
  static const String encryptionTestProductionUrl =
      'https://checkout.yagoutpay.com/ms-transaction-core-1-0/othersRedirection/encryption';

  // Test merchant values provided in the doc (replace with your actual production keys when live)
  static const String aggregatorId = 'yagout';

  // Hosted sample - UAT (from documentation)
  static const String hostedTestMerchantId = '202504290002';
  static const String hostedTestKey =
      'neTdYIKd87JEj4C6ZoYjaeBiCoeOr40ZKBEI8EU/8lo=';

  // API sample - UAT (from documentation)
  static const String apiTestMerchantId = '202505090001';
  static const String apiTestKey =
      '6eUzH0ZdoVVBMTHrgdA0sqOFyKm54zojV4/faiSirkE=';

  // API pg_details sample from the guide - UAT (from documentation)
  static const String apiPgId = '67ee846571e740418d688c3f';
  static const String apiPaymode = 'WA';
  static const String apiSchemeId = '7';
  static const String apiWalletType = 'telebirr';

  // Production credentials (to be provided by YagoutPay)
  static const String hostedProductionMerchantId =
      'YOUR_PRODUCTION_MERCHANT_ID';
  static const String hostedProductionKey = 'YOUR_PRODUCTION_ENCRYPTION_KEY';
  static const String apiProductionMerchantId =
      'YOUR_PRODUCTION_API_MERCHANT_ID';
  static const String apiProductionKey = 'YOUR_PRODUCTION_API_ENCRYPTION_KEY';
  static const String apiProductionPgId = 'YOUR_PRODUCTION_PG_ID';
  static const String apiProductionPaymode = 'YOUR_PRODUCTION_PAYMODE';
  static const String apiProductionSchemeId = 'YOUR_PRODUCTION_SCHEME_ID';
  static const String apiProductionWalletType = 'YOUR_PRODUCTION_WALLET_TYPE';

  // Default values for required fields
  static const String defaultCountry = 'ETH';
  static const String defaultCurrency = 'ETB';
  static const String defaultTransactionType = 'SALE';
  static const String defaultChannel =
      'API'; // Changed from 'MOBILE' to 'API' for API integration

  // Getter methods for environment-specific values
  static String get hostedUrl => useUat ? hostedUatUrl : hostedProductionUrl;
  static String get apiUrl => useUat ? apiUatUrl : apiProductionUrl;
  static String get encryptionTestUrl =>
      useUat ? encryptionTestUatUrl : encryptionTestProductionUrl;

  static String get hostedMerchantId =>
      useUat ? hostedTestMerchantId : hostedProductionMerchantId;
  static String get hostedKey => useUat ? hostedTestKey : hostedProductionKey;

  static String get apiMerchantId =>
      useUat ? apiTestMerchantId : apiProductionMerchantId;
  static String get apiKey => useUat ? apiTestKey : apiProductionKey;

  static String get pgId => useUat ? apiPgId : apiProductionPgId;
  static String get paymode => useUat ? apiPaymode : apiProductionPaymode;
  static String get schemeId => useUat ? apiSchemeId : apiProductionSchemeId;
  static String get walletType =>
      useUat ? apiWalletType : apiProductionWalletType;
}
