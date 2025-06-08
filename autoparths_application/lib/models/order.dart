
import 'package:autoparths_application/models/product.dart'; // Импортируем Product для OrderItem

class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 0,
    );
  }
}

class Order {
  final String id;
  final List<OrderItem> products;
  final double amount;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.products,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final List<dynamic> productsJson = json['products'] ?? [];
    final products = productsJson.map((itemJson) => OrderItem.fromJson(itemJson)).toList();

    return Order(
      id: json['_id'] ?? '',
      products: products,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 