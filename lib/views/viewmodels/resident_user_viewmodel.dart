// viewmodels/resident_user_viewmodel.dart
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

enum ResidentUserStatus { idle, loading, success, error }

class ResidentUserViewModel extends ChangeNotifier {
  final AuthService _service = AuthService();

  ResidentUserStatus _status = ResidentUserStatus.idle;
  String _errorMessage = '';
  Map<String, dynamic>? _response;

  ResidentUserStatus get status => _status;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get response => _response;

  Future<void> createResidentUser(Map<String, dynamic> data) async {
    _status = ResidentUserStatus.loading;
    notifyListeners();

    try {
      final result = await _service.createResidentUser(data);
      _response = result;
      _status = ResidentUserStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _status = ResidentUserStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _status = ResidentUserStatus.idle;
    _errorMessage = '';
    _response = null;
    notifyListeners();
  }
}
