import 'package:flutter/material.dart';




class FindMyJobsScreen extends StatefulWidget {
  const FindMyJobsScreen({Key? key}) : super(key: key);

  @override
  State<FindMyJobsScreen> createState() => _JobListingScreenState();
}

class _JobListingScreenState extends State<FindMyJobsScreen> {
  String selectedTab = 'Active';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4A745),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'My Jobs/Find Jobs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD4A745),
              Color(0xFF8FB84E),
            ],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or skill...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Active'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton('Drafts'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton('Hourly'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Job List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildJobCard(
                    title: 'Painter Needed',
                    postedDate: 'Posted On: 16 Sept 2025',
                    applicants: 12,
                    showEditDelete: selectedTab == 'Drafts',
                    payRate: selectedTab == 'Hourly' ? '₹150 / hour' : null,
                    shift: selectedTab == 'Hourly' ? '4 hrs' : null,
                    location: selectedTab == 'Hourly' ? 'City Center' : null,
                    applicantCount: selectedTab == 'Hourly' ? 5 : null,
                  ),
                  const SizedBox(height: 12),
                  _buildJobCard(
                    title: 'Painter Needed',
                    postedDate: 'Posted On: 16 Sept 2025',
                    applicants: 12,
                    showEditDelete: selectedTab == 'Drafts',
                    payRate: selectedTab == 'Hourly' ? '₹150 / hour' : null,
                    shift: selectedTab == 'Hourly' ? '4 hrs' : null,
                    location: selectedTab == 'Hourly' ? 'City Center' : null,
                    applicantCount: selectedTab == 'Hourly' ? 5 : null,
                  ),
                  const SizedBox(height: 12),
                  _buildJobCard(
                    title: 'Painter Needed',
                    postedDate: 'Posted On: 16 Sept 2025',
                    applicants: 12,
                    showEditDelete: selectedTab == 'Drafts',
                    payRate: selectedTab == 'Hourly' ? '₹150 / hour' : null,
                    shift: selectedTab == 'Hourly' ? '4 hrs' : null,
                    location: selectedTab == 'Hourly' ? 'City Center' : null,
                    applicantCount: selectedTab == 'Hourly' ? 5 : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label;
        });
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
    required String title,
    required String postedDate,
    required int applicants,
    required bool showEditDelete,
    String? payRate,
    String? shift,
    String? location,
    int? applicantCount,
  }) {
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
                  children: const [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Color(0xFF4CAF50),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Open/Ongoing',
                      style: TextStyle(
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
          if (payRate != null) ...[
            Text(
              'Pay Rate: $payRate',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            Text(
              'Shift: $shift',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            Text(
              'Location: $location',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            Text(
              'Applicants: $applicantCount',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ] else ...[
            Text(
              postedDate,
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
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
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
              if (showEditDelete) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
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
              ],
              if (showEditDelete || selectedTab == 'Active') ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
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
            ],
          ),
        ],
      ),
    );
  }
}