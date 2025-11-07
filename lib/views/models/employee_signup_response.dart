// models/employee_signup_response.dart
class EmployeeSignUpResponse {
  final bool status;
  final String message;
  final EmployeeUserData user;
  final EmployeeData employee;

  EmployeeSignUpResponse({
    required this.status,
    required this.message,
    required this.user,
    required this.employee,
  });

  factory EmployeeSignUpResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeSignUpResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      user: EmployeeUserData.fromJson(json['user']),
      employee: EmployeeData.fromJson(json['employee']),
    );
  }
}

class EmployeeUserData {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  EmployeeUserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeUserData.fromJson(Map<String, dynamic> json) {
    return EmployeeUserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class EmployeeData {
  final int id;
  final int userId;
  final String experienceYears;
  final List<String> services;
  final int workRadiusKm;
  final int hourlyRate;
  final String availability;
  final String about;
  final String idNumber;
  final String? idProofPath;
  final String? selfiePath;
  final bool phoneVerified;
  final String createdAt;
  final String updatedAt;

  EmployeeData({
    required this.id,
    required this.userId,
    required this.experienceYears,
    required this.services,
    required this.workRadiusKm,
    required this.hourlyRate,
    required this.availability,
    required this.about,
    required this.idNumber,
    this.idProofPath,
    this.selfiePath,
    required this.phoneVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      experienceYears: json['experience_years']?.toString() ?? '0',
      services:
          json['services'] != null ? List<String>.from(json['services']) : [],
      workRadiusKm: json['work_radius_km'] ?? 0,
      hourlyRate: json['hourly_rate'] ?? 0,
      availability: json['availability'] ?? '',
      about: json['about'] ?? '',
      idNumber: json['id_number'] ?? '',
      idProofPath: json['id_proof_path'],
      selfiePath: json['selfie_path'],
      phoneVerified: json['phone_verified'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
