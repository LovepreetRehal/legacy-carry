import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legacy_carry/views/viewmodels/send_otp_viewmodel.dart';
import 'professional_details_screen.dart';

class EmployeeRegisterScreen extends StatelessWidget {
  const EmployeeRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SendOtpViewModel(),
      child: const _EmployeeRegisterContent(),
    );
  }
}

class _EmployeeRegisterContent extends StatefulWidget {
  const _EmployeeRegisterContent();

  @override
  State<_EmployeeRegisterContent> createState() =>
      _EmployeeRegisterContentState();
}

class _EmployeeRegisterContentState extends State<_EmployeeRegisterContent> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    final otpVm = Provider.of<SendOtpViewModel>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDFB139), Color(0xFFB9AE3C), Color(0xFF3CA349)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey, // ✅ add Form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔙 Top Bar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Join As an Employee",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 📝 Form Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextFormField(
                          "Name*",
                          Icons.person_outline,
                          controller: _nameController,
                          hint: "John Doe",
                          validator: (value) =>
                          value!.isEmpty ? "Please enter your name" : null,
                        ),
                        const SizedBox(height: 12),

                        _buildTextFormField(
                          "Email Address*",
                          Icons.email_outlined,
                          controller: _emailController,
                          hint: "info@gmail.com",
                          validator: (value) {
                            if (value!.isEmpty) return "Please enter email";
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                .hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 📞 Phone with Verify
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                "Phone Number*",
                                Icons.phone_outlined,
                                controller: _phoneController,
                                hint: "+91-9876543210",
                                validator: (value) {
                                  if (value!.isEmpty)
                                    return "Enter phone number";
                                  if (value.length < 10)
                                    return "Enter valid phone number";
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
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
                                if (_phoneController.text.isEmpty ||
                                    _phoneController.text.length < 10) {
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
                                  phone:
                                  _phoneController.text.trim(),
                                  purpose: "login",
                                );

                                if (otpVm.status ==
                                    OtpStatus.success) {
                                  final response = otpVm.otpResponse;
                                  final message = response?['message'] ?? 'OTP sent successfully';
                                  final code = response?['code']; // for testing if needed

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(otpVm.errorMessage.isNotEmpty
                                          ? message+ "  "+code.toString()
                                          : message + "  "+code.toString()),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else if (otpVm.status ==
                                    OtpStatus.error) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                      Text(otpVm.errorMessage),
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
                                  : const Text("VERIFY"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 🔢 OTP fields
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                                (index) => SizedBox(
                              width: 45,
                              child: TextFormField(
                                controller: _otpControllers[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                decoration: InputDecoration(
                                  counterText: "",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) =>
                                value!.isEmpty ? "" : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildTextFormField(
                          "Current Address*",
                          Icons.location_on,
                          controller: _addressController,
                          hint: "India",
                          validator: (value) => value!.isEmpty
                              ? "Please enter address"
                              : null,
                        ),
                        const SizedBox(height: 12),

                        _buildTextFormField(
                          "Password*",
                          Icons.lock_outline,
                          controller: _passwordController,
                          hint: "Set Password",
                          obscure: true,
                          validator: (value) {
                            if (value!.isEmpty) return "Enter password";
                            if (value.length < 6)
                              return "Minimum 6 characters required";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildTextFormField(
                          "Confirm Password*",
                          Icons.lock_outline,
                          controller: _confirmPasswordController,
                          hint: "Confirm Password",
                          obscure: true,
                          validator: (value) {
                            if (value!.isEmpty)
                              return "Confirm your password";
                            if (value != _passwordController.text)
                              return "Passwords do not match";
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🚀 Next button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("NEXT"),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final otpCode = _otpControllers
                              .map((controller) => controller.text)
                              .join();

                          if (otpCode.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Enter full 6-digit OTP"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfessionalDetailsScreen(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
                                address: _addressController.text.trim(),
                                password: _passwordController.text.trim(),
                                otp: otpCode,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      String title,
      IconData icon, {
        String? hint,
        bool obscure = false,
        TextEditingController? controller,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
