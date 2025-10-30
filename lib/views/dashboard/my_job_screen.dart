import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/my_jobs_viewmodel.dart';
import '../resident/view_job_screen.dart';
import '../resident/edit_job_screen.dart';

class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyJobsViewModel()..fetchAllJobs(),
      child: const _MyJobsContent(),
    );
  }
}

class _MyJobsContent extends StatefulWidget {
  const _MyJobsContent();

  @override
  State<_MyJobsContent> createState() => _MyJobsContentState();
}

class _MyJobsContentState extends State<_MyJobsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this); // active, upcoming, and completed tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyJobsViewModel>(context);

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
                    /* GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),*/
                    const SizedBox(width: 12),
                    const Text(
                      "My Jobs",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      onPressed: () => viewModel.fetchAllJobs(),
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
                    Tab(text: "Active"),
                    Tab(text: "Upcoming"),
                    Tab(text: "Completed"),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tab Views
              Expanded(
                child: viewModel.status == MyJobsStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.status == MyJobsStatus.error
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error: ${viewModel.errorMessage}',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => viewModel.fetchAllJobs(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildJobList(viewModel.activeJobs, "active"),
                              _buildJobList(viewModel.upcomingJobs, "upcoming"),
                              _buildJobList(
                                  viewModel.completedJobs, "completed"),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobList(List<dynamic> jobs, String type) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type} jobs found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        var job = jobs[index];
        return _buildJobCard(job, type);
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, String type) {
    final jobTitle = job['job_title'] ?? 'No Title';
    final location = job['location'] ?? 'Unknown Location';
    final address = job['address'] ?? '';
    final workersRequired = job['workers_required'] ?? 0;
    final payAmount = job['pay_amount'] ?? '0';
    final status = job['status'] ?? type;
    final startDate = job['start_date'] ?? '';
    final shift = job['shift'] ?? '';

    // Format date
    String formattedDate = '';
    if (startDate.isNotEmpty) {
      try {
        final date = DateTime.parse(startDate);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDate = startDate.split('T')[0]; 
      }
    }

    Color statusColor;
    switch (status.toLowerCase()) {
      case "active":
        statusColor = Colors.green;
        break;
      case "draft":
      case "upcoming":
        statusColor = Colors.orange;
        break;
      case "completed":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  jobTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.people, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text('$workersRequired Workers Required'),
            ],
          ),
          if (formattedDate.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(formattedDate),
                if (shift.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Chip(
                    label: Text(
                      shift.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    padding: const EdgeInsets.all(2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.currency_rupee, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                '$payAmount',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              address,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: status == "active"
                    ? Colors.green
                    : status == "completed"
                        ? Colors.blue
                        : Colors.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              onPressed: () {
                if (status == "active") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewJobScreen(jobData: job),
                    ),
                  );
                } else if (type == "upcoming") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditJobScreen(jobData: job),
                    ),
                  );
                }
                // You can add similar logic for completed cases if needed
              },
              child: Text(
                status == "active"
                    ? "View Details"
                    : status == "completed"
                        ? "View Report"
                        : "Edit Job",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
