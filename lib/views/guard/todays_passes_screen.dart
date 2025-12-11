import 'package:flutter/material.dart';

class TodaysPassesScreen extends StatelessWidget {
  const TodaysPassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFFE9C878), Color(0xFF75AF4A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
                  ],
                ),

                const Text("Today’s Passes",
                    style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Visitor Name / Vehicle No.",
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _filter("All", true),
                    _filter("Upcoming", false),
                    _filter("Expired", false),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    children: [
                      _passTile("Rajiv Kumar", "03:30 PM", "Active"),
                      _passTile("Neha Gupta", "04:30 PM", "Expired"),
                      _passTile("Gauri Sharma", "04:30 PM", "Active"),
                      _passTile("Sanjay", "06:30 PM", "Upcoming"),
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

  Widget _filter(String text, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          color: selected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(30)),
      child: Text(text,
          style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _passTile(String name, String time, String status) {
    Color badgeColor =
    status == "Active" ? Colors.green : (status == "Expired" ? Colors.grey : Colors.orange);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(time),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6)),
            child: Text(status,
                style: TextStyle(
                    color: badgeColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.qr_code, size: 28),
        ],
      ),
    );
  }
}
