import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legacy_carry/views/viewmodels/get_job_viewmodel.dart';
import 'package:legacy_carry/views/providers/user_profile_provider.dart';
import 'job_detail_screen.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetJobViewmodel()..fetchDashboardData(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF6C945), Color(0xFF7BC57B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Consumer<GetJobViewmodel>(
              builder: (context, vm, _) {
                // Filter jobs with status "active"
                final activeJobs = vm.jobData.where((job) {
                  final jobMap = job as Map<String, dynamic>;
                  final status = jobMap['status']?.toString().toLowerCase();
                  return status == 'active';
                }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer<UserProfileProvider>(
                            builder: (context, profileProvider, _) {
                              final greeting = profileProvider.isLoading
                                  ? "Hello 👋"
                                  : "Hello ${profileProvider.userName} 👋";
                              return Text(
                                greeting,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              );
                            },
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoCard(
                              "Active Jobs", activeJobs.length.toString()),
                          _buildInfoCard("Applicants", "09"),
                          _buildInfoCard("Upcoming Shifts", "01"),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // _buildActionButton(
                          //   icon: Icons.post_add,
                          //   label: "Post Job",
                          //   onTap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => const PostAJobOne(),
                          //       ),
                          //     );
                          //   },
                          // ),
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

                      // Recommended Jobs
                      const Text(
                        "Recommended Jobs:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Loading State
                      if (vm.status == GetJobStatus.loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      // Error State
                      else if (vm.status == GetJobStatus.error)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  "Error: ${vm.errorMessage}",
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => vm.fetchDashboardData(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text("Retry"),
                                ),
                              ],
                            ),
                          ),
                        )
                      // Empty State
                      else if (activeJobs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              "No active jobs available",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      // Jobs List
                      else
                        ...activeJobs.take(5).map((job) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildJobCardFromData(
                              context: context,
                              job: job as Map<String, dynamic>,
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Info Card Widget
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Button Widget
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
                BoxShadow(
                    color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.green, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  // Job Card Widget from API Data
  Widget _buildJobCardFromData({
    required BuildContext context,
    required Map<String, dynamic> job,
  }) {
    // Extract data from job
    final String jobTitle =
        job['job_title']?.toString() ?? job['title']?.toString() ?? 'Job Title';
    final String employerName = job['user']?['name']?.toString() ??
        job['employer_name']?.toString() ??
        job['posted_by']?.toString() ??
        'Employer';
    final String date = _formatDate(job['start_date'] ?? job['created_at']);
    final String payAmount = job['pay_amount']?.toString() ?? '0';
    final String payType =
        _formatPayType(job['pay_type']?.toString() ?? 'per_day');
    final String pay = '₹$payAmount / $payType';
    final String location = job['location']?.toString() ??
        job['job_location']?.toString() ??
        'Location not specified';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(jobData: job),
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
            Text(
              jobTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    employerName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                Text(location),
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
                      builder: (context) => JobDetailScreen(jobData: job),
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

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Date not available';

    try {
      String dateStr = dateValue.toString();
      DateTime date = DateTime.parse(dateStr);

      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      String day = date.day.toString();
      String month = months[date.month - 1];
      String year = date.year.toString();

      return '$day $month $year';
    } catch (e) {
      return dateValue.toString();
    }
  }

  String _formatPayType(String payType) {
    switch (payType.toLowerCase()) {
      case 'per_day':
      case 'per day':
        return 'Day';
      case 'per_hour':
      case 'per hour':
        return 'Hour';
      case 'fixed':
        return 'Fixed';
      default:
        return payType;
    }
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
