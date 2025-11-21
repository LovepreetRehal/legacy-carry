import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../employe/select_type_screen.dart';
import '../employe/dashboard_screen.dart';
import '../resident/resident_dashboard_screen.dart';
import '../viewmodels/verify_otp_view_model.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String otpValue = ""; // SAVE OTP HERE

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerifyOtpViewModel(),
      builder: (context, child) {
        final otpVM = Provider.of<VerifyOtpViewModel>(context);

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'resources/image/bg_leaves.png',
                  fit: BoxFit.cover,
                ),
              ),

              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
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
                    children: [
                      const Text(
                        "Enter OTP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We sent a 6-digit code to +91${widget.phoneNumber}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // 🔥 PIN CODE FIELD (White Background)
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        cursorColor: Colors.green,
                        autoFocus: true,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        enableActiveFill: true, // <-- WHITE BACKGROUND
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: 50,
                          fieldWidth: 40,

                          activeColor: Colors.green,
                          inactiveColor: Colors.green,
                          selectedColor: Colors.green,

                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                        ),

                        onChanged: (value) {
                          otpValue = value;
                        },

                        onCompleted: (otp) {
                          otpValue = otp;
                        },
                      ),

                      const SizedBox(height: 20),

                      // VERIFY BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: otpVM.status == OtpStatus.loading
                              ? null
                              : () async {
                            if (otpValue.length != 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter valid 6-digit OTP"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            await otpVM.verifyUserOtp(
                              phone: widget.phoneNumber,
                              otp: otpValue,
                            );

                            if (otpVM.status == OtpStatus.success) {
                              final user = otpVM.otpResponse?['user'];
                              final role = user?['role']?.toString().toLowerCase();
                              final token = otpVM.otpResponse?['token'];

                              final prefs = await SharedPreferences.getInstance();
                              if (token != null) prefs.setString('auth_token', token);
                              if (role != null) prefs.setString('user_role', role);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("OTP Verified Successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              if (role == 'customer') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ResidentDashboardScreen(),
                                  ),
                                );
                              } else if (role == 'labor') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const DashboardScreen(),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const SelectTypeScreen(),
                                  ),
                                );
                              }
                            }

                            // ERROR
                            else if (otpVM.status ==
                                OtpStatus.error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    otpVM.errorMessage.isNotEmpty
                                        ? otpVM.errorMessage
                                        : "Invalid OTP",
                                  ),
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

                          child: otpVM.status == OtpStatus.loading
                              ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                              : const Text("Verify & Continue", style: TextStyle(fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

