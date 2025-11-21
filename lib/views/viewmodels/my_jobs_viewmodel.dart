import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum MyJobsStatus { idle, loading, success, error }

class MyJobsViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  MyJobsStatus _status = MyJobsStatus.idle;
  String _errorMessage = '';
  List<dynamic> _activeJobs = [];
  List<dynamic> _draftJobs = [];
  List<dynamic> _completedJobs = [];
  int? _userId;

  MyJobsStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<dynamic> get activeJobs => _activeJobs;
  List<dynamic> get draftJobs => _draftJobs;
  List<dynamic> get completedJobs => _completedJobs;

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

  /// Fetch Active Jobs
  Future<void> fetchActiveJobs() async {
    _status = MyJobsStatus.loading;
    notifyListeners();

    try {
      final userId = await _ensureUserId();
      _activeJobs = await _authService.getResidentJobs(
        userId: userId,
        status: 'active',
      );
      _status = MyJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = MyJobsStatus.error;
      _activeJobs = [];
    }

    notifyListeners();
  }

  /// Fetch Draft Jobs
  Future<void> fetchDraftJobs() async {
    _status = MyJobsStatus.loading;
    notifyListeners();

    try {
      final userId = await _ensureUserId();
      _draftJobs = await _authService.getResidentJobs(
        userId: userId,
        status: 'draft',
      );
      _status = MyJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = MyJobsStatus.error;
      _draftJobs = [];
    }

    notifyListeners();
  }

  /// Fetch Completed Jobs
  Future<void> fetchCompletedJobs() async {
    _status = MyJobsStatus.loading;
    notifyListeners();

    try {
      final userId = await _ensureUserId();
      _completedJobs = await _authService.getResidentJobs(
        userId: userId,
        status: 'completed',
      );
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
      final userId = await _ensureUserId();
      await Future.wait([
        _authService
            .getResidentJobs(userId: userId, status: 'active')
            .then((value) => _activeJobs = value),
        _authService
            .getResidentJobs(userId: userId, status: 'draft')
            .then((value) => _draftJobs = value),
        _authService
            .getResidentJobs(userId: userId, status: 'completed')
            .then((value) => _completedJobs = value),
      ]);
      _status = MyJobsStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = MyJobsStatus.error;
      _activeJobs = [];
      _draftJobs = [];
      _completedJobs = [];
    }

    notifyListeners();
  }

  void reset() {
    _status = MyJobsStatus.idle;
    _errorMessage = '';
    _activeJobs = [];
    _draftJobs = [];
    _completedJobs = [];
    _userId = null;
    notifyListeners();
  }

  Future<void> publishDraftJob(int jobId) async {
    try {
      final userId = await _ensureUserId();
      await _authService.updateJobStatus(
        jobId: jobId,
        status: 'active',
        approvedBy: userId,
      );

      final draftIndex = _draftJobs.indexWhere((job) {
        final dynamic id = job is Map<String, dynamic> ? job['id'] : null;
        return id != null && id == jobId;
      });

      if (draftIndex != -1) {
        final job = Map<String, dynamic>.from(_draftJobs.removeAt(draftIndex));
        job['status'] = 'active';
        _activeJobs = [job, ..._activeJobs];
      } else {
        await fetchAllJobs();
        return;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
