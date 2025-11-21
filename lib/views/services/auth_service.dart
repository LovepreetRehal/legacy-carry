// services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/create_job_model.dart';
import '../models/create_job_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/sign_up_request.dart';

class AuthService {
  final String baseUrl = 'https://legacycarry.com/api';

  // Getter for base URL without /api suffix (for asset URLs)
  String get baseUrlWithoutApi => baseUrl.replaceAll('/api', '');

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

        // Save token and role to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', loginResponse.token);
        await prefs.setString(
            'user_role', loginResponse.user.role.toLowerCase());
        print("Token  ${loginResponse.token}");
        print(" Role  ${loginResponse.user.role}");

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

  /// Employee Signup API
  Future<Map<String, dynamic>> signUpEmployee(SignUpRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    print("Employee SignUp response -> ${response.body}");

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (json['status'] == true) {
        // Save token if provided in response
        if (json['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', json['token']);
          if (json['user'] != null && json['user']['role'] != null) {
            await prefs.setString(
                'user_role', json['user']['role'].toString().toLowerCase());
          }
        }
        return json;
      } else {
        // Handle validation errors
        final errorMessage = _extractValidationErrors(json);
        throw Exception(errorMessage);
      }
    } else {
      // Handle validation errors for non-200/201 status codes
      final errorMessage = _extractValidationErrors(json);
      throw Exception(errorMessage);
    }
  }

  /// Extract validation errors from API response
  String _extractValidationErrors(Map<String, dynamic> json) {
    if (json['errors'] != null && json['errors'] is Map) {
      final errors = json['errors'] as Map<String, dynamic>;
      final errorMessages = <String>[];

      errors.forEach((field, messages) {
        if (messages is List) {
          for (var message in messages) {
            errorMessages.add('${_formatFieldName(field)}: $message');
          }
        } else if (messages is String) {
          errorMessages.add('${_formatFieldName(field)}: $messages');
        }
      });

      if (errorMessages.isNotEmpty) {
        return errorMessages.join('\n');
      }
    }

    // Fallback to message if no errors object
    return json['message'] ?? 'Employee signup failed';
  }

  /// Format field name for display (e.g., "phone" -> "Phone")
  String _formatFieldName(String field) {
    // Convert snake_case to Title Case
    return field
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Future<CreateJobResponse> createJob(CreateJobRequest jobData) async {
    final url = Uri.parse('$baseUrl/jobs/create');

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

      print(" URL: $url");
      print(" Body: ${jobData.toJson()}");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      // Decode JSON safely
      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success response
        return CreateJobResponse.fromJson(jsonData);
      } else {
        //  API returned error JSON
        final errorMessage = jsonData['message'] ??
            'Failed to create job. Unknown server error.';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      print(" Exception while creating job: $e");
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
      final url = Uri.parse("$baseUrl/countries");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded;
        }

        if (decoded is Map<String, dynamic>) {
          if (decoded['countries'] is List) {
            return List<dynamic>.from(decoded['countries']);
          }
          if (decoded['data'] is List) {
            return List<dynamic>.from(decoded['data']);
          }
        }

        print("❌ Unexpected countries response shape: ${response.body}");
        return [];
      } else {
        print("❌ Failed to fetch countries: ${response.statusCode}");
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
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded;
        }

        if (decoded is Map<String, dynamic>) {
          if (decoded['states'] is List) {
            return List<dynamic>.from(decoded['states']);
          }
          if (decoded['data'] is List) {
            return List<dynamic>.from(decoded['data']);
          }
        }

        print("❌ Unexpected states response shape: ${response.body}");
        return [];
      }
      print("❌ Failed to fetch states: ${response.statusCode}");
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

  /// Get recommended jobs for the logged-in employer/employee profile.
  Future<List<dynamic>> getRecommendedJobs({required int employerId}) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/jobs/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      //body: jsonEncode({'employer_id': employerId}),
    );

    print("getRecommendedJobs body -> ${jsonEncode({
          'employer_id': employerId
        })}");
    print(
        "GetHomeEmployee  body -> ${jsonEncode({'employer_id': employerId})}");
    print("getRecommendedJobs response -> ${baseUrl + "/jobs"}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is Map && jsonData['data'] is List) {
        return List<dynamic>.from(jsonData['data']);
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Get Resident Jobs by status (active, draft, completed)
  Future<List<dynamic>> getResidentJobs({
    required int userId,
    required String status,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final normalizedStatus = status.toLowerCase();
    final response = await http.get(
      Uri.parse('$baseUrl/resident-jobs/$userId/$normalizedStatus'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(
        "getResidentJobs($normalizedStatus) response -> ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final data = jsonData is Map<String, dynamic> ? jsonData['data'] : null;

      if (data is List) {
        return List<dynamic>.from(data);
      } else if (data is Map) {
        return data.values.toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateJobStatus({
    required int jobId,
    required String status,
    required int approvedBy,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.post(
      Uri.parse('$baseUrl/jobs/$jobId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
        'approved_by': approvedBy,
      }),
    );

    print(
        "updateJobStatus($jobId -> $status) response -> ${response.statusCode} ${response.body}");

    Map<String, dynamic>? jsonData;
    try {
      jsonData = jsonDecode(response.body);
    } catch (_) {
      // ignore json decode error, handled below
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final isSuccess =
          (jsonData?['status'] == true) || (jsonData?['success'] == true);
      if (isSuccess && jsonData != null) {
        return jsonData;
      }
      final message = jsonData?['message'] ??
          'Failed to update job status. Please try again.';
      throw Exception(message);
    } else {
      final message =
          jsonData?['message'] ?? 'Server error: ${response.statusCode}';
      throw Exception(message);
    }
  }

  Future<List<dynamic>> searchResidentJobs({
    required int userId,
    String keyword = '',
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.post(
      Uri.parse('$baseUrl/resident-search-jobs/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'keyword': keyword}),
    );

    print(
        "searchResidentJobs response -> ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final data = jsonData is Map<String, dynamic> ? jsonData['data'] : null;

      if (data is List) {
        return List<dynamic>.from(data);
      } else if (data is Map) {
        return data.values.toList();
      }
      return [];
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> searchEmployeeJobs({
    String keyword = '',
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.post(
      Uri.parse('$baseUrl/search-jobs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'keyword': keyword}),
    );

    print(
        "searchEmployeeJobs response -> ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final data = jsonData is Map<String, dynamic> ? jsonData['data'] : null;

      if (data is List) {
        return List<dynamic>.from(data);
      } else if (data is Map) {
        return data.values.toList();
      }
      return [];
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getJobDetails(String jobId) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final endpoints = [
      '$baseUrl/job-detials/$jobId',
      '$baseUrl/jobs-detials/$jobId',
      '$baseUrl/job-details/$jobId',
    ];

    Exception? lastError;

    for (final endpoint in endpoints) {
      try {
        final response = await http.get(Uri.parse(endpoint), headers: headers);
        print("getJobDetails($endpoint) response -> ${response.body}");

        if (response.statusCode != 200) {
          lastError =
              Exception('Server error: ${response.statusCode} ($endpoint)');
          continue;
        }

        final jsonData = jsonDecode(response.body);

        if (jsonData is! Map<String, dynamic>) {
          lastError = Exception('Unexpected response format ($endpoint)');
          continue;
        }

        final bool isSuccess =
            jsonData['status'] == true || jsonData['success'] == true;
        if (!isSuccess) {
          lastError = Exception(
              jsonData['message'] ?? 'Failed to fetch job details ($endpoint)');
          continue;
        }

        if (jsonData['data'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(jsonData['data']);
        }

        lastError = Exception('Job details missing in response ($endpoint)');
      } catch (e) {
        lastError = Exception('Failed to fetch job details ($endpoint): $e');
      }
    }

    throw lastError ??
        Exception('Unable to fetch job details from available endpoints.');
  }

  /// Get Employee Active Jobs
  // TODO: Update endpoint URL when employee API endpoint is available
  Future<List<dynamic>> getEmployeeActiveJobs() async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.get(
      Uri.parse(
          '$baseUrl/employee/jobs/active'), // TODO: Update with actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("getEmployeeActiveJobs response -> ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is Map && jsonData['data'] is Map) {
        return jsonData['data'].values.toList();
      } else if (jsonData is Map && jsonData['data'] is List) {
        return jsonData['data'];
      } else if (jsonData is List) {
        return jsonData;
      } else {
        return [];
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Get Employee Draft Jobs
  // TODO: Update endpoint URL when employee API endpoint is available
  Future<List<dynamic>> getEmployeeDraftJobs() async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.get(
      Uri.parse(
          '$baseUrl/employee/jobs/draft'), // TODO: Update with actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("getRecommendedJobs response -> ${baseUrl + "/jobs"}");

    print("getEmployeeDraftJobs response -> ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is Map && jsonData['data'] is Map) {
        return jsonData['data'].values.toList();
      } else if (jsonData is Map && jsonData['data'] is List) {
        return jsonData['data'];
      } else if (jsonData is List) {
        return jsonData;
      } else {
        return [];
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Get Employee Hourly Jobs
  // TODO: Update endpoint URL when employee API endpoint is available
  Future<List<dynamic>> getEmployeeHourlyJobs() async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final response = await http.get(
      Uri.parse(
          '$baseUrl/employee/jobs/hourly'), // TODO: Update with actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("getEmployeeHourlyJobs response -> ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is Map && jsonData['data'] is Map) {
        return jsonData['data'].values.toList();
      } else if (jsonData is Map && jsonData['data'] is List) {
        return jsonData['data'];
      } else if (jsonData is List) {
        return jsonData;
      } else {
        return [];
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Filter Employee Jobs by Status (active, upcoming, completed)
  /// Endpoint: /filter-jobs/{user_id}/{status}?email={email}
  Future<List<dynamic>> filterEmployeeJobsByStatus({
    required int userId,
    required String status, // 'active', 'upcoming', 'completed'
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    try {
      // Get user email from profile
      final profile = await getUserProfile();
      final dynamic userData = profile['user'] ?? profile['data'] ?? profile;
      final String? email = userData?['email'] ?? profile['email'];

      if (email == null || email.isEmpty) {
        throw Exception('User email not found');
      }

      // Build URL with query parameter
      final url = Uri.parse('$baseUrl/filter-jobs/$userId/$status').replace(
        queryParameters: {'email': email},
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("filterEmployeeJobsByStatus($status) response -> ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Check if status is true
        if (jsonData is Map && jsonData['status'] == true) {
          // Extract data array from response
          if (jsonData['data'] is List) {
            return jsonData['data'];
          } else if (jsonData['data'] is Map) {
            return jsonData['data'].values.toList();
          } else {
            return [];
          }
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to fetch jobs');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in filterEmployeeJobsByStatus: $e");
      rethrow;
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
      print(" Exception while updating job: $e");
      print(stack);
      throw Exception("Error updating job: $e");
    }
  }

  /// Report Bug/Problem
  Future<Map<String, dynamic>> reportBug({
    required int userId,
    required String reportType,
    required String description,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/reports');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'report_type': reportType,
          'description': description,
          'email': email,
        }),
      );

      print(" URL: $url");
      print(
          " Body: {user_id: $userId, report_type: $reportType, description: $description, email: $email}");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        final errorMessage =
            jsonResponse['message'] ?? 'Failed to submit report. Server error.';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      print(" Exception while reporting bug: $e");
      print(stack);
      rethrow;
    }
  }

  /// Upload Document
  Future<Map<String, dynamic>> uploadDocument({
    required int userId,
    required String documentType,
    required File file,
  }) async {
    final url = Uri.parse('$baseUrl/user-documents/upload');

    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add fields
      request.fields['user_id'] = userId.toString();
      request.fields['document_type'] = documentType;

      // Add file
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
      );
      request.files.add(multipartFile);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(" URL: $url");
      print(" User ID: $userId");
      print(" Document Type: $documentType");
      print(" File Path: ${file.path}");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        final errorMessage = jsonResponse['message'] ??
            'Failed to upload document. Server error.';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      print(" Exception while uploading document: $e");
      print(stack);
      rethrow;
    }
  }

  /// Get documents uploaded by a user
  Future<List<dynamic>> getUserDocuments(int userId) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/user-documents/$userId');

    final headers = {
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);
      print(" Get User Documents URL: $url");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);
      final bool isSuccess = jsonResponse['status'] == true ||
          jsonResponse['success'] == true ||
          response.statusCode == 200;

      if (isSuccess && jsonResponse['data'] is List) {
        return List<dynamic>.from(jsonResponse['data']);
      }

      final message =
          jsonResponse['message'] ?? 'Failed to fetch uploaded documents';
      throw Exception(message);
    } catch (e, stackTrace) {
      print(" Exception while fetching user documents: $e");
      print(stackTrace);
      rethrow;
    }
  }

  Future<List<dynamic>> getPaymentMethods({required int userId}) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final url = Uri.parse('$baseUrl/users/$userId/payment-methods');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(
        "getPaymentMethods response (${response.statusCode}) -> ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is Map<String, dynamic>) {
        final data = jsonData['data'];
        if (data is List) {
          return List<dynamic>.from(data);
        } else if (data == null) {
          return [];
        }
      } else if (jsonData is List) {
        return List<dynamic>.from(jsonData);
      }

      return [];
    } else {
      throw Exception(
          'Failed to fetch payment methods: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addPaymentMethod({
    required int userId,
    required String methodType,
    required Map<String, dynamic> details,
    required bool isPrimary,
    required String provider,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final url = Uri.parse('$baseUrl/users/$userId/payment-methods');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'type': methodType,
        'details': details,
        'is_primary': isPrimary,
        'provider': provider,
      }),
    );

    print(
        "addPaymentMethod response (${response.statusCode}) -> ${response.body}");

    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        jsonData['status'] == true) {
      return jsonData;
    } else {
      final message = jsonData['message'] ?? 'Failed to add payment method';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> updatePaymentMethod({
    required int userId,
    required int paymentMethodId,
    required String methodType,
    required Map<String, dynamic> details,
    required bool isPrimary,
    required String provider,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final url =
        Uri.parse('$baseUrl/users/$userId/payment-methods/$paymentMethodId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'type': methodType,
        'details': details,
        'is_primary': isPrimary,
        'provider': provider,
      }),
    );

    print(
        "updatePaymentMethod response (${response.statusCode}) -> ${response.body}");

    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        jsonData['status'] == true) {
      return jsonData;
    } else {
      final message = jsonData['message'] ?? 'Failed to update payment method';
      throw Exception(message);
    }
  }

  /// Submit Job Application
  Future<Map<String, dynamic>> submitJobApplication({
    required String jobId,
    required String startDatetime,
    required int expectedCost,
    required String messageToEmployer,
    String certificatePhoto = '',
    required String userId,
    required String residentId,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final url = Uri.parse('$baseUrl/submit-job-application');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'job_id': jobId,
          'start_datetime': startDatetime,
          'expected_cost': expectedCost,
          'message_to_employer': messageToEmployer,
          'certificate_photo': certificatePhoto,
          'user_id': userId,
          'resident_id': residentId,
        }),
      );

      print(" Submit Job Application URL: $url");
      print(" Request Body: ${jsonEncode({
            'job_id': jobId,
            'start_datetime': startDatetime,
            'expected_cost': expectedCost,
            'message_to_employer': messageToEmployer,
            'certificate_photo': certificatePhoto,
            'user_id': userId,
            'resident_id': residentId,
          })}");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonResponse['status'] == true) {
          return jsonResponse;
        } else {
          throw Exception(
              jsonResponse['message'] ?? 'Failed to submit application');
        }
      } else {
        final errorMessage = jsonResponse['message'] ??
            'Failed to submit application. Server error: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      print(" Exception while submitting job application: $e");
      print(stack);
      rethrow;
    }
  }

  /// Get FAQs
  Future<List<dynamic>> getFAQs() async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final url = Uri.parse('$baseUrl/settings/faqs');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(" Get FAQs URL: $url");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Handle different response formats
        if (jsonResponse is List) {
          return jsonResponse;
        } else if (jsonResponse is Map && jsonResponse['data'] is List) {
          return jsonResponse['data'];
        } else {
          return [];
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e, stack) {
      print(" Exception while fetching FAQs: $e");
      print(stack);
      rethrow;
    }
  }

  /// Logout API
  Future<Map<String, dynamic>> logout() async {
    final token = await getToken();
    if (token == null) {
      // If no token, just return success since user is already logged out locally
      return {'status': true, 'message': 'Already logged out'};
    }

    final url = Uri.parse('$baseUrl/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(" Logout URL: $url");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      // Clear token from SharedPreferences regardless of response
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_role');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        // Even if API fails, we've cleared local data, so return success
        return {
          'status': true,
          'message': jsonResponse['message'] ?? 'Logged out locally'
        };
      }
    } catch (e, stack) {
      print(" Exception while logging out: $e");
      print(stack);

      // Clear token from SharedPreferences even if API call fails
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_role');
      } catch (_) {
        // Ignore errors when clearing preferences
      }

      // Return success since we've cleared local data
      return {
        'status': true,
        'message': 'Logged out locally (API call failed)'
      };
    }
  }

  /// Update User Profile
  Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required String name,
    required String email,
    required String phone,
    File? avatar,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final url = Uri.parse('$baseUrl/user/$userId/update');

    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add form fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone;

      // Add avatar file if provided
      if (avatar != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'avatar',
          avatar.path,
        );
        request.files.add(multipartFile);
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(" Update User Profile URL: $url");
      print(" User ID: $userId");
      print(" Name: $name");
      print(" Email: $email");
      print(" Phone: $phone");
      print(" Avatar: ${avatar != null ? avatar.path : 'Not provided'}");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        final errorMessage = jsonResponse['message'] ??
            'Failed to update profile. Server error: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      print(" Exception while updating user profile: $e");
      print(stack);
      rethrow;
    }
  }

  /// Update Language & Region
  Future<Map<String, dynamic>> updateLanguageRegion({
    required int userId,
    required String language,
    required String region,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final url = Uri.parse('$baseUrl/user/$userId/language-region');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'language': language,
          'region': region,
        }),
      );

      print(" Update Language & Region URL: $url");
      print(" User ID: $userId");
      print(" Language: $language");
      print(" Region: $region");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        final errorMessage = jsonResponse['message'] ??
            'Failed to update language & region. Server error: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      print(" Exception while updating language & region: $e");
      print(stack);
      rethrow;
    }
  }

  /// Get Applications for a Job (Resident)
  /// Fetches all applications for a specific job
  /// Note: The endpoint may return all applications for the resident's jobs,
  /// so we filter by job_id to get applications for the specific job
  Future<List<dynamic>> getApplicationsForJob({required String jobId}) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    // First, try to get user profile to get user_id
    // The endpoint might use user_id, so we'll get it first
    final profile = await getUserProfile();
    final dynamic userData = profile['user'] ??
        profile['data']?['user'] ??
        profile['data'] ??
        profile;
    final dynamic userIdCandidate = userData?['id'] ?? profile['id'];

    if (userIdCandidate == null) {
      throw Exception('Unable to determine user ID');
    }

    final userId = userIdCandidate.toString();
    final url = Uri.parse('$baseUrl/get-applications-resident/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(" Get Applications for Job URL: $url");
      print(" User ID: $userId");
      print(" Job ID (filtering): $jobId");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map && jsonResponse['status'] == true) {
          // Get all applications from the response
          List<dynamic> allApplications = [];
          if (jsonResponse['applications'] is List) {
            allApplications = jsonResponse['applications'];
          }

          // Filter applications by job_id to get only applications for this specific job
          final jobIdNum = int.tryParse(jobId);
          final filteredApplications = allApplications.where((app) {
            final appJobId = app['job_id'];
            // Try to match job_id as both int and string
            if (appJobId == null) return false;
            if (appJobId.toString() == jobId) return true;
            if (jobIdNum != null && appJobId == jobIdNum) return true;
            return false;
          }).toList();

          print(" Total applications: ${allApplications.length}");
          print(
              " Filtered applications for job $jobId: ${filteredApplications.length}");

          return filteredApplications;
        } else {
          final errorMessage =
              jsonResponse['message'] ?? 'Failed to fetch applications for job';
          throw Exception(errorMessage);
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e, stack) {
      print(" Exception while fetching applications for job: $e");
      print(stack);
      rethrow;
    }
  }

  /// Update Application Status (Resident)
  /// Updates the status of an application (hired, applied, completed, cancel)
  /// The id in the body is the application_id
  Future<Map<String, dynamic>> updateApplicationStatus({
    required int applicationId,
    required String status, // 'applied', 'hired', 'completed', 'cancel'
    bool? shortlisted,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final url = Uri.parse('$baseUrl/resident-application-status');

    try {
      final body = {
        'id': applicationId,
        'status': status,
      };

      // Add shortlisted if provided
      if (shortlisted != null) {
        body['shortlisted'] = shortlisted;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print(" Update Application Status URL: $url");
      print(" Application ID: $applicationId");
      print(" Status: $status");
      print(" Shortlisted: $shortlisted");
      print(" Request Body: ${jsonEncode(body)}");
      print(" Status Code: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonResponse['status'] == true || jsonResponse['success'] == true) {
          return jsonResponse;
        } else {
          final errorMessage =
              jsonResponse['message'] ?? 'Failed to update application status';
          throw Exception(errorMessage);
        }
      } else {
        final errorMessage = jsonResponse['message'] ??
            'Failed to update application status. Server error: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e, stack) {
      print(" Exception while updating application status: $e");
      print(stack);
      rethrow;
    }
  }
}
