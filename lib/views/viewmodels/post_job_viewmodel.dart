import 'package:flutter/foundation.dart';
import '../models/create_job_model.dart';
import '../models/create_job_request.dart';
import '../services/auth_service.dart';

enum PostJobStatus { idle, loading, success, error }

class PostJobViewmodel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  PostJobStatus _status = PostJobStatus.idle;
  String _errorMessage = '';
  CreateJobResponse? _createJobResponse;

  PostJobStatus get status => _status;
  String get errorMessage => _errorMessage;
  CreateJobResponse? get createJobResponse => _createJobResponse;

  /// Handles job creation process
  Future<void> createJob(CreateJobRequest request) async {
    _status = PostJobStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authService.createJob(request);
      _createJobResponse = response;
      _status = PostJobStatus.success;
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      _status = PostJobStatus.error;

      if (kDebugMode) {
        print("❌ Error while creating job: $_errorMessage");
        print(stackTrace);
      }
    }

    notifyListeners();
  }
}
