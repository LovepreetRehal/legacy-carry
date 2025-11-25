import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../employe/job_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Hello, Rajiv Kumar!",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Text(
                          "Welcome Back 👋",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.settings, color: Colors.black),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard("Today", "₹850"),
                    _buildStatCard("This Week", "₹4,200"),
                    _buildStatCard("Balance", "₹12,540"),
                  ],
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text("Find Jobs"),
                        onPressed: () {

                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.work, color: Colors.white),
                        label: const Text("My Jobs"),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.account_balance_wallet,
                            color: Colors.white),
                        label: const Text("Earnings"),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.message, color: Colors.white),
                        label: const Text("Messages"),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Availability Switch
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Availability",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Switch(value: true, onChanged: (val) {}),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Recommended Jobs
                const Text(
                  "Recommend Jobs:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildJobCard(
                  context: context,
                  title: "Carpentry at Green Meadows",
                  company: "Rajiv Kumar",
                  date: "18 Sep 2025",
                  pay: "₹500 / Day",
                  distance: "2.3 Km",
                ),
                const SizedBox(height: 12),
                _buildJobCard(
                  context: context,
                  title: "Painter Job",
                  company: "Raj Interiors",
                  date: "17 Sep 2025",
                  pay: "₹700 / Day",
                  distance: "3 Km",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
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
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
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
            const SizedBox(height: 6),
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
