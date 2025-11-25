import 'package:flutter/material.dart';

class ReviewJobScreen extends StatelessWidget {
  const ReviewJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCC9A24), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Back Arrow
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 10),

              /// Title
              const Center(
                child: Text(
                  "Review Job",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Job Card
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.format_paint, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "Painter Needed",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: "Location: ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: "Delhi, India"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: "Dates: ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: "20 Sept – 25 Sept"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: "Pay: ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: "₹900/day (Advance: ₹200)"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: "Skills: ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: "Painting, Safety gear"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Buttons
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Publish Button
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        "Publish Job",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Save Draft
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        "Save Draft",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
