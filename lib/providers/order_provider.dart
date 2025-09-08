import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersData = prefs.getString('orders');

      if (ordersData != null) {
        final List<dynamic> decodedData = json.decode(ordersData);
        _orders = decodedData.map((order) => Order.fromJson(order)).toList();
      }
    } catch (e) {
      print('Error loading orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersData = json.encode(
        _orders.map((order) => order.toJson()).toList(),
      );
      await prefs.setString('orders', ordersData);
    } catch (e) {
      print('Error saving orders: $e');
    }
  }

  Future<String> placeOrder(
    List<CartItem> items,
    double totalAmount,
    String shippingAddress,
    String paymentMethod, {
    String? yagoutPayOrderId, // Optional YagoutPay order ID
  }) async {
    // Use YagoutPay order ID if provided, otherwise generate internal ID
    final orderId =
        yagoutPayOrderId ?? DateTime.now().millisecondsSinceEpoch.toString();

    final order = Order(
      id: orderId,
      items: items,
      totalAmount: totalAmount,
      status: 'Processing',
      orderDate: DateTime.now(),
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
    );

    _orders.insert(0, order);
    await _saveOrders();
    notifyListeners();

    return orderId;
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }
}
