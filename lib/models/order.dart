import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String shippingAddress;
  final String paymentMethod;

  // Additional fields required by YagoutPay
  final String? country;
  final String? currency;
  final String? transactionType;
  final String? successUrl;
  final String? failureUrl;
  final String? channel;

  // UDF fields for additional transaction information
  final String? udf1;
  final String? udf2;
  final String? udf3;
  final String? udf4;
  final String? udf5;
  final String? udf6;
  final String? udf7;

  // Item details
  final int? itemCount;
  final String? itemValue;
  final String? itemCategory;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.shippingAddress,
    required this.paymentMethod,
    this.country,
    this.currency,
    this.transactionType,
    this.successUrl,
    this.failureUrl,
    this.channel,
    this.udf1,
    this.udf2,
    this.udf3,
    this.udf4,
    this.udf5,
    this.udf6,
    this.udf7,
    this.itemCount,
    this.itemValue,
    this.itemCategory,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      status: json['status'],
      orderDate: DateTime.parse(json['orderDate']),
      shippingAddress: json['shippingAddress'],
      paymentMethod: json['paymentMethod'],
      country: json['country'],
      currency: json['currency'],
      transactionType: json['transactionType'],
      successUrl: json['successUrl'],
      failureUrl: json['failureUrl'],
      channel: json['channel'],
      udf1: json['udf1'],
      udf2: json['udf2'],
      udf3: json['udf3'],
      udf4: json['udf4'],
      udf5: json['udf5'],
      udf6: json['udf6'],
      udf7: json['udf7'],
      itemCount: json['itemCount'],
      itemValue: json['itemValue'],
      itemCategory: json['itemCategory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'country': country,
      'currency': currency,
      'transactionType': transactionType,
      'successUrl': successUrl,
      'failureUrl': failureUrl,
      'channel': channel,
      'udf1': udf1,
      'udf2': udf2,
      'udf3': udf3,
      'udf4': udf4,
      'udf5': udf5,
      'udf6': udf6,
      'udf7': udf7,
      'itemCount': itemCount,
      'itemValue': itemValue,
      'itemCategory': itemCategory,
    };
  }
}
