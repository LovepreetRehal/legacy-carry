import 'package:flutter/material.dart';
import 'package:legacy_carry/views/resident/post_a_job_two.dart';
import 'package:legacy_carry/views/viewmodels/post_job_viewmodel.dart';
import 'package:provider/provider.dart';

import '../models/create_job_request.dart';


class PostAJobOne extends StatelessWidget {
  const PostAJobOne({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostJobViewmodel(),
      child: const _PostAJobOneScreenContent(),
    );
  }
}

class _PostAJobOneScreenContent extends StatefulWidget {
  const _PostAJobOneScreenContent();

  @override
  State<_PostAJobOneScreenContent> createState() => _PostAJobOneContentState();
}

class _PostAJobOneContentState extends State<_PostAJobOneScreenContent> {

  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String jobType = 'Full Day';
  String? workersRequired;

  final List<String> workersList = List.generate(20, (index) => '${index + 1}');

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
              'Step 1/3',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Title
                TextField(
                  controller: jobTitleController,
                  decoration: InputDecoration(
                    hintText: 'Enter Job Title',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Location Map Thumbnail
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Map Thumbnail'),
                ),
                const SizedBox(height: 12),

                // Address Input
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: 'Enter Address',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Job Type Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['Full Day', 'Part Time', 'Hourly'].map((type) {
                    final isSelected = jobType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            jobType = type;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Workers Required Dropdown
                DropdownButtonFormField<String>(
                  value: workersRequired,
                  hint: const Text('Enter Number of Workers'),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: workersList.map((worker) {
                    return DropdownMenuItem(
                      value: worker,
                      child: Text(worker),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      workersRequired = value;
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F8D46),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {

                      if (jobTitleController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          workersRequired == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill all required fields")),
                        );
                        return;
                      }


                      final updatedJobData = CreateJobRequest(
                        jobTitle: jobTitleController.text.trim(),
                        location: locationController.text.trim().isEmpty
                            ? "Unknown Location"
                            : locationController.text.trim(),
                        address: addressController.text.trim(),
                        jobType: jobType.toLowerCase().replaceAll(' ', '_'), // full_day, part_time, hourly
                        workersRequired: int.parse(workersRequired!),
                        skillsRequired: [], // will add in Step 2
                        toolsProvided: false,
                        documentsRequired: [],
                        safetyInstructions: "",
                        startDate: "",
                        endDate: "",
                        shift: "",
                        payType: "",
                        payAmount: 0,
                        advancePayment: false,
                        advanceAmount: 0,
                        user_id: 0,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostJobStep2Screen(jobData: updatedJobData),
                        ),
                      );
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
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
