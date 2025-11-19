import 'package:flutter/material.dart';
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
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes =
  List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in otpControllers) c.dispose();
    for (var n in otpFocusNodes) n.dispose();
    super.dispose();
  }

  /// Auto move to next or back
  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

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

                      // -------- OTP BOXES -------- //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 40,
                            child: TextField(
                              controller: otpControllers[index],
                              focusNode: otpFocusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) => _onOtpChanged(value, index),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // -------- VERIFY BUTTON -------- //
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: otpVM.status == OtpStatus.loading
                              ? null
                              : () async {
                            // Collect OTP
                            final enteredOtp = otpControllers
                                .map((c) => c.text.trim())
                                .join();

                            // Validation
                            if (enteredOtp.length != 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text("Please enter all 6 digits"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Call API
                            await otpVM.verifyUserOtp(
                              phone: widget.phoneNumber,
                              otp: enteredOtp,
                            );

                            // SUCCESS
                            if (otpVM.status == OtpStatus.success) {
                              final user = otpVM.otpResponse?['user'];
                              final role = user?['role']
                                  ?.toString()
                                  .toLowerCase();
                              final token =
                              otpVM.otpResponse?['token'];

                              // Save Auth Data
                              final prefs =
                              await SharedPreferences.getInstance();
                              if (token != null) {
                                await prefs.setString(
                                    'auth_token', token);
                              }
                              if (role != null) {
                                await prefs.setString(
                                    'user_role', role);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("OTP Verified ✅"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // NAVIGATION
                              if (role == 'customer') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const ResidentDashboardScreen(),
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
                              : const Text(
                            "Verify & Continue",
                            style: TextStyle(fontSize: 16),
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
      },
    );
  }
}
