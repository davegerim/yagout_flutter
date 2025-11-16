import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    // Defer initialization until after the build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Initialize providers
    await context.read<AuthProvider>().checkAuthStatus();
    await context.read<ProductProvider>().loadProducts();
    await context.read<CartProvider>().loadCart();
    await context.read<WishlistProvider>().loadWishlist();

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Shoe Store',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Step into Style',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 50),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
