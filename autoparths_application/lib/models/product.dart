// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryName;
  final String categoryId;
  final int quantity;
  final String slug;
  final Map<String, dynamic>? photo;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryName,
    required this.categoryId,
    required this.quantity,
    required this.slug,
    this.photo,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      categoryName: category?['name'] ?? '',
      categoryId: category?['_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      slug: json['slug'] ?? '',
      photo: json['photo'] as Map<String, dynamic>?,
    );
  }
}