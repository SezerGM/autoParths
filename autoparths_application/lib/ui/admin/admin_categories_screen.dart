import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../models/category.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
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
      await _apiClient.init();
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

  Future<void> _showAddEditCategoryDialog([Category? category]) async {
    final nameController = TextEditingController(text: category?.name);
    final slugController = TextEditingController(text: category?.slug);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Добавить категорию' : 'Редактировать категорию'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: slugController,
                decoration: const InputDecoration(labelText: 'Slug'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите slug';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'slug': slugController.text,
                });
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        if (category == null) {
          await _apiClient.createCategory(result['name']!, result['slug']!);
        } else {
          await _apiClient.updateCategory(category.id, result['name']!, result['slug']!);
        }
        _fetchCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(category == null ? 'Категория создана' : 'Категория обновлена'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение удаления'),
        content: Text('Вы уверены, что хотите удалить категорию "${category.name}"?'),
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
        await _apiClient.deleteCategory(category.id);
        _fetchCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Категория удалена')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при удалении: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление категориями (Админ)'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddEditCategoryDialog(),
          ),
        ],
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
                      subtitle: Text(category.slug),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddEditCategoryDialog(category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(category),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
} 