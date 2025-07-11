import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление пользователями (Админ)'),
        backgroundColor: Colors.redAccent,
      ),
      body: const Center(
        child: Text('Экран управления пользователями'),
      ),
    );
  }
} 