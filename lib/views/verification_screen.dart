import 'dart:io';
import 'package:flutter/material.dart';
import 'package:legacy_carry/views/employe/sign_in_with_number_screen.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'models/UserData.dart';
import 'models/sign_up_request.dart';
import 'viewmodels/signup_viewmodel.dart';

class VerificationScreen extends StatelessWidget {
  final UserData userData; // store the passed user data

  const VerificationScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: _VerifyScreenContent(userData: userData),
    );
  }
}

class _VerifyScreenContent extends StatefulWidget {
  final UserData userData; //  store the UserData as a field

  const _VerifyScreenContent({required this.userData, Key? key})
      : super(key: key);

  @override
  State<_VerifyScreenContent> createState() => _VerifyScreenContentState();
}

class _VerifyScreenContentState extends State<_VerifyScreenContent> {
  final TextEditingController phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController idController = TextEditingController();

  // Store selected files
  File? _idProofFile;
  File? _selfieFile;

  // Track if files are selected
  bool get _hasIdProof => _idProofFile != null;
  bool get _hasSelfie => _selfieFile != null;

  Future<void> _pickIdProof() async {
    try {
      // Show options: Camera, Gallery, or File (PDF)
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select ID Proof Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('File (PDF/Image)'),
                onTap: () => Navigator.pop(context, null),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        // Use image picker for camera/gallery
        final XFile? image = await _imagePicker.pickImage(source: source);
        if (image != null) {
          setState(() {
            _idProofFile = File(image.path);
          });
        }
      } else {
        // Use file picker for PDF/image files
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          allowMultiple: false,
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            _idProofFile = File(result.files.single.path!);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickSelfie() async {
    try {
      // Show options: Camera or Gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Selfie Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await _imagePicker.pickImage(source: source);
        if (image != null) {
          setState(() {
            _selfieFile = File(image.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Join As a Employee",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Fill in your profile to receive job offers",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildStep("Personal Info", false),
                    _buildStep("Professional", false),
                    _buildStep("Verification", true),
                    _buildStep("Agreement", false),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Card Container
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Verification Documents",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ID Number + Verify Button
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: idController,
                                  decoration: const InputDecoration(
                                    hintText: "Enter Your Govt ID Number",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size(80, 48),
                                ),
                                onPressed: () {},
                                child: const Text("VERIFY"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // OTP Verification (Display only - already verified)
                          const Text("OTP Verification*"),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "OTP: ${widget.userData.otp}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "OTP was verified during registration",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Upload ID Proof
                          const Text("Upload ID Proof"),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickIdProof,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _hasIdProof
                                        ? Row(
                                            children: [
                                              const Icon(Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _idProofFile!.path
                                                      .split('/')
                                                      .last,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            "Choose File/Image/Camera",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                          ),
                                  ),
                                  IconButton(
                                    onPressed: _hasIdProof
                                        ? () {
                                            setState(() {
                                              _idProofFile = null;
                                            });
                                          }
                                        : _pickIdProof,
                                    icon: Icon(
                                      _hasIdProof
                                          ? Icons.close
                                          : Icons.upload_file,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Upload Selfie
                          const Text("Upload Selfie for Face Verification*"),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickSelfie,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _hasSelfie
                                        ? Row(
                                            children: [
                                              const Icon(Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _selfieFile!.path
                                                      .split('/')
                                                      .last,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            "Choose File/Image/Camera",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                          ),
                                  ),
                                  if (_hasSelfie)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selfieFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    onPressed: _hasSelfie
                                        ? () {
                                            setState(() {
                                              _selfieFile = null;
                                            });
                                          }
                                        : _pickSelfie,
                                    icon: Icon(
                                      _hasSelfie
                                          ? Icons.close
                                          : Icons.upload_file,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Navigation Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("PREVIOUS"),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // Use OTP from userData (already verified during registration)
                                    final otp = widget.userData.otp;
                                    final idNumber = idController.text;

                                    if (otp.isEmpty || otp.length < 6) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text("OTP is required"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (idNumber.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text("Please enter ID number"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // Print userData
                                    print("=== User Data ===");
                                    print("Name: ${widget.userData.name}");
                                    print("Phone: ${widget.userData.phone}");
                                    print("Email: ${widget.userData.email}");
                                    print(
                                        "Password: ${widget.userData.password}");
                                    print(
                                        "Experience: ${widget.userData.experience}");
                                    print(
                                        "Work Radius: ${widget.userData.workRadius}");
                                    print("Rate: ${widget.userData.rate}");
                                    print("About: ${widget.userData.about}");
                                    print(
                                        "Availability: ${widget.userData.availability}");
                                    print(
                                        "Services: ${widget.userData.services}");
                                    print("ID Number: $idNumber");
                                    print("OTP: $otp");

                                    // Files are saved locally but not sent to API yet
                                    print(
                                        "=== Files (Saved Locally - Not Sent to API) ===");
                                    if (_hasIdProof) {
                                      print("ID Proof: ${_idProofFile!.path}");
                                    } else {
                                      print("ID Proof: Not selected");
                                    }
                                    if (_hasSelfie) {
                                      print("Selfie: ${_selfieFile!.path}");
                                    } else {
                                      print("Selfie: Not selected");
                                    }

                                    final signUpViewModel =
                                        Provider.of<SignUpViewModel>(context,
                                            listen: false);

                                    // Convert experience format: "5+ Years" -> "5", "1-3 Years" -> "2", etc.
                                    String experienceYears = "0";
                                    if (widget.userData.experience != null) {
                                      final exp = widget.userData.experience!;
                                      if (exp == "Fresher") {
                                        experienceYears = "0";
                                      } else if (exp == "1-3 Years") {
                                        experienceYears = "2";
                                      } else if (exp == "3-5 Years") {
                                        experienceYears = "4";
                                      } else if (exp == "5+ Years") {
                                        experienceYears = "5";
                                      } else {
                                        // Try to extract number from string
                                        final match =
                                            RegExp(r'(\d+)').firstMatch(exp);
                                        if (match != null) {
                                          experienceYears = match.group(1)!;
                                        }
                                      }
                                    }

                                    // Convert availability format: "Full - Time" -> "Full-Time"
                                    String availability = "Full-Time";
                                    if (widget.userData.availability != null) {
                                      availability = widget
                                          .userData.availability!
                                          .replaceAll(" - ", "-")
                                          .replaceAll(" -", "-")
                                          .replaceAll("- ", "-");
                                    }

                                    // Get services from userData or default
                                    List<String> services =
                                        widget.userData.services ??
                                            ["Plumbing"];
                                    if (services.isEmpty) {
                                      services = ["Plumbing"];
                                    }

                                    // Build request from actual userData
                                    final request = SignUpRequest(
                                      name: widget.userData.name,
                                      phone: widget.userData.phone,
                                      email: widget.userData.email,
                                      password: widget.userData.password,
                                      role: "labor",
                                      isActive: true,
                                      otp: otp,
                                      experienceYears: experienceYears,
                                      services: services,
                                      workRadiusKm:
                                          widget.userData.workRadius?.toInt() ??
                                              5,
                                      hourlyRate: int.tryParse(
                                              widget.userData.rate ?? "700") ??
                                          700,
                                      availability: availability,
                                      about: widget.userData.about ?? "",
                                      idNumber: idNumber,
                                    );

                                    await signUpViewModel
                                        .signUpEmployee(request);

                                    if (signUpViewModel.status ==
                                        SignUpStatus.success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Signup successful! Please sign in to continue."),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const SignInWithNumberScreen()),
                                        (route) =>
                                            false, // Remove all previous routes
                                      );
                                    } else if (signUpViewModel.status ==
                                        SignUpStatus.error) {
                                      // Show validation errors
                                      final errorMessage =
                                          signUpViewModel.errorMessage;

                                      // If error contains newlines, show in a dialog for better readability
                                      if (errorMessage.contains('\n')) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'Validation Error',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: errorMessage
                                                    .split('\n')
                                                    .map((error) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 8),
                                                          child: Text(
                                                            error,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                        ))
                                                    .toList(),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        // Single line error - show in SnackBar
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(errorMessage),
                                            backgroundColor: Colors.red,
                                            duration:
                                                const Duration(seconds: 4),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text("NEXT"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildStep(String title, bool isActive) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 9,
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
