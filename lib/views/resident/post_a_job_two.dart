import 'package:flutter/material.dart';
import 'package:legacy_carry/views/models/create_job_request.dart';
import 'package:legacy_carry/views/resident/post_a_job_three.dart';

class PostJobStep2Screen extends StatefulWidget {
  final CreateJobRequest jobData;

  const PostJobStep2Screen({super.key, required this.jobData});

  @override
  State<PostJobStep2Screen> createState() => _PostJobStep2ScreenState();
}

class _PostJobStep2ScreenState extends State<PostJobStep2Screen> {
  List<String> skills = ['Painter', 'Carpenter', 'Plumber', 'Electrician'];
  List<bool> skillsSelected = [false, false, false, false];

  bool toolsProvided = true;
  bool idRequired = false;
  bool certificateRequired = false;
  TextEditingController safetyController = TextEditingController();

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
              'Step 2/3',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDFB139), Color(0xFF3CA349)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // ✅ Added scroll
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Skills Required",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(skills.length, (index) {
                    return ChoiceChip(
                      label: Text(skills[index]),
                      selected: skillsSelected[index],
                      onSelected: (selected) {
                        setState(() {
                          skillsSelected[index] = selected;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Tools Provided?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => toolsProvided = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              toolsProvided ? Colors.green : Colors.white,
                          foregroundColor:
                              toolsProvided ? Colors.white : Colors.black,
                        ),
                        child: const Text("YES"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => toolsProvided = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              !toolsProvided ? Colors.green : Colors.white,
                          foregroundColor:
                              !toolsProvided ? Colors.white : Colors.black,
                        ),
                        child: const Text("NO"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Documents Required",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: idRequired,
                      onChanged: (value) =>
                          setState(() => idRequired = value ?? false),
                    ),
                    const Text("ID"),
                    const SizedBox(width: 20),
                    Checkbox(
                      value: certificateRequired,
                      onChanged: (value) =>
                          setState(() => certificateRequired = value ?? false),
                    ),
                    const Text("Certificate"),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Safety Instructions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: safetyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Safety Instructions...",
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(150, 45),
                    ),
                    onPressed: () {
                      //  Collect selected skills
                      List<String> selectedSkills = [];
                      for (int i = 0; i < skills.length; i++) {
                        if (skillsSelected[i]) selectedSkills.add(skills[i]);
                      }

                      //  Collect documents
                      List<String> documentsRequired = [];
                      if (idRequired) documentsRequired.add("ID");
                      if (certificateRequired)
                        documentsRequired.add("Certificate");

                      //  Merge data from step 1 and step 2
                      final updatedJobData = CreateJobRequest(
                          jobTitle: widget.jobData.jobTitle,
                          location: widget.jobData.location,
                          address: widget.jobData.address,
                          jobType: widget.jobData.jobType,
                          workersRequired: widget.jobData.workersRequired,
                          skillsRequired: selectedSkills,
                          toolsProvided: toolsProvided,
                          documentsRequired: documentsRequired,
                          safetyInstructions:
                              safetyController.text.trim().isEmpty
                                  ? ""
                                  : safetyController.text.trim(),
                          startDate: widget.jobData.startDate,
                          endDate: widget.jobData.endDate,
                          shift: widget.jobData.shift,
                          payType: widget.jobData.payType,
                          payAmount: widget.jobData.payAmount,
                          advancePayment: widget.jobData.advancePayment,
                          advanceAmount: widget.jobData.advanceAmount,
                          user_id: widget.jobData.user_id);

                      //  Go to Step 3
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostAJobThree(jobData: updatedJobData),
                        ),
                      );
                    },
                    child: const Text(
                      "Next",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
