# Shoe Store Flutter App

A complete e-commerce shoe selling mobile app built with Flutter, featuring YagoutPay payment integration.

## 🚀 Features

- **Complete E-commerce Flow**: Product catalog, shopping cart, checkout, and order management
- **User Authentication**: Login/signup with persistent session management
- **Payment Integration**: YagoutPay payment gateway with AES encryption
- **Modern UI**: Material Design with custom Poppins fonts
- **State Management**: Provider pattern for efficient state management
- **Cross-Platform**: Runs on Android, iOS, Web, and Desktop

## 📱 Screens

- **Splash Screen**: Animated app loading with initialization
- **Authentication**: Login and signup screens
- **Home**: Product catalog with categories and search
- **Product Details**: Detailed product view with add to cart
- **Shopping Cart**: Cart management with quantity controls
- **Checkout**: Payment processing with YagoutPay integration
- **Orders**: Order history and tracking
- **Profile**: User profile and settings
- **Wishlist**: Saved products management

## 🛠️ Setup & Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Chrome browser (for web testing)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd yagout_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For web (recommended for testing)
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   ```

## 💳 YagoutPay Integration

### Configuration

The app is configured to use YagoutPay UAT environment for testing. Configuration is located in `lib/config/yagoutpay_config.dart`:

### Payment Flow

1. **Order Creation**: App generates unique order ID in format `OR-DOIT-XXXX`
2. **Data Encryption**: Payment data is encrypted using AES-256-CBC
3. **API Request**: Encrypted data sent to YagoutPay UAT endpoint
4. **Response Handling**: Decrypted response processed for payment status

### Testing Payments

- Use any valid email and phone number for testing
- Test amounts: Any amount (e.g., 100 ETB)
- The app uses mock authentication - any email/password combination works

## 🔧 Recent Fixes Applied

### 1. Asset Configuration Fix
- **Issue**: Missing `assets/icons/` directory causing build errors
- **Solution**: Removed unused `assets/icons/` reference from `pubspec.yaml`

### 2. Flutter Version Compatibility
- **Issue**: `CardTheme` compatibility error with newer Flutter versions
- **Solution**: Updated `CardTheme` to `CardThemeData` in `lib/utils/app_theme.dart`

## 📁 Project Structure

```
lib/
├── config/
│   └── yagoutpay_config.dart      # Payment gateway configuration
├── models/
│   ├── cart_item.dart            # Shopping cart item model
│   ├── order.dart                # Order model
│   ├── product.dart              # Product model
│   └── user.dart                 # User model
├── providers/
│   ├── auth_provider.dart        # Authentication state management
│   ├── cart_provider.dart        # Shopping cart state
│   ├── order_provider.dart       # Order management
│   ├── product_provider.dart     # Product catalog state
│   └── wishlist_provider.dart    # Wishlist management
├── screens/
│   ├── auth/                     # Login and signup screens
│   ├── cart/                     # Shopping cart screen
│   ├── checkout/                 # Checkout and payment screens
│   ├── home/                     # Home and product catalog
│   ├── orders/                   # Order history
│   ├── product/                  # Product details
│   ├── profile/                  # User profile
│   ├── search/                   # Product search
│   ├── wishlist/                 # Wishlist management
│   └── splash_screen.dart        # App loading screen
├── services/
│   ├── yagoutpay_service.dart    # Original payment service
│   └── yagoutpay_service_fixed.dart # Fixed payment service
├── utils/
│   ├── app_theme.dart            # App theme configuration
│   └── crypto/
│       └── aes_util.dart         # AES encryption utilities
├── widgets/
│   ├── category_chip.dart        # Category selection widget
│   └── product_card.dart         # Product display widget
└── main.dart                     # App entry point
```

## 🎨 UI/UX Features

- **Custom Theme**: Blue primary color scheme with Poppins font family
- **Responsive Design**: Adapts to different screen sizes
- **Smooth Animations**: Fade and scale animations on splash screen
- **Material Design**: Follows Material Design guidelines
- **Loading States**: Proper loading indicators throughout the app

## 🔐 Security Features

- **AES Encryption**: All payment data encrypted using AES-256-CBC
- **Secure Storage**: User data stored securely using SharedPreferences
- **Input Validation**: Form validation for user inputs
- **HTTPS Communication**: All API calls use secure HTTPS

## 🧪 Testing

### Manual Testing Checklist

- [ ] App launches successfully
- [ ] Splash screen animation works
- [ ] User can login/signup
- [ ] Product catalog loads
- [ ] Add to cart functionality
- [ ] Checkout process
- [ ] YagoutPay payment integration
- [ ] Order history display

### Test Credentials

- **Email**: Any valid email format (e.g., `test@example.com`)
- **Password**: Any non-empty password
- **Phone**: Any valid phone number format

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
# Deploy the build/web folder to your hosting service
```

### Android Deployment
```bash
flutter build apk --release
# Install the generated APK file
```

### iOS Deployment
```bash
flutter build ios --release
# Use Xcode to deploy to App Store
```

## 📝 Environment Configuration

### Production Environment (Future)
- Update `useUat = false` in `yagoutpay_config.dart`
- Replace production credentials when provided by YagoutPay

For issues related to:
- **Flutter App**: Check this README and code comments
- **YagoutPay Integration**: Refer to YagoutPay API documentation
- **Payment Processing**: Contact YagoutPay support

## 📄 License

This project is for educational and development purposes.

---

**Last Updated**: September 2024
**Flutter Version**: 3.35.3
**Dart Version**: 3.9.2
