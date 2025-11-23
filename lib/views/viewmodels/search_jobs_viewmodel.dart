import 'package:flutter/material.dart';

import '../services/auth_service.dart';

enum SearchJobsStatus { idle, loading, success, error }

class SearchJobsViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  SearchJobsStatus _status = SearchJobsStatus.idle;
  String _errorMessage = '';
  List<dynamic> _jobs = [];
  int? _userId;
  String _role = 'customer'; // customer => resident, labor => employee
  String _currentKeyword = '';
  bool _hasInitialized = false;
  bool _contextLoaded = false;

  SearchJobsStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<dynamic> get jobs => _jobs;
  String get keyword => _currentKeyword;
  bool get isLoading => _status == SearchJobsStatus.loading;
  bool get isResident => _role == 'customer';

  Future<void> loadInitialJobs() async {
    if (_hasInitialized) return;
    _hasInitialized = true;
    await searchJobs();
  }

  Future<void> searchJobs({String keyword = ''}) async {
    _currentKeyword = keyword.trim();
    _status = SearchJobsStatus.loading;
    notifyListeners();

    try {
      await _ensureUserContext();
      List<dynamic> results = [];

      if (isResident) {
        final userId = _userId;
        if (userId == null) {
          throw Exception('Unable to determine resident user id');
        }
        results = await _authService.searchResidentJobs(
          userId: userId,
          keyword: _currentKeyword,
        );
      } else {
        results = await _authService.searchEmployeeJobs(
          keyword: _currentKeyword,
        );
      }

      _jobs = results;
      _status = SearchJobsStatus.success;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
      _status = SearchJobsStatus.error;
    }

    notifyListeners();
  }

  Future<void> _ensureUserContext() async {
    if (_contextLoaded && (!isResident || (_userId != null && _userId! > 0))) {
      return;
    }

    try {
      final profile = await _authService.getUserProfile();
      final dynamic userData = profile['user'] ??
          profile['data']?['user'] ??
          profile['data'] ??
          profile;

      final dynamic roleCandidate =
          userData?['role'] ?? profile['role'] ?? profile['user_role'];
      final dynamic idCandidate =
          userData?['id'] ?? profile['data']?['id'] ?? profile['id'];

      _role = roleCandidate?.toString().toLowerCase() ?? 'customer';

      final parsedId = int.tryParse(idCandidate?.toString() ?? '');
      if (parsedId != null && parsedId > 0) {
        _userId = parsedId;
      }
      _contextLoaded = true;
    } catch (e) {
      throw Exception('Unable to determine user context: $e');
    }
  }

  void reset() {
    _status = SearchJobsStatus.idle;
    _errorMessage = '';
    _jobs = [];
    _currentKeyword = '';
    _userId = null;
    _role = 'customer';
    _contextLoaded = false;
    notifyListeners();
  }
}
