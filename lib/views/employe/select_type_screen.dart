import 'package:flutter/material.dart';
import 'package:legacy_carry/views/complete_profile_screen.dart';

import '../employe/employee_register_screen.dart';
import '../resident/post_a_job_one.dart';

class SelectTypeScreen extends StatefulWidget {
  const SelectTypeScreen({super.key});

  @override
  State<SelectTypeScreen> createState() => _RegisterAsScreenState();
}

class _RegisterAsScreenState extends State<SelectTypeScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDFB139), // top yellow
              Color(0xFFB9AE3C), // middle
              Color(0xFF3CA349), // bottom green
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                "Register As",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),

              // Options
              buildOption(
                title: "EMPLOYEE",
                subtitle: "Sign Up as a Worker like Plumber, Electrician, Carpenter etc.",
                icon: Icons.work_outline,
                value: "employee",
              ),
              const SizedBox(height: 15),

              buildOption(
                title: "EMPLOYER",
                subtitle: "",
                icon: Icons.group_outlined,
                value: "employer",
              ),
              const SizedBox(height: 15),

              buildOption(
                title: "SECURITY GUARD",
                subtitle: "",
                icon: Icons.shield_outlined,
                value: "guard",
              ),

              const Spacer(),

              // Proceed button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: selectedRole == null
                        ? null
                        : () {
                      print("Selected role: $selectedRole");

                      if (selectedRole == "employee") {
                        // ✅ Go to Employee registration
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmployeeRegisterScreen(),
                          ),
                        );
                      } else if (selectedRole == "employer") {
                        // ✅ Go to Employee registration
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CompleteProfileScreen(),
                          )
                        );
                      }
                      else {
                        // 🚧 Show Coming Soon dialog or snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Security Guard registration coming soon!",
                            ),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text(
                      "PROCEED",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  // Custom option card
  Widget buildOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final bool isSelected = selectedRole == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.white,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green[800] : Colors.black,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ]
                ],
              ),
            ),
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.green[800] : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
