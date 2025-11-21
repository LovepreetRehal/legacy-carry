import 'package:flutter/material.dart';
import 'package:legacy_carry/views/verification_screen.dart';

import '../models/UserData.dart';

class ProfessionalDetailsScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String password;
  final String otp;

  const ProfessionalDetailsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
    required this.otp,
  });

  @override
  State<ProfessionalDetailsScreen> createState() =>
      _ProfessionalDetailsScreenState();
}

class _ProfessionalDetailsScreenState extends State<ProfessionalDetailsScreen> {
  String? experience;
  double workRadius = 5;
  TextEditingController rateController = TextEditingController(text: "700");
  String availability = "Full - Time";
  TextEditingController aboutController = TextEditingController();
  List<String> selectedServices = [];

  final services = [
    {"icon": Icons.plumbing, "label": "Plumbing"},
    {"icon": Icons.format_paint, "label": "Painting"},
    {"icon": Icons.electrical_services, "label": "Electrical"},
    {"icon": Icons.handyman, "label": "Carpentry"},
    {"icon": Icons.construction, "label": "Construction"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFF9CCC65)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar Row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    const Expanded(
                      child: Text(
                        "Join As a Employee",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // balance
                  ],
                ),
              ),

              const Text(
                "Fill in your profile to receive job offers",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildStep("Personal Info", false),
                    _buildStep("Professional", true),
                    _buildStep("Verification", false),
                    _buildStep("Agreement", false),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Form Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Professional Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dropdown - Experience
                        DropdownButtonFormField<String>(
                          value: experience,
                          hint: const Text("Select Experience Level"),
                          decoration: _inputDecoration(),
                          items:
                              ["Fresher", "1-3 Years", "3-5 Years", "5+ Years"]
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              experience = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Services Grid
                        const Text(
                          "Select Services*",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: services.map((s) {
                              final serviceLabel = s["label"] as String;
                              final isSelected =
                                  selectedServices.contains(serviceLabel);
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedServices.remove(serviceLabel);
                                      } else {
                                        selectedServices.add(serviceLabel);
                                      }
                                    });
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: isSelected
                                            ? Colors.green
                                            : Colors.grey.shade200,
                                        child: Icon(
                                          s["icon"] as IconData,
                                          size: 30,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        serviceLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (selectedServices.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "Please select at least one service",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Slider
                        const Text("Work Radius"),
                        Slider(
                          value: workRadius,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          label: "${workRadius.toInt()} KM",
                          onChanged: (val) {
                            setState(() {
                              workRadius = val;
                            });
                          },
                        ),
                        Text("${workRadius.toInt()} KM"),

                        const SizedBox(height: 16),

                        // Hourly Rate
                        TextFormField(
                          controller: rateController,
                          decoration: _inputDecoration(
                            hint: "₹ 0",
                            label: "Hourly Rate (₹)",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Suggested Price Range: ₹500–₹1000 per hour.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),

                        const SizedBox(height: 16),

                        // Availability Dropdown
                        DropdownButtonFormField<String>(
                          value: availability,
                          decoration: _inputDecoration(label: "Availability"),
                          items: ["Full - Time", "Part - Time"]
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              availability = val!;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // About
                        TextFormField(
                          controller: aboutController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            hint: "Tell Us About Your Work Experience",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("PREVIOUS"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedServices.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Please select at least one service"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (experience == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select experience level"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          print("=== Personal Details ===");
                          print("Name: ${widget.name}");
                          print("Email: ${widget.email}");
                          print("Phone: ${widget.phone}");
                          print("Address: ${widget.address}");
                          print("Password: ${widget.password}");
                          print("OTP: ${widget.otp}");

                          print("=== Professional Details ===");
                          print("Experience: $experience");
                          print("Work Radius: ${workRadius.toInt()} KM");
                          print("Hourly Rate: ${rateController.text}");
                          print("Availability: $availability");
                          print("About: ${aboutController.text}");
                          print("Services: $selectedServices");

                          final userData = UserData(
                            name: widget.name,
                            email: widget.email,
                            phone: widget.phone,
                            address: widget.address,
                            password: widget.password,
                            otp: widget.otp,
                            experience: experience,
                            workRadius: workRadius,
                            rate: rateController.text,
                            availability: availability,
                            about: aboutController.text,
                            services: selectedServices,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VerificationScreen(userData: userData),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("NEXT"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, String? label}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

class StepChip extends StatelessWidget {
  final String label;
  final bool active;

  const StepChip({super.key, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
      backgroundColor: active ? Colors.green : Colors.grey.shade300,
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
