import 'package:flutter/material.dart';
import 'package:legacy_carry/views/employe/professional_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:legacy_carry/views/viewmodels/send_otp_viewmodel.dart';

class EmployeeRegisterScreen extends StatelessWidget {
  const EmployeeRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SendOtpViewModel(),
      child: const _EmployeeRegisterContent(),
    );
  }
}

class _EmployeeRegisterContent extends StatefulWidget {
  const _EmployeeRegisterContent();

  @override
  State<_EmployeeRegisterContent> createState() =>
      _EmployeeRegisterContentState();
}

class _EmployeeRegisterContentState extends State<_EmployeeRegisterContent> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final otpVm = Provider.of<SendOtpViewModel>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDFB139), Color(0xFFB9AE3C), Color(0xFF3CA349)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Join As an Employee",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(left: 48),
                  child: Text(
                    "Fill in your profile to receive job offers",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),

                // Stepper Tabs
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildStep("Personal Info", true),
                      _buildStep("Professional", false),
                      _buildStep("Verification", false),
                      _buildStep("Agreement", false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      _buildTextField("Name*", Icons.person_outline,
                          hint: "John Doe"),

                      const SizedBox(height: 12),
                      // Email
                      _buildTextField("Email Address*", Icons.email_outlined,
                          hint: "info@gmail.com"),

                      const SizedBox(height: 12),
                      // Phone with verify
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Phone Number*",
                              Icons.phone_outlined,
                              hint: "+91-9876543210",
                              controller: _phoneController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(70, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: otpVm.status == OtpStatus.loading
                                ? null
                                : () async {
                              await otpVm.sendUserOtp(
                                countryCode: "+91",
                                phone: _phoneController.text.trim(),
                                purpose: "login",
                              );

                              if (otpVm.status == OtpStatus.success) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                    Text("OTP Sent Successfully"),
                                  ),
                                );
                              } else if (otpVm.status ==
                                  OtpStatus.error) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Error: ${otpVm.errorMessage}"),
                                  ),
                                );
                              }
                            },
                            child: otpVm.status == OtpStatus.loading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text("VERIFY"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      // OTP fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                              (index) => SizedBox(
                            width: 50,
                            child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      // Address
                      _buildTextField("Current Address*", Icons.location_on,
                          hint: "India"),

                      const SizedBox(height: 12),
                      // Password
                      _buildTextField("Password*", Icons.lock_outline,
                          hint: "Set Password", obscure: true),

                      const SizedBox(height: 12),
                      // Confirm Password
                      _buildTextField("Confirm Password*", Icons.lock_outline,
                          hint: "Confirm Password", obscure: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Next button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const ProfessionalDetailsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("NEXT"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Step builder
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

  // Custom text field builder
  Widget _buildTextField(
      String title,
      IconData icon, {
        String? hint,
        bool obscure = false,
        TextEditingController? controller,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
