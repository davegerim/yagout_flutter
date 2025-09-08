class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? profileImage;

  // Billing details (required for fraud protection)
  final String? billAddress;
  final String? billCity;
  final String? billState;
  final String? billCountry;
  final String? billZip;

  // Shipping details (required for physical delivery)
  final String? shipAddress;
  final String? shipCity;
  final String? shipState;
  final String? shipCountry;
  final String? shipZip;
  final int? shipDays;
  final int? addressCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.profileImage,
    this.billAddress,
    this.billCity,
    this.billState,
    this.billCountry,
    this.billZip,
    this.shipAddress,
    this.shipCity,
    this.shipState,
    this.shipCountry,
    this.shipZip,
    this.shipDays,
    this.addressCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      profileImage: json['profileImage'],
      billAddress: json['billAddress'],
      billCity: json['billCity'],
      billState: json['billState'],
      billCountry: json['billCountry'],
      billZip: json['billZip'],
      shipAddress: json['shipAddress'],
      shipCity: json['shipCity'],
      shipState: json['shipState'],
      shipCountry: json['shipCountry'],
      shipZip: json['shipZip'],
      shipDays: json['shipDays'],
      addressCount: json['addressCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'billAddress': billAddress,
      'billCity': billCity,
      'billState': billState,
      'billCountry': billCountry,
      'billZip': billZip,
      'shipAddress': shipAddress,
      'shipCity': shipCity,
      'shipState': shipState,
      'shipCountry': shipCountry,
      'shipZip': shipZip,
      'shipDays': shipDays,
      'addressCount': addressCount,
    };
  }
}
