import 'package:flutter/material.dart';

void main() {
  runApp(const JobApp());
}

class JobApp extends StatelessWidget {
  const JobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyJobsScreen(),
    );
  }
}

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

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
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "My Jobs",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab( child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text("Active"),
                        )),
                    Tab(text: "Upcoming"),
                    Tab(text: "Completed"),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildJobList("Active"),
                    _buildJobList("Upcoming"),
                    _buildJobList("Completed"),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobList(String type) {
    List<Map<String, String>> jobs = [];

    if (type == "Active") {
      jobs = [
        {
          "title": "Carpentry at Green Meadows",
          "company": "Rajiv Kumar",
          "date": "18 Sep 2025",
          "time": "09:00 AM",
          "status": "Active"
        },
      ];
    } else if (type == "Upcoming") {
      jobs = [
        {
          "title": "Helper at Warehouse",
          "company": "Akash Traders",
          "date": "19 Sep 2025",
          "time": "08:00 AM",
          "status": "Upcoming"
        },
      ];
    } else if (type == "Completed") {
      jobs = [
        {
          "title": "Electrician Job",
          "company": "Sunil Electricals",
          "date": "15 Sep 2025",
          "time": "10:00 AM",
          "status": "Completed"
        },
      ];
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        var job = jobs[index];
        return _buildJobCard(
          title: job["title"]!,
          company: job["company"]!,
          date: job["date"]!,
          time: job["time"]!,
          status: job["status"]!,
        );
      },
    );
  }

  Widget _buildJobCard({
    required String title,
    required String company,
    required String date,
    required String time,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case "Active":
        statusColor = Colors.green;
        break;
      case "Upcoming":
        statusColor = Colors.orange;
        break;
      case "Completed":
        statusColor = Colors.black87;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: Colors.redAccent),
              const SizedBox(width: 6),
              Text(date),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(time),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: status == "Active"
                    ? Colors.grey.shade300
                    : Colors.white,
                foregroundColor: Colors.black,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              onPressed: () {},
              child: Text(
                status == "Active" ? "End Shift" : "View Details",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
