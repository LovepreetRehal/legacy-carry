import 'package:flutter/material.dart';
import 'package:legacy_carry/views/resident/post_a_job_two.dart';
import 'package:legacy_carry/views/viewmodels/post_job_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

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

class _PostAJobOneContentState extends State<_PostAJobOneScreenContent> with WidgetsBindingObserver {

  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  GoogleMapController? _mapController;
  
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);

  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  bool _shouldRetryLocation = false;

  String jobType = 'Full Day';
  String? workersRequired;

  final List<String> workersList = List.generate(20, (index) => '${index + 1}');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
          CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
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

                // Location Map
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentLocation ?? _defaultLocation,
                            zoom: 14.0,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                            if (_currentLocation != null) {
                              controller.animateCamera(
                                CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
                              );
                            }
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          markers: _currentLocation != null
                              ? {
                                  Marker(
                                    markerId: const MarkerId('current_location'),
                                    position: _currentLocation!,
                                    infoWindow: const InfoWindow(
                                      title: 'Your Current Location',
                                    ),
                                  ),
                                }
                              : {},
                        ),
                        if (_isLoadingLocation)
                          Container(
                            color: Colors.white.withOpacity(0.7),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
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
                        jobType: jobType.toLowerCase().replaceAll(' ', '_'),

                        workersRequired: int.parse(workersRequired!),
                        skillsRequired: [],

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
