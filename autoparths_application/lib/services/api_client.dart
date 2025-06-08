// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'dart:io';

class ApiClient {
  static const String baseUrl = 'http://192.168.0.148:8000/api/v1';
  static const String _tokenKey = 'auth_token';
  final Dio dio;
  String? _token;
  final _logger = Logger('ApiClient');
  
  ApiClient() : dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    contentType: 'application/json',
    validateStatus: (status) => status! < 500,
  )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      print('Загружен токен из хранилища: $_token');
      _updateAuthorizationHeader();
    } catch (e) {
      print('Ошибка при загрузке токена: $e');
    }
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('Токен сохранен в хранилище: $token');
    _updateAuthorizationHeader();
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('Токен удален из хранилища');
    _updateAuthorizationHeader();
  }

  bool get hasToken => _token != null;

  void _updateAuthorizationHeader() {
    if (_token != null) {
      dio.options.headers['Authorization'] = 'Bearer $_token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  // Существующий метод получения продуктов
  Future<List<Product>> getProducts() async {
    try {
      final response = await dio.get('/product/get-product');
      final List<dynamic> productsJson = response.data['products'];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  // Новый метод получения категорий
  Future<List<Category>> getCategories() async {
    try {
      print('Запрашиваем список категорий...');
      final response = await dio.get('/category/get-category');
      print('Получен ответ с категориями: ${response.data}');
      final List<dynamic> categoriesJson = response.data['category'];
      print('Количество категорий: ${categoriesJson.length}');
      final categories = categoriesJson.map((json) => Category.fromJson(json)).toList();
      print('Преобразованные категории: ${categories.map((c) => '${c.name} (${c.slug})').join(', ')}');
      return categories;
    } catch (e) {
      print('Ошибка при загрузке категорий: $e');
      throw Exception('Failed to load categories: $e');
    }
  }

  // Метод получения продуктов по категории
  Future<List<Product>> getProductsByCategory(String slug) async {
    try {
      print('Запрашиваем продукты для категории со slug: $slug');
      final response = await dio.get('/product/product-category/$slug');
      print('Получен ответ с продуктами категории: ${response.data}');
      
      if (response.data == null || !response.data.containsKey('products')) {
        print('Неверный формат ответа: ${response.data}');
        return [];
      }
      
      final List<dynamic> productsJson = response.data['products'];
      print('Количество продуктов в категории: ${productsJson.length}');
      
      final products = productsJson.map((json) => Product.fromJson(json)).toList();
      print('Преобразованные продукты: ${products.map((p) => p.name).join(', ')}');
      
      return products;
    } catch (e) {
      print('Ошибка при загрузке продуктов категории: $e');
      throw Exception('Failed to load products by category: $e');
    }
  }

  // Метод получения продукта по slug
  Future<Product> getProductBySlug(String slug) async {
    try {
      print('Запрашиваем продукт по slug: $slug');
      final response = await dio.get('/product/get-product/$slug');
      print('Получен ответ с продуктом: ${response.data}');

      if (response.data == null || !response.data.containsKey('product')) {
        print('Неверный формат ответа для продукта по slug: ${response.data}');
        throw Exception('Неверный формат ответа сервера.');
      }

      final productJson = response.data['product'];
      final product = Product.fromJson(productJson);
      print('Преобразованный продукт: ${product.name}');

      return product;
    } catch (e) {
      print('Ошибка при загрузке продукта по slug: $e');
      throw Exception('Не удалось загрузить продукт: $e');
    }
  }

  // Метод удаления продукта по ID
  Future<void> deleteProduct(String productId) async {
    try {
      _logger.info('Отправляем запрос на удаление продукта с ID: $productId');
      final response = await dio.delete('/product/$productId');
      _logger.info('Получен ответ на запрос удаления продукта: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 204) { // 200 или 204 обычно означают успешное удаление
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.data['message'] ?? 'Не удалось удалить продукт',
        );
      }
    } on DioException catch (e) {
      _logger.severe('Ошибка при удалении продукта: ${e.response?.data ?? e.message}');
      throw Exception('Ошибка при удалении продукта: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      _logger.severe('Неизвестная ошибка при удалении продукта: $e');
      throw Exception('Ошибка при удалении продукта: $e');
    }
  }

  // Метод поиска продуктов по ключевому слову
  Future<List<Product>> searchProducts(String keyword) async {
    try {
      print('Выполняем поиск по ключевому слову: $keyword');
      final response = await dio.get('/product/search/$keyword');
      print('Получен ответ с результатами поиска: ${response.data}');

      if (response.data == null || !response.data.containsKey('products')) {
        print('Неверный формат ответа для поиска: ${response.data}');
        return [];
      }

      final List<dynamic> productsJson = response.data['products'] ?? [];
      final products = productsJson.map((json) => Product.fromJson(json)).toList();
      print('Найдено продуктов: ${products.length}');

      return products;
    } catch (e) {
      print('Ошибка при поиске продуктов: $e');
      throw Exception('Не удалось выполнить поиск продуктов: $e');
    }
  }

  // Метод создания новой категории
  Future<Category> createCategory(String name, String slug) async {
    try {
      print('Создаем новую категорию: $name ($slug)');
      final response = await dio.post(
        '/category/create-category',
        data: {
          'name': name,
          'slug': slug,
        },
      );
      print('Получен ответ при создании категории: ${response.data}');

      if (response.data == null || !response.data.containsKey('category')) {
        throw Exception('Неверный формат ответа сервера при создании категории');
      }

      return Category.fromJson(response.data['category']);
    } catch (e) {
      print('Ошибка при создании категории: $e');
      throw Exception('Не удалось создать категорию: $e');
    }
  }

  // Метод обновления категории
  Future<Category> updateCategory(String id, String name, String slug) async {
    try {
      print('Обновляем категорию $id: $name ($slug)');
      final response = await dio.put(
        '/category/$id',
        data: {
          'name': name,
          'slug': slug,
        },
      );
      print('Получен ответ при обновлении категории: ${response.data}');

      if (response.data == null || !response.data.containsKey('category')) {
        throw Exception('Неверный формат ответа сервера при обновлении категории');
      }

      return Category.fromJson(response.data['category']);
    } catch (e) {
      print('Ошибка при обновлении категории: $e');
      throw Exception('Не удалось обновить категорию: $e');
    }
  }

  // Метод удаления категории
  Future<void> deleteCategory(String id) async {
    try {
      print('Удаляем категорию с ID: $id');
      final response = await dio.delete('/category/$id');
      print('Получен ответ при удалении категории: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Не удалось удалить категорию: ${response.data['message'] ?? 'Неизвестная ошибка'}');
      }
    } catch (e) {
      print('Ошибка при удалении категории: $e');
      throw Exception('Не удалось удалить категорию: $e');
    }
  }

  // Метод для загрузки изображения
  Future<String> uploadImage(File imageFile) async {
    try {
      print('Загружаем изображение: ${imageFile.path}');
      
      // Создаем FormData для отправки файла
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await dio.post(
        '/upload/image',
        data: formData,
      );

      print('Получен ответ при загрузке изображения: ${response.data}');

      if (response.data == null || !response.data.containsKey('url')) {
        throw Exception('Неверный формат ответа сервера при загрузке изображения');
      }

      return response.data['url'];
    } catch (e) {
      print('Ошибка при загрузке изображения: $e');
      throw Exception('Не удалось загрузить изображение: $e');
    }
  }

  // Обновляем метод создания продукта для поддержки загрузки изображения
  Future<Product> createProduct({
    required String name,
    required String slug,
    required String description,
    required double price,
    required int categoryId,
    String? image,
  }) async {
    try {
      print('Создаем новый продукт: $name ($slug)');
      
      // Если есть изображение, загружаем его
      String? imageUrl;
      if (image != null) {
        imageUrl = await uploadImage(File(image));
      }

      final response = await dio.post(
        '/product/create-product',
        data: {
          'name': name,
          'slug': slug,
          'description': description,
          'price': price,
          'category_id': categoryId,
          if (imageUrl != null) 'image': imageUrl,
        },
      );
      print('Получен ответ при создании продукта: ${response.data}');

      if (response.data == null || !response.data.containsKey('product')) {
        throw Exception('Неверный формат ответа сервера при создании продукта');
      }

      return Product.fromJson(response.data['product']);
    } catch (e) {
      print('Ошибка при создании продукта: $e');
      throw Exception('Не удалось создать продукт: $e');
    }
  }

  // Обновляем метод обновления продукта для поддержки загрузки изображения
  Future<Product> updateProduct({
    required int id,
    String? name,
    String? slug,
    String? description,
    double? price,
    int? categoryId,
    String? image,
  }) async {
    try {
      print('Обновляем продукт с ID: $id');
      
      // Если есть новое изображение, загружаем его
      String? imageUrl;
      if (image != null) {
        imageUrl = await uploadImage(File(image));
      }

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (slug != null) data['slug'] = slug;
      if (description != null) data['description'] = description;
      if (price != null) data['price'] = price;
      if (categoryId != null) data['category_id'] = categoryId;
      if (imageUrl != null) data['image'] = imageUrl;

      final response = await dio.put(
        '/product/$id',
        data: data,
      );
      print('Получен ответ при обновлении продукта: ${response.data}');

      if (response.data == null || !response.data.containsKey('product')) {
        throw Exception('Неверный формат ответа сервера при обновлении продукта');
      }

      return Product.fromJson(response.data['product']);
    } catch (e) {
      print('Ошибка при обновлении продукта: $e');
      throw Exception('Не удалось обновить продукт: $e');
    }
  }
}