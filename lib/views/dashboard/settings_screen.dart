import 'package:flutter/material.dart';
import 'package:legacy_carry/views/change_language.dart';
import 'package:legacy_carry/views/change_password_screen.dart';
import 'package:legacy_carry/views/contact_support_screen.dart';
import 'package:legacy_carry/views/dashboard/edit_profie.dart';
import 'package:legacy_carry/views/faq_screen.dart';
import 'package:legacy_carry/views/job_alerts_screen.dart';
import 'package:legacy_carry/views/manage_documents_screen.dart';
import 'package:legacy_carry/views/report_problem_screen.dart';
import 'package:legacy_carry/views/splace_screen.dart';
import 'package:legacy_carry/views/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  late Future<List<dynamic>> _paymentMethodsFuture;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _paymentMethodsFuture = _fetchPaymentMethods();
  }

  Future<List<dynamic>> _fetchPaymentMethods() async {
    try {
      final profile = await _authService.getUserProfile();
      final userId = _extractUserId(profile);
      if (userId == null) {
        throw Exception('Unable to determine user information');
      }
      _currentUserId = userId;
      return await _authService.getPaymentMethods(userId: userId);
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
      rethrow;
    }
  }

  void _refreshPaymentMethods() {
    setState(() {
      _paymentMethodsFuture = _fetchPaymentMethods();
    });
  }

  int? _extractUserId(Map<String, dynamic> profile) {
    final candidate =
        profile['user']?['id'] ?? profile['data']?['id'] ?? profile['id'];
    if (candidate == null) return null;
    return int.tryParse(candidate.toString());
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  Map<String, dynamic>? _getPrimaryMethod(List<dynamic> methods) {
    for (final method in methods) {
      final mapped = _toMap(method);
      if (mapped != null && mapped['is_primary'] == true) {
        return mapped;
      }
    }
    return methods.isNotEmpty ? _toMap(methods.first) : null;
  }

  String _inferMethodType(Map<String, dynamic>? method) {
    if (method == null) return 'METHOD';

    // First try to get from explicit type fields
    final explicitType = method['method_type'] ?? method['type'];
    if (explicitType != null &&
        explicitType.toString().toLowerCase() != 'upi') {
      return explicitType.toString().toUpperCase();
    }

    // If type is missing or incorrectly set to 'upi', infer from details
    final details = method['details'];
    if (details is Map && details.isNotEmpty) {
      if (details.containsKey('upi_id')) {
        return 'UPI';
      } else if (details.containsKey('bank_name') ||
          (details.containsKey('account_number') &&
              details.containsKey('ifsc'))) {
        return 'BANK';
      } else if (details.containsKey('card_number') ||
          details.containsKey('token') ||
          details.containsKey('last4')) {
        return 'CARD';
      } else if (details.containsKey('wallet_name') ||
          details.containsKey('wallet_number')) {
        return 'WALLET';
      }
    }

    // Fallback to explicit type or default
    return explicitType?.toString().toUpperCase() ?? 'METHOD';
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.redAccent;
    }
  }

  String _buildDetailsText(Map<String, dynamic>? method) {
    if (method == null) return 'Details unavailable';
    final masked = method['masked']?.toString();
    final details = method['details'];

    if (details is Map && details.isNotEmpty) {
      return details.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join('\n');
    }

    if (masked != null && masked.isNotEmpty) {
      return masked;
    }
    return 'Details unavailable';
  }

  Widget _buildAdditionalMethodCard(
    Map<String, dynamic> method, {
    required VoidCallback onEdit,
  }) {
    final provider = method['provider']?.toString() ?? 'Unknown provider';
    final methodType = _inferMethodType(method);
    final verificationStatus =
        method['verification_status']?.toString() ?? 'unverified';
    final detailText = _buildDetailsText(method);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$provider — $methodType',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detailText,
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${verificationStatus.toUpperCase()}',
            style: TextStyle(
              fontSize: 11,
              color: _statusColor(verificationStatus),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onEdit,
              child: const Text(
                'Edit',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDFB139), Color(0xFFB9AE3C), Color(0xFF3CA349)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  children: [
                    // IconButton(
                    //   onPressed: () => Navigator.pop(context),
                    //   icon: const Icon(Icons.arrow_back, color: Colors.white),
                    // ),
                    const Expanded(
                      child: Text(
                        'Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // to balance the back icon space
                  ],
                ),

                const SizedBox(height: 16),

                // Profile & Account Section
                const SectionTitle(title: 'Profile & Account'),
                _buildTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ));
                  },
                ),
                _buildTile(
                  icon: Icons.language,
                  title: 'Language & Region',
                  trailing: const Text(
                    'English(EN)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangeLanguageScreen(),
                        ));
                  },
                ),

                const SizedBox(height: 16),

                // Notifications Section
                const SectionTitle(title: 'Notifications'),
                _buildSwitchTile('Job Alerts', true, (val) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JobAlertsScreen(),
                      ));
                }),
                _buildSwitchTile('Message Notifications', true, (val) {}),
                _buildSwitchTile('Payment Updates', false, (val) {}),

                const SizedBox(height: 16),

                // Payout Method Section
                const SectionTitle(title: 'Payout Method'),
                _buildPayoutSection(),

                const SizedBox(height: 16),

                // Privacy & Security Section
                const SectionTitle(title: 'Privacy & Security'),
                _buildTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ));
                  },
                ),
                _buildTile(
                  icon: Icons.file_copy_outlined,
                  title: 'Manage Documents',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageDocumentsScreen(),
                        ));
                  },
                ),
                _buildTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    // Capture the SettingsScreen context
                    final settingsContext = context;
                    _showLogoutDialog(settingsContext);
                  },
                ),

                const SizedBox(height: 16),

                // Help & Support Section
                const SectionTitle(title: 'Help & Support'),
                _buildTile(
                  icon: Icons.help_outline,
                  title: 'FAQ\'s',
                  trailing: const Icon(Icons.keyboard_arrow_down),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQScreen(),
                        ));
                  },
                ),
                _buildTile(
                  icon: Icons.phone_outlined,
                  title: 'Contact Support',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactSupportScreen(),
                        ));
                  },
                ),
                _buildTile(
                  icon: Icons.report_problem_outlined,
                  title: 'Report a Problem',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportProblemScreen(),
                        ));
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[800]),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }

  Widget _payoutContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildPayoutActions({
    required bool hasLinkedMethod,
    VoidCallback? onChange,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (hasLinkedMethod)
              ElevatedButton(
                onPressed: onChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Change', style: TextStyle(fontSize: 12)),
              ),
            if (hasLinkedMethod) const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                hasLinkedMethod ? 'Add New' : 'Link Method',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onAdd,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green,
            side: const BorderSide(color: Colors.green),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child:
              const Text('+UPI +Bank Account', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildPayoutSection() {
    return FutureBuilder<List<dynamic>>(
      future: _paymentMethodsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _payoutContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Current Linked Method',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),
                Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return _payoutContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Linked Method',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unable to load payout methods right now.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  snapshot.error.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPayoutActions(
                  hasLinkedMethod: false,
                  onAdd: () => _showPaymentMethodDialog(),
                ),
              ],
            ),
          );
        }

        final methods = snapshot.data ?? [];
        if (methods.isEmpty) {
          return _payoutContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No payout methods linked yet',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add a payout method to receive your earnings securely.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                _buildPayoutActions(
                  hasLinkedMethod: false,
                  onAdd: () => _showPaymentMethodDialog(),
                ),
              ],
            ),
          );
        }

        final method = _getPrimaryMethod(methods);
        final provider = method?['provider']?.toString() ?? 'Unknown provider';
        final methodType = _inferMethodType(method);
        final verificationStatus =
            method?['verification_status']?.toString() ?? 'unverified';
        final detailsText = _buildDetailsText(method);

        final normalizedMethods = methods
            .map(_toMap)
            .where((value) => value != null)
            .cast<Map<String, dynamic>>()
            .toList();

        final otherMethods = normalizedMethods.where((m) {
          if (method == null) return true;
          final primaryId = method['id']?.toString();
          final currentId = m['id']?.toString();
          if (primaryId != null && currentId != null) {
            return primaryId != currentId;
          }
          return !identical(m, method);
        }).toList();

        return _payoutContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Linked Method',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_balance, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$provider — $methodType',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detailsText,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Status: ${verificationStatus.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _statusColor(verificationStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPayoutActions(
                hasLinkedMethod: true,
                onAdd: () => _showPaymentMethodDialog(),
                onChange: method == null
                    ? null
                    : () => _showPaymentMethodDialog(
                          existingMethod: method,
                        ),
              ),
              if (otherMethods.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Other linked methods',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                ...otherMethods.map(
                  (m) => _buildAdditionalMethodCard(
                    m,
                    onEdit: () => _showPaymentMethodDialog(existingMethod: m),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPaymentMethodDialog(
      {Map<String, dynamic>? existingMethod}) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile still loading. Please try again.'),
        ),
      );
      _refreshPaymentMethods();
      return;
    }

    final isEditing = existingMethod != null;
    final methodDetails = _toMap(existingMethod?['details']) ?? {};

    final providerController = TextEditingController(
      text: existingMethod?['provider']?.toString() ?? '',
    );
    final upiIdController = TextEditingController(
      text: methodDetails['upi_id']?.toString() ?? '',
    );
    final bankNameController = TextEditingController(
      text: methodDetails['bank_name']?.toString() ?? '',
    );
    final accountNumberController = TextEditingController(
      text: methodDetails['account_number']?.toString() ?? '',
    );
    final ifscController = TextEditingController(
      text: methodDetails['ifsc']?.toString() ?? '',
    );
    final accountHolderController = TextEditingController(
      text: methodDetails['account_holder']?.toString() ?? '',
    );
    final cardNumberController = TextEditingController(
      text: methodDetails['card_number']?.toString() ?? '',
    );
    final last4Controller = TextEditingController(
      text: methodDetails['last4']?.toString() ?? '',
    );
    final expiryController = TextEditingController(
      text: methodDetails['expiry']?.toString() ?? '',
    );
    final cardTokenController = TextEditingController(
      text: methodDetails['token']?.toString() ?? '',
    );
    final walletNameController = TextEditingController(
      text: methodDetails['wallet_name']?.toString() ?? '',
    );
    final walletNumberController = TextEditingController(
      text: methodDetails['wallet_number']?.toString() ?? '',
    );

    bool isPrimary = existingMethod?['is_primary'] == true;
    String methodType = _inferMethodType(existingMethod).toLowerCase();
    if (methodType == 'method') {
      methodType = 'upi'; // Default fallback
    }
    bool isSubmitting = false;
    String? errorMessage;
    bool useCardToken = methodDetails['token'] != null &&
        methodDetails['token'].toString().isNotEmpty;

    Future<void> closeControllers() async {
      providerController.dispose();
      upiIdController.dispose();
      bankNameController.dispose();
      accountNumberController.dispose();
      ifscController.dispose();
      accountHolderController.dispose();
      cardNumberController.dispose();
      last4Controller.dispose();
      expiryController.dispose();
      cardTokenController.dispose();
      walletNameController.dispose();
      walletNumberController.dispose();
    }

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> handleSubmit() async {
              final provider = providerController.text.trim();
              if (provider.isEmpty) {
                setState(() {
                  errorMessage = 'Provider name is required.';
                });
                return;
              }

              Map<String, dynamic> details;
              if (methodType == 'upi') {
                final upiId = upiIdController.text.trim();
                if (upiId.isEmpty) {
                  setState(() {
                    errorMessage = 'UPI ID is required.';
                  });
                  return;
                }
                details = {'upi_id': upiId};
              } else if (methodType == 'bank') {
                final bankName = bankNameController.text.trim();
                final accountNumber = accountNumberController.text.trim();
                final ifsc = ifscController.text.trim();
                if (bankName.isEmpty || accountNumber.isEmpty || ifsc.isEmpty) {
                  setState(() {
                    errorMessage =
                        'Bank name, account number and IFSC are required for bank accounts.';
                  });
                  return;
                }
                details = {
                  'bank_name': bankName,
                  'account_number': accountNumber,
                  'ifsc': ifsc,
                };
                final holder = accountHolderController.text.trim();
                if (holder.isNotEmpty) {
                  details['account_holder'] = holder;
                }
              } else if (methodType == 'card') {
                if (useCardToken) {
                  final token = cardTokenController.text.trim();
                  if (token.isEmpty) {
                    setState(() {
                      errorMessage = 'Card token is required.';
                    });
                    return;
                  }
                  details = {'token': token};
                } else {
                  final cardNumber = cardNumberController.text.trim();
                  final last4 = last4Controller.text.trim();
                  final expiry = expiryController.text.trim();
                  if (cardNumber.isEmpty || last4.isEmpty || expiry.isEmpty) {
                    setState(() {
                      errorMessage =
                          'Card number, last 4 digits, and expiry are required.';
                    });
                    return;
                  }
                  details = {
                    'card_number': cardNumber,
                    'last4': last4,
                    'expiry': expiry,
                  };
                }
              } else if (methodType == 'wallet') {
                final walletName = walletNameController.text.trim();
                final walletNumber = walletNumberController.text.trim();
                if (walletName.isEmpty || walletNumber.isEmpty) {
                  setState(() {
                    errorMessage =
                        'Wallet name and wallet number are required.';
                  });
                  return;
                }
                details = {
                  'wallet_name': walletName,
                  'wallet_number': walletNumber,
                };
              } else {
                setState(() {
                  errorMessage = 'Invalid payment method type.';
                });
                return;
              }

              Future<void> submitFuture() async {
                setState(() {
                  errorMessage = null;
                  isSubmitting = true;
                });

                try {
                  if (isEditing) {
                    final idValue = existingMethod['id'];
                    final id = idValue == null
                        ? null
                        : int.tryParse(idValue.toString());
                    if (id == null) {
                      throw Exception('Missing payout method identifier.');
                    }
                    await _authService.updatePaymentMethod(
                      userId: _currentUserId!,
                      paymentMethodId: id,
                      methodType: methodType,
                      details: details,
                      isPrimary: isPrimary,
                      provider: provider,
                    );
                  } else {
                    await _authService.addPaymentMethod(
                      userId: _currentUserId!,
                      methodType: methodType,
                      details: details,
                      isPrimary: isPrimary,
                      provider: provider,
                    );
                  }

                  if (!mounted) return;
                  Navigator.of(dialogContext).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Payout method updated successfully.'
                            : 'Payout method added successfully.',
                      ),
                    ),
                  );
                  _refreshPaymentMethods();
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString().replaceFirst('Exception: ', '');
                    isSubmitting = false;
                  });
                }
              }

              await submitFuture();
            }

            return AlertDialog(
              title: Text(
                  isEditing ? 'Update payout method' : 'Add payout method'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: methodType,
                      decoration: const InputDecoration(
                        labelText: 'Method Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'upi',
                          child: Text('UPI'),
                        ),
                        DropdownMenuItem(
                          value: 'bank',
                          child: Text('Bank Account'),
                        ),
                        DropdownMenuItem(
                          value: 'card',
                          child: Text('Card'),
                        ),
                        DropdownMenuItem(
                          value: 'wallet',
                          child: Text('Wallet'),
                        ),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() {
                                methodType = value;
                                errorMessage = null;
                                if (value == 'card') {
                                  useCardToken = false;
                                }
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: providerController,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        labelText: 'Provider',
                        hintText: methodType == 'upi'
                            ? 'e.g., Google Pay, PhonePe'
                            : methodType == 'bank'
                                ? 'e.g., SBI, HDFC'
                                : methodType == 'card'
                                    ? 'e.g., Visa, Mastercard, Razorpay'
                                    : 'e.g., Paytm Wallet',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (methodType == 'upi')
                      TextField(
                        controller: upiIdController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'UPI ID',
                          hintText: 'example@bank',
                        ),
                      )
                    else if (methodType == 'bank') ...[
                      TextField(
                        controller: bankNameController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Bank Name',
                          hintText: 'e.g., State Bank of India',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: accountHolderController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Account Holder Name (optional)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: accountNumberController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Account Number',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: ifscController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'IFSC Code',
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ] else if (methodType == 'card') ...[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Use tokenized card'),
                        value: useCardToken,
                        onChanged: isSubmitting
                            ? null
                            : (value) {
                                setState(() {
                                  useCardToken = value;
                                  errorMessage = null;
                                });
                              },
                      ),
                      const SizedBox(height: 12),
                      if (useCardToken)
                        TextField(
                          controller: cardTokenController,
                          enabled: !isSubmitting,
                          decoration: const InputDecoration(
                            labelText: 'Card Token',
                            hintText: 'tok_9f3d98df93dd',
                          ),
                        )
                      else ...[
                        TextField(
                          controller: cardNumberController,
                          enabled: !isSubmitting,
                          decoration: const InputDecoration(
                            labelText: 'Card Number',
                            hintText: '4111111111111111',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: last4Controller,
                          enabled: !isSubmitting,
                          decoration: const InputDecoration(
                            labelText: 'Last 4 Digits',
                            hintText: '1111',
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: expiryController,
                          enabled: !isSubmitting,
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date',
                            hintText: '12/27',
                          ),
                        ),
                      ],
                    ] else if (methodType == 'wallet') ...[
                      TextField(
                        controller: walletNameController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Wallet Name',
                          hintText: 'e.g., Paytm',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: walletNumberController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Wallet Number',
                          hintText: '9876543210',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Set as primary method'),
                      value: isPrimary,
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                isPrimary = value;
                              });
                            },
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () => handleSubmit(),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    await closeControllers();
  }
}

void _showLogoutDialog(BuildContext settingsContext) {
  showDialog(
    context: settingsContext,
    barrierDismissible: false, // prevent dismissing by tapping outside
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFFD4B04A), // dialog background
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to log out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {
                      // Close the logout confirmation dialog first
                      Navigator.of(dialogContext).pop();

                      // Wait a frame to ensure dialog is closed
                      await Future.delayed(const Duration(milliseconds: 50));

                      // Show loading indicator using SettingsScreen context
                      showDialog(
                        context: settingsContext,
                        barrierDismissible: false,
                        builder: (BuildContext loadingDialogContext) {
                          return const Dialog(
                            backgroundColor: Colors.transparent,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      );

                      try {
                        // Call logout API
                        final authService = AuthService();
                        await authService.logout();
                        print("✅ Logout API called successfully");
                      } catch (e) {
                        print("Error during logout API call: $e");
                        // Continue with local logout even if API fails
                      }

                      // Clear all SharedPreferences data (in case API didn't clear it)
                      try {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();
                        print("✅ SharedPreferences cleared");
                      } catch (e) {
                        print("Error clearing SharedPreferences: $e");
                      }

                      // Close loading dialog using SettingsScreen context
                      if (settingsContext.mounted) {
                        try {
                          Navigator.of(settingsContext).pop();
                          print("✅ Loading dialog closed");
                        } catch (e) {
                          print("Error closing loading dialog: $e");
                        }
                      }

                      // Small delay to ensure dialog is fully closed
                      await Future.delayed(const Duration(milliseconds: 100));

                      // Navigate to WelcomeScreen and remove all previous routes
                      if (settingsContext.mounted) {
                        print("✅ Navigating to splash screen");
                        Navigator.of(settingsContext).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const SplaceScreen()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    child: const Text(
                      'Yes , Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext)
                          .pop(); // Just close the dialog
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
