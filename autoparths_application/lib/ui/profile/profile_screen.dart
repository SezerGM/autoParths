import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../models/order.dart';
import '../../services/api_client.dart';
import 'package:logging/logging.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService(ApiClient());
  final _logger = Logger('ProfileScreen');
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  List<Order> _orders = [];
  bool _isLoadingOrders = false;
  bool _isEditing = false;
  bool _isInitializing = true; // Флаг для отслеживания инициализации (загрузки токена)

  // Контроллеры для полей ввода
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authService.init().then((_) async {
      // После инициализации и загрузки токена, пытаемся получить данные пользователя
      try {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          setState(() {
            _currentUser = user;
            _isInitializing = false;
          });
          // Загружаем заказы для авторизованного пользователя
          await _loadOrders();
        } else {
          setState(() {
            _isInitializing = false;
          });
        }
      } catch (e) {
        print('Ошибка при получении данных пользователя: $e');
        setState(() {
          _isInitializing = false;
        });
      }
    }).catchError((error) {
      _logger.severe('Ошибка инициализации ProfileScreen: $error');
      setState(() {
        _isInitializing = false;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  void _populateEditFields() {
    if (_currentUser != null) {
      _nameController.text = _currentUser!.name;
      _emailController.text = _currentUser!.email;
      _phoneController.text = _currentUser!.phone ?? '';
      _addressController.text = _currentUser!.address ?? '';
    }
  }

  Future<void> _loadOrders() async {
    if (_currentUser?.token == null) return;

    setState(() {
      _isLoadingOrders = true;
    });

    try {
      final orders = await _authService.getOrders(_currentUser!.token!);
      setState(() {
        _orders = orders;
        _isLoadingOrders = false;
      });
    } catch (e) {
      print('Ошибка при загрузке заказов: $e');
      setState(() {
        _isLoadingOrders = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User user;
      if (_isLogin) {
        print('Attempting login...');
        user = await _authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
        print('Login successful. Received user: ${user.toJson()}');
      } else {
        print('Attempting registration...');
        user = await _authService.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
          address: _addressController.text,
        );
        print('Registration successful. Received user: ${user.toJson()}');
      }
      
      // Сохраняем токен после успешной авторизации
      if (user.token != null) {
        await _authService.setToken(user.token!);
      }

      // Обновляем состояние после успешной авторизации/регистрации
      setState(() {
        _currentUser = user;
        _isLoading = false;
        print('_currentUser updated to: ${_currentUser?.toJson()}');
      });

      // Загружаем заказы после успешной авторизации
      await _loadOrders();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        print('Error during auth: $_errorMessage');
      });
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Пожалуйста, введите email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.forgotPassword(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Инструкции по восстановлению пароля отправлены на ваш email')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.clearAuthToken();
    setState(() {
      _currentUser = null;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _addressController.clear();
    });
  }

  // Метод для переключения в режим редактирования
  void _startEditing() {
    _populateEditFields();
    setState(() {
      _isEditing = true;
    });
  }

  // Метод для отмены редактирования
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _errorMessage = null;
    });
    _populateEditFields(); // Сбрасываем изменения, загружая текущие данные
  }

  // Метод для сохранения изменений
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Попытка сохранить профиль с данными:');
      print('Имя: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Телефон: ${_phoneController.text}');
      print('Адрес: ${_addressController.text}');

      final updatedUser = await _authService.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        phone: _phoneController.text,
        address: _addressController.text,
      );
      _logger.info('Профиль успешно обновлен');
      setState(() {
        _currentUser = updatedUser;
        _isEditing = false;
        _passwordController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль успешно обновлен')),
        );
      }
    } catch (e) {
      _logger.severe('Ошибка при сохранении профиля: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser != null ? 'Профиль пользователя' : (_isLogin ? 'Вход' : 'Регистрация')),
        centerTitle: false,
        backgroundColor: Colors.lightBlue,
        actions: [
           if (_currentUser != null && !_isEditing) // Кнопка редактирования только в режиме просмотра
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: _startEditing,
            ),
        ],
      ),
      body: _currentUser != null
          ? _buildProfileView() // Показываем информацию о пользователе, если он авторизован
          : _buildAuthForm(), // Иначе показываем формы входа/регистрации
    );
  }

  Widget _buildAuthForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isLogin) ...[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Имя'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
            ],
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите email';
                }
                if (!value.contains('@')) {
                  return 'Пожалуйста, введите корректный email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите пароль';
                }
                if (value.length < 6) {
                  return 'Пароль должен быть не менее 6 символов';
                }
                return null;
              },
            ),
            if (!_isLogin) ...[
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите телефон';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Адрес'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите адрес';
                  }
                  return null;
                },
              ),
            ],
            SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            if (_isLogin)
              TextButton(
                onPressed: _forgotPassword,
                child: Text('Забыли пароль?'),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _errorMessage = null;
                });
              },
              child: Text(_isLogin
                  ? 'Нет аккаунта? Зарегистрируйтесь'
                  : 'Уже есть аккаунт? Войдите'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser!.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _currentUser!.email,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_currentUser!.phone != null) ...[
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(_currentUser!.phone!),
                    ),
                  ],
                  if (_currentUser!.address != null) ...[
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(_currentUser!.address!),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _startEditing,
                        icon: const Icon(Icons.edit),
                        label: const Text('Редактировать'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Выйти'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Показываем кнопку админ-панели только для пользователей с ролью admin
                  if (_currentUser?.isAdmin == true) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          print('Переход в админ-панель. Роль пользователя: ${_currentUser?.role}');
                          print('isAdmin: ${_currentUser?.isAdmin}');
                          context.go('/admin');
                        },
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Панель администратора'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Статистика и история заказов (скрыты в режиме редактирования)
          if (!_isEditing) ...[
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Статистика',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.shopping_cart,
                          'Всего заказов',
                          _orders.length.toString(),
                        ),
                        _buildStatItem(
                          Icons.pending_actions,
                          'В обработке',
                          _orders.where((o) => o.status == 'Processing').length.toString(),
                        ),
                        _buildStatItem(
                          Icons.check_circle,
                          'Выполнено',
                          _orders.where((o) => o.status == 'Completed').length.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'История заказов',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Реализовать просмотр всех заказов
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Просмотр всех заказов будет доступен в следующем обновлении')),
                            );
                          },
                          child: Text('Все заказы'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (_isLoadingOrders)
                      Center(child: CircularProgressIndicator())
                    else if (_orders.isEmpty)
                      Center(
                        child: Text(
                          'У вас пока нет заказов',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _orders.length > 3 ? 3 : _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return ListTile(
                            title: Text('Заказ #${order.id.substring(0, 8)}'),
                            subtitle: Text(
                              '${order.products.length} товаров • ${order.amount} ₽',
                            ),
                            trailing: Chip(
                              label: Text(order.status),
                              backgroundColor: _getStatusColor(order.status),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Кнопка выхода (скрыта в режиме редактирования)
            ElevatedButton.icon(
              onPressed: _isInitializing ? null : _logout, // Отключаем кнопку, пока идет инициализация
              icon: Icon(Icons.logout),
              label: Text('Выйти'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 0),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.lightBlue, size: 20),
        SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.lightBlue, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.orange[100]!;
      case 'completed':
        return Colors.green[100]!;
      case 'cancelled':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
