import 'package:flutter/material.dart';
import 'gradient_bg.dart';
import 'appbar.dart';

class ActiveVisitorsScreen extends StatelessWidget {
  const ActiveVisitorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            buildAppBar("Active Visitors (Inside Society)"),

            // Search box
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by Name / Vehicle...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return visitorCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget visitorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.motorcycle, size: 28),
          const SizedBox(width: 10),

          // 👉 Expanded prevents overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Rajiv Kumar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3),
                Text(
                  "03:30 PM   •   ABC-1223",
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          insideBadge(),

          const SizedBox(width: 8),

          markExitBtn(),
        ],
      ),
    );
  }


  Widget insideBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text("Inside", style: TextStyle(color: Colors.white)),
    );
  }

  Widget markExitBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text("Mark Exit", style: TextStyle(color: Colors.white)),
    );
  }
}
