import 'package:flutter/material.dart';
import 'gradient_bg.dart';
import 'appbar.dart';

class EntryExitLogsScreen extends StatelessWidget {
  const EntryExitLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            buildAppBar("Entry / Exit Logs"),

            // Top Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                tabButton("Today", true),
                const SizedBox(width: 10),
                tabButton("This Week", false),
                const SizedBox(width: 10),
                tabButton("Custom", false),
              ],
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return entryCard();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget tabButton(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget entryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 26),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Rajiv Kumar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3),
                Text(
                  "03:30PM   |   Entry   |   05:30PM   •   ABC-1223",
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
