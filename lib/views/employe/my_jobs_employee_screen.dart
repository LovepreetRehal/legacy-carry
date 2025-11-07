import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/employee_jobs_viewmodel.dart';
import '../resident/edit_job_screen.dart';

class FindMyJobsScreen extends StatefulWidget {
  const FindMyJobsScreen({Key? key}) : super(key: key);

  @override
  State<FindMyJobsScreen> createState() => _JobListingScreenState();
}

class _JobListingScreenState extends State<FindMyJobsScreen> {
  String selectedTab = 'Active';

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
                                      child: _buildTabButton('Drafts', vm),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildTabButton('Hourly', vm),
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
                                          final job = filteredJobs[index];
                                          return _buildJobCard(
                                            job: job,
                                            showEditDelete:
                                                selectedTab == 'Drafts',
                                          );
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
    required bool showEditDelete,
  }) {
    // Extract data from job object
    final String title = job['title'] ?? job['job_title'] ?? 'No Title';
    final String postedDate =
        job['posted_date'] ?? job['created_at'] ?? job['postedOn'] ?? 'N/A';
    final int applicants = job['applicants_count'] ?? job['applicants'] ?? 0;
    final String? payRate = job['pay_rate'] ?? job['hourly_rate'];
    final String? shift = job['shift'] ?? job['shift_duration'];
    final String? location = job['location'] ?? job['job_location'];
    final String status = job['status'] ?? 'open';

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
                      color: status.toLowerCase() == 'open' ||
                              status.toLowerCase() == 'active'
                          ? const Color(0xFF4CAF50)
                          : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status.toLowerCase() == 'draft'
                          ? 'Draft'
                          : 'Open/Ongoing',
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
          if (selectedTab == 'Hourly' && payRate != null) ...[
            Text(
              'Pay Rate: $payRate',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            if (shift != null)
              Text(
                'Shift: $shift',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            if (location != null)
              Text(
                'Location: $location',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            Text(
              'Applicants: $applicants',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ] else ...[
            Text(
              'Posted On: $postedDate',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            Text(
              'Applicants: $applicants',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (!showEditDelete) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to applicants screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'View Applicants',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (showEditDelete) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to edit job screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditJobScreen(jobData: job),
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
                    ),
                    child: const Text(
                      'Edit Job',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Show delete confirmation dialog
                    _showDeleteDialog(context, job);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Warning Dialog - Delete Job Confirmation
  void _showDeleteDialog(BuildContext context, Map<String, dynamic> job) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFFF5E6B3),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD32F2F).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.priority_high,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Warning',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                const Text(
                  'This action cannot be undone. Are you sure you want to delete this job?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // onDelete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete Job',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
