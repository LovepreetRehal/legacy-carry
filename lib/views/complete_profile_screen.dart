import 'package:flutter/material.dart';
import 'employe/select_type_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final villageController = TextEditingController();

  String? selectedResidentialStatus;
  String? selectedPaymentMethod;
  String? selectedState = "Punjab";
  String? selectedDistrict = "Patiala";

  final residentialOptions = ["Society", "Individual", "Commercial"];
  final paymentOptions = ["Bank Transfer", "Cash", "UPI"];

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    villageController.dispose();
    super.dispose();
  }

  void handleSaveAndContinue() {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final village = villageController.text.trim();

    // Print or use the collected values
    debugPrint('===============================');
    debugPrint('Full Name: $name');
    debugPrint('Email: $email');
    debugPrint('Residential Status: $selectedResidentialStatus');
    debugPrint('State: $selectedState');
    debugPrint('District: $selectedDistrict');
    debugPrint('Village/Town: $village');
    debugPrint('Payment Method: $selectedPaymentMethod');
    debugPrint('===============================');

    // You can also create a Map to send to API easily 👇
    final profileData = {
      "full_name": name,
      "email": email,
      "residential_status": selectedResidentialStatus,
      "state": selectedState,
      "district": selectedDistrict,
      "village": village,
      "payment_method": selectedPaymentMethod,
    };

    debugPrint("Profile Data Map: $profileData");

    // 👉 Navigate to next screen after saving data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SelectTypeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5C041), // top yellowish
              Color(0xFF3CA349), // bottom green
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Complete Your Profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          hintText: "Enter Your Name",
                          labelText: "Full Name",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Enter Email Address",
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedResidentialStatus,
                        items: residentialOptions
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedResidentialStatus = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Select your Residential Status",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedState,
                        items: const [
                          DropdownMenuItem(
                            value: "Punjab",
                            child: Text("Punjab"),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedState = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Select State",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedDistrict,
                        items: const [
                          DropdownMenuItem(
                            value: "Patiala",
                            child: Text("Patiala"),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedDistrict = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Select Distt/City",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: villageController,
                        decoration: const InputDecoration(
                          hintText: "Enter Address",
                          labelText: "Village/Town",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedPaymentMethod,
                        items: paymentOptions
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedPaymentMethod = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Preferred Payment Method",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: handleSaveAndContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Save & Continue",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
