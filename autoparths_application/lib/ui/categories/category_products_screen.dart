import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/api_client.dart';
import '../main/item_build.dart'; // Предполагаем, что ItemBuild используется для отображения продуктов

class CategoryProductsScreen extends StatefulWidget {
  final String categorySlug;

  const CategoryProductsScreen({super.key, required this.categorySlug});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> products = [];
  Category? category;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCategoryAndProducts();
  }

  Future<void> _loadCategoryAndProducts() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Загружаем категорию
      final categories = await ApiClient().getCategories();
      category = categories.firstWhere(
        (c) => c.slug == widget.categorySlug,
        orElse: () => throw Exception('Категория не найдена'),
      );

      // Загружаем продукты
      final loadedProducts = await ApiClient().getProductsByCategory(widget.categorySlug);
      
      setState(() {
        products = loadedProducts;
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
      setState(() {
        isLoading = false;
        error = 'Не удалось загрузить данные. Пожалуйста, попробуйте позже.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category?.name ?? 'Загрузка...'),
        centerTitle: false,
        backgroundColor: Colors.lightBlue,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Text(error!),
                )
              : products.isEmpty
                  ? const Center(
                      child: Text('Продукты в данной категории не найдены'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ItemBuild(product: product),
                        );
                      },
                    ),
    );
  }
} 