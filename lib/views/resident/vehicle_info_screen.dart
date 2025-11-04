import 'package:flutter/material.dart';
import 'scan_vehicle_qr_screen.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  String addVehicle = "Yes";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFF6C945), Color(0xFF7BC57B)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, size: 28)),
                    const SizedBox(width: 12),
                    const Text("Vehicle Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF3E6A7), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextField("Vehicle Number", "Enter Vehicle Number"),
                      buildDropdown("Vehicle Type", ["Car", "Bike", "Auto"], "Car"),

                      const Text("Add Vehicle QR"),
                      Row(
                        children: [
                          Radio(value: "Yes", groupValue: addVehicle, onChanged: (v) => setState(() => addVehicle = v.toString())),
                          const Text("Yes"),
                          Radio(value: "No", groupValue: addVehicle, onChanged: (v) => setState(() => addVehicle = v.toString())),
                          const Text("No"),
                        ],
                      ),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanVehicleQRScreen()));
                        },
                        icon: const Icon(Icons.chevron_right),
                        label: const Text("NEXT"),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, String hint) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 6),
      Text(label),
      TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    ],
  );

  Widget buildDropdown(String label, List<String> items, String selected) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 6),
      Text(label),
      DropdownButtonFormField(
        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
        value: selected,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) {},
      ),
    ],
  );
}
