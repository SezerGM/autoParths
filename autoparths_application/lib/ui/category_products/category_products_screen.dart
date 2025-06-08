import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../models/product.dart';
import '../main/item_build.dart'; // Переиспользуем виджет ItemBuild

class CategoryProductsScreen extends StatefulWidget {
  final String categorySlug; // Slug категории, который будет передан через маршрут

  const CategoryProductsScreen({super.key, required this.categorySlug});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProductsByCategory();
  }

  Future<void> _fetchProductsByCategory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _apiClient.init(); // Убедимся, что ApiClient инициализирован
      final products = await _apiClient.getProductsByCategory(widget.categorySlug);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
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
        title: Text('Товары категории: ${widget.categorySlug}'), // TODO: Возможно, отображать название категории
        centerTitle: false,
        backgroundColor: Colors.lightBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text('Ошибка загрузки товаров: $_error'),
                )
              : _products.isEmpty
                  ? const Center(
                      child: Text('В данной категории нет товаров.'),
                    )
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        // Переиспользуем виджет ItemBuild
                        return ItemBuild(
                          product: product,
                           
                        );
                      },
                    ),
    );
  }
} 