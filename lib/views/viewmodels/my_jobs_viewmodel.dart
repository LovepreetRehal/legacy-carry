import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum MyJobsStatus { idle, loading, success, error }

class MyJobsViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  MyJobsStatus _status = MyJobsStatus.idle;
  String _errorMessage = '';
  List<dynamic> _activeJobs = [];
  List<dynamic> _upcomingJobs = [];
  List<dynamic> _completedJobs = [];

  MyJobsStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<dynamic> get activeJobs => _activeJobs;
  List<dynamic> get upcomingJobs => _upcomingJobs;
  List<dynamic> get completedJobs => _completedJobs;

  /// Fetch Active Jobs
  Future<void> fetchActiveJobs() async {
    _status = MyJobsStatus.loading;
    notifyListeners();

    try {
      _activeJobs = await _authService.getActiveJobs();
      _status = MyJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = MyJobsStatus.error;
      _activeJobs = [];
    }

    notifyListeners();
  }

  /// Fetch Upcoming Jobs
  Future<void> fetchUpcomingJobs() async {
    _status = MyJobsStatus.loading;
    notifyListeners();

    try {
      _upcomingJobs = await _authService.getUpcomingJobs();
      _status = MyJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = MyJobsStatus.error;
      _upcomingJobs = [];
    }

    notifyListeners();
  }

  /// Fetch Completed Jobs
  Future<void> fetchCompletedJobs() async {
    _status = MyJobsStatus.loading;
    notifyListeners();

    try {
      _completedJobs = await _authService.getCompletedJobs();
      _status = MyJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = MyJobsStatus.error;
      _completedJobs = [];
    }

    notifyListeners();
  }

  /// Fetch all jobs (Active, Upcoming, and Completed)
  Future<void> fetchAllJobs() async {
    _status = MyJobsStatus.loading;
    notifyListeners();

    try {
      await Future.wait([
        _authService.getActiveJobs().then((value) => _activeJobs = value),
        _authService.getUpcomingJobs().then((value) => _upcomingJobs = value),
        _authService.getCompletedJobs().then((value) => _completedJobs = value),
      ]);
      _status = MyJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = MyJobsStatus.error;
      _activeJobs = [];
      _upcomingJobs = [];
      _completedJobs = [];
    }

    notifyListeners();
  }

  void reset() {
    _status = MyJobsStatus.idle;
    _errorMessage = '';
    _activeJobs = [];
    _upcomingJobs = [];
    _completedJobs = [];
    notifyListeners();
  }
}
