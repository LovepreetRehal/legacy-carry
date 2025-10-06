import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum OtpStatus { idle, loading, success, error }

class SendOtpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  OtpStatus _status = OtpStatus.idle;
  String _errorMessage = '';
  Map<String, dynamic>? _otpResponse;

  OtpStatus get status => _status;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get otpResponse => _otpResponse;

  Future<void> sendUserOtp({
    required String countryCode,
    required String phone,
    required String purpose,
  }) async {
    _status = OtpStatus.loading;
    notifyListeners();
    print("sendUserOtp request -> $countryCode $phone $purpose");

    try {
      final response = await _authService.sendUserOtp(
        countryCode: countryCode,
        phone: phone,
        purpose: purpose,
      );

      _otpResponse = response;
      _status = OtpStatus.success;
      print("sendUserOtp success -> ${response.toString()}");
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = OtpStatus.error;
      print("sendUserOtp error -> $e");
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
