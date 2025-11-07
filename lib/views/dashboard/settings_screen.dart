import 'package:flutter/material.dart';
import 'package:legacy_carry/views/change_password_screen.dart';
import 'package:legacy_carry/views/contact_support_screen.dart';
import 'package:legacy_carry/views/dashboard/edit_profie.dart';
import 'package:legacy_carry/views/faq_screen.dart';
import 'package:legacy_carry/views/job_alerts_screen.dart';
import 'package:legacy_carry/views/manage_documents_screen.dart';
import 'package:legacy_carry/views/report_problem_screen.dart';
import 'package:legacy_carry/views/splace_screen.dart';
import 'package:legacy_carry/views/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDFB139), Color(0xFFB9AE3C), Color(0xFF3CA349)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  children: [
                    // IconButton(
                    //   onPressed: () => Navigator.pop(context),
                    //   icon: const Icon(Icons.arrow_back, color: Colors.white),
                    // ),
                    const Expanded(
                      child: Text(
                        'Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // to balance the back icon space
                  ],
                ),

                const SizedBox(height: 16),

                // Profile & Account Section
                const SectionTitle(title: 'Profile & Account'),
                _buildTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ));
                  },
                ),
                _buildTile(
                  icon: Icons.language,
                  title: 'Language & Region',
                  trailing: const Text(
                    'English(EN)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {},
                ),

                const SizedBox(height: 16),

                // Notifications Section
                const SectionTitle(title: 'Notifications'),
                _buildSwitchTile('Job Alerts', true, (val) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JobAlertsScreen(),
                      ));
                }),
                _buildSwitchTile('Message Notifications', true, (val) {}),
                _buildSwitchTile('Payment Updates', false, (val) {}),

                const SizedBox(height: 16),

                // Payout Method Section
                // const SectionTitle(title: 'Payout Method'),
                //_buildPayoutCard(),

                const SizedBox(height: 16),

                // Privacy & Security Section
                const SectionTitle(title: 'Privacy & Security'),
                _buildTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ));
                  },
                ),
                _buildTile(
                  icon: Icons.file_copy_outlined,
                  title: 'Manage Documents',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageDocumentsScreen(),
                        ));
                  },
                ),
                _buildTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    // Capture the SettingsScreen context
                    final settingsContext = context;
                    _showLogoutDialog(settingsContext);
                  },
                ),

                const SizedBox(height: 16),

                // Help & Support Section
                const SectionTitle(title: 'Help & Support'),
                _buildTile(
                  icon: Icons.help_outline,
                  title: 'FAQ\'s',
                  trailing: const Icon(Icons.keyboard_arrow_down),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQScreen(),
                        ));
                  },
                ),
                _buildTile(
                  icon: Icons.phone_outlined,
                  title: 'Contact Support',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactSupportScreen(),
                        ));
                  },
                ),
                _buildTile(
                  icon: Icons.report_problem_outlined,
                  title: 'Report a Problem',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportProblemScreen(),
                        ));
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[800]),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildPayoutCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Linked Method',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.account_balance, color: Colors.green),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Bank A/C — HDFC ****1234\nSupported: UPI ID, Bank Account, Wallet',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Change', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Add New', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Linked Bank: Axis Bank ****5678',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('+UPI +Bank Account',
                style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

void _showLogoutDialog(BuildContext settingsContext) {
  showDialog(
    context: settingsContext,
    barrierDismissible: false, // prevent dismissing by tapping outside
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFFD4B04A), // dialog background
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to log out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {
                      // Close the logout confirmation dialog first
                      Navigator.of(dialogContext).pop();

                      // Wait a frame to ensure dialog is closed
                      await Future.delayed(const Duration(milliseconds: 50));

                      // Show loading indicator using SettingsScreen context
                      showDialog(
                        context: settingsContext,
                        barrierDismissible: false,
                        builder: (BuildContext loadingDialogContext) {
                          return const Dialog(
                            backgroundColor: Colors.transparent,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      );

                      try {
                        // Call logout API
                        final authService = AuthService();
                        await authService.logout();
                        print("✅ Logout API called successfully");
                      } catch (e) {
                        print("Error during logout API call: $e");
                        // Continue with local logout even if API fails
                      }

                      // Clear all SharedPreferences data (in case API didn't clear it)
                      try {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();
                        print("✅ SharedPreferences cleared");
                      } catch (e) {
                        print("Error clearing SharedPreferences: $e");
                      }

                      // Close loading dialog using SettingsScreen context
                      if (settingsContext.mounted) {
                        try {
                          Navigator.of(settingsContext).pop();
                          print("✅ Loading dialog closed");
                        } catch (e) {
                          print("Error closing loading dialog: $e");
                        }
                      }

                      // Small delay to ensure dialog is fully closed
                      await Future.delayed(const Duration(milliseconds: 100));

                      // Navigate to WelcomeScreen and remove all previous routes
                      if (settingsContext.mounted) {
                        print("✅ Navigating to splash screen");
                        Navigator.of(settingsContext).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const SplaceScreen()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    child: const Text(
                      'Yes , Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext)
                          .pop(); // Just close the dialog
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black87),
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

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
