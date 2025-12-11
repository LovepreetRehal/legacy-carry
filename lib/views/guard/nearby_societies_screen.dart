import 'package:flutter/material.dart';

class NearbySocietiesScreen extends StatelessWidget {
  const NearbySocietiesScreen({super.key});

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
                    IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
                  ],
                ),

                const Text("Society Access Control",
                    style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _tab("My Visitor Passes", false),
                    const SizedBox(width: 10),
                    _tab("Nearby Societies", true),
                  ],
                ),
                const SizedBox(height: 20),

                _searchBox(),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    children: [
                      _societyCard("Basenty Residency", "1.2 km", "1250 Flats"),
                      const SizedBox(height: 12),
                      _societyCard("Tasty Blues", "2.1 km", "850 Flats"),
                      const SizedBox(height: 12),
                      _societyCard("Royal Gardens", "500m", "1100 Flats"),
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
          borderRadius: BorderRadius.circular(8)),
      child: Text(title,
          style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _searchBox() {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: "Search Society",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _societyCard(String name, String distance, String flats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name,
                  style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const Text(" Active",
                  style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Distance: $distance"),
          Text("Total Flats: $flats"),
        ],
      ),
    );
  }
}
