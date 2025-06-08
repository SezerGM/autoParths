import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../models/category.dart';
import 'package:go_router/go_router.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiClient _apiClient = ApiClient();
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _apiClient.init(); // Убедимся, что ApiClient инициализирован
      final categories = await _apiClient.getCategories();
      setState(() {
        _categories = categories;
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
        title: const Text('Категории'),
        centerTitle: false,
        backgroundColor: Colors.lightBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text('Ошибка загрузки категорий: $_error'),
                )
              : ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return ListTile(
                      title: Text(category.name),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Переход на экран продуктов по категории
                        print('Нажата категория: ${category.name}');
                        context.push('/category-products/${category.slug}');
                      },
                    );
                  },               ),
    );
  }
}