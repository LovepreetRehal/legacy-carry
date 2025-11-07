import 'package:flutter/material.dart';
import '../employe/job_detail_screen.dart';

class SearchJobsScreen extends StatelessWidget {
  const SearchJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDFB139), // yellow top
              Color(0xFFB9AE3C), // mid olive
              Color(0xFF3CA349), // green bottom
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    hintText: "Search Jobs by Skill/Location.....",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Filter Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildFilterButton("Skill")),
                        const SizedBox(width: 12),
                        Expanded(child: _buildFilterButton("Pay Range")),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildFilterButton("Distance")),
                        const SizedBox(width: 12),
                        Expanded(child: _buildFilterButton("Date")),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Job List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // _buildJobCard(
                    //   context: context,
                    //   title: "Carpentry at Green Meadows",
                    //   company: "Rajiv Kumar",
                    //   date: "18 Sep 2025",
                    //   pay: "₹500 / Day",
                    //   distance: "2.3 Km",
                    // ),
                    // const SizedBox(height: 12),
                    // _buildJobCard(
                    //   context: context,
                    //   title: "Painter Job",
                    //   company: "Raj Interiors",
                    //   date: "17 Sep 2025",
                    //   pay: "₹700 / Day",
                    //   distance: "3 Km",
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
    );
  }

  Widget _buildFilterButton(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {},
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildJobCard({
    required BuildContext context,
    required String title,
    required String company,
    required String date,
    required String pay,
    required String distance,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(
              jobData: {
                'job_title': title,
                'employer_name': company,
                'start_date': date,
                'pay_amount': pay.split('₹')[1].split(' /')[0],
                'pay_type': pay.contains('Day') ? 'per_day' : 'per_hour',
                'location': distance,
                'rating': 5.0,
                'reviews': 24,
                'tasks': 'Wood cutting, furniture repair',
                'tools_provided': true,
                'time': '9:00 AM',
                'expected_duration': '3 Days',
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(company),
                const Spacer(),
                const Icon(Icons.calendar_today,
                    size: 16, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(date),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Text(pay),
                const Spacer(),
                const Icon(Icons.location_on, size: 16, color: Colors.pink),
                const SizedBox(width: 6),
                Text(distance),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailScreen(
                        jobData: {
                          'job_title': title,
                          'employer_name': company,
                          'start_date': date,
                          'pay_amount': pay.split('₹')[1].split(' /')[0],
                          'pay_type':
                              pay.contains('Day') ? 'per_day' : 'per_hour',
                          'location': distance,
                          'rating': 5.0,
                          'reviews': 24,
                          'tasks': 'Wood cutting, furniture repair',
                          'tools_provided': true,
                          'time': '9:00 AM',
                          'expected_duration': '3 Days',
                        },
                      ),
                    ),
                  );
                },
                child: const Text("APPLY"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
