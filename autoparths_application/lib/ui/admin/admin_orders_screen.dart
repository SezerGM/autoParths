import 'package:flutter/material.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление заказами (Админ)'),
        backgroundColor: Colors.redAccent,
      ),
      body: const Center(
        child: Text('Экран управления заказами'),
      ),
    );
  }
} 