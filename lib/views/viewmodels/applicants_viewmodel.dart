import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum ApplicantsStatus { idle, loading, success, error }

class ApplicantsViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  ApplicantsStatus _status = ApplicantsStatus.idle;
  String _errorMessage = '';
  List<dynamic> _applications = [];
  String? _jobId;
  bool _isHiring = false;
  int? _hiringApplicationId;

  ApplicantsStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<dynamic> get applications => _applications;
  bool get isLoading => _status == ApplicantsStatus.loading;
  bool get hasError => _status == ApplicantsStatus.error;
  bool get isEmpty =>
      _applications.isEmpty && _status == ApplicantsStatus.success;
  String get baseUrlWithoutApi => _authService.baseUrlWithoutApi;
  bool get isHiring => _isHiring;
  bool isHiringApplication(int applicationId) =>
      _isHiring && _hiringApplicationId == applicationId;

  /// Fetch applications for a specific job
  Future<void> fetchApplications(String jobId) async {
    if (_jobId == jobId &&
        _applications.isNotEmpty &&
        _status == ApplicantsStatus.success) {
      // Already loaded for this job
      return;
    }

    _jobId = jobId;
    _status = ApplicantsStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _applications = await _authService.getApplicationsForJob(jobId: jobId);
      _status = ApplicantsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
      _status = ApplicantsStatus.error;
      _applications = [];
    }

    notifyListeners();
  }

  /// Refresh applications
  Future<void> refreshApplications() async {
    if (_jobId != null) {
      await fetchApplications(_jobId!);
    }
  }

  /// Hire an applicant (update application status to 'hired')
  Future<bool> hireApplicant(int applicationId) async {
    _isHiring = true;
    _hiringApplicationId = applicationId;
    notifyListeners();

    try {
      final response = await _authService.updateApplicationStatus(
        applicationId: applicationId,
        status: 'hired',
      );

      // Update the application in the list with the new status
      final index = _applications.indexWhere((app) {
        final appId = app['application_id'];
        return appId == applicationId ||
            appId.toString() == applicationId.toString();
      });

      if (index != -1) {
        // Update the application status from the response
        if (response['application'] != null) {
          _applications[index] = response['application'];
        } else {
          // Fallback: manually update the status
          final updatedApp = Map<String, dynamic>.from(_applications[index]);
          updatedApp['status'] = 'hired';
          _applications[index] = updatedApp;
        }
      }

      _isHiring = false;
      _hiringApplicationId = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isHiring = false;
      _hiringApplicationId = null;
      _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
      notifyListeners();
      return false;
    }
  }

  /// Shortlist an applicant
  Future<bool> shortlistApplicant(int applicationId, bool shortlisted) async {
    _isHiring = true;
    _hiringApplicationId = applicationId;
    notifyListeners();

    try {
      // Update status to keep it as 'applied' but set shortlisted flag
      await _authService.updateApplicationStatus(
        applicationId: applicationId,
        status: 'applied',
        shortlisted: shortlisted,
      );

      // Update the application in the list
      final index = _applications.indexWhere((app) {
        final appId = app['application_id'];
        return appId == applicationId ||
            appId.toString() == applicationId.toString();
      });

      if (index != -1) {
        final updatedApp = Map<String, dynamic>.from(_applications[index]);
        updatedApp['shortlisted'] = shortlisted ? 1 : 0;
        _applications[index] = updatedApp;
      }

      _isHiring = false;
      _hiringApplicationId = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isHiring = false;
      _hiringApplicationId = null;
      _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = ApplicantsStatus.idle;
    _errorMessage = '';
    _applications = [];
    _jobId = null;
    _isHiring = false;
    _hiringApplicationId = null;
    notifyListeners();
  }
}
