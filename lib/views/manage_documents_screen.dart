import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'services/auth_service.dart';

class ManageDocumentsScreen extends StatefulWidget {
  const ManageDocumentsScreen({super.key});

  @override
  State<ManageDocumentsScreen> createState() => _ManageDocumentsScreenState();
}

class _ManageDocumentsScreenState extends State<ManageDocumentsScreen> {
  // Store selected files for each document type
  PlatformFile? idProofFile;
  PlatformFile? addressProofFile;
  PlatformFile? verificationPhotoFile;
  final AuthService _authService = AuthService();

  // Track upload status for each document
  bool isUploadingIdProof = false;
  bool isUploadingAddressProof = false;
  bool isUploadingVerificationPhoto = false;

  // Track uploaded status
  bool idProofUploaded = false;
  bool addressProofUploaded = false;
  bool verificationPhotoUploaded = false;

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
      print("Error getting user ID: $e");
      return 0;
    }
  }

  // Map document type display name to API document_type value
  String _getDocumentTypeApiValue(String displayName) {
    switch (displayName) {
      case 'ID Proof':
        return 'id_proof';
      case 'Address Proof':
        return 'address_proof';
      case 'Verification Photo':
        return 'verification_photo';
      default:
        return displayName.toLowerCase().replaceAll(' ', '_');
    }
  }

  Future<void> _pickFile(String documentType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: documentType == 'Verification Photo'
            ? FileType.image
            : FileType.custom,
        allowedExtensions: documentType == 'Verification Photo'
            ? null
            : ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Update state with selected file
        setState(() {
          switch (documentType) {
            case 'ID Proof':
              idProofFile = file;
              idProofUploaded = false;
              break;
            case 'Address Proof':
              addressProofFile = file;
              addressProofUploaded = false;
              break;
            case 'Verification Photo':
              verificationPhotoFile = file;
              verificationPhotoUploaded = false;
              break;
          }
        });

        // Upload the file immediately after selection
        await _uploadFile(documentType, file);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error picking file: $e');
      }
    }
  }

  Future<void> _uploadFile(
      String documentType, PlatformFile platformFile) async {
    try {
      // Get user ID
      final userId = await _getUserId();
      if (userId == 0) {
        _showErrorDialog('Unable to get user information. Please try again.');
        return;
      }

      // Convert PlatformFile to File
      if (platformFile.path == null) {
        _showErrorDialog('File path is not available.');
        return;
      }
      final file = File(platformFile.path!);
      if (!await file.exists()) {
        _showErrorDialog('Selected file does not exist.');
        return;
      }

      // Set uploading state
      setState(() {
        switch (documentType) {
          case 'ID Proof':
            isUploadingIdProof = true;
            break;
          case 'Address Proof':
            isUploadingAddressProof = true;
            break;
          case 'Verification Photo':
            isUploadingVerificationPhoto = true;
            break;
        }
      });

      // Get API document type value
      final apiDocumentType = _getDocumentTypeApiValue(documentType);

      // Upload document
      await _authService.uploadDocument(
        userId: userId,
        documentType: apiDocumentType,
        file: file,
      );

      // Success - update state
      setState(() {
        switch (documentType) {
          case 'ID Proof':
            isUploadingIdProof = false;
            idProofUploaded = true;
            break;
          case 'Address Proof':
            isUploadingAddressProof = false;
            addressProofUploaded = true;
            break;
          case 'Verification Photo':
            isUploadingVerificationPhoto = false;
            verificationPhotoUploaded = true;
            break;
        }
      });

      _showSuccessDialog('$documentType uploaded successfully!');
    } catch (e) {
      // Reset uploading state on error
      setState(() {
        switch (documentType) {
          case 'ID Proof':
            isUploadingIdProof = false;
            break;
          case 'Address Proof':
            isUploadingAddressProof = false;
            break;
          case 'Verification Photo':
            isUploadingVerificationPhoto = false;
            break;
        }
      });
      print("Error uploading document: $e");
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manage Documents",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6C945), Color(0xFF7BC57B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _documentCard("ID Proof", "Upload Aadhaar, PAN, Passport etc.",
                    idProofFile, isUploadingIdProof, idProofUploaded),
                const SizedBox(height: 15),
                _documentCard(
                    "Address Proof",
                    "Upload utility bill, rental agreement etc.",
                    addressProofFile,
                    isUploadingAddressProof,
                    addressProofUploaded),
                const SizedBox(height: 15),
                _documentCard(
                    "Verification Photo",
                    "Upload a clear passport - size photo",
                    verificationPhotoFile,
                    isUploadingVerificationPhoto,
                    verificationPhotoUploaded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _documentCard(String title, String subtitle,
      PlatformFile? selectedFile, bool isUploading, bool isUploaded) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          if (selectedFile != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedFile.name,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isUploaded)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          ElevatedButton(
            onPressed: isUploading ? null : () => _pickFile(title),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploading
                  ? Colors.grey.shade300
                  : isUploaded
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
              foregroundColor: Colors.black87,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: isUploading
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black54),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("Uploading..."),
                    ],
                  )
                : Text(isUploaded ? "Replace" : "Upload / Replace"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFF5E6B3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFF5E6B3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFD32F2F),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
