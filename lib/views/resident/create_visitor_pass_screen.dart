import 'package:flutter/material.dart';
import 'vehicle_info_screen.dart';

class CreateVisitorPassScreen extends StatefulWidget {
  const CreateVisitorPassScreen({super.key});

  @override
  State<CreateVisitorPassScreen> createState() => _CreateVisitorPassScreenState();
}

class _CreateVisitorPassScreenState extends State<CreateVisitorPassScreen> {
  String visitType = "General Visit";
  String uploadOption = "Camera";

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 28)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1.3),
                          borderRadius: BorderRadius.circular(5)),
                      child: const Text(
                        "Creator Visitor Pass",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E6A7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Create Visitor Pass",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text(
                        "Create a digital pass to grant your visitor access",
                        style: TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 12),

                      buildDropdown("Select Society", ["Society A", "Society B"], null),
                      buildDropdown("Visit Type", ["General Visit", "Delivery", "Maintenance"], visitType),
                      buildTextField("Visitor Name", "Enter Visitor's full name"),
                      buildTextField("Phone Number", "+91XXXXXXXXXX", type: TextInputType.phone),
                      buildTextField("Purpose of Visit", "Describe the purpose"),

                      buildTextField("Valid From", "dd/mm/yyyy"),
                      buildTextField("Valid Until", "dd/mm/yyyy"),

                      const SizedBox(height: 10),
                      const Text("Upload Photo"),
                      Row(
                        children: [
                          Radio(
                            value: "Camera",
                            groupValue: uploadOption,
                            onChanged: (v) => setState(() => uploadOption = v.toString()),
                          ),
                          const Text("Camera"),
                          Radio(
                            value: "Gallery",
                            groupValue: uploadOption,
                            onChanged: (v) => setState(() => uploadOption = v.toString()),
                          ),
                          const Text("Select photo/file"),
                        ],
                      ),

                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade800,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VehicleInfoScreen()),
                            );
                          },
                          icon: const Icon(Icons.chevron_right),
                          label: const Text("NEXT"),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, String hint, {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text(label),
        TextField(
          keyboardType: type,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget buildDropdown(String label, List<String> items, String? selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text(label),
        DropdownButtonFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          value: selected ?? items[0],
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ))
              .toList(),
          onChanged: (v) {},
        ),
      ],
    );
  }
}
