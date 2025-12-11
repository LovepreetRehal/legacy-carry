import 'package:flutter/material.dart';
import 'gradient_bg.dart';
import 'appbar.dart';

class ParkingOverviewScreen extends StatelessWidget {
  const ParkingOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            buildAppBar("Parking Overview"),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      numberCard("Total Vehicles", "32"),
                      const SizedBox(width: 15),
                      numberCard("Slots Available", "12"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  tableRow("Vehicle No.", "Owner Name", "Entry Time"),
                  tableRow("ABC-1223", "Rajiv Kumar", "03:30 PM"),
                  tableRow("ABC-1223", "Rajiv Kumar", "03:30 PM"),

                  const SizedBox(height: 15),
                  detailsBtn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget numberCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget tableRow(String a, String b, String c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(a)),
          Expanded(child: Text(b)),
          Expanded(child: Text(c)),
        ],
      ),
    );
  }

  Widget detailsBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("View Details", style: TextStyle(color: Colors.white)),
    );
  }
}
