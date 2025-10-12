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

  // ✅ Verify OTP
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

      if (response['status'] == true) {
        // OTP Verified successfully
        _otpResponse = response;
        _status = OtpStatus.success;
        print("verifyUserOtp success -> $response");
      } else {
        // OTP failed (e.g., Invalid OTP)
        _errorMessage = response['message'] ?? "Invalid OTP";
        _status = OtpStatus.error;
        print("verifyUserOtp failed -> $_errorMessage");
      }
    } catch (e) {
      _errorMessage = "Something went wrong";
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
