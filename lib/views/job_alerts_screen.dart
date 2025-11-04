import 'package:flutter/material.dart';
import 'notifiation_base_screen.dart';


class JobAlertsScreen extends StatefulWidget {
  const JobAlertsScreen({super.key});

  @override
  State<JobAlertsScreen> createState() => _JobAlertsScreenState();
}

class _JobAlertsScreenState extends State<JobAlertsScreen> {
  bool enableJobAlerts = true;
  bool dailyDigest = true;
  bool instantNotifications = false;

  @override
  Widget build(BuildContext context) {
    return NotificationBaseScreen(
      title: "Job Alerts",

      content: Column(
        children: [
          CustomSwitchTile(
            title: "Enable Job Alerts",
            value: enableJobAlerts,
            onChanged: (v) => setState(() => enableJobAlerts = v),
          ),
          CustomSwitchTile(
            title: "Daily Digest",
            value: dailyDigest,
            onChanged: (v) => setState(() => dailyDigest = v),
          ),
          CustomSwitchTile(
            title: "Instant Notifications",
            value: instantNotifications,
            onChanged: (v) => setState(() => instantNotifications = v),
          ),
        ],
      ),
    );
  }
}
