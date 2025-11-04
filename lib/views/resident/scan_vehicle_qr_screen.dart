import 'package:flutter/material.dart';

class ScanVehicleQRScreen extends StatelessWidget {
  const ScanVehicleQRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFF6C945), Color(0xFF7BC57B)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, size: 28)),
                  const SizedBox(width: 10),
                  const Text("Scan Vehicle QR", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),

              const Spacer(),

              const Icon(Icons.qr_code_2, size: 240, color: Colors.white),

              const Spacer(),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Create Pass"),
              ),

              const SizedBox(height: 25)
            ],
          ),
        ),
      ),
    );
  }
}
