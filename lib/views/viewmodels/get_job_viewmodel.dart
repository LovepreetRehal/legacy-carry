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
      final userId = await _fetchUserId();
      final response =
          await _authService.getRecommendedJobs(employerId: userId);

      _jobData = response;

      _status = GetJobStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = GetJobStatus.error;
      _jobData = [];
    }

    notifyListeners();
  }

  Future<int> _fetchUserId() async {
    final profile = await _authService.getUserProfile();

    final possibleIds = [
      if (profile['user'] is Map && profile['user']['id'] != null)
        profile['user']['id'],
      if (profile['data'] is Map && profile['data']['id'] != null)
        profile['data']['id'],
      profile['id'],
    ].where((element) => element != null).toList();

    for (final id in possibleIds) {
      final parsedId = int.tryParse(id.toString());
      if (parsedId != null && parsedId > 0) {
        return parsedId;
      }
    }

    throw Exception('Unable to determine user ID');
  }
}
