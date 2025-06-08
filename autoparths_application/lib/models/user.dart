class User {
  static const int ROLE_USER = 0;
  static const int ROLE_ADMIN = 1;

  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? token;
  final int role;

  User({
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.token,
    required this.role,
  });

  String get roleName {
    switch (role) {
      case ROLE_ADMIN:
        return 'admin';
      case ROLE_USER:
      default:
        return 'user';
    }
  }

  bool get isAdmin => role == ROLE_ADMIN;

  factory User.fromJson(Map<String, dynamic> json) {
    print('Parsing user data from JSON: $json');
    
    // Проверяем наличие обязательных полей
    if (json['name'] == null || json['email'] == null) {
      print('Warning: Missing required fields in user data');
    }

    // Обработка роли пользователя
    int userRole = ROLE_USER;
    if (json['role'] != null) {
      if (json['role'] is int) {
        userRole = json['role'];
      } else if (json['role'] is String) {
        // Если роль приходит как строка
        userRole = json['role'].toLowerCase() == 'admin' ? ROLE_ADMIN : ROLE_USER;
      }
    }
    print('Parsed user role: $userRole');

    final user = User(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      token: json['token']?.toString(),
      role: userRole,
    );

    print('Created user object: ${user.toJson()}');
    print('User role: ${user.role}');
    print('User isAdmin: ${user.isAdmin}');
    return user;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'role': role,
    };

    if (phone != null) map['phone'] = phone!;
    if (address != null) map['address'] = address!;
    if (token != null) map['token'] = token!;

    return map;
  }
}