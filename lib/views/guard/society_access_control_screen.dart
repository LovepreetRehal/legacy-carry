import 'package:flutter/material.dart';

class SocietyAccessControlScreen extends StatelessWidget {
  const SocietyAccessControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9C878), Color(0xFF75AF4A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {},
                ),

                const Text(
                  "Society Access Control",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    _tab("My Visitor Passes", true),
                    const SizedBox(width: 10),
                    _tab("Nearby Societies", false),
                  ],
                ),

                const SizedBox(height: 20),

                _visitorCard(
                    name: "Rajiv Kumar",
                    label: "Labor",
                    purpose: "Plumbing Work"),
                const SizedBox(height: 16),

                _visitorCard(
                    name: "Neha Gupta",
                    label: "Guest",
                    purpose: "Family Visit"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(String title, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: selected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(8)),
      child: Text(title,
          style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _visitorCard(
      {required String name,
        required String label,
        required String purpose}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),

          const SizedBox(height: 10),
          Text("Purpose: $purpose"),

          const SizedBox(height: 12),

          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text("Show QR")),
              const SizedBox(width: 10),
              OutlinedButton(onPressed: () {}, child: const Text("Details")),
            ],
          )
        ],
      ),
    );
  }
}
