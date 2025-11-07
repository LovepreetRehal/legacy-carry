import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum EmployeeJobsStatus { idle, loading, success, error }

class EmployeeJobsViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  EmployeeJobsStatus _status = EmployeeJobsStatus.idle;
  String _errorMessage = '';
  List<dynamic> _activeJobs = [];
  List<dynamic> _draftJobs = [];
  List<dynamic> _hourlyJobs = [];
  List<dynamic> _allJobs = [];

  EmployeeJobsStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<dynamic> get activeJobs => _activeJobs;
  List<dynamic> get draftJobs => _draftJobs;
  List<dynamic> get hourlyJobs => _hourlyJobs;
  List<dynamic> get allJobs => _allJobs;

  /// Fetch Active Jobs for Employee
  Future<void> fetchActiveJobs() async {
    _status = EmployeeJobsStatus.loading;
    notifyListeners();

    try {
      _activeJobs = await _authService.getEmployeeActiveJobs();
      _status = EmployeeJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = EmployeeJobsStatus.error;
      _activeJobs = [];
    }

    notifyListeners();
  }

  /// Fetch Draft Jobs for Employee
  Future<void> fetchDraftJobs() async {
    _status = EmployeeJobsStatus.loading;
    notifyListeners();

    try {
      _draftJobs = await _authService.getEmployeeDraftJobs();
      _status = EmployeeJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = EmployeeJobsStatus.error;
      _draftJobs = [];
    }

    notifyListeners();
  }

  /// Fetch Hourly Jobs for Employee
  Future<void> fetchHourlyJobs() async {
    _status = EmployeeJobsStatus.loading;
    notifyListeners();

    try {
      _hourlyJobs = await _authService.getEmployeeHourlyJobs();
      _status = EmployeeJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = EmployeeJobsStatus.error;
      _hourlyJobs = [];
    }

    notifyListeners();
  }

  /// Fetch all employee jobs (Active, Draft, and Hourly)
  Future<void> fetchAllEmployeeJobs() async {
    _status = EmployeeJobsStatus.loading;
    notifyListeners();

    try {
      await Future.wait([
        _authService
            .getEmployeeActiveJobs()
            .then((value) => _activeJobs = value),
        _authService.getEmployeeDraftJobs().then((value) => _draftJobs = value),
        _authService
            .getEmployeeHourlyJobs()
            .then((value) => _hourlyJobs = value),
      ]);

      // Combine all jobs for general use
      _allJobs = [..._activeJobs, ..._draftJobs, ..._hourlyJobs];
      _status = EmployeeJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = EmployeeJobsStatus.error;
      _activeJobs = [];
      _draftJobs = [];
      _hourlyJobs = [];
      _allJobs = [];
    }

    notifyListeners();
  }

  /// Fetch jobs by status/tab
  Future<void> fetchJobsByTab(String tab) async {
    _status = EmployeeJobsStatus.loading;
    notifyListeners();

    try {
      switch (tab.toLowerCase()) {
        case 'active':
          _activeJobs = await _authService.getEmployeeActiveJobs();
          break;
        case 'drafts':
        case 'draft':
          _draftJobs = await _authService.getEmployeeDraftJobs();
          break;
        case 'hourly':
          _hourlyJobs = await _authService.getEmployeeHourlyJobs();
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
      case 'drafts':
      case 'draft':
        return _draftJobs;
      case 'hourly':
        return _hourlyJobs;
      default:
        return _allJobs;
    }
  }

  void reset() {
    _status = EmployeeJobsStatus.idle;
    _errorMessage = '';
    _activeJobs = [];
    _draftJobs = [];
    _hourlyJobs = [];
    _allJobs = [];
    notifyListeners();
  }
}
