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

      if (response != null) {
        _createJobResponse = response;
        _status = PostJobStatus.success;
        if (kDebugMode) {
          print("✅ Job created successfully: ${response.toString()}");
        }
      } else {
        // If backend returns null or invalid format
        _errorMessage = "No valid response from server.";
        _status = PostJobStatus.error;
      }
    } catch (e, stackTrace) {
      // Clean up the error message for UI
      _errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Error creating job: ', '')
          .trim();

      _status = PostJobStatus.error;

      if (kDebugMode) {
        print("❌ Error while creating job: $_errorMessage");
        print(stackTrace);
      }
    }

    notifyListeners();
  }
}
