import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:legacy_carry/views/employe/select_type_screen.dart';
import 'package:legacy_carry/views/employe/dashboard_screen.dart';
import 'package:legacy_carry/views/resident/resident_dashboard_screen.dart';
import 'package:legacy_carry/views/employe/sign_in_with_number_screen.dart';

class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

class _SplaceScreenState extends State<SplaceScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait a bit for splash effect
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');

    debugPrint("🔑 Saved Token: $token");
    debugPrint("🧑‍💼 Saved Role: $role");

    if (token != null && role != null) {
      //  User already logged in, navigate based on role
      if (role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ResidentDashboardScreen(),
          ),
        );
      } else if (role == 'labor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SignInWithNumberScreen(),
          ),
        );
      }
    } else {
      //  No login info found → Go to sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInWithNumberScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDFB139), // #DFB139 at 0%
              Color(0xFFB9AE3C), // #B9AE3C at 48%
              Color(0xFF3CA349), // #3CA349 at 100%
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              "resources/image/logo.png",
              height: 100,
              width: 200,
            ),
            const SizedBox(height: 10),

            // Title
            const Text(
              "Welcome - Legacy Carry",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Find Laborers - Connect with verified professionals in your "
                    "area for home repairs, construction, and more. Pay securely "
                    "with UPI, cards, and wallets.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // Manual button (fallback)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInWithNumberScreen(),),
                );
              },
              label: const Text(
                "Let's get started",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: const Icon(Icons.arrow_forward, color: Colors.black),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
