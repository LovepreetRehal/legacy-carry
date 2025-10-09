// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  final String baseUrl = 'https://legacycarry.com/api';

  /// Login API
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    print("Login response -> ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        return LoginResponse.fromJson(json);
      } else {
        throw Exception(json['message'] ?? 'Login failed');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

// New Send OTP API
  Future<Map<String, dynamic>> sendUserOtp({
    required String countryCode,
    required String phone,
    required String purpose,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-user-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "country_code": countryCode,
        "phone": phone,
        "purpose": purpose, // 'login', 'verify_job', 'visitor_pass'
      }),
    );

    print("sendUserOtp response-> ${response.body}");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        return json;
      } else {
        throw Exception(json['message'] ?? 'OTP sending failed');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // services/auth_service.dart

  Future<Map<String, dynamic>> verifyUserOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "phone": phone,
        "otp": otp,
      }),
    );
    print("verifyUserOtp response -> $phone  ,  otp   -> $otp");

    print("verifyUserOtp response -> ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        return json;
      } else {
        throw Exception(json['message'] ?? 'OTP verification failed');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }


  Future<Map<String, dynamic>> createResidentUser(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resident-users-create'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    print("ResidentUserCreate response -> ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        return json;
      } else {
        throw Exception(json['message'] ?? 'User creation failed');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }


  Future<List<Map<String, dynamic>>> getCountries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/countries'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // assuming API returns something like { "status": true, "data": [ { code: "+91", name: "India" }, ... ] }
      if (jsonData['status'] == true && jsonData['data'] != null) {
        List<dynamic> list = jsonData['data'];
        // convert each to Map<String, dynamic>
        return list.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to fetch countries');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }


  // services/auth_service.dart

  Future<Map<String, dynamic>> getUserProfile({required String token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'), // assuming endpoint is /profile
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // add token if API requires auth
      },
    );

    print("getUserProfile response -> ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        return json; // you can also return json['data'] if you only need the profile data
      } else {
        throw Exception(json['message'] ?? 'Failed to fetch profile');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }


}
