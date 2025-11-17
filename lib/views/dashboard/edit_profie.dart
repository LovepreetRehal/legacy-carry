import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/get_profile_view_model.dart';
import '../services/auth_service.dart';
import '../providers/user_profile_provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetProfileViewModel()..fetchProfile(),
      child: const _EditProfileContent(),
    );
  }
}

class _EditProfileContent extends StatefulWidget {
  const _EditProfileContent();

  @override
  State<_EditProfileContent> createState() => _EditProfileContentState();
}

class _EditProfileContentState extends State<_EditProfileContent> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  bool _dataSet = false;
  bool _isSaving = false;
  XFile? _image; //  Store the selected photo

  final ImagePicker _picker = ImagePicker(); //  Initialize ImagePicker
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetProfileViewModel>(context, listen: false).fetchProfile();
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedImage =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      _image = pickedImage;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedImage =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    setState(() {
                      _image = pickedImage;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Validate inputs
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your phone number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Get user ID from profile data
      final profileVM =
          Provider.of<GetProfileViewModel>(context, listen: false);
      final user = profileVM.profileData?['user'];

      if (user == null || user['id'] == null) {
        throw Exception('User ID not found. Please try again.');
      }

      final userId = int.tryParse(user['id'].toString());
      if (userId == null) {
        throw Exception('Invalid user ID');
      }

      // Convert XFile to File if image is selected
      File? avatarFile;
      if (_image != null) {
        avatarFile = File(_image!.path);
      }

      // Call update profile API
      final response = await _authService.updateUserProfile(
        userId: userId,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        avatar: avatarFile,
      );

      // Clear the local image state so it shows the server image
      if (mounted) {
        setState(() {
          _image = null; // Clear local image to show server image
        });
      }

      // Update profile data with response if it contains user data
      // This ensures we have the latest avatar URL immediately
      if (response['data'] != null && mounted) {
        // Update the profile data directly from response
        final updatedUser = response['data'];
        print(
            "📸 Updated user data from response - Avatar: ${updatedUser['avatar']}");
        final currentProfileData = profileVM.profileData ?? {};
        final updatedProfileData = {
          ...currentProfileData,
          'user': updatedUser,
        };
        profileVM.updateProfileData(updatedProfileData);
        context
            .read<UserProfileProvider>()
            .updateProfileData(updatedProfileData);
      }

      // Refresh profile data to get updated avatar URL (in case response didn't have it)
      await profileVM.fetchProfile();

      if (mounted && profileVM.profileData != null) {
        context
            .read<UserProfileProvider>()
            .updateProfileData(profileVM.profileData);
      }

      // Debug: Print avatar URL after refresh
      final refreshedUser = profileVM.profileData?['user'];
      print(" Avatar URL after refresh: ${refreshedUser?['avatar']}");

      // Force a rebuild to show the updated avatar
      if (mounted) {
        setState(() {});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? "Profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // Small delay to ensure avatar is visible before navigating back
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted && Navigator.of(context).canPop()) {
          // Navigate back after successful update when possible
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
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
        child: Consumer<GetProfileViewModel>(
          builder: (context, profileVM, child) {
            if (profileVM.status == ProfileStatus.loading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading profile...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            } else if (profileVM.status == ProfileStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      profileVM.errorMessage,
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<GetProfileViewModel>(context, listen: false)
                            .fetchProfile();
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (profileVM.status == ProfileStatus.success &&
                profileVM.profileData != null &&
                !_dataSet) {
              final user = profileVM.profileData!['user'];
              if (user != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    nameController.text = user['name']?.toString() ?? '';
                    emailController.text = user['email']?.toString() ?? '';
                    phoneController.text = user['phone']?.toString() ?? '';
                    _dataSet = true;
                  });
                  print(" Profile data loaded into form: ${user['name']}");
                });
              } else {
                print(" User data is null in profile response");
              }
            }

            return Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7C55E),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ✅ Profile photo section
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Consumer<GetProfileViewModel>(
                              builder: (context, profileVM, child) {
                                final user = profileVM.profileData?['user'];
                                String? existingAvatarUrl =
                                    user?['avatar']?.toString();

                                // Handle relative URLs by prepending base URL if needed
                                if (existingAvatarUrl != null &&
                                    existingAvatarUrl.isNotEmpty) {
                                  // If it's a relative URL, prepend the base URL
                                  if (!existingAvatarUrl
                                          .startsWith('http://') &&
                                      !existingAvatarUrl
                                          .startsWith('https://')) {
                                    // Remove leading slash if present
                                    if (existingAvatarUrl.startsWith('/')) {
                                      existingAvatarUrl =
                                          existingAvatarUrl.substring(1);
                                    }
                                    // Prepend base URL (without /api)
                                    final baseUrl =
                                        _authService.baseUrlWithoutApi;
                                    existingAvatarUrl =
                                        '$baseUrl/$existingAvatarUrl';
                                  }
                                }

                                print(
                                    "🖼️ Avatar URL: $existingAvatarUrl"); // Debug print

                                final ImageProvider? avatarImage =
                                    _image != null
                                        ? FileImage(File(_image!.path))
                                        : (existingAvatarUrl != null &&
                                                existingAvatarUrl.isNotEmpty)
                                            ? NetworkImage(existingAvatarUrl)
                                            : null;

                                return CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  backgroundImage: avatarImage,
                                  onBackgroundImageError: avatarImage != null
                                      ? (exception, stackTrace) {
                                          print(
                                              "❌ Error loading avatar: $exception");
                                          print("URL was: $existingAvatarUrl");
                                        }
                                      : null,
                                  child: _image == null &&
                                          (existingAvatarUrl == null ||
                                              existingAvatarUrl.isEmpty)
                                      ? const Text(
                                          'PHOTO',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Enter Your Name",
                          labelText: "Full Name",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Enter Your Email",
                          labelText: "Email",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Enter Your Phone No.",
                          labelText: "Phone Number",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F8D46),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
