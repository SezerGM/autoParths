import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель администратора'),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Добро пожаловать в панель администратора!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Здесь будут кнопки для перехода к разделам управления
            ElevatedButton(
              onPressed: () {
                context.go('/admin/products');
              },
              child: const Text('Управление товарами'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.go('/admin/categories');
              },
              child: const Text('Управление категориями'),
            ),
             const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.go('/admin/users');
              },
              child: const Text('Управление пользователями'),
            ),
             const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.go('/admin/orders');
              },
              child: const Text('Управление заказами'),
            ),
          ],
        ),
      ),
    );
  }
} 