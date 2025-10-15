// views/login_screen.dart
import 'package:flutter/material.dart';
import 'package:legacy_carry/views/employe/select_type_screen.dart';
import 'package:legacy_carry/views/viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';

import '../viewmodels/send_otp_viewmodel.dart';
import 'enter_otp_screen.dart';

class SignInWithNumberScreen extends StatelessWidget {
  const SignInWithNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SendOtpViewModel(),
      child: const _SignInWithNumberScreen(),
    );
  }
}

class _SignInWithNumberScreen extends StatefulWidget {
  const _SignInWithNumberScreen();

  @override
  State<_SignInWithNumberScreen> createState() =>
      _EmployeeRegisterContentState();
}

class _EmployeeRegisterContentState extends State<_SignInWithNumberScreen> {
  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<SendOtpViewModel>(context);
    final phoneController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              'resources/image/bg_leaves.png',
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Gradient Overlay (soft tint)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Main Form
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Sign in With Phone",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter Your Mobile Number to Receive OTP",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // ✅ Phone Number Field
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Mobile Number',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final phone = phoneController.text.trim();
                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter your phone number"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        await loginVM.sendUserOtp(
                          countryCode: "+91",
                          phone: phone,
                          purpose: "login",
                        );

                        if (loginVM.status == OtpStatus.success) {
                          final response = loginVM.otpResponse;
                          final message = response?['message'] ?? 'OTP sent successfully';
                          final code = response?['code']; // for testing if needed
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loginVM.errorMessage.isNotEmpty
                                  ? message
                                  : message + "  "+code.toString()),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Navigate to OTP screen
                          Future.delayed(const Duration(milliseconds: 500), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtpVerificationScreen(
                                  phoneNumber: phone,
                                ),
                              ),
                            );
                          });
                        }
                        else if (loginVM.status == OtpStatus.error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loginVM.errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Send OTP",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ✅ Sign in with email (Text button)
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SelectTypeScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
