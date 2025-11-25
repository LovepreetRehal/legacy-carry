import 'package:flutter/material.dart';

class JobPublishedScreen extends StatelessWidget {
  const JobPublishedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Publish Job",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDFB139),
              Color(0xFFB9AE3C),
              Color(0xFF3CA349),
            ],
          ),
        ),

        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 120),

              // ✔ Success Icon
              Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 70, color: Colors.green),
              ),

              const SizedBox(height: 25),

              const Text(
                "Your Job has been",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const Text(
                "Published Successfully.",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 30),

              // Job Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.brush, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          "Painter Needed",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const Divider(height: 20),

                    const Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: "Location: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "Delhi, India"),
                      ]),
                    ),
                    const SizedBox(height: 5),

                    const Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: "Dates: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "20 Sept – 25 Sept"),
                      ]),
                    ),
                    const SizedBox(height: 5),

                    const Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: "Pay: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "₹800/day (Advance: ₹200)"),
                      ]),
                    ),
                    const SizedBox(height: 5),

                    const Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: "Skills: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "Painting, Safety gear"),
                      ]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // View Applicants
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text("View Applicants"),
                  ),

                  const SizedBox(width: 15),

                  // Post Another Job
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      elevation: 3,
                    ),
                    child: const Text("Post Another Job"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
