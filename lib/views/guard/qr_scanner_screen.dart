import 'package:flutter/material.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9C878), Color(0xFF75AF4A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Frame UI
              Expanded(
                child: Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style:
                ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {},
                child: const Text("Align QR Within Frame"),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
