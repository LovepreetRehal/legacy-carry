import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CountryViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _error = '';
  List<Map<String, dynamic>> _countries = [];

  bool get isLoading => _isLoading;
  String get error => _error;
  List<Map<String, dynamic>> get countries => _countries;

  Future<void> loadCountries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _countries = await _authService.getCountries();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
