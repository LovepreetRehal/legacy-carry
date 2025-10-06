// viewmodels/login_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';
import '../models/login_response.dart';

enum LoginStatus { idle, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  LoginStatus _status = LoginStatus.idle;
  String _errorMessage = '';
  LoginResponse? _loginResponse;

  LoginStatus get status => _status;
  String get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;

  Future<void> login(String email, String password) async {
    _status = LoginStatus.loading;
    notifyListeners();
    print("api respose  email -> " +email );
    print("api respose password-> " +password );

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      _loginResponse = response;
      _status = LoginStatus.success;
      print("api respose -> " +response.message);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = LoginStatus.error;
      print("api respose Error -> $e");
    }

    notifyListeners();
  }

  void reset() {
    _status = LoginStatus.idle;
    _errorMessage = '';
    notifyListeners();
  }
}
