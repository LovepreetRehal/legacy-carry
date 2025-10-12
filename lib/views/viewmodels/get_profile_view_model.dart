// viewmodels/get_profile_viewmodel.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum ProfileStatus { idle, loading, success, error }

class GetProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  ProfileStatus _status = ProfileStatus.idle;
  String _errorMessage = '';
  Map<String, dynamic>? _profileData;

  ProfileStatus get status => _status;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get profileData => _profileData;

  /// Fetch user profile
  Future<void> fetchProfile() async {
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      final data = await _authService.getUserProfile();
      _profileData = data['data']; // assuming API returns {status: true, data: {...}}
      _status = ProfileStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProfileStatus.error;
    }

    notifyListeners();
  }

  /// Optional: Reset the state
  void reset() {
    _status = ProfileStatus.idle;
    _errorMessage = '';
    _profileData = null;
    notifyListeners();
  }
}
