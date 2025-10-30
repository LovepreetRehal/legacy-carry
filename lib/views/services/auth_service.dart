// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/create_job_model.dart';
import '../models/create_job_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/sign_up_request.dart';

class AuthService {
  final String baseUrl = 'https://legacycarry.com/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

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
        final loginResponse = LoginResponse.fromJson(json);

        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', loginResponse.token);

        return loginResponse;
      } else {
        throw Exception(json['message'] ?? 'Login failed');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// SIGNUP API
  Future<LoginResponse> signUp(SignUpRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    print("SignUp response -> ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        return LoginResponse.fromJson(json);
      } else {
        throw Exception(json['message'] ?? 'SignUp failed');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<CreateJobResponse> createJob(CreateJobRequest jobData) async {
    final url = Uri.parse('$baseUrl/jobs/create'); // ✅ ensure correct endpoint

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer $token', // uncomment if needed
        },
        body: jsonEncode(jobData.toJson()),
      );

      print("📡 URL: $url");
      print("📤 Body: ${jobData.toJson()}");
      print("📡 Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      // Decode JSON safely
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Success response
        return CreateJobResponse.fromJson(jsonData);
      } else {
        // ❌ API returned error JSON
        final errorMessage = jsonData['message'] ??
            'Failed to create job. Unknown server error.';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      print("❌ Exception while creating job: $e");
      print(stack);
      throw Exception("Error creating job: $e");
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
    final url = Uri.parse('$baseUrl/login-otp');

    print("📤 Sending verifyUserOtp request to $url");
    print("Body: ${jsonEncode({'phone': phone, 'otp': otp})}");

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "phone": phone,
          "otp": otp,
        }),
      );

      print("📩 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == true) {
          print("✅ OTP verification successful!");
          return json;
        } else {
          print("⚠️ OTP verification failed: ${json['message']}");
          return {
            "status": false,
            "message": json['message'] ?? 'OTP verification failed',
          };
        }
      } else {
        print("❌ Server returned ${response.statusCode}");
        return {
          "status": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      print("❌ Exception during OTP verification: $e");
      return {
        "status": false,
        "message": "Something went wrong: $e",
      };
    }
  }

  Future<Map<String, dynamic>> createResidentUser(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resident-users-create'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    print(
        "ResidentUserCreate response (${response.statusCode}) -> ${response.body}");

    Map<String, dynamic>? json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // keep json null if body isn't valid JSON
    }

    // Success
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (json != null && json['status'] == true) {
        return json;
      }
      // API returned 200 but status false -> surface detailed message if any
      final message =
          (json != null ? json['message'] : null) ?? 'User creation failed';
      final detailed = _extractErrorDetails(json);
      throw Exception(detailed?.isNotEmpty == true ? detailed : message);
    }

    // Error statuses: attempt to extract detailed validation messages
    final serverMessage = (json != null ? json['message'] : null) ??
        'Server error: ${response.statusCode}';
    final detailed = _extractErrorDetails(json);
    throw Exception(detailed?.isNotEmpty == true ? detailed : serverMessage);
  }

  String? _extractErrorDetails(Map<String, dynamic>? json) {
    if (json == null) return null;
    final errors = json['errors'];
    if (errors is Map) {
      final parts = <String>[];
      errors.forEach((key, value) {
        if (value is List) {
          final first = value.isNotEmpty ? value.first.toString() : '';
          if (first.isNotEmpty) {
            parts.add('$key: $first');
          }
        } else if (value is String) {
          parts.add('$key: $value');
        }
      });
      if (parts.isNotEmpty) {
        return parts.join('\n');
      }
    }
    // If API sometimes nests error under 'error' or returns string message
    if (json['error'] is String) return json['error'];
    if (json['message'] is String) return json['message'];
    return null;
  }

  Future<List<dynamic>> getCountries() async {
    try {
      final url = Uri.parse(
          "$baseUrl/countries"); // 👈 replace with your actual base URL
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // If API returns something like { "data": [ ... ] }
        if (data['data'] != null && data['data'] is List) {
          return data['data'];
        }

        // If API returns a raw list [ ... ]
        if (data is List) {
          return data;
        }

        // If structure is unexpected
        return [];
      } else {
        print("❌ Failed: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Exception in getCountries(): $e");
      return [];
    }
  }

  Future<List<dynamic>> getStates(int countryId) async {
    try {
      final url = Uri.parse("$baseUrl/countries/$countryId/states");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'] is List) {
          return data['data'];
        } else if (data is List) {
          return data;
        }
      }
      return [];
    } catch (e) {
      print("❌ Error fetching states: $e");
      return [];
    }
  }

  // services/auth_service.dart

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getToken(); // get token from SharedPreferences
    if (token == null) throw Exception('User not logged in');

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

  ///  Get Dashboard Data (returns List)
  Future<List<dynamic>> getDashboardData() async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/jobs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("getDashboardData response -> ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        //  API returns a list directly
        return jsonData;
      } else if (jsonData is Map && jsonData['data'] is List) {
        // Some APIs wrap list in "data"
        return jsonData['data'];
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Get Active Jobs
  Future<List<dynamic>> getActiveJobs() async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/jobs/active'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("getActiveJobs response -> ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is Map && jsonData['data'] is Map) {
        // Convert Map to List
        return jsonData['data'].values.toList();
      } else if (jsonData is Map && jsonData['data'] is List) {
        return jsonData['data'];
      } else {
        return [];
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Get Upcoming Jobs (Draft)
  Future<List<dynamic>> getUpcomingJobs() async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/jobs/draft'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("getUpcomingJobs response -> ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is Map && jsonData['data'] is Map) {
        // Convert Map to List
        return jsonData['data'].values.toList();
      } else if (jsonData is Map && jsonData['data'] is List) {
        return jsonData['data'];
      } else {
        return [];
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Get Completed Jobs
  Future<List<dynamic>> getCompletedJobs() async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/jobs/completed'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("getCompletedJobs response -> ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is Map && jsonData['data'] is Map) {
        // Convert Map to List
        return jsonData['data'].values.toList();
      } else if (jsonData is Map && jsonData['data'] is List) {
        return jsonData['data'];
      } else {
        return [];
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Delete Job
  Future<Map<String, dynamic>> deleteJob(String jobId) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.post(
      Uri.parse('$baseUrl/jobs/$jobId/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("deleteJob response (${response.statusCode}) -> ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['status'] == true || jsonData['success'] == true) {
        return jsonData;
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to delete job');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Update Job
  Future<Map<String, dynamic>> updateJob(
      String jobId, Map<String, dynamic> jobData) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final url = Uri.parse('$baseUrl/jobs/$jobId/edit');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(jobData),
      );

      print(" URL: $url");
      print(" Body: $jobData");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonResponse['status'] == true || jsonResponse['success'] == true) {
          return jsonResponse;
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update job');
        }
      } else {
        final errorMessage =
            jsonResponse['message'] ?? 'Failed to update job. Server error.';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      print("❌ Exception while updating job: $e");
      print(stack);
      throw Exception("Error updating job: $e");
    }
  }
}
