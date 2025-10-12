class SignUpRequest {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String role;
  final bool isActive;
  final String otp;
  final String experienceYears;
  final List<String> services;
  final int workRadiusKm;
  final int hourlyRate;
  final String availability;
  final String about;
  final String idNumber;

  SignUpRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
    this.isActive = true,
    required this.otp,
    required this.experienceYears,
    required this.services,
    required this.workRadiusKm,
    required this.hourlyRate,
    required this.availability,
    required this.about,
    required this.idNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
      "email": email,
      "password": password,
      "role": role,
      "is_active": isActive,
      "otp": otp,
      "experience_years": experienceYears,
      "services": services,
      "work_radius_km": workRadiusKm,
      "hourly_rate": hourlyRate,
      "availability": availability,
      "about": about,
      "id_number": idNumber,
    };
  }
}
