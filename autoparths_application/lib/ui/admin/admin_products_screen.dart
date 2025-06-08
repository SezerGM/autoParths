import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../models/product.dart';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Убедимся, что ApiClient инициализирован (токен загружен)
      await _apiClient.init();
      print('Загрузка продуктов для админ-панели...');
      final products = await _apiClient.getProducts();
      print('Получены продукты для админ-панели: ${products.length} шт.');
      // print('Первые 5 продуктов: ${products.take(5).map((p) => p.toJson()).toList()}');
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка при загрузке продуктов для админ-панели: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление товарами (Админ)'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              // Переход на экран добавления товара
              final result = await context.push<bool>('/admin/products/edit');
              // Если вернулись с результатом true, обновляем список
              if (result == true) {
                _fetchProducts();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text('Ошибка загрузки товаров: $_error'),
                )
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      leading: product.photo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.memory(
                                Uint8List.fromList(List<int>.from(product.photo!['data'])),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const CircleAvatar(child: Icon(Icons.error));
                                },
                              ),
                            )
                          : const CircleAvatar(child: Icon(Icons.image_not_supported)),
                      title: Text(product.name),
                      subtitle: Text('${product.price} ₽ - ${product.categoryName}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              // Переход на экран редактирования товара
                              final result = await context.push<bool>('/admin/products/edit', extra: product);
                              // Если вернулись с результатом true, обновляем список
                              if (result == true) {
                                _fetchProducts();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Показываем диалог подтверждения
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Подтверждение удаления'),
                                  content: Text('Вы уверены, что хотите удалить товар "${product.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Отмена'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldDelete == true) {
                                try {
                                  // Удаляем товар
                                  await _apiClient.deleteProduct(product.id);
                                  // Обновляем список товаров
                                  _fetchProducts();
                                  // Показываем уведомление об успехе
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Товар успешно удален')),
                                    );
                                  }
                                } catch (e) {
                                  // Показываем ошибку
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Ошибка при удалении товара: $e')),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
} 