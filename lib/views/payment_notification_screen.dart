import 'package:flutter/material.dart';
import 'notifiation_base_screen.dart';

class PaymentNotificationsScreen extends StatefulWidget {
  const PaymentNotificationsScreen({super.key});

  @override
  State<PaymentNotificationsScreen> createState() => _PaymentNotificationsScreenState();
}

class _PaymentNotificationsScreenState extends State<PaymentNotificationsScreen> {
  bool enablePayment = true;
  bool successAlert = true;
  bool failureAlert = false;
  bool refundAlert = false;

  @override
  Widget build(BuildContext context) {
    return NotificationBaseScreen(
      title: "Payment Notifications",
      content: Column(
        children: [
          CustomSwitchTile(
            title: "Enable Payment Updates",
            value: enablePayment,
            onChanged: (v) => setState(() => enablePayment = v),
          ),
          CustomSwitchTile(
            title: "Payment Success Alerts",
            value: successAlert,
            onChanged: (v) => setState(() => successAlert = v),
          ),
          CustomSwitchTile(
            title: "Payment Failure Alerts",
            value: failureAlert,
            onChanged: (v) => setState(() => failureAlert = v),
          ),
          CustomSwitchTile(
            title: "Refund / Withdrawal Updates",
            value: refundAlert,
            onChanged: (v) => setState(() => refundAlert = v),
          ),
        ],
      ),
    );
  }
}
