import 'package:flutter/material.dart';
import '../models/login_request.dart';
import '../models/sign_up_request.dart';
import '../services/auth_service.dart';
import '../models/login_response.dart';

/// Enum to track the signup process status
enum SignUpStatus { idle, loading, success, error }

class SignUpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  SignUpStatus _status = SignUpStatus.idle;
  String _errorMessage = '';
  LoginResponse? _signUpResponse;

  SignUpStatus get status => _status;
  String get errorMessage => _errorMessage;
  LoginResponse? get signUpResponse => _signUpResponse;

  /// Handles user signup
  Future<void> signUp(SignUpRequest request) async {
    _status = SignUpStatus.loading;
    notifyListeners();

    try {
      final response = await _authService.signUp(request);
      _signUpResponse = response;
      _status = SignUpStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = SignUpStatus.error;
    }

    notifyListeners();
  }
}
