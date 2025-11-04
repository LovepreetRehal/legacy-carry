import 'package:flutter/material.dart';

class JobTimelineScreen extends StatelessWidget {
  const JobTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe1b645), Color(0xff7fc36c)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back)),
                const SizedBox(width: 10),
                const Text(
                  "Job Timeline",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 25),

            // Timeline Items
            _timelineTile("Check In", "08:05 AM", "28.6139, 77.2090"),
            _timelineTile("Break", "01:15 PM", "30 mins"),
            _timelineTile("Check-Out", "06:10 PM", "28.6142, 77.2101"),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _greenButton("Add Note", () {
                  Navigator.pushNamed(context, "/shareNote");
                }),
                const SizedBox(width: 15),
                _yellowButton("Report Issue", () {
                  Navigator.pushNamed(context, "/reportIssue");
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _timelineTile(String title, String time, String location) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.access_time, size: 20),
              const SizedBox(width: 6),
              Text(time),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 6),
              Text(location),
            ],
          ),
        ],
      ),
    );
  }

  Widget _greenButton(String txt, VoidCallback onTap) => ElevatedButton(
    style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10)),
    onPressed: onTap,
    child: Text(txt),
  );

  Widget _yellowButton(String txt, VoidCallback onTap) => ElevatedButton(
    style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffe1b645),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10)),
    onPressed: onTap,
    child: Text(txt),
  );
}
