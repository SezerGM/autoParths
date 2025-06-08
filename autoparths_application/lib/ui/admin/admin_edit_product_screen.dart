import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../services/api_client.dart';
import '../../models/product.dart';
import 'package:image_picker/image_picker.dart'; // Для выбора изображения
import 'dart:io'; // Для работы с файлами
import '../../models/category.dart'; // Для выбора категории

class AdminEditProductScreen extends StatefulWidget {
  final Product? product; // Если передан товар, значит, это режим редактирования

  const AdminEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _slugController = TextEditingController(); // Возможно, slug тоже редактируется/создается

  Category? _selectedCategory; // Для выбора категории
  List<Category> _categories = []; // Список категорий для выбора
  bool _isLoadingCategories = false;

  File? _imageFile; // Для выбранного изображения
  bool _isLoading = false;
  String? _errorMessage;

  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    // Если передан товар, заполняем поля его данными
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
      _slugController.text = widget.product!.slug; // Предполагаем, что slug можно редактировать или он генерируется
      // TODO: Загрузить текущее изображение, если есть
      // TODO: Выбрать текущую категорию widget.product.category
    }
    _fetchCategories(); // Загружаем список категорий для выпадающего списка
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
     setState(() {
       _isLoadingCategories = true;
     });
     try {
       await _apiClient.init(); // Убедимся, что ApiClient инициализирован
       _categories = await _apiClient.getCategories();
       // TODO: Если в режиме редактирования, установить _selectedCategory на основе widget.product.category
       setState(() {
         _isLoadingCategories = false;
       });
     } catch (e) {
        // TODO: Обработка ошибки загрузки категорий
       setState(() {
         _isLoadingCategories = false;
       });
     }
   }

   Future<void> _pickImage() async {
     final picker = ImagePicker();
     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

     if (pickedFile != null) {
       setState(() {
         _imageFile = File(pickedFile.path);
       });
     }
   }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() {
        _errorMessage = 'Пожалуйста, выберите категорию';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiClient.init(); // Убедимся, что ApiClient инициализирован

      final price = double.parse(_priceController.text);
      final categoryId = int.parse(_selectedCategory!.id);

      if (widget.product == null) {
        // Создание нового продукта
        await _apiClient.createProduct(
          name: _nameController.text,
          slug: _slugController.text,
          description: _descriptionController.text,
          price: price,
          categoryId: categoryId,
          image: _imageFile?.path, // TODO: Реализовать загрузку изображения
        );
      } else {
        // Обновление существующего продукта
        await _apiClient.updateProduct(
          id: int.parse(widget.product!.id),
          name: _nameController.text,
          slug: _slugController.text,
          description: _descriptionController.text,
          price: price,
          categoryId: categoryId,
          image: _imageFile?.path, // TODO: Реализовать загрузку изображения
        );
      }

      // После успешного сохранения:
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null ? 'Товар успешно добавлен' : 'Товар успешно обновлен'),
          ),
        );
        Navigator.of(context).pop(true); // Возвращаем true для обновления списка
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data['message'] ?? e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Добавить товар' : 'Редактировать товар'),
        backgroundColor: Colors.redAccent,
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator()) // Индикатор загрузки категорий
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Название товара'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите название товара';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Цена'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите цену';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Пожалуйста, введите корректную цену';
                        }
                        return null;
                      },
                    ),
                     const SizedBox(height: 16),
                    TextFormField(
                      controller: _slugController,
                      decoration: const InputDecoration(labelText: 'Slug (уникальный идентификатор)'),
                      validator: (value) {
                         if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите slug';
                        }
                        // TODO: Добавить валидацию на уникальность slug при добавлении нового товара
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Описание'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите описание';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                     // Выпадающий список для выбора категории
                     DropdownButtonFormField<Category>(
                        decoration: const InputDecoration(labelText: 'Категория'),
                        value: _selectedCategory, // TODO: Установить значение по умолчанию при редактировании
                        items: _categories.map((category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Пожалуйста, выберите категорию';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),

                    // Виджет для выбора и отображения изображения
                     GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                           height: 150,
                           decoration: BoxDecoration(
                             color: Colors.grey[200],
                             borderRadius: BorderRadius.circular(8.0),
                             border: Border.all(color: Colors.grey),
                           ),
                           alignment: Alignment.center,
                           child: _imageFile != null
                               ? Image.file(_imageFile!, fit: BoxFit.cover) // Отображаем выбранное изображение
                               // TODO: Отображать текущее изображение товара при редактировании
                               : Column(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Icon(Icons.camera_alt, size: 40, color: Colors.grey[700]),
                                     SizedBox(height: 8),
                                     Text('Выберите изображение', style: TextStyle(color: Colors.grey[700])), 
                                   ],
                                 ),
                        ),
                     ),
                    const SizedBox(height: 24),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(widget.product == null ? 'Добавить товар' : 'Сохранить изменения'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.redAccent,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                       ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 