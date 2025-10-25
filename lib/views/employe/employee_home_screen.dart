import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:legacy_carry/views/resident/post_a_job_one.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/get_job_viewmodel.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetJobViewmodel()..fetchDashboardData(),
      child: Consumer<GetJobViewmodel>(
        builder: (context, vm, _) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF6C945), Color(0xFF7BC57B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: vm.status == GetJobStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.status == GetJobStatus.error
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Error: ${vm.errorMessage}",
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: vm.fetchDashboardData,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Hello Ramesh 👋",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: Colors.black),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Top Cards Row
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoCard(
                              "Active Jobs",
                              vm.jobData.length
                                  .toString()), // Dynamic count
                          _buildInfoCard("Applicants", "09"),
                          _buildInfoCard("Upcoming Shifts", "01"),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.post_add,
                            label: "Post Job",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const PostAJobOne(),
                                ),
                              );
                            },
                          ),
                          _buildActionButton(
                              icon: Icons.search,
                              label: "Find Labor",
                              onTap: () {}),
                          _buildActionButton(
                              icon: Icons.message,
                              label: "Messages",
                              onTap: () {}),
                          _buildActionButton(
                              icon: Icons.payment,
                              label: "Payments",
                              onTap: () {}),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent Applicants
                      const Text(
                        "Recent Applicants:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      // const SizedBox(height: 12),
                      // _buildApplicantCard(
                      //     "Vikas", "Electrician", Icons.electric_bolt),
                      // _buildApplicantCard(
                      //     "Rahul", "Plumber", Icons.plumbing),
                      // _buildApplicantCard(
                      //     "Sunita", "Cook", Icons.restaurant),
                      // const SizedBox(height: 24),
                      //
                      // // ✅ Job List
                      // const Text(
                      //   "Available Jobs:",
                      //   style: TextStyle(
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.black),
                      // ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: vm.jobData.length,
                        itemBuilder: (context, index) {
                          final job = vm.jobData[index] as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.work, color: Colors.blueAccent, size: 28),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job['job_title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          " ${job['pay_type'] ?? ''} | ₹${job['pay_amount'] ?? ''}",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () {
                                    // Navigate to job details screen
                                  },
                                  child: const Text("View"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String count) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54)),
            const SizedBox(height: 4),
            Text(count,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.green, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  Widget _buildApplicantCard(String name, String jobTitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(jobTitle,
                      style: const TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {},
            child: const Text("View"),
          ),
        ],
      ),
    );
  }
}









/*


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legacy_carry/views/viewmodels/get_job_viewmodel.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetJobViewmodel()..fetchDashboardData(),
      child: Consumer<GetJobViewmodel>(
        builder: (context, vm, _) {
          if (vm.status == GetJobStatus.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (vm.status == GetJobStatus.error) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Error: ${vm.errorMessage}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: vm.fetchDashboardData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          } else {
            final jobs = vm.jobData ?? [];

            return Scaffold(
              backgroundColor: Colors.green[100],
              appBar: AppBar(
                title: const Text("Available Jobs"),
                backgroundColor: Colors.green[700],
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: jobs.isEmpty
                      ? const Center(
                    child: Text(
                      "No jobs available",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                      : ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index] as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['job_title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text("📍 ${job['location'] ?? ''}"),
                              const SizedBox(height: 6),
                              Text("Workers Required: ${job['workers_required'] ?? ''}"),
                              const SizedBox(height: 6),
                              Text(
                                "Pay: ₹${job['pay_amount'] ?? ''} (${job['pay_type'] ?? ''})",
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Shift: ${job['shift'] ?? ''}",
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigate to job details or apply screen
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                  ),
                                  child: const Text("View Details"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
*/
