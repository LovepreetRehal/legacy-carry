// Add this import at the top
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'viewmodels/country_view_model.dart';
import 'services/auth_service.dart';
import 'models/login_request.dart';
import 'viewmodels/send_otp_viewmodel.dart';
import 'viewmodels/resident_user_viewmodel.dart';
import 'resident/resident_dashboard_screen.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => CountryViewModel()
              ..fetchCountries()
              ..fetchSocieties()),
        ChangeNotifierProvider(create: (_) => SendOtpViewModel()),
        ChangeNotifierProvider(create: (_) => ResidentUserViewModel()),
      ],
      child: const _CompleteProfileScreen(),
    );
  }
}

class _CompleteProfileScreen extends StatefulWidget {
  const _CompleteProfileScreen();

  @override
  State<_CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<_CompleteProfileScreen> {
  static const String _createSocietyOptionLabel = "Create your own society";

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final villageController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final TextEditingController customSocietyNameController =
      TextEditingController();
  final TextEditingController customSocietyAddressController =
      TextEditingController();
  final TextEditingController customSocietyPincodeController =
      TextEditingController();

  String? selectedResidentialStatus;
  String? selectedPaymentMethod;
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  String? selectedSociety;
  String? selectedDistrict = "Patiala";
  int? selectedCountryId;
  int? selectedStateId;
  int? selectedCityId;
  int? selectedSocietyId;

  final residentialOptions = ["Society", "Individual", "Commercial"];
  final paymentOptions = ["Bank Transfer", "Cash", "UPI"];

  final TextEditingController countrySearchController = TextEditingController();
  final TextEditingController countryDisplayController =
      TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    villageController.dispose();
    countrySearchController.dispose();
    countryDisplayController.dispose();
    customSocietyNameController.dispose();
    customSocietyAddressController.dispose();
    customSocietyPincodeController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // (Deprecated) dialog-based country selection was removed in favor of inline Autocomplete.

  void handleSaveAndContinue() async {
    // Validate full name
    if (fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your full name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate email
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email address"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email address"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate phone number
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your phone number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (phoneController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please enter a valid phone number (minimum 10 digits)"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate OTP
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the 6-digit OTP"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a complete 6-digit OTP"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate address
    if (villageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your address/village"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate country
    if (selectedCountry == null || selectedCountry!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a country"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate state
    if (selectedState == null || selectedState!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a state"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate city (required for Society)
    if (selectedCity == null || selectedCity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a city"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate society selection if residential status is Society
    if (selectedResidentialStatus == "Society") {
      if (selectedSociety == null || selectedSociety!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a society"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validate residential status
    if (selectedResidentialStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select residential status"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate payment method
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a payment method"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final profileData = {
      "name": fullNameController.text.trim(), // API expects name
      "full_name": fullNameController.text.trim(), // API also expects full_name
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "password": passwordController.text.trim().isEmpty
          ? "password123" // Default password if not provided
          : passwordController.text.trim(),
      "otp": otp,
      "role": "customer", // Resident/Employer role
      "is_active": true,
      "society_id": selectedSocietyId,
      "address": villageController.text.trim(), // API expects address
      // Optional fields with defaults
      "residential_status": selectedResidentialStatus ?? "Individual",
      "country": selectedCountry ?? "India",
      "state": selectedState ?? "",
      "city": selectedCity ?? "",
      "district": selectedDistrict ?? "",
      "payment_method": selectedPaymentMethod ?? "Cash",
    };

    debugPrint("=====================================");
    debugPrint("Profile Data Map:");
    debugPrint(profileData.toString());
    debugPrint("=====================================");

    final countryViewModel =
        Provider.of<CountryViewModel>(context, listen: false);

    // Only create society if user selected "Society" residential type
    if (selectedResidentialStatus == "Society" && selectedSociety != null) {
      // Validate dependent fields
      if ((selectedCity == null || selectedCity!.isEmpty) ||
          (selectedState == null || selectedState!.isEmpty) ||
          selectedCityId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Please select State and City before choosing Society"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await countryViewModel.createSociety(
        name: selectedSociety!,
        address: villageController.text.trim(),
        city: selectedCity!,
        state: selectedState!,
        pincode: "123456", // you can make this dynamic if needed
        cityId: selectedCityId!,
      );

      if (!success) {
        // Get error message from view model
        final errorMessage =
            countryViewModel.lastSocietyError ?? "Failed to create society";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    // Create Resident User via API
    final residentViewModel =
        Provider.of<ResidentUserViewModel>(context, listen: false);

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Creating your account..."),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    await residentViewModel.createResidentUser(profileData);

    if (residentViewModel.status == ResidentUserStatus.success) {
      final response = residentViewModel.response;

      debugPrint("🔍 Full API Response: $response");

      // Try to extract token from different possible locations in the response
      String? token;
      if (response != null) {
        // Try different possible token paths
        token = response['token'] ??
            response['data']?['token'] ??
            response['data']?['user']?['token'] ??
            response['user']?['token'] ??
            response['auth_token'];
      }

      // Save token and role if found
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', 'customer');
        debugPrint(
            "✅ Token saved successfully: ${token.substring(0, token.length > 20 ? 20 : token.length)}...");

        // Verify token was saved
        final savedToken = await prefs.getString('auth_token');
        if (savedToken == null || savedToken.isEmpty) {
          debugPrint(
              "❌ ERROR: Token was not properly saved to SharedPreferences!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Account created but authentication failed. Please try logging in."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }
        debugPrint(
            "✅ Token verification - saved token exists: ${savedToken.isNotEmpty}");
      } else {
        debugPrint(
            "⚠️ Warning: No token found in response! Trying auto-login...");
        debugPrint("Response keys: ${response?.keys.toList() ?? 'null'}");

        try {
          final auth = AuthService();
          final loginResp = await auth.login(
            LoginRequest(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            ),
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', loginResp.token);
          await prefs.setString('user_role', 'customer');
          debugPrint("✅ Auto-login succeeded. Token saved.");
        } catch (e) {
          debugPrint("❌ Auto-login failed: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Account created but no auth token received. Please log in to continue."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          // Don't navigate if token is missing
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Resident Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const ResidentDashboardScreen()),
      );
    } else if (residentViewModel.status == ResidentUserStatus.error) {
      // Extract and display error message
      String errorMessage = residentViewModel.errorMessage;

      // Clean up the error message (remove "Exception: " prefix if present)
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage.isEmpty
              ? "An error occurred during registration"
              : errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _showCreateSocietyDialog(CountryViewModel viewModel) async {
    if (selectedCityId == null ||
        selectedCity == null ||
        selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select state and city before creating a society"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    customSocietyNameController.text = selectedSociety ?? '';
    customSocietyAddressController.text = villageController.text;
    customSocietyPincodeController.clear();

    bool? created;
    String? newlyCreatedName;

    bool isSubmitting = false;
    String? dialogError;

    created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text("Create Society"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: customSocietyNameController,
                      decoration: const InputDecoration(
                        labelText: "Society Name",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: customSocietyAddressController,
                      decoration: const InputDecoration(
                        labelText: "Address",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: customSocietyPincodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Pincode",
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "City: ${selectedCity!}\nState: ${selectedState!}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        dialogError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final name = customSocietyNameController.text.trim();
                          final address =
                              customSocietyAddressController.text.trim();
                          final pincode =
                              customSocietyPincodeController.text.trim();

                          if (name.isEmpty || address.isEmpty) {
                            setDialogState(() {
                              dialogError =
                                  "Name and address are required fields.";
                            });
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                            dialogError = null;
                          });

                          final success = await viewModel.createSociety(
                            name: name,
                            address: address,
                            city: selectedCity!,
                            state: selectedState!,
                            pincode: pincode.isEmpty ? "000000" : pincode,
                            cityId: selectedCityId!,
                          );

                          if (success) {
                            newlyCreatedName = name;
                            Navigator.of(dialogContext).pop(true);
                          } else {
                            setDialogState(() {
                              isSubmitting = false;
                              dialogError = viewModel.lastSocietyError ??
                                  "Failed to create society";
                            });
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );

    if (created == true) {
      await viewModel.fetchSocietiesByCity(selectedCityId!);
      Map<String, dynamic>? createdSociety;
      if (newlyCreatedName != null) {
        final match = viewModel.societies.firstWhere(
          (s) => s['name'] == newlyCreatedName,
          orElse: () => <String, dynamic>{},
        );
        if (match.isNotEmpty) {
          createdSociety = match;
        }
      }

      setState(() {
        selectedSociety = newlyCreatedName;
        selectedSocietyId =
            createdSociety != null ? createdSociety['id'] : null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Society created successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
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

                      // Phone Number Field with Send OTP button
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: "Enter Phone Number",
                                labelText: "Phone Number",
                                prefixText: "+91 ",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Builder(
                            builder: (context) {
                              final otpVm =
                                  Provider.of<SendOtpViewModel>(context);
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size(70, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: otpVm.status == OtpStatus.loading
                                    ? null
                                    : () async {
                                        if (phoneController.text.isEmpty ||
                                            phoneController.text.length < 10) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Enter valid phone number first"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        await otpVm.sendUserOtp(
                                          countryCode: "+91",
                                          phone: phoneController.text.trim(),
                                          purpose: "login",
                                        );

                                        if (otpVm.status == OtpStatus.success) {
                                          final response = otpVm.otpResponse;
                                          final message =
                                              response?['message'] ??
                                                  'OTP sent successfully';
                                          final code = response?['code'];

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "$message ${code != null ? '  $code' : ''}"),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else if (otpVm.status ==
                                            OtpStatus.error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(otpVm.errorMessage),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                child: otpVm.status == OtpStatus.loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text("Send OTP"),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // OTP Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (index) => SizedBox(
                            width: 45,
                            child: TextField(
                              controller: otpControllers[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password Field
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.lock_outline),
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

                      // Country Autocomplete (inline searchable, no dialog)
                      viewModel.isLoadingCountries &&
                              viewModel.countries.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                final query =
                                    textEditingValue.text.toLowerCase();
                                final List<String> names = viewModel.countries
                                    .map<String>(
                                        (c) => (c['name'] ?? '').toString())
                                    .toList();
                                if (query.isEmpty) return names;
                                return names.where(
                                    (n) => n.toLowerCase().contains(query));
                              },
                              onSelected: (String selection) {
                                final country = viewModel.countries
                                    .firstWhere((c) => c['name'] == selection);
                                setState(() {
                                  selectedCountry = selection;
                                  selectedCountryId = country['id'];
                                  selectedState = null;
                                  selectedCity = null;
                                });
                                viewModel.fetchStates(selectedCountryId!);
                              },
                              fieldViewBuilder: (context, controller, focusNode,
                                  onFieldSubmitted) {
                                if (selectedCountry != null &&
                                    controller.text.isEmpty) {
                                  controller.text = selectedCountry!;
                                }
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: "Country",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    hintText: "Type to search country",
                                  ),
                                );
                              },
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
                                  selectedCityId = null;
                                  selectedSociety = null;
                                  selectedSocietyId = null;
                                });
                                viewModel.clearSocieties();
                                viewModel.fetchCities(selectedStateId!);
                              },
                              decoration: const InputDecoration(
                                labelText: "State",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                      const SizedBox(height: 12),

                      // City Autocomplete (inline searchable)
                      viewModel.isLoadingCities && viewModel.cities.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                final query =
                                    textEditingValue.text.toLowerCase();
                                final List<String> names = viewModel.cities
                                    .map<String>(
                                        (c) => (c['name'] ?? '').toString())
                                    .toList();
                                if (query.isEmpty) return names;
                                return names.where(
                                    (n) => n.toLowerCase().contains(query));
                              },
                              onSelected: (String selection) {
                                final city = viewModel.cities.firstWhere(
                                  (c) => c['name'] == selection,
                                  orElse: () => <String, dynamic>{},
                                );
                                setState(() {
                                  selectedCity = selection;
                                  selectedCityId = city['id'];
                                  selectedSociety = null;
                                  selectedSocietyId = null;
                                });
                                if (selectedCityId != null) {
                                  viewModel
                                      .fetchSocietiesByCity(selectedCityId!);
                                } else {
                                  viewModel.clearSocieties();
                                }
                              },
                              fieldViewBuilder: (context, controller, focusNode,
                                  onFieldSubmitted) {
                                if (selectedCity != null &&
                                    controller.text.isEmpty) {
                                  controller.text = selectedCity!;
                                }
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: "City",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    hintText: "Type to search city",
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 12),

                      // Society Autocomplete (inline searchable)
                      viewModel.isLoadingSocieties &&
                              viewModel.societies.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                final query =
                                    textEditingValue.text.toLowerCase();
                                // Get unique society names
                                final uniqueSocieties = viewModel.societies
                                    .fold<List<Map<String, dynamic>>>(
                                  [],
                                  (uniqueList, society) {
                                    if (!uniqueList.any(
                                        (s) => s['name'] == society['name'])) {
                                      uniqueList.add(society);
                                    }
                                    return uniqueList;
                                  },
                                );
                                final List<String> filtered = uniqueSocieties
                                    .map<String>(
                                        (s) => (s['name'] ?? '').toString())
                                    .where((name) =>
                                        name.toLowerCase().contains(query))
                                    .toList();

                                if (query.isEmpty ||
                                    _createSocietyOptionLabel
                                        .toLowerCase()
                                        .contains(query)) {
                                  filtered.add(_createSocietyOptionLabel);
                                }

                                return filtered;
                              },
                              onSelected: (String selection) {
                                if (selection == _createSocietyOptionLabel) {
                                  _showCreateSocietyDialog(viewModel);
                                  return;
                                }
                                final society = viewModel.societies.firstWhere(
                                  (s) => s['name'] == selection,
                                  orElse: () => <String, dynamic>{},
                                );
                                setState(() {
                                  selectedSociety = selection;
                                  selectedSocietyId = society['id'];
                                });
                              },
                              fieldViewBuilder: (context, controller, focusNode,
                                  onFieldSubmitted) {
                                if (selectedSociety != null &&
                                    controller.text.isEmpty) {
                                  controller.text = selectedSociety!;
                                }
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: "Society",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    hintText: "Type to search society",
                                  ),
                                );
                              },
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
