import 'package:flutter/material.dart';

class ApplyForJobScreen extends StatefulWidget {
  const ApplyForJobScreen({Key? key}) : super(key: key);

  @override
  State<ApplyForJobScreen> createState() => _ApplyForJobScreenState();
}

class _ApplyForJobScreenState extends State<ApplyForJobScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe1b645), Color(0xff7fc36c)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 26),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Apply For Job",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // Date & Time Field
              _buildInputLabel("Proposed Start Date/Time"),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: _inputDecoration(Icons.calendar_month),
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2050),
                  );
                  if (date != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (time != null) {
                      setState(() {
                        dateController.text =
                        "${date.day}-${date.month}-${date.year} ${time.format(context)}";
                      });
                    }
                  }
                },
              ),

              const SizedBox(height: 15),

              // Expected Cost
              _buildInputLabel("Expected Cost"),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(Icons.currency_rupee),
              ),

              const SizedBox(height: 15),

              // Message Field
              _buildInputLabel("Message to Employer"),
              TextField(
                controller: messageController,
                maxLines: 2,
                decoration: _inputDecoration(Icons.edit),
              ),

              const SizedBox(height: 15),

              // Upload File
              _buildInputLabel("Attach Certificate / Photo"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black54),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Choose File  No file chosen",
                        style: TextStyle(fontSize: 15)),
                    Icon(Icons.camera_alt, size: 22),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 6,
                ),
                onPressed: () {
                  // TODO: Submit API
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("Send Application"),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
    );
  }

  InputDecoration _inputDecoration(IconData suffixIcon) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      suffixIcon: Icon(suffixIcon, size: 22),
      hintText: "",
    );
  }
}
