import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum OtpStatus { idle, loading, success, error }

class VerifyOtpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  OtpStatus _status = OtpStatus.idle;
  String _errorMessage = '';
  Map<String, dynamic>? _otpResponse;

  OtpStatus get status => _status;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get otpResponse => _otpResponse;



  // ✅ Verify OTP (New)
  Future<void> verifyUserOtp({
    required String phone,
    required String otp,
  }) async {
    _status = OtpStatus.loading;
    notifyListeners();

    try {
      final response = await _authService.verifyUserOtp(
        phone: phone,
        otp: otp,
      );

      _otpResponse = response;
      _status = OtpStatus.success;
      print("verifyUserOtp success -> ${response.toString()}");
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = OtpStatus.error;
      print("verifyUserOtp error -> $e");
    }

    notifyListeners();
  }

  void reset() {
    _status = OtpStatus.idle;
    _errorMessage = '';
    _otpResponse = null;
    notifyListeners();
  }
}
