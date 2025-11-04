import 'package:flutter/material.dart';

import 'notifiation_base_screen.dart';


class MessageNotificationsScreen extends StatefulWidget {
  const MessageNotificationsScreen({super.key});

  @override
  State<MessageNotificationsScreen> createState() => _MessageNotificationsScreenState();
}

class _MessageNotificationsScreenState extends State<MessageNotificationsScreen> {
  bool enableMessage = true;
  bool sound = true;
  bool vibration = false;
  bool preview = false;

  @override
  Widget build(BuildContext context) {
    return NotificationBaseScreen(
      title: "Message Notifications",
      content: Column(
        children: [
          CustomSwitchTile(
            title: "Enable Message Notifications",
            value: enableMessage,
            onChanged: (v) => setState(() => enableMessage = v),
          ),
          CustomSwitchTile(
            title: "Sound Alerts",
            value: sound,
            onChanged: (v) => setState(() => sound = v),
          ),
          CustomSwitchTile(
            title: "Vibration Alerts",
            value: vibration,
            onChanged: (v) => setState(() => vibration = v),
          ),
          CustomSwitchTile(
            title: "Show Preview",
            value: preview,
            onChanged: (v) => setState(() => preview = v),
          ),
        ],
      ),
    );
  }
}
