import 'dart:convert';
import 'package:flutter/material.dart';
import 'apply_for_job_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> jobData;

  const JobDetailScreen({Key? key, required this.jobData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from jobData with fallbacks
    final String jobTitle = jobData['job_title']?.toString() ??
        jobData['title']?.toString() ??
        'Job Title';
    final String employerName = jobData['user']?['name']?.toString() ??
        jobData['employer_name']?.toString() ??
        jobData['posted_by']?.toString() ??
        'Employer';
    final String description = jobData['description']?.toString() ??
        jobData['safety_instructions']?.toString() ??
        jobData['tasks']?.toString() ??
        '';

    // Handle skills_required as list or string
    List<String> skillsList = [];
    if (jobData['skills_required'] != null) {
      if (jobData['skills_required'] is List) {
        skillsList = List<String>.from(jobData['skills_required']);
      } else if (jobData['skills_required'] is String) {
        try {
          final decoded = jsonDecode(jobData['skills_required']);
          if (decoded is List) {
            skillsList = List<String>.from(decoded);
          }
        } catch (_) {
          skillsList = [jobData['skills_required'].toString()];
        }
      }
    }
    final String tasks = skillsList.isNotEmpty
        ? skillsList.join(', ')
        : description.isNotEmpty
            ? description
            : 'Not specified';

    final bool toolsProvided = jobData['tools_provided'] == true ||
        jobData['tools_provided']?.toString().toLowerCase() == 'yes' ||
        jobData['tools_provided'] == 1;

    final String startDate =
        _formatDate(jobData['start_date'] ?? jobData['created_at']);
    final String? endDate =
        jobData['end_date'] != null ? _formatDate(jobData['end_date']) : null;

    final String shift = jobData['shift']?.toString() ??
        jobData['time']?.toString() ??
        'Not specified';

    final String pay = jobData['pay_amount'] != null
        ? '₹${jobData['pay_amount']} / ${_formatPayType(jobData['pay_type']?.toString() ?? 'per_day')}'
        : 'Not specified';

    // Helper function to safely parse int
    int parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    final int workersRequired = parseInt(jobData['workers_required'], 1);

    final String location = jobData['location']?.toString() ??
        jobData['job_location']?.toString() ??
        'Location not specified';

    final String address = jobData['address']?.toString() ?? '';

    // Handle documents_required as list or string
    List<String> documentsList = [];
    if (jobData['documents_required'] != null) {
      if (jobData['documents_required'] is List) {
        documentsList = List<String>.from(jobData['documents_required']);
      } else if (jobData['documents_required'] is String) {
        try {
          final decoded = jsonDecode(jobData['documents_required']);
          if (decoded is List) {
            documentsList = List<String>.from(decoded);
          }
        } catch (_) {
          documentsList = [jobData['documents_required'].toString()];
        }
      }
    }

    final String safetyInstructions =
        jobData['safety_instructions']?.toString() ?? '';

    final bool advancePayment = jobData['advance_payment'] == true ||
        jobData['advance_payment']?.toString().toLowerCase() == 'yes' ||
        jobData['advance_payment'] == 1;
    final int advanceAmount = parseInt(jobData['advance_amount'], 0);

    // Helper function to safely parse double
    double parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    final double rating = parseDouble(jobData['rating'], 5.0);
    final int reviews =
        parseInt(jobData['reviews'] ?? jobData['review_count'], 0);
    final String employerPhone = jobData['user']?['phone']?.toString() ??
        jobData['employer_phone']?.toString() ??
        '';

    // Calculate duration if both dates are available
    String duration = 'Not specified';
    if (jobData['start_date'] != null && jobData['end_date'] != null) {
      try {
        final start = DateTime.parse(jobData['start_date'].toString());
        final end = DateTime.parse(jobData['end_date'].toString());
        final diff = end.difference(start).inDays;
        duration =
            diff > 0 ? '$diff ${diff == 1 ? 'Day' : 'Days'}' : 'Same day';
      } catch (_) {
        duration = jobData['expected_duration']?.toString() ?? 'Not specified';
      }
    } else if (jobData['expected_duration'] != null) {
      duration = jobData['expected_duration'].toString();
    }

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
          child: Column(
            children: [
              // Header with back button and title
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        jobTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Content Card
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employer Section with Contact Button
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.green,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Employer: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        employerName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (employerPhone.isNotEmpty) {
                                  // TODO: Implement phone call functionality
                                }
                              },
                              icon: const Icon(Icons.phone, size: 16),
                              label: const Text(
                                'CONTACT',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Rating Section
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFF6C945),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            ...List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color: index < rating.floor()
                                    ? const Color(0xFFF6C945)
                                    : Colors.grey[300],
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '($reviews reviews)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: Colors.grey, thickness: 1),
                        const SizedBox(height: 20),

                        // Job Details
                        if (skillsList.isNotEmpty || description.isNotEmpty)
                          _buildJobDetailRow(
                            icon: Icons.assignment,
                            label: 'Tasks/Skills Required: ',
                            value: tasks,
                          ),
                        if (skillsList.isNotEmpty || description.isNotEmpty)
                          const SizedBox(height: 12),
                        _buildJobDetailRow(
                          icon: Icons.build,
                          label: 'Tools Provided: ',
                          value: toolsProvided ? 'Yes' : 'No',
                        ),
                        const SizedBox(height: 12),
                        _buildJobDetailRow(
                          icon: Icons.people,
                          label: 'Workers Required: ',
                          value: workersRequired.toString(),
                        ),
                        const SizedBox(height: 12),
                        _buildJobDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Start Date: ',
                          value: startDate,
                        ),
                        if (endDate != null) ...[
                          const SizedBox(height: 12),
                          _buildJobDetailRow(
                            icon: Icons.event,
                            label: 'End Date: ',
                            value: endDate,
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildJobDetailRow(
                          icon: Icons.access_time,
                          label: 'Shift: ',
                          value: shift,
                        ),
                        const SizedBox(height: 12),
                        _buildJobDetailRow(
                          icon: Icons.currency_rupee,
                          label: 'Pay: ',
                          value: pay,
                        ),
                        if (advancePayment && advanceAmount > 0) ...[
                          const SizedBox(height: 12),
                          _buildJobDetailRow(
                            icon: Icons.account_balance_wallet,
                            label: 'Advance Payment: ',
                            value: '₹$advanceAmount',
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildJobDetailRow(
                          icon: Icons.hourglass_empty,
                          label: 'Duration: ',
                          value: duration,
                        ),
                        const SizedBox(height: 12),
                        _buildJobDetailRow(
                          icon: Icons.location_on,
                          label: 'Location: ',
                          value: location,
                        ),
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildJobDetailRow(
                            icon: Icons.home,
                            label: 'Address: ',
                            value: address,
                          ),
                        ],
                        if (safetyInstructions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildJobDetailRow(
                            icon: Icons.security,
                            label: 'Safety Instructions: ',
                            value: safetyInstructions,
                          ),
                        ],
                        if (documentsList.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.description,
                                size: 20,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Required Documents:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...documentsList.map((doc) => Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, top: 2),
                                          child: Text(
                                            '• $doc',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 20),
                        const Divider(color: Colors.grey, thickness: 1),
                        const SizedBox(height: 20),

                        // Map Section
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                // Placeholder for map - you can replace this with Google Maps widget
                                Container(
                                  color: Colors.grey[100],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.map,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          location,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Map pin indicator
                                const Center(
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Get job ID from jobData
                                  final jobId = jobData['id']?.toString() ??
                                      jobData['job_id']?.toString() ??
                                      '';
                                  if (jobId.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ApplyForJobScreen(jobId: jobId),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Job ID not found'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[800],
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Apply',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Navigate to message screen
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6C945),
                                  foregroundColor: Colors.black87,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Flexible(
                                      child: Text(
                                        'Message Employer',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Safety Note
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.yellow[200]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Safety Note:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      documentsList.isNotEmpty
                                          ? 'Always verify employer details before starting work. Required Documents: ${documentsList.join(', ')}'
                                          : 'Always verify employer details before starting work. Required Documents: ID Proof, Address Proof',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildJobDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.black54,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              children: [
                if (label.isNotEmpty)
                  TextSpan(
                    text: label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '18 Sep 2025';

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
        return 'per day';
      case 'per_hour':
      case 'per hour':
        return 'per hour';
      case 'fixed':
        return 'fixed';
      default:
        return payType;
    }
  }
}
