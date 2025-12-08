import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/employee_jobs_viewmodel.dart';
import 'job_detail_screen.dart';

class FindMyJobsScreen extends StatefulWidget {
  const FindMyJobsScreen({Key? key}) : super(key: key);

  @override
  State<FindMyJobsScreen> createState() => _JobListingScreenState();
}

class _JobListingScreenState extends State<FindMyJobsScreen> {
  String selectedTab = 'Active'; // Active, Upcoming, or Completed

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmployeeJobsViewModel()..fetchAllEmployeeJobs(),
      child: Consumer<EmployeeJobsViewModel>(
        builder: (context, vm, _) {
          // Get jobs for the selected tab
          List<dynamic> filteredJobs = vm.getJobsForTab(selectedTab);

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
                child: vm.status == EmployeeJobsStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.status == EmployeeJobsStatus.error
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
                                  onPressed: () {
                                    vm.fetchAllEmployeeJobs();
                                  },
                                  child: const Text("Retry"),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // AppBar
                              Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back,
                                          color: Colors.black),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    const Expanded(
                                      child: Text(
                                        'My Jobs/Find Jobs',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 48),
                                  ],
                                ),
                              ),

                              // Search Bar
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search by name or skill...',
                                    prefixIcon: const Icon(Icons.search,
                                        color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),

                              // Tab Bar
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildTabButton('Active', vm),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildTabButton('Upcoming', vm),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildTabButton('Completed', vm),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Job List
                              Expanded(
                                child: filteredJobs.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No jobs found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        itemCount: filteredJobs.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final Map<String, dynamic> job =
                                              Map<String, dynamic>.from(
                                                  filteredJobs[index] as Map);
                                          return _buildJobCard(
                                              job: job,
                                              selectedTab: selectedTab);
                                        },
                                      ),
                              ),
                            ],
                          ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButton(String label, EmployeeJobsViewModel vm) {
    final isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label;
        });
        // Fetch jobs for the selected tab
        vm.fetchJobsByTab(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5E20) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required Map<String, dynamic> job,
    required String selectedTab,
  }) {
    // Extract nested job post data
    final Map<String, dynamic>? jobPost =
        job['job_post'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(job['job_post'])
            : null;

    final String title =
        jobPost?['job_title'] ?? job['job_title'] ?? job['title'] ?? 'No Title';
    final String startDatetime =
        job['start_datetime'] ?? jobPost?['start_date'] ?? 'N/A';
    final String? expectedCost = job['expected_cost']?.toString();
    final String applicationStatus =
        job['status'] ?? job['application_status'] ?? 'applied';
    final int shortlisted = job['shortlisted'] ?? 0;
    final String? messageToEmployer = job['message_to_employer'];
    final int? jobId = job['job_id'] ?? jobPost?['id'];

    final String? location = jobPost?['location'] ?? jobPost?['address'];
    final String? shift = jobPost?['shift'];
    final String? payAmount = jobPost?['pay_amount']?.toString();
    final String? payType = jobPost?['pay_type'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.format_paint,
                  color: Color(0xFF1B5E20),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: applicationStatus.toLowerCase() == 'applied' ||
                              applicationStatus.toLowerCase() == 'shortlisted'
                          ? const Color(0xFF4CAF50)
                          : applicationStatus.toLowerCase() == 'completed'
                              ? Colors.blue
                              : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      applicationStatus.toLowerCase() == 'shortlisted'
                          ? 'Shortlisted'
                          : applicationStatus.toLowerCase() == 'completed'
                              ? 'Completed'
                              : selectedTab == 'Active'
                                  ? 'Active'
                                  : 'Applied',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (startDatetime != 'N/A')
            Text(
              'Start Date: $startDatetime',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          if (expectedCost != null)
            Text(
              'Expected Cost: $expectedCost',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          if (location != null && location.isNotEmpty)
            Text(
              'Location: $location',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          if (shift != null && shift.isNotEmpty)
            Text(
              'Shift: $shift',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          if (payAmount != null && payAmount.isNotEmpty)
            Text(
              'Pay: $payAmount${payType != null ? ' ($payType)' : ''}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          if (shortlisted == 1)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Shortlisted',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (messageToEmployer != null && messageToEmployer.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Message: $messageToEmployer',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (jobId != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final Map<String, dynamic> jobData = {};
                if (jobPost != null) {
                  jobData.addAll(jobPost);
                }
                jobData.addAll(job);
                jobData['job_id'] = jobId;
                jobData.putIfAbsent('job_title', () => title);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JobDetailScreen(
                      jobData: jobData,
                      showActions: false,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
