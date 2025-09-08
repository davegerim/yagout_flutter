import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items => _items;
  int get itemCount => _items.length;

  Future<void> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistData = prefs.getString('wishlist_items');

      if (wishlistData != null) {
        final List<dynamic> decodedData = json.decode(wishlistData);
        _items = decodedData.map((item) => Product.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistData = json.encode(
        _items.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('wishlist_items', wishlistData);
    } catch (e) {
      print('Error saving wishlist: $e');
    }
  }

  void toggleWishlist(Product product) {
    final existingIndex = _items.indexWhere((item) => item.id == product.id);

    if (existingIndex >= 0) {
      _items.removeAt(existingIndex);
    } else {
      _items.add(product);
    }

    _saveWishlist();
    notifyListeners();
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }
}
