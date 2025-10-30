import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/create_job_request.dart';
import '../viewmodels/post_job_viewmodel.dart';
import 'resident_dashboard_screen.dart';
import '../services/auth_service.dart';

class PostAJobThree extends StatelessWidget {
  final CreateJobRequest jobData;

  const PostAJobThree({super.key, required this.jobData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostJobViewmodel(),
      child: _PostJobStep3Content(jobData: jobData),
    );
  }
}

class _PostJobStep3Content extends StatefulWidget {
  final CreateJobRequest jobData;

  const _PostJobStep3Content({required this.jobData, Key? key})
      : super(key: key);

  @override
  State<_PostJobStep3Content> createState() => _PostJobStep3ScreenState();
}

class _PostJobStep3ScreenState extends State<_PostJobStep3Content> {
  final AuthService _authService = AuthService();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController payAmountController = TextEditingController();
  final TextEditingController advanceAmountController = TextEditingController();

  String selectedShift = "Morning (08:00am-12:00pm)";
  String selectedPayType = "Per Hour";
  bool advancePayment = true;

  final shifts = ["Morning (08:00am-12:00pm)", "Afternoon", "Evening"];
  final payTypes = ["Per Hour", "Per Day", "Per Job"];

  // Method to get logged-in user ID
  Future<int> _getUserId() async {
    try {
      final profileData = await _authService.getUserProfile();
      final userId = profileData['user']?['id'] ??
          profileData['data']?['id'] ??
          profileData['id'];

      if (userId != null) {
        return int.tryParse(userId.toString()) ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting user ID: $e');
      return 0;
    }
  }

  // 🗓 Date Picker helper
  Future<void> _pickDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post a Job"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Step 3/3',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDFB139), Color(0xFF3CA349)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Start Date
                TextField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Start Date",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(context, startDateController),
                ),
                const SizedBox(height: 10),

                // End Date
                TextField(
                  controller: endDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "End Date",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(context, endDateController),
                ),
                const SizedBox(height: 10),

                // Shift Dropdown
                DropdownButtonFormField<String>(
                  value: selectedShift,
                  decoration: const InputDecoration(
                    labelText: "Shift",
                    border: OutlineInputBorder(),
                  ),
                  items: shifts
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => selectedShift = val ?? shifts[0]),
                ),
                const SizedBox(height: 10),

                // Pay Type Dropdown
                DropdownButtonFormField<String>(
                  value: selectedPayType,
                  decoration: const InputDecoration(
                    labelText: "Pay Type",
                    border: OutlineInputBorder(),
                  ),
                  items: payTypes
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => selectedPayType = val ?? payTypes[0]),
                ),
                const SizedBox(height: 10),

                // Pay Amount
                TextField(
                  controller: payAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Pay Amount (₹)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                const Text("Advance Payment?"),
                const SizedBox(height: 5),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => advancePayment = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              advancePayment ? Colors.green : Colors.white,
                          foregroundColor:
                              advancePayment ? Colors.white : Colors.black,
                        ),
                        child: const Text("YES"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => advancePayment = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              !advancePayment ? Colors.green : Colors.white,
                          foregroundColor:
                              !advancePayment ? Colors.white : Colors.black,
                        ),
                        child: const Text("NO"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Advance Amount
                TextField(
                  controller: advanceAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Advance Amount (₹)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(150, 45),
                    ),
                    onPressed: () async {
                      //  Step 1: Get logged-in user ID
                      final userId = await _getUserId();

                      if (userId == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                " Unable to get user information. Please login again."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      //  Step 2: Build the request
                      final request = CreateJobRequest(
                        jobTitle: widget.jobData.jobTitle,
                        location: widget.jobData.location,
                        address: widget.jobData.address,
                        jobType: widget.jobData.jobType,
                        workersRequired: widget.jobData.workersRequired,
                        skillsRequired: widget.jobData.skillsRequired,
                        toolsProvided: widget.jobData.toolsProvided,
                        documentsRequired: widget.jobData.documentsRequired,
                        safetyInstructions: widget.jobData.safetyInstructions,
                        startDate: startDateController.text.trim(),
                        endDate: endDateController.text.trim(),
                        shift: "morning",
                        payType: "per_day",
                        payAmount:
                            int.tryParse(payAmountController.text.trim()) ?? 0,
                        advancePayment: advancePayment,
                        advanceAmount:
                            int.tryParse(advanceAmountController.text.trim()) ??
                                0,
                        user_id:
                            userId, // Dynamically fetched from logged-in user
                      );

                      final jobViewModel =
                          Provider.of<PostJobViewmodel>(context, listen: false);

                      // Step 3: Create job
                      await jobViewModel.createJob(request);

                      //  Step 4: Handle result
                      if (jobViewModel.status == PostJobStatus.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(" Job created successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) =>
                                const ResidentDashboardScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                        String message = jobViewModel.errorMessage;

                        // Clean up the exception message to show nicely
                        if (message.contains('Exception:')) {
                          message = message.replaceAll('Exception:', '').trim();
                        }
                        if (message.contains('Error creating job:')) {
                          message = message
                              .replaceAll('Error creating job:', '')
                              .trim();
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(" Job creation failed: $message"),
                            backgroundColor: Colors.redAccent,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: const Text("Review Job"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
