import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum GetJobStatus { idle, loading, success, error }

class GetJobViewmodel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  List<dynamic> _jobData = [];
  GetJobStatus _status = GetJobStatus.idle;
  String _errorMessage = '';

  List<dynamic> get jobData => _jobData;
  GetJobStatus get status => _status;
  String get errorMessage => _errorMessage;

  Future<void> fetchDashboardData() async {
    _status = GetJobStatus.loading;
    notifyListeners();

    try {
      final response = await _authService.getDashboardData();

      if (response is List) {
        _jobData = response;
      }/* else if (response is Map && response['data'] is List) {
        _jobData = response['data'];
      }*/ else {
        _jobData = [];
        throw Exception('Unexpected response format');
      }

      _status = GetJobStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = GetJobStatus.error;
      _jobData = [];
    }

    notifyListeners();
  }
}
