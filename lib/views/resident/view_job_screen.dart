import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:legacy_carry/views/resident/applicants_screen.dart';
import '../services/auth_service.dart';
import 'edit_job_screen.dart';

class ViewJobScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const ViewJobScreen({Key? key, required this.jobData}) : super(key: key);

  @override
  State<ViewJobScreen> createState() => _ViewJobScreenState();
}

class _ViewJobScreenState extends State<ViewJobScreen> {
  final AuthService _authService = AuthService();
  late Map<String, dynamic> _jobData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _jobData = Map<String, dynamic>.from(widget.jobData);
    _fetchJobDetails();
  }

  Future<void> _fetchJobDetails() async {
    final jobId = _extractJobId(_jobData);
    if (jobId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Job ID not available';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.getJobDetails(jobId);
      if (!mounted) return;
      setState(() {
        _jobData = {..._jobData, ...result};
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
        _isLoading = false;
      });
    }
  }

  String? _extractJobId(Map<String, dynamic> data) {
    final dynamic idValue = data['id'] ?? data['job_id'];
    if (idValue == null) return null;
    final id = idValue.toString();
    return id.isEmpty ? null : id;
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Not specified';

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
      // If parsing fails, return the original string or a default value
      return dateValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD4A745), Color(0xFF7BC57B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            ),
          ),
        ),
      );
    }

    // Show error message
    if (_errorMessage != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD4A745), Color(0xFF7BC57B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'View Job',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Color(0xFFD32F2F),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              _fetchJobDetails();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // Extract data from jobData
    final String title = _jobData['title']?.toString() ??
        _jobData['job_title']?.toString() ??
        'Warehouse Helper';
    final String status = _jobData['status']?.toString() ?? 'Open / Ongoing';
    final String payRate = _jobData['pay_rate']?.toString() ??
        _jobData['hourly_rate']?.toString() ??
        (_jobData['pay_amount'] != null
            ? '₹${_jobData['pay_amount']} / ${_jobData['pay_type']?.toString() ?? 'per_day'}'
            : '₹150 per hour');
    final String shift = _jobData['shift']?.toString() ??
        _jobData['shift_duration']?.toString() ??
        _jobData['time']?.toString() ??
        '4 hrs (09:00Am-01:00pm)';
    final String location = _jobData['location']?.toString() ??
        _jobData['job_location']?.toString() ??
        'City Center, Delhi';
    final String postedDate =
        _formatDate(_jobData['posted_date'] ?? _jobData['created_at'] ?? null);
    final int applicants =
        int.tryParse(_jobData['applicants_count']?.toString() ?? '0') ??
            int.tryParse(_jobData['applicants']?.toString() ?? '0') ??
            5;
    final String description = _jobData['description']?.toString() ??
        _jobData['job_description']?.toString() ??
        'Looking for a reliable warehouse helper to assist with loading/Unloading goods and organizing inventory. Physical work required.';

    // Handle skills_required as list or string
    List<String> skills = [];
    if (_jobData['skills_required'] != null) {
      if (_jobData['skills_required'] is List) {
        skills = (_jobData['skills_required'] as List)
            .map((e) => e.toString())
            .toList();
      } else if (_jobData['skills_required'] is String) {
        try {
          final decoded = jsonDecode(_jobData['skills_required']);
          if (decoded is List) {
            skills = List<String>.from(decoded);
          }
        } catch (_) {
          skills = [_jobData['skills_required'].toString()];
        }
      }
    } else if (_jobData['skills'] is List) {
      skills = (_jobData['skills'] as List).map((e) => e.toString()).toList();
    }

    if (skills.isEmpty) {
      skills = ['Basic Lifting', 'Time Management', 'Team Work'];
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD4A745), Color(0xFF7BC57B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'View Job',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content Card
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5DC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Job Details
                        _buildDetailRow('Pay Rate : ', payRate),
                        _buildDetailRow('Shift : ', shift),
                        _buildDetailRow('Location : ', location),
                        _buildDetailRow('Posted on : ', postedDate),
                        _buildDetailRow('Applicants : ', applicants.toString()),

                        const SizedBox(height: 20),
                        const Divider(color: Colors.black26),
                        const SizedBox(height: 16),

                        // Job Description
                        const Text(
                          'Job Description:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: Colors.black26),
                        const SizedBox(height: 16),

                        // Skills Required
                        const Text(
                          'Skills Required:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...skills.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${entry.key + 1}. ${entry.value}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Get job ID from jobData
                                  final jobId = _extractJobId(_jobData);
                                  if (jobId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Job ID not found'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  // Navigate to view applicants
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ApplicantsScreen(jobId: jobId),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'View Applicants',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Navigate to edit job
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditJobScreen(
                                        jobData: _jobData,
                                      ),
                                    ),
                                  );

                                  // If job was updated successfully, refresh the job details
                                  if (result == true && mounted) {
                                    _fetchJobDetails();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Edit Job',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Show delete dialog
                                _showDeleteDialog(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[400],
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteJob() async {
    try {
      // Get job ID from jobData
      final jobId = _extractJobId(_jobData);
      if (jobId == null) {
        _showErrorDialog('Job ID not found');
        return;
      }

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
        ),
      );

      // Call delete API using AuthService
      await _authService.deleteJob(jobId);

      // Close loading indicator
      if (!mounted) return;
      Navigator.pop(context);

      // Success - show success message and navigate back
      _showSuccessDialog('Job deleted successfully');
    } catch (e) {
      // Close loading if still showing
      if (mounted) {
        Navigator.pop(context);
      }
      print("Error deleting job: $e");
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFF5E6B3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context,
                    true); // Go back to previous screen with success flag
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFF5E6B3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFD32F2F),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFFF5E6B3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Warning',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone. Are you sure you want to delete this job?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _deleteJob(); // Call delete API
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Delete Job'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Placeholder for Edit Job Screen
class EditJobScreenPlaceholder extends StatelessWidget {
  const EditJobScreenPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Job')),
      body: const Center(child: Text('Edit Job Screen')),
    );
  }
}

// Demo Main
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ViewJobScreen(
        jobData: {
          'title': 'Warehouse Helper',
          'status': 'Open / Ongoing',
          'pay_rate': '₹150 per hour',
          'shift': '4 hrs (09:00Am-01:00pm)',
          'location': 'City Center, Delhi',
          'posted_date': '16 Sept 2025',
          'applicants': 5,
          'description':
              'Looking for a reliable warehouse helper to assist with loading/Unloading goods and organizing inventory. Physical work required.',
          'skills': ['Basic Lifting', 'Time Management', 'Team Work'],
        },
      ),
    );
  }
}
