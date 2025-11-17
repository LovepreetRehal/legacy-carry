import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String _errorMessage = '';

  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  String get userName {
    final user = _profileData?['user'];
    if (user is Map && user['name'] != null) {
      return user['name'].toString();
    }

    final dataMap = _profileData?['data'];
    if (dataMap is Map && dataMap['name'] != null) {
      return dataMap['name'].toString();
    }

    if (_profileData?['name'] != null) {
      return _profileData!['name'].toString();
    }

    return 'User';
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final data = await _authService.getUserProfile();
      _profileData = data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfileData(Map<String, dynamic>? data) {
    if (data == null) return;
    _profileData = data;
    notifyListeners();
  }

  void updateUserNameLocally(String newName) {
    if (_profileData == null) {
      _profileData = {
        'user': {'name': newName}
      };
    } else {
      final updatedUser = Map<String, dynamic>.from(
        (_profileData?['user'] as Map<String, dynamic>? ?? {}),
      )..['name'] = newName;

      _profileData = {
        ..._profileData!,
        'user': updatedUser,
      };
    }
    notifyListeners();
  }
}
