import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories => [
    'All',
    'Running',
    'Casual',
    'Formal',
    'Sports',
    'Sneakers',
  ];

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _products = [
        Product(
          id: '1',
          name: 'Air Max 270',
          brand: 'Nike',
          price: 150.0,
          originalPrice: 200.0,
          description:
              'The Nike Air Max 270 delivers visible cushioning under every step.',
          images: [
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500',
          ],
          sizes: ['7', '8', '9', '10', '11'],
          colors: ['Black', 'White', 'Red'],
          category: 'Running',
          rating: 4.5,
          reviewCount: 128,
          isPopular: true,
          stock: 50,
        ),
        Product(
          id: '2',
          name: 'Stan Smith',
          brand: 'Adidas',
          price: 80.0,
          originalPrice: 100.0,
          description:
              'Clean and simple, the adidas Stan Smith shoes are a timeless icon.',
          images: [
            'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=500',
            'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?w=500',
          ],
          sizes: ['6', '7', '8', '9', '10'],
          colors: ['White', 'Green'],
          category: 'Casual',
          rating: 4.3,
          reviewCount: 89,
          isNew: true,
          stock: 30,
        ),
        Product(
          id: '3',
          name: 'Chuck Taylor',
          brand: 'Converse',
          price: 60.0,
          originalPrice: 75.0,
          description: 'The iconic Chuck Taylor All Star sneaker.',
          images: [
            'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=500',
            'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=500',
          ],
          sizes: ['6', '7', '8', '9', '10', '11'],
          colors: ['Black', 'White', 'Red', 'Blue'],
          category: 'Sneakers',
          rating: 4.2,
          reviewCount: 156,
          stock: 25,
        ),
        Product(
          id: '4',
          name: 'Ultra Boost',
          brand: 'Adidas',
          price: 180.0,
          originalPrice: 220.0,
          description:
              'Experience endless energy return with Boost technology.',
          images: [
            'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=500',
            'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=500',
          ],
          sizes: ['7', '8', '9', '10', '11', '12'],
          colors: ['Black', 'White', 'Grey'],
          category: 'Running',
          rating: 4.7,
          reviewCount: 203,
          isPopular: true,
          stock: 40,
        ),
        Product(
          id: '5',
          name: 'Air Force 1',
          brand: 'Nike',
          price: 90.0,
          originalPrice: 110.0,
          description: 'The radiance lives on in the Nike Air Force 1.',
          images: [
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500',
            'https://images.unsplash.com/photo-1600269452121-4f2416e55c28?w=500',
          ],
          sizes: ['6', '7', '8', '9', '10', '11'],
          colors: ['White', 'Black', 'Red'],
          category: 'Casual',
          rating: 4.4,
          reviewCount: 167,
          stock: 35,
        ),
      ];

      _filteredProducts = List.from(_products);
    } catch (e) {
      print('Error loading products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _filterProducts();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _filterProducts();
  }

  void _filterProducts() {
    _filteredProducts =
        _products.where((product) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.brand.toLowerCase().contains(_searchQuery.toLowerCase());

          final matchesCategory =
              _selectedCategory == 'All' ||
              product.category == _selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
