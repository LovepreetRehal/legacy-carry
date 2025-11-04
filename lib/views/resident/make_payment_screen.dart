import 'package:flutter/material.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({Key? key}) : super(key: key);

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  String selectedWorker = "Rahul Sharma";
  String paymentMethod = "UPI";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6C945), Color(0xFF7BC57B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Text("Make Payment",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),

                const Text("Select Worker"),
                DropdownButtonFormField(
                  value: selectedWorker,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ["Rahul Sharma", "Amit Verma", "Sunil Kumar"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedWorker = v!),
                ),
                const SizedBox(height: 12),

                const Text("Amount(₹)"),
                const TextField(
                  decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Enter Amount"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                const Text("Payment Method"),
                DropdownButtonFormField(
                  value: paymentMethod,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ["UPI", "Cash", "Bank Transfer"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => paymentMethod = v!),
                ),
                const SizedBox(height: 12),

                const Text("Notes (Optional)"),
                const TextField(
                  decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Write a Note..."),
                  maxLines: 2,
                ),

                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade900,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    onPressed: () {},
                    child: const Text("Pay Now", style: TextStyle(fontSize: 18)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
