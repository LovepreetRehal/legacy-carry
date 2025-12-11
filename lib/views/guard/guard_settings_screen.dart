import 'package:flutter/material.dart';
import 'gradient_bg.dart';
import 'appbar.dart';

class GuardSettingsScreen extends StatelessWidget {
  const GuardSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            buildAppBar("Guard Settings"),

            const SizedBox(height: 20),

            profileCard(),

            const SizedBox(height: 20),

            settingsTile(Icons.notifications, "Notifications", toggle: true),
            settingsTile(Icons.schedule, "Shift Schedule"),
            settingsTile(Icons.call, "Contact Supervisor"),
            settingsTile(Icons.help, "Help/FAQs"),

            const Spacer(),

            logoutBtn(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget profileCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text("Rajesh Kumar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Guard ID: Guard-102"),
          Text("Main Gate - Tower A"),
          Text("Timing: 9AM–6PM"),
        ],
      ),
    );
  }

  Widget settingsTile(IconData icon, String title, {bool toggle = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 26),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          if (toggle)
            Switch(
              value: true,
              onChanged: (v) {},
              activeColor: Colors.green,
            )
          else
            const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget logoutBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}
