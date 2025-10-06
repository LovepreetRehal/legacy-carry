// models/login_response.dart
class User {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      isActive: json['is_active'],
    );
  }
}

class LoginResponse {
  final bool status;
  final String message;
  final User user;
  final String token;

  LoginResponse({
    required this.status,
    required this.message,
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      message: json['message'],
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}
