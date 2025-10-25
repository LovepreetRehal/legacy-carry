import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'employe/dashboard_screen.dart';
import 'models/UserData.dart';
import 'models/sign_up_request.dart';
import 'viewmodels/signup_viewmodel.dart';

class VerificationScreen extends StatelessWidget {
  final UserData userData; // store the passed user data

  const VerificationScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: _VerifyScreenContent(userData: userData),
    );
  }
}

class _VerifyScreenContent extends StatefulWidget {
  final UserData userData; // ✅ store the UserData as a field

  const _VerifyScreenContent({required this.userData, Key? key}) : super(key: key);

  @override
  State<_VerifyScreenContent> createState() => _VerifyScreenContentState();
}

class _VerifyScreenContentState extends State<_VerifyScreenContent> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final idController = TextEditingController();
    final otpControllers = List.generate(4, (_) => TextEditingController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDFB139),
              Color(0xFFB9AE3C),
              Color(0xFF3CA349),
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Join As a Employee",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Fill in your profile to receive job offers",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildStep("Personal Info", false),
                    _buildStep("Professional", false),
                    _buildStep("Verification", true),
                    _buildStep("Agreement", false),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Card Container
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Verification Documents",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ID Number + Verify Button
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: idController,
                                  decoration: const InputDecoration(
                                    hintText: "Enter Your Govt ID Number",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size(80, 48),
                                ),
                                onPressed: () {},
                                child: const Text("VERIFY"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // OTP Verification
                          const Text("OTP Verification*"),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) {
                              return SizedBox(
                                width: 50,
                                child: TextField(
                                  controller: otpControllers[index],
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 20),

                          // Upload ID Proof
                          const Text("Upload ID Proof"),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(
                                child: Text("Choose File/Image/Camera"),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.upload_file,
                                    color: Colors.green),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Upload Selfie
                          const Text("Upload Selfie for Face Verification*"),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(
                                child: Text("Choose File/Image/Camera"),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.upload_file,
                                    color: Colors.green),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Navigation Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("PREVIOUS"),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final otp = otpControllers.map((c) => c.text).join();
                                    final idNumber = idController.text.trim(); // Trim spaces

                                    // ✅ Validation for ID Number
                                    if (idNumber.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please enter your ID number")),
                                      );
                                      return; // Stop execution
                                    }

                                    // (Optional) Additional check if you expect a specific length or format
                                    if (idNumber.length < 6) { // example condition
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("ID number must be at least 6 characters long")),
                                      );
                                      return;
                                    }

                                    // Print userData
                                    print("=== User Data ===");
                                    print("Name: ${widget.userData.name}");
                                    print("Phone: ${widget.userData.phone}");
                                    print("Email: ${widget.userData.email}");
                                    print("Password: ${widget.userData.password}");
                                    print("Experience: ${widget.userData.experience}");
                                    print("Work Radius: ${widget.userData.workRadius}");
                                    print("Rate: ${widget.userData.rate}");
                                    print("About: ${widget.userData.about}");
                                    print("Availability: ${widget.userData.availability}");
                                    print("ID Number: $idNumber");
                                    print("OTP: ${widget.userData.otp}");

                                    final signUpViewModel =
                                    Provider.of<SignUpViewModel>(context, listen: false);

                                    // Build request from actual userData
                                    final request = SignUpRequest(
                                      name: widget.userData.name,
                                      phone: widget.userData.phone,
                                      email: widget.userData.email,
                                      password: widget.userData.password,
                                      role: "labor",
                                      otp: widget.userData.otp,
                                      experienceYears: widget.userData.experience ?? "0",
                                      services: ["Plumbing"], // Replace as needed
                                      workRadiusKm: widget.userData.workRadius?.toInt() ?? 0,
                                      hourlyRate: int.tryParse(widget.userData.rate ?? "0") ?? 0,
                                      availability: widget.userData.availability ?? "true",
                                      about: widget.userData.about ?? "",
                                      idNumber: idNumber,
                                    );

                                    await signUpViewModel.signUp(request);

                                    if (signUpViewModel.status == SignUpStatus.success) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                                      );
                                    } else if (signUpViewModel.status == SignUpStatus.error) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Signup failed: ${signUpViewModel.errorMessage}")),
                                      );
                                    }
                                  },
                                  child: const Text("NEXT"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildStep(String title, bool isActive) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 9,
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
