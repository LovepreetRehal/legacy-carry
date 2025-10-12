// Add this import at the top
import 'package:flutter/material.dart';
import 'package:legacy_carry/views/employe/dashboard_screen.dart';
import 'package:legacy_carry/views/employe/sign_in_with_number_screen.dart';
import 'package:provider/provider.dart';
import 'employe/select_type_screen.dart';
import 'viewmodels/country_view_model.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CountryViewModel()..fetchCountries()..fetchSocieties(),
      child: const _CompleteProfileScreen(),
    );
  }
}

class _CompleteProfileScreen extends StatefulWidget {
  const _CompleteProfileScreen({super.key});

  @override
  State<_CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<_CompleteProfileScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final villageController = TextEditingController();

  String? selectedResidentialStatus;
  String? selectedPaymentMethod;
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  String? selectedSociety;
  String? selectedDistrict = "Patiala";
  int? selectedCountryId;
  int? selectedStateId;

  final residentialOptions = ["Society", "Individual", "Commercial"];
  final paymentOptions = ["Bank Transfer", "Cash", "UPI"];

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    villageController.dispose();
    super.dispose();
  }

  void handleSaveAndContinue() async {
    final profileData = {
      "full_name": fullNameController.text.trim(),
      "email": emailController.text.trim(),
      "residential_status": selectedResidentialStatus,
      "country": selectedCountry,
      "state": selectedState,
      "city": selectedCity,
      "society": selectedSociety,
      "district": selectedDistrict,
      "village": villageController.text.trim(),
      "payment_method": selectedPaymentMethod,
    };

    debugPrint("=====================================");
    debugPrint("Profile Data Map:");
    debugPrint(profileData.toString());
    debugPrint("=====================================");

    final viewModel = Provider.of<CountryViewModel>(context, listen: false);

    // Only create society if user selected "Society" residential type
    if (selectedResidentialStatus == "Society" && selectedSociety != null) {
      // You can customize these values or add extra fields
      final success = await viewModel.createSociety(
        name: selectedSociety!,
        address: villageController.text.trim(),
        city: selectedCity ?? "",
        state: selectedState ?? "",
        pincode: "123456", // you can make this dynamic if needed
      );

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create society")),
        );
        return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInWithNumberScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CountryViewModel>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5C041), Color(0xFF3CA349)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                          hintText: "Enter Your Name",
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
                          hintText: "Enter Email Address",
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedResidentialStatus,
                        items: residentialOptions
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (val) => setState(() {
                          selectedResidentialStatus = val;
                        }),
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "Residential Status",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Country Dropdown
                      viewModel.isLoadingCountries && viewModel.countries.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                        value: selectedCountry,
                        isExpanded: true,
                        hint: const Text("Select Country"),
                        items: viewModel.countries.map((country) {
                          return DropdownMenuItem<String>(
                            value: country['name'],
                            child: Text(country['name']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          final country = viewModel.countries
                              .firstWhere((c) => c['name'] == val);
                          setState(() {
                            selectedCountry = val;
                            selectedCountryId = country['id'];
                            selectedState = null;
                            selectedCity = null;
                          });
                          viewModel.fetchStates(selectedCountryId!);
                        },
                        decoration: const InputDecoration(
                          labelText: "Country",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // State Dropdown
                      viewModel.isLoadingStates && viewModel.states.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                        value: selectedState,
                        isExpanded: true,
                        hint: const Text("Select State"),
                        items: viewModel.states.map((state) {
                          return DropdownMenuItem<String>(
                            value: state['name'],
                            child: Text(state['name']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          final state = viewModel.states
                              .firstWhere((s) => s['name'] == val);
                          setState(() {
                            selectedState = val;
                            selectedStateId = state['id'];
                            selectedCity = null;
                          });
                          viewModel.fetchCities(selectedStateId!);
                        },
                        decoration: const InputDecoration(
                          labelText: "State",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // City Dropdown
                      viewModel.isLoadingCities && viewModel.cities.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                        value: selectedCity,
                        isExpanded: true,
                        hint: const Text("Select City"),
                        items: viewModel.cities.map((city) {
                          return DropdownMenuItem<String>(
                            value: city['name'],
                            child: Text(city['name']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedCity = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "City",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Societies Dropdown
                      viewModel.isLoadingSocieties && viewModel.societies.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                        value: selectedSociety,
                        isExpanded: true,
                        hint: const Text("Select Society"),
                        items: viewModel.societies.map((society) {
                          return DropdownMenuItem<String>(
                            value: society['name'],
                            child: Text(society['name']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedSociety = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Society",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: villageController,
                        decoration: const InputDecoration(
                          hintText: "Enter Address",
                          labelText: "Village/Town",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedPaymentMethod,
                        isExpanded: true,
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
                          labelText: "Payment Method",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: handleSaveAndContinue,
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
