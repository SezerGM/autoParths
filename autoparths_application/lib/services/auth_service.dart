import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/order.dart';
import 'api_client.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.0.148:8000/api/v1';
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<void> init() async {
    await _apiClient.init();
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'address': address,
        },
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        await _apiClient.setToken(response.data['token']);
        return user;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Ошибка регистрации: ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Ошибка регистрации: ${e.response?.data ?? e.message}');
    }
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Отправляем запрос на вход...');
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('Получен ответ от сервера: ${response.data}');

      if (response.statusCode == 200) {
        print('Статус ответа: ${response.statusCode}');
        
        if (response.data['success'] == true) {
          final userData = response.data['user'] as Map<String, dynamic>;
          print('Данные пользователя из ответа: $userData');
          print('Роль пользователя: ${userData['role']}');
          print('Токен из ответа: ${response.data['token']}');
          
          // Создаем объект пользователя с данными из ответа
          final user = User.fromJson({
            ...userData,
            'token': response.data['token'],
          });
          
          print('Созданный объект пользователя: ${user.toJson()}');
          print('Роль пользователя после создания объекта: ${user.role}');
          print('isAdmin: ${user.isAdmin}');
          await _apiClient.setToken(response.data['token']);
          return user;
        } else {
          throw Exception('Ошибка входа: ${response.data['message']}');
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Ошибка входа: ${response.data}',
        );
      }
    } on DioException catch (e) {
      print('Ошибка Dio при входе: ${e.response?.data ?? e.message}');
      throw Exception('Ошибка входа: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Неизвестная ошибка при входе: $e');
      throw Exception('Ошибка входа: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Ошибка восстановления пароля: ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Ошибка восстановления пароля: ${e.response?.data ?? e.message}');
    }
  }

  Future<List<Order>> getOrders(String token) async {
    try {
      // Убедимся, что токен загружен перед выполнением запроса
      if (!_apiClient.hasToken) {
        await _apiClient.init();
      }
      // Если после инициализации токен все еще null, возможно, пользователь не авторизован
      if (!_apiClient.hasToken) {
        throw Exception('Пользователь не авторизован или токен не загружен.');
      }

      final response = await _apiClient.dio.get(
        '/orders',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = response.data['data'];
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка при получении заказов: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Ошибка при получении заказов: ${e.message}');
    }
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? password,
    String? phone,
    String? address,
  }) async {
    try {
      print('Отправляем запрос на обновление профиля...');
      // Убедимся, что токен загружен перед выполнением запроса
      if (!_apiClient.hasToken) {
        await _apiClient.init();
      }
      // Если после инициализации токен все еще null, возможно, пользователь не авторизован
      if (!_apiClient.hasToken) {
        throw Exception('Пользователь не авторизован или токен не загружен.');
      }

      // Создаем Map только с теми полями, которые нужно обновить
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (password != null) updateData['password'] = password;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;

      print('Данные для обновления: $updateData');

      final response = await _apiClient.dio.put(
        '/auth/profile',
        data: updateData,
      );

      print('Получен ответ от сервера: ${response.data}');

      if (response.data['success'] == true) {
        final userData = response.data['user'] as Map<String, dynamic>;
        print('Данные обновленного пользователя: $userData');
        return User.fromJson(userData);
      } else {
        throw Exception(response.data['message'] ?? 'Ошибка обновления профиля');
      }
    } catch (e) {
      print('Ошибка при обновлении профиля: $e');
      throw Exception('Ошибка обновления профиля: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      // Убедимся, что токен загружен
      if (!_apiClient.hasToken) {
        await _apiClient.init();
      }
      
      // Если токен не найден, возвращаем null
      if (!_apiClient.hasToken) {
        return null;
      }

      final response = await _apiClient.dio.get('/auth/profile');
      print('Получен ответ при запросе профиля: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['user'] as Map<String, dynamic>;
        print('Данные пользователя из профиля: $userData');
        print('Роль пользователя из профиля: ${userData['role']}');
        
        final user = User.fromJson(userData);
        print('Созданный объект пользователя: ${user.toJson()}');
        print('Роль пользователя после создания объекта: ${user.role}');
        print('isAdmin: ${user.isAdmin}');
        
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Ошибка при получении данных пользователя: $e');
      return null;
    }
  }

  Future<void> setToken(String token) async {
    await _apiClient.setToken(token);
  }

  Future<void> clearAuthToken() async {
    await _apiClient.clearToken();
  }
} 