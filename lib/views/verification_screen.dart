import 'package:flutter/material.dart';

import 'employe/dashboard_screen.dart';
import 'models/UserData.dart';

class VerificationScreen extends StatelessWidget {
  final UserData userData;


  const VerificationScreen({
    super.key,
    required this.userData, // ✅ Required data
  });



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
              Color(0xFFDFB139), // yellow top
              Color(0xFFB9AE3C), // mid olive
              Color(0xFF3CA349), // green bottom
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Back button
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
                    _buildStep("Personal Info",false ),
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
                          // Section Title
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
                                  onPressed: () {
                                    // TODO: Go to next step
                                    showVerificationDialog(context);

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

Future<void> showVerificationDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                "VERIFICATION",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your identity will be verified by our team.\n"
                    "You can still receive requests but won’t get\n"
                    "payouts until verified.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );

                },
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      );
    },
  );
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
