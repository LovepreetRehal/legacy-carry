import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legacy_carry/views/resident/payments_screen.dart';
import 'package:legacy_carry/views/resident/post_a_job_one.dart';
import '../providers/user_profile_provider.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  static const List<Map<String, String>> recentApplicants = [
    // {"name": "Vikas", "job": "Electrician", "emoji": "🔌"},
    // {"name": "Rahul", "job": "Plumber", "emoji": "🚰"},
    // {"name": "Sunita", "job": "Cook", "emoji": "🍳"},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<UserProfileProvider>();
      if (!profileProvider.isLoading && profileProvider.profileData == null) {
        profileProvider.fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5C041),
              Color(0xFF3CA349),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
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
                          ),
                        );
                      },
                    ),
                    const Icon(Icons.notifications_none),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard("Active Jobs", "0"),
                    _buildStatCard("Applicants", "0"),
                    _buildStatCard("Upcoming Shifts", "0"),
                  ],
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(context, "Post Job", Icons.post_add),
                    _buildActionButton(context, "Find Labor", Icons.search),

                  ],
                ),    // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    _buildActionButton(context, "Messages", Icons.message),
                    _buildActionButton(context, "Payments", Icons.payment),
                  ],
                ),
                const SizedBox(height: 20),

                // Recent Applicants Header
                const Text(
                  "Recent Applicants:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Recent Applicants List
                Expanded(
                  child: recentApplicants.isEmpty
                      ? const Center(
                    child: Text(
                      "No Data Yet!!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  )
                      :ListView.builder(
                    itemCount: recentApplicants.length,
                    itemBuilder: (context, index) {
                      final applicant = recentApplicants[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Text(
                            applicant["emoji"]!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(applicant["name"]!),
                          subtitle: Text(applicant["job"]!),
                          trailing: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("View"),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Action Button Widget
  Widget _buildActionButton(BuildContext context, String label, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton.icon(
          onPressed: () {
            if (label == "Post Job") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostAJobOne(),
                ),
              );
            } else if (label == "Payments") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentsScreen(),
                ),
              );
            } else {
              // Placeholder: You can implement navigation for other buttons as desired
            }
          },
          icon: Icon(icon, size: 18, color: Colors.black87),
          label: Text(
            label,
            style: const TextStyle(color: Colors.black87),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
