import 'package:flutter/material.dart';

class MyVisitorPassesScreen extends StatelessWidget {
  const MyVisitorPassesScreen({super.key});

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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {},
                    ),
                    const Spacer(),
                  ],
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Active Passes",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6)),
                      child: const Text(
                        "+ Create New Pass",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    children: [
                      _passCard(
                        name: "Rajiv Kumar",
                        label: "Labor",
                        purpose: "Plumbing Work",
                        phone: "+91 9876543210",
                      ),
                      const SizedBox(height: 16),
                      _passCard(
                        name: "Neha Gupta",
                        label: "Guest",
                        purpose: "Family Visit",
                        phone: "+91 9876543210",
                      ),
                    ],
                  ),
                )
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style:
        TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _passCard({
    required String name,
    required String label,
    required String purpose,
    required String phone,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 5),
                  Text("Active",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold))
                ],
              )
            ],
          ),
          const SizedBox(height: 8),

          _chip(label),

          const SizedBox(height: 8),
          Text("Purpose: $purpose"),
          const SizedBox(height: 4),
          Text("Phone: $phone"),

          const SizedBox(height: 16),

          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text("Show QR")),
              const SizedBox(width: 10),
              OutlinedButton(onPressed: () {}, child: const Text("Details")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.yellow.shade300,
          borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
