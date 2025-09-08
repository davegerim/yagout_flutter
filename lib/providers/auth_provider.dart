import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null) {
        // In a real app, you would validate the token here
        _isAuthenticated = true;
        _user = User(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+1234567890',
          address: '123 Main St, City, Country',
        );
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful login
      if (email.isNotEmpty && password.isNotEmpty) {
        _user = User(
          id: '1',
          name: 'John Doe',
          email: email,
          phone: '+1234567890',
          address: '123 Main St, City, Country',
        );
        _isAuthenticated = true;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', 'logged_in');

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful signup
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        _user = User(id: '1', name: name, email: email);
        _isAuthenticated = true;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', 'logged_in');

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Signup error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _user = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    notifyListeners();
  }
}
