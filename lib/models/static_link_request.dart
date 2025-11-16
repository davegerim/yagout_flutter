class StaticLinkRequest {
  final String reqUserId;
  final String meId;
  final String amount;
  final String customerEmail;
  final String mobileNo;
  final String expiryDate;
  final List<String> mediaType;
  final String orderId;
  final String firstName;
  final String lastName;
  final String product;
  final String dialCode;
  final String failureUrl;
  final String successUrl;
  final String country;
  final String currency;

  StaticLinkRequest({
    required this.reqUserId,
    required this.meId,
    required this.amount,
    required this.customerEmail,
    required this.mobileNo,
    required this.expiryDate,
    required this.mediaType,
    required this.orderId,
    required this.firstName,
    required this.lastName,
    required this.product,
    required this.dialCode,
    required this.failureUrl,
    required this.successUrl,
    required this.country,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'req_user_id': reqUserId,
      'me_id': meId,
      'amount': amount,
      'customer_email': customerEmail,
      'mobile_no': mobileNo,
      'expiry_date': expiryDate,
      'media_type': mediaType,
      'order_id': orderId,
      'first_name': firstName,
      'last_name': lastName,
      'product': product,
      'dial_code': dialCode,
      'failure_url': failureUrl,
      'success_url': successUrl,
      'country': country,
      'currency': currency,
    };
  }

  factory StaticLinkRequest.fromJson(Map<String, dynamic> json) {
    return StaticLinkRequest(
      reqUserId: json['req_user_id'] ?? '',
      meId: json['me_id'] ?? '',
      amount: json['amount'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      mediaType: List<String>.from(json['media_type'] ?? []),
      orderId: json['order_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      product: json['product'] ?? '',
      dialCode: json['dial_code'] ?? '',
      failureUrl: json['failure_url'] ?? '',
      successUrl: json['success_url'] ?? '',
      country: json['country'] ?? '',
      currency: json['currency'] ?? '',
    );
  }
}

