import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String? issueType = "Attendance Issue";
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe1b645), Color(0xff7fc36c)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back)),
                const SizedBox(width: 10),
                const Text("Report Issue",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))
              ],
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: const Color(0x80ffffff),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Issue Type"),
                  DropdownButton<String>(
                      value: issueType,
                      isExpanded: true,
                      items: ["Attendance Issue", "Payment Issue", "Other"]
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => issueType = v)),
                  const SizedBox(height: 10),
                  const Text("Description"),
                  TextField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                        hintText: "Describe the issue.....",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  const Text("Upload Photo(Optional)"),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Choose Photo   No file Chosen"),
                        Icon(Icons.camera_alt)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            submitted
                ? Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text("Issue reported successfully",
                      style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _greenButton("Submit Issue", () {
                  setState(() => submitted = true);
                }),
                const SizedBox(width: 15),
                _yellowButton("Cancel", () => Navigator.pop(context)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _greenButton(String txt, VoidCallback fn) => ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade800),
      onPressed: fn,
      child: Text(txt));

  Widget _yellowButton(String txt, VoidCallback fn) => ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffe1b645)),
      onPressed: fn,
      child: Text(txt));
}
