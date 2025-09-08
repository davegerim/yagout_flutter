class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double originalPrice;
  final String description;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isPopular;
  final bool isNew;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.originalPrice,
    required this.description,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.category,
    required this.rating,
    required this.reviewCount,
    this.isPopular = false,
    this.isNew = false,
    required this.stock,
  });

  double get discountPercentage {
    if (originalPrice <= price) return 0;
    return ((originalPrice - price) / originalPrice * 100);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      price: json['price'].toDouble(),
      originalPrice: json['originalPrice'].toDouble(),
      description: json['description'],
      images: List<String>.from(json['images']),
      sizes: List<String>.from(json['sizes']),
      colors: List<String>.from(json['colors']),
      category: json['category'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      isPopular: json['isPopular'] ?? false,
      isNew: json['isNew'] ?? false,
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'originalPrice': originalPrice,
      'description': description,
      'images': images,
      'sizes': sizes,
      'colors': colors,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'isPopular': isPopular,
      'isNew': isNew,
      'stock': stock,
    };
  }
}
