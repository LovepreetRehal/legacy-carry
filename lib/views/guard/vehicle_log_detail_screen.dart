import 'package:flutter/material.dart';
import 'gradient_bg.dart';
import 'appbar.dart';

class VehicleLogDetailScreen extends StatelessWidget {
  const VehicleLogDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            buildAppBar("Vehicle Log Detail"),

            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text("ABC-1223",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  infoBox(),

                  const SizedBox(height: 20),

                  logTile("12 Sept 2025", "In: 03:30PM", "Out: 12:30PM", "Inside"),
                  logTile("11 Sept 2025", "In: 09:00AM", "Out: 11:30AM", "Exited"),
                  logTile("10 Sept 2025", "In: 08:00AM", "Out: 10:00AM", "Exited"),

                  const SizedBox(height: 20),
                  exitBtn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Vehicle No : ABC - 1223"),
          Text("Type : Car"),
          Text("Owner : Rajiv Kumar"),
          Text("Pass ID 0001"),
        ],
      ),
    );
  }

  Widget logTile(String date, String inTime, String outTime, String status) {
    Color color = status == "Inside" ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(color: Colors.white)),
          Text(inTime, style: const TextStyle(color: Colors.white)),
          Text(outTime, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget exitBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("Mark Exit", style: TextStyle(color: Colors.white)),
    );
  }
}
