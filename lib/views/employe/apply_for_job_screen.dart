import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';

class ApplyForJobScreen extends StatefulWidget {
  final String jobId;

  const ApplyForJobScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<ApplyForJobScreen> createState() => _ApplyForJobScreenState();
}

class _ApplyForJobScreenState extends State<ApplyForJobScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _certificatePhoto;
  bool _isLoading = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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
                        _selectedDate = date;
                        _selectedTime = time;
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
              GestureDetector(
                onTap: () async {
                  final ImageSource? source = await showDialog<ImageSource>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Select Image Source'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Camera'),
                            onTap: () =>
                                Navigator.pop(context, ImageSource.camera),
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Gallery'),
                            onTap: () =>
                                Navigator.pop(context, ImageSource.gallery),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (source != null) {
                    final XFile? image =
                        await _imagePicker.pickImage(source: source);
                    if (image != null) {
                      setState(() {
                        _certificatePhoto = File(image.path);
                      });
                    }
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black54),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      if (_certificatePhoto != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _certificatePhoto!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Tap to change photo",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ] else ...[
                        const Expanded(
                          child: Text(
                            "Choose File  No file chosen",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        const Icon(Icons.camera_alt, size: 22),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 6,
                  disabledBackgroundColor: Colors.grey,
                ),
                onPressed: _isLoading ? null : _submitApplication,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
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

  // Get user ID from profile
  Future<String> _getUserId() async {
    try {
      final profileData = await _authService.getUserProfile();
      final userId = profileData['user']?['id']?.toString() ??
          profileData['data']?['id']?.toString() ??
          profileData['id']?.toString();

      if (userId != null) {
        return userId;
      }
      throw Exception('User ID not found');
    } catch (e) {
      print("Error getting user ID: $e");
      rethrow;
    }
  }

  // Format date and time to ISO format (2025-10-15T10:00:00)
  String _formatDateTime(DateTime date, TimeOfDay time) {
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return dateTime.toIso8601String().split('.')[0]; // Remove milliseconds
  }

  // Submit application
  Future<void> _submitApplication() async {
    // Validate inputs
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (costController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter expected cost'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final expectedCost = int.tryParse(costController.text.trim());
    if (expectedCost == null || expectedCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid expected cost'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user ID
      final userId = await _getUserId();

      // Format datetime to ISO format
      final startDatetime = _formatDateTime(_selectedDate!, _selectedTime!);

      // For now, send empty string for certificate_photo
      // TODO: Implement file upload if needed
      final certificatePhoto = '';

      // Submit application
      final response = await _authService.submitJobApplication(
        jobId: widget.jobId,
        startDatetime: startDatetime,
        expectedCost: expectedCost,
        messageToEmployer: messageController.text.trim(),
        certificatePhoto: certificatePhoto,
        userId: userId,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response['message'] ?? 'Application submitted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate success
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    costController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
