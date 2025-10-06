import 'package:flutter/material.dart';

import 'employe/choose_language_screen.dart';
import 'employe/login_screen.dart';

class HireWorkersScreen extends StatelessWidget {
  const HireWorkersScreen({super.key});

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
            stops: [0.0, 0.48, 1.0], // matching CSS stops
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              "resources/image/img_user.png", // add your logo
              height: 100,
              width: 100,
              fit: BoxFit.cover, // 🔥 behaves like "centerCrop"

            ),
            const SizedBox(height: 10),

            // Title
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              "Post jobs and hire workers quickly",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
            const SizedBox(height: 15),

            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Create a job in seconds, review verified workers, and manage payments — all from one place.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChooseLanguageScreen()),
                );

              },
              label: const Text(
                "Continue as Employer",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // icon: const Icon(Icons.arrow_forward, color: Colors.black),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
