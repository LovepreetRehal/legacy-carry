import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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

  // Track server state
  bool isFetchingDocuments = false;
  String? fetchDocumentsError;
  Map<String, Map<String, dynamic>> uploadedDocumentsByType = {};

  @override
  void initState() {
    super.initState();
    _loadUploadedDocuments();
  }

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
      // For Verification Photo, use camera only
      if (documentType == 'Verification Photo') {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );

        if (image != null) {
          final file = File(image.path);
          if (!await file.exists()) {
            if (mounted) {
              _showErrorDialog('Captured image file not found.');
            }
            return;
          }

          // Create a PlatformFile object for consistency with existing code
          // Note: PlatformFile constructor may vary by package version
          // We only need path for upload, so we create a minimal object
          final fileSize = await file.length();
          final platformFile = PlatformFile(
            name: image.name,
            path: image.path,
            size: fileSize,
          );

          // Update state with selected file
          setState(() {
            verificationPhotoFile = platformFile;
            verificationPhotoUploaded = false;
          });

          // Upload the file immediately after selection
          await _uploadFile(documentType, platformFile);
        }
      } else {
        // For other documents, use file picker
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
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
            }
          });

          // Upload the file immediately after selection
          await _uploadFile(documentType, file);
        }
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
      final filePath = platformFile.path;
      if (filePath == null || filePath.isEmpty) {
        _showErrorDialog('File path is not available.');
        return;
      }
      final file = File(filePath);
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

      await _loadUploadedDocuments(userId: userId);
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

  Future<void> _loadUploadedDocuments({int? userId}) async {
    if (!mounted) return;
    setState(() {
      isFetchingDocuments = true;
      fetchDocumentsError = null;
    });

    try {
      final resolvedUserId = userId ?? await _getUserId();
      if (resolvedUserId == 0) {
        throw Exception('Unable to get user information. Please try again.');
      }

      final documents = await _authService.getUserDocuments(resolvedUserId);
      final mapped = <String, Map<String, dynamic>>{};

      for (final doc in documents) {
        final type = doc['document_type']?.toString();
        if (type != null) {
          mapped[type] = Map<String, dynamic>.from(doc);
        }
      }

      if (!mounted) return;
      setState(() {
        uploadedDocumentsByType = mapped;
        idProofUploaded = mapped.containsKey('id_proof');
        addressProofUploaded = mapped.containsKey('address_proof');
        verificationPhotoUploaded = mapped.containsKey('verification_photo');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        fetchDocumentsError =
            e.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isFetchingDocuments = false;
      });
    }
  }

  Map<String, dynamic>? _getDocumentDataForTitle(String title) {
    final type = _getDocumentTypeApiValue(title);
    return uploadedDocumentsByType[type];
  }

  String _formatDocumentStatus(String? status) {
    if (status == null || status.isEmpty) return 'Pending review';
    return status
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _extractFileName(String? path) {
    if (path == null || path.isEmpty) return 'Uploaded document';
    final segments = path.split('/');
    return segments.isNotEmpty ? segments.last : path;
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

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  if (isFetchingDocuments)
                    const LinearProgressIndicator(
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                    ),
                  if (fetchDocumentsError != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fetchDocumentsError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: isFetchingDocuments
                                ? null
                                : () => _loadUploadedDocuments(),
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    ),
                  ],
                  _documentCard(
                      "ID Proof",
                      "Upload Aadhaar, PAN, Passport etc.",
                      idProofFile,
                      isUploadingIdProof,
                      idProofUploaded,
                      existingDocument: _getDocumentDataForTitle("ID Proof")),
                  const SizedBox(height: 15),
                  _documentCard(
                      "Address Proof",
                      "Upload utility bill, rental agreement etc.",
                      addressProofFile,
                      isUploadingAddressProof,
                      addressProofUploaded,
                      existingDocument:
                          _getDocumentDataForTitle("Address Proof")),
                  const SizedBox(height: 15),
                  _documentCard(
                      "Verification Photo",
                      "Upload a clear passport - size photo",
                      verificationPhotoFile,
                      isUploadingVerificationPhoto,
                      verificationPhotoUploaded,
                      existingDocument:
                          _getDocumentDataForTitle("Verification Photo")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _documentCard(String title, String subtitle,
      PlatformFile? selectedFile, bool isUploading, bool isUploaded,
      {Map<String, dynamic>? existingDocument}) {
    final documentStatus =
        existingDocument?['status']?.toString().toLowerCase();
    final bool isRejectedStatus = documentStatus == 'rejected';
    final bool canUploadOrReplace = !isUploaded || isRejectedStatus;

    return Container(
      width: double.infinity, // ⭐ ADD THIS LINE
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
          if (existingDocument != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _extractFileName(
                              existingDocument['file_path']?.toString()),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.cloud_done, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Status: ${_formatDocumentStatus(existingDocument['status']?.toString())}',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  if (existingDocument['remarks'] != null &&
                      existingDocument['remarks'].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Remarks: ${existingDocument['remarks']}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
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
            onPressed: (isUploading || !canUploadOrReplace)
                ? null
                : () => _pickFile(title),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploading
                  ? Colors.grey.shade300
                  : !isUploaded
                      ? Colors.grey.shade200
                      : isRejectedStatus
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
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
                : Text(!isUploaded
                    ? "Upload"
                    : isRejectedStatus
                        ? "Replace"
                        : "Uploaded"),
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
