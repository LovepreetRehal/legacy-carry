class UserData {
  String name;
  String email;
  String phone;
  String address;
  String password;
  String otp;
  String? experience;
  double? workRadius;
  String? rate;
  String? availability;
  String? about;
  List<String>? services;

  UserData({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
    required this.otp,
    this.experience,
    this.workRadius,
    this.rate,
    this.availability,
    this.about,
    this.services,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "password": password,
      "otp": otp,
      "experience": experience,
      "workRadius": workRadius,
      "rate": rate,
      "availability": availability,
      "about": about,
      "services": services,
    };
  }
}
