import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'employe/select_type_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final villageController = TextEditingController();

  String? selectedResidentialStatus;
  String? selectedPaymentMethod;

  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  List<dynamic> countries = [];
  List<dynamic> states = [];
  List<dynamic> cities = [];

  final residentialOptions = ["Society", "Individual", "Commercial"];
  final paymentOptions = ["Bank Transfer", "Cash", "UPI"];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('{{live_link}}/countries'), // 👈 Replace {{live_link}} with real link
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          countries = data;
        });
      } else {
        debugPrint("Failed to load countries: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching countries: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onCountrySelected(String? countryName) {
    setState(() {
      selectedCountry = countryName;
      selectedState = null;
      selectedCity = null;

      final country = countries.firstWhere(
            (c) => c['name'] == countryName,
        orElse: () => null,
      );

      states = country != null ? country['states'] ?? [] : [];
      cities = [];
    });
  }

  void onStateSelected(String? stateName) {
    setState(() {
      selectedState = stateName;
      selectedCity = null;

      final state = states.firstWhere(
            (s) => s['name'] == stateName,
        orElse: () => null,
      );

      cities = state != null ? state['cities'] ?? [] : [];
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    villageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5C041),
              Color(0xFF3CA349),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Complete Your Profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// Country Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCountry,
                        items: countries
                            .map((c) => DropdownMenuItem<String>(
                          value: c['name'],
                          child: Text(c['name']),
                        ))
                            .toList(),
                        onChanged: onCountrySelected,
                        decoration: const InputDecoration(
                          labelText: "Select Country",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// State Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedState,
                        items: states
                            .map((s) => DropdownMenuItem<String>(
                          value: s['name'],
                          child: Text(s['name']),
                        ))
                            .toList(),
                        onChanged: onStateSelected,
                        decoration: const InputDecoration(
                          labelText: "Select State",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// City Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCity,
                        items: cities
                            .map((c) => DropdownMenuItem<String>(
                          value: c['name'],
                          child: Text(c['name']),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedCity = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Select City",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// Residential
                      DropdownButtonFormField<String>(
                        value: selectedResidentialStatus,
                        items: residentialOptions
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedResidentialStatus = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Residential Status",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: villageController,
                        decoration: const InputDecoration(
                          labelText: "Village/Town",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedPaymentMethod,
                        items: paymentOptions
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedPaymentMethod = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Preferred Payment Method",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // You can now send the selected country/state/city to your create-user API
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const SelectTypeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Save & Continue",
                            style: TextStyle(fontSize: 16),
                          ),
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
    );
  }
}
