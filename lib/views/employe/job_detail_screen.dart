import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../chat_screen.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'apply_for_job_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const JobDetailScreen({Key? key, required this.jobData}) : super(key: key);

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  late Map<String, dynamic> _jobData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasApplied = false;
  bool _isOpeningChat = false;
  
  GoogleMapController? _mapController;
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  bool _shouldRetryLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _jobData = Map<String, dynamic>.from(widget.jobData);
    _fetchJobDetails();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _shouldRetryLocation) {
      _shouldRetryLocation = false;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _getCurrentLocation();
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {

        if (mounted) {
          _showLocationServiceDialog();
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }


      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }


      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });


      if (_mapController != null && _currentLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      print('Error getting location: $e');
    }
  }

  Future<void> _showLocationServiceDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Location services are disabled. Please enable location services to see your current location on the map.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                Navigator.of(context).pop();
                _shouldRetryLocation = true;

                await Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchJobDetails() async {
    final jobId = _extractJobId(_jobData);
    if (jobId == null) {
      setState(() {
        _errorMessage = 'Job ID not available';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.getJobDetails(jobId);
      if (!mounted) return;
      setState(() {
        _jobData = {..._jobData, ...result};
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _extractJobId(Map<String, dynamic> data) {
    final dynamic idValue = data['id'] ?? data['job_id'];
    if (idValue == null) return null;
    final id = idValue.toString();
    return id.isEmpty ? null : id;
  }

  String? _extractResidentId(Map<String, dynamic> data) {
    final dynamic residentValue = data['resident_id'] ??
        data['resident']?['id'] ??
        data['user_id'] ??
        data['user']?['id'] ??
        data['user_details']?['id'];
    if (residentValue == null) return null;
    final id = residentValue.toString();
    return id.isEmpty ? null : id;
  }

  Map<String, dynamic>? _extractEmployerData(Map<String, dynamic> data) {
    final dynamic employer = data['user'] ?? data['user_details'];
    if (employer is Map<String, dynamic>) {
      return employer;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> jobData = _jobData;

    final String jobTitle = jobData['job_title']?.toString() ??
        jobData['title']?.toString() ??
        'Job Title';
    final Map<String, dynamic>? employerData = _extractEmployerData(jobData);
    final String employerName = employerData?['name']?.toString() ??
        jobData['employer_name']?.toString() ??
        jobData['posted_by']?.toString() ??
        'Employer';
    final String employerAvatar =
        _buildAvatarUrl(employerData?['avatar']?.toString());
    final String description = jobData['description']?.toString() ??
        jobData['safety_instructions']?.toString() ??
        jobData['tasks']?.toString() ??
        '';


    List<String> skillsList = [];
    if (jobData['skills_required'] != null) {
      if (jobData['skills_required'] is List) {
        skillsList = List<String>.from(jobData['skills_required']);
      } else if (jobData['skills_required'] is String) {
        try {
          final decoded = jsonDecode(jobData['skills_required']);
          if (decoded is List) {
            skillsList = List<String>.from(decoded);
          }
        } catch (_) {
          skillsList = [jobData['skills_required'].toString()];
        }
      }
    }
    final String tasks = skillsList.isNotEmpty
        ? skillsList.join(', ')
        : description.isNotEmpty
            ? description
            : 'Not specified';

    final bool toolsProvided = jobData['tools_provided'] == true ||
        jobData['tools_provided']?.toString().toLowerCase() == 'yes' ||
        jobData['tools_provided'] == 1;

    final String startDate =
        _formatDate(jobData['start_date'] ?? jobData['created_at']);
    final String? endDate =
        jobData['end_date'] != null ? _formatDate(jobData['end_date']) : null;

    final String shift = jobData['shift']?.toString() ??
        jobData['time']?.toString() ??
        'Not specified';

    final String pay = jobData['pay_amount'] != null
        ? '₹${jobData['pay_amount']} / ${_formatPayType(jobData['pay_type']?.toString() ?? 'per_day')}'
        : 'Not specified';


    int parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    final int workersRequired = parseInt(jobData['workers_required'], 1);

    final String location = jobData['location']?.toString() ??
        jobData['job_location']?.toString() ??
        'Location not specified';

    final String address = jobData['address']?.toString() ?? '';


    List<String> documentsList = [];
    if (jobData['documents_required'] != null) {
      if (jobData['documents_required'] is List) {
        documentsList = List<String>.from(jobData['documents_required']);
      } else if (jobData['documents_required'] is String) {
        try {
          final decoded = jsonDecode(jobData['documents_required']);
          if (decoded is List) {
            documentsList = List<String>.from(decoded);
          }
        } catch (_) {
          documentsList = [jobData['documents_required'].toString()];
        }
      }
    }

    final String safetyInstructions =
        jobData['safety_instructions']?.toString() ?? '';

    final bool advancePayment = jobData['advance_payment'] == true ||
        jobData['advance_payment']?.toString().toLowerCase() == 'yes' ||
        jobData['advance_payment'] == 1;
    final bool isApplied = jobData['applied'] == true ||
        jobData['applied'] == 1 ||
        jobData['applied']?.toString().toLowerCase() == 'true';
    final int advanceAmount = parseInt(jobData['advance_amount'], 0);


    double parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    final double rating = parseDouble(jobData['rating'], 5.0);
    final int reviews =
        parseInt(jobData['reviews'] ?? jobData['review_count'], 0);
    final String employerPhone = employerData?['phone']?.toString() ??
        jobData['employer_phone']?.toString() ??
        '';


    String duration = 'Not specified';
    if (jobData['start_date'] != null && jobData['end_date'] != null) {
      try {
        final start = DateTime.parse(jobData['start_date'].toString());
        final end = DateTime.parse(jobData['end_date'].toString());
        final diff = end.difference(start).inDays;
        duration =
            diff > 0 ? '$diff ${diff == 1 ? 'Day' : 'Days'}' : 'Same day';
      } catch (_) {
        duration = jobData['expected_duration']?.toString() ?? 'Not specified';
      }
    } else if (jobData['expected_duration'] != null) {
      duration = jobData['expected_duration'].toString();
    }

    return WillPopScope(
      onWillPop: () async {
        _handleScreenPop();
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF6C945), Color(0xFF7BC57B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: _handleScreenPop,
                      ),
                      Expanded(
                        child: Text(
                          jobTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),

                    ],
                  ),
                ),

                if (_isLoading)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.black12,
                      color: Colors.green[700],
                    ),
                  ),

                if (_errorMessage != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: _buildErrorBanner(_errorMessage!),
                  ),


                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.green[100],
                                backgroundImage: employerAvatar.isNotEmpty
                                    ? NetworkImage(employerAvatar)
                                        as ImageProvider
                                    : null,
                                child: employerAvatar.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.green,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(

                                          child: Text(
                                            employerName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),

                                      ],
                                    ),
                                    if (employerPhone.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Phone: $employerPhone',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed:
                                    employerPhone.isNotEmpty ? () {} : null,
                                icon: const Icon(Icons.phone, size: 16),
                                label: const Text(
                                  'CONTACT',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: employerPhone.isNotEmpty
                                      ? Colors.green[700]
                                      : Colors.grey[400],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),


                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFF6C945),
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              ...List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  color: index < rating.floor()
                                      ? const Color(0xFFF6C945)
                                      : Colors.grey[300],
                                  size: 20,
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                '($reviews reviews)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: Colors.grey, thickness: 1),
                          const SizedBox(height: 20),


                          if (skillsList.isNotEmpty || description.isNotEmpty)
                            _buildJobDetailRow(
                              icon: Icons.assignment,
                              label: 'Tasks/Skills Required: ',
                              value: tasks,
                            ),
                          if (skillsList.isNotEmpty || description.isNotEmpty)
                            const SizedBox(height: 12),
                          _buildJobDetailRow(
                            icon: Icons.build,
                            label: 'Tools Provided: ',
                            value: toolsProvided ? 'Yes' : 'No',
                          ),
                          const SizedBox(height: 12),
                          _buildJobDetailRow(
                            icon: Icons.people,
                            label: 'Workers Required: ',
                            value: workersRequired.toString(),
                          ),
                          const SizedBox(height: 12),
                          _buildJobDetailRow(
                            icon: Icons.calendar_today,
                            label: 'Start Date: ',
                            value: startDate,
                          ),
                          if (endDate != null) ...[
                            const SizedBox(height: 12),
                            _buildJobDetailRow(
                              icon: Icons.event,
                              label: 'End Date: ',
                              value: endDate,
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildJobDetailRow(
                            icon: Icons.access_time,
                            label: 'Shift: ',
                            value: shift,
                          ),
                          const SizedBox(height: 12),
                          _buildJobDetailRow(
                            icon: Icons.currency_rupee,
                            label: 'Pay: ',
                            value: pay,
                          ),
                          if (advancePayment && advanceAmount > 0) ...[
                            const SizedBox(height: 12),
                            _buildJobDetailRow(
                              icon: Icons.account_balance_wallet,
                              label: 'Advance Payment: ',
                              value: '₹$advanceAmount',
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildJobDetailRow(
                            icon: Icons.hourglass_empty,
                            label: 'Duration: ',
                            value: duration,
                          ),
                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildJobDetailRow(
                              icon: Icons.home,
                              label: 'Address: ',
                              value: address,
                            ),
                          ],
                          if (safetyInstructions.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildJobDetailRow(
                              icon: Icons.security,
                              label: 'Safety Instructions: ',
                              value: safetyInstructions,
                            ),
                          ],
                          if (documentsList.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.description,
                                  size: 20,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Required Documents:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ...documentsList.map((doc) => Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, top: 2),
                                            child: Text(
                                              '• $doc',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 20),
                          const Divider(color: Colors.grey, thickness: 1),
                          const SizedBox(height: 20),


                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: GoogleMap(
                                initialCameraPosition: const CameraPosition(
                                  target: _defaultLocation,
                                  zoom: 14.0,
                                ),
                                onMapCreated: (GoogleMapController controller) {
                                  _mapController = controller;
                                },
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                zoomControlsEnabled: true,
                                mapToolbarEnabled: false,
                                markers: {
                                  const Marker(
                                    markerId: MarkerId('job_location'),
                                    position: _defaultLocation,
                                    infoWindow: InfoWindow(
                                      title: 'Job Location',
                                    ),
                                  ),
                                  if (_currentLocation != null)
                                    Marker(
                                      markerId: const MarkerId('current_location'),
                                      position: _currentLocation!,
                                      infoWindow: const InfoWindow(
                                        title: 'Your Current Location',
                                      ),
                                    ),
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),


                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isApplied
                                      ? null
                                      : () => _handleApplyTap(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isApplied
                                        ? Colors.grey[400]
                                        : Colors.green[800],
                                    foregroundColor: isApplied
                                        ? Colors.black54
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isApplied ? 'Already Applied' : 'Apply',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        isApplied
                                            ? Icons.check_circle_outline
                                            : Icons.arrow_forward,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      _isOpeningChat ? null : _handleMessageTap,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF6C945),
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Flexible(
                                        child: Text(
                                          'Message Employer',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Safety Note
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.yellow[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.yellow[200]!),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Safety Note:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        documentsList.isNotEmpty
                                            ? 'Always verify employer details before starting work. Required Documents: ${documentsList.join(', ')}'
                                            : 'Always verify employer details before starting work. Required Documents: ID Proof, Address Proof',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleApplyTap() async {
    final jobId = _extractJobId(_jobData) ?? '';
    if (jobId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final residentId = _extractResidentId(_jobData) ?? '';
    if (residentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resident information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ApplyForJobScreen(jobId: jobId, residentId: residentId),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _jobData = {..._jobData, 'applied': true};
        _hasApplied = true;
      });
    }
  }

  Future<void> _handleMessageTap() async {
    final employerData = _extractEmployerData(_jobData);
    final String employerName = employerData?['name']?.toString() ?? 'Employer';
    final String employerId = employerData?['id']?.toString() ?? '';

    if (employerId.isEmpty) {
      _showSnack('Employer details not available');
      return;
    }

    setState(() {
      _isOpeningChat = true;
    });

    try {
      final profile = await _authService.getUserProfile();
      final identity = _extractCurrentUserIdentity(profile);

      if (identity == null || identity['id'] == null) {
        throw Exception('Unable to determine your user details');
      }

      final myId = identity['id']!;
      final myName = identity['name'] ?? 'You';
      final chatId = _buildChatId(myId, employerId);

      final employerAvatar =
          _buildAvatarUrl(employerData?['avatar']?.toString());

      await Future.wait([
        _chatService.upsertUserProfile(
          userId: myId,
          name: myName,
        ),
        _chatService.upsertUserProfile(
          userId: employerId,
          name: employerName,
          imageUrl: employerAvatar,
        ),
      ]);

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            myId: myId,
            myName: myName,
            otherName: employerName,
            otherId: employerId,
          ),
        ),
      );
    } catch (e) {
      _showSnack('Unable to open chat: ${_friendlyError(e)}');
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningChat = false;
        });
      }
    }
  }

  void _handleScreenPop() {
    Navigator.pop(context, _hasApplied ? true : null);
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
          IconButton(
            onPressed: _fetchJobDetails,
            icon: const Icon(Icons.refresh, size: 18),
            color: Colors.red,
            tooltip: 'Retry',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Map<String, String?>? _extractCurrentUserIdentity(
      Map<String, dynamic> profile) {
    final candidates = <Map<String, dynamic>>[];

    void addCandidate(dynamic value) {
      if (value is Map<String, dynamic>) {
        candidates.add(value);
      }
    }

    addCandidate(profile['user']);
    addCandidate(profile['data']);
    if (profile['data'] is Map<String, dynamic>) {
      addCandidate((profile['data'] as Map<String, dynamic>)['user']);
    }
    addCandidate(profile);

    for (final candidate in candidates) {
      final idValue = candidate['id'];
      if (idValue == null) continue;
      final id = idValue.toString();
      if (id.isEmpty) continue;
      final name = candidate['name']?.toString();
      return {'id': id, 'name': name};
    }

    return null;
  }

  String _buildChatId(String firstId, String secondId) {
    final ids = [firstId, secondId]..sort();
    return '${ids.first}_${ids.last}';
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _friendlyError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  Widget _buildJobDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.black54,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              children: [
                if (label.isNotEmpty)
                  TextSpan(
                    text: label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '18 Sep 2025';

    try {
      String dateStr = dateValue.toString();
      DateTime date = DateTime.parse(dateStr);

      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      String day = date.day.toString();
      String month = months[date.month - 1];
      String year = date.year.toString();

      return '$day $month $year';
    } catch (e) {
      return dateValue.toString();
    }
  }

  String _formatPayType(String payType) {
    switch (payType.toLowerCase()) {
      case 'per_day':
      case 'per day':
        return 'per day';
      case 'per_hour':
      case 'per hour':
        return 'per hour';
      case 'fixed':
        return 'fixed';
      default:
        return payType;
    }
  }

  String _buildAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final sanitizedPath = path.startsWith('/') ? path.substring(1) : path;
    final base = 'https://legacycarry.com';
    if (sanitizedPath.startsWith('uploads/')) {
      return '$base/$sanitizedPath';
    }
    return '$base/uploads/$sanitizedPath';
  }
}
