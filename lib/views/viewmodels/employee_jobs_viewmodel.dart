import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum EmployeeJobsStatus { idle, loading, success, error }

class EmployeeJobsViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  EmployeeJobsStatus _status = EmployeeJobsStatus.idle;
  String _errorMessage = '';
  List<dynamic> _activeJobs = [];
  List<dynamic> _upcomingJobs = [];
  List<dynamic> _completedJobs = [];
  List<dynamic> _allJobs = [];
  int? _userId;

  EmployeeJobsStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<dynamic> get activeJobs => _activeJobs;
  List<dynamic> get upcomingJobs => _upcomingJobs;
  List<dynamic> get completedJobs => _completedJobs;
  List<dynamic> get allJobs => _allJobs;

  /// Get user ID from profile
  Future<int> _ensureUserId() async {
    if (_userId != null && _userId! > 0) return _userId!;

    try {
      final profile = await _authService.getUserProfile();
      final dynamic idCandidate = profile['user']?['id'] ??
          profile['data']?['user']?['id'] ??
          profile['data']?['id'] ??
          profile['id'];

      final parsedId = int.tryParse(idCandidate?.toString() ?? '');
      if (parsedId == null || parsedId <= 0) {
        throw Exception('Unable to determine user id');
      }
      _userId = parsedId;
      return parsedId;
    } catch (e) {
      throw Exception('Unable to determine user id: $e');
    }
  }

  /// Fetch Active Jobs for Employee
  Future<void> fetchActiveJobs() async {
    _status = EmployeeJobsStatus.loading;
    notifyListeners();

    try {
      final userId = await _ensureUserId();
      _activeJobs = await _authService.filterEmployeeJobsByStatus(
        userId: userId,
        status: 'active',
      );
      _status = EmployeeJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = EmployeeJobsStatus.error;
      _activeJobs = [];
    }

    notifyListeners();
  }

  /// Fetch Upcoming Jobs for Employee
  Future<void> fetchUpcomingJobs() async {
    _status = EmployeeJobsStatus.loading;
    notifyListeners();

    try {
      final userId = await _ensureUserId();
      _upcomingJobs = await _authService.filterEmployeeJobsByStatus(
        userId: userId,
        status: 'upcoming',
      );
      _status = EmployeeJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = EmployeeJobsStatus.error;
      _upcomingJobs = [];
    }

    notifyListeners();
  }

  /// Fetch Completed Jobs for Employee
  Future<void> fetchCompletedJobs() async {
    _status = EmployeeJobsStatus.loading;
    notifyListeners();

    try {
      final userId = await _ensureUserId();
      _completedJobs = await _authService.filterEmployeeJobsByStatus(
        userId: userId,
        status: 'completed',
      );
      _status = EmployeeJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = EmployeeJobsStatus.error;
      _completedJobs = [];
    }

    notifyListeners();
  }

  /// Fetch all employee jobs (Active, Upcoming, and Completed)
  Future<void> fetchAllEmployeeJobs() async {
    _status = EmployeeJobsStatus.loading;
    notifyListeners();

    try {
      final userId = await _ensureUserId();
      await Future.wait([
        _authService
            .filterEmployeeJobsByStatus(userId: userId, status: 'active')
            .then((value) => _activeJobs = value),
        _authService
            .filterEmployeeJobsByStatus(userId: userId, status: 'upcoming')
            .then((value) => _upcomingJobs = value),
        _authService
            .filterEmployeeJobsByStatus(userId: userId, status: 'completed')
            .then((value) => _completedJobs = value),
      ]);

      // Combine all jobs for general use
      _allJobs = [..._activeJobs, ..._upcomingJobs, ..._completedJobs];
      _status = EmployeeJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = EmployeeJobsStatus.error;
      _activeJobs = [];
      _upcomingJobs = [];
      _completedJobs = [];
      _allJobs = [];
    }

    notifyListeners();
  }

  /// Fetch jobs by status/tab
  Future<void> fetchJobsByTab(String tab) async {
    _status = EmployeeJobsStatus.loading;
    notifyListeners();

    try {
      final userId = await _ensureUserId();
      switch (tab.toLowerCase()) {
        case 'active':
          _activeJobs = await _authService.filterEmployeeJobsByStatus(
            userId: userId,
            status: 'active',
          );
          break;
        case 'upcoming':
          _upcomingJobs = await _authService.filterEmployeeJobsByStatus(
            userId: userId,
            status: 'upcoming',
          );
          break;
        case 'completed':
          _completedJobs = await _authService.filterEmployeeJobsByStatus(
            userId: userId,
            status: 'completed',
          );
          break;
        default:
          await fetchAllEmployeeJobs();
      }
      _status = EmployeeJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = EmployeeJobsStatus.error;
    }

    notifyListeners();
  }

  /// Get jobs for a specific tab
  List<dynamic> getJobsForTab(String tab) {
    switch (tab.toLowerCase()) {
      case 'active':
        return _activeJobs;
      case 'upcoming':
        return _upcomingJobs;
      case 'completed':
        return _completedJobs;
      default:
        return _allJobs;
    }
  }

  void reset() {
    _status = EmployeeJobsStatus.idle;
    _errorMessage = '';
    _activeJobs = [];
    _upcomingJobs = [];
    _completedJobs = [];
    _allJobs = [];
    _userId = null;
    notifyListeners();
  }
}
