import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'providers/user_profile_provider.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  final List<String> _languages = const [
    'English',
    'Hindi',
    'Marathi',
    'Punjabi',
    'Bengali',
  ];

  final List<String> _regions = const [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
  ];

  late String _selectedLanguage;
  late String _selectedRegion;
  bool _isSaving = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languages.first;
    _selectedRegion = _regions.first;

    // Prefill from existing profile, if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<UserProfileProvider>().profileData?['user']
          as Map<String, dynamic>?;
      final currentLanguage = profile?['language']?.toString();
      final currentRegion = profile?['region']?.toString();

      setState(() {
        if (currentLanguage != null && _languages.contains(currentLanguage)) {
          _selectedLanguage = currentLanguage;
        }
        if (currentRegion != null && _regions.contains(currentRegion)) {
          _selectedRegion = currentRegion;
        }
      });
    });
  }

  Future<void> _savePreferences() async {
    if (_isSaving) return;

    try {
      setState(() {
        _isSaving = true;
      });

      final profileProvider = context.read<UserProfileProvider>();
      final user =
          profileProvider.profileData?['user'] as Map<String, dynamic>?;
      final idValue = user?['id'];
      if (idValue == null) {
        throw Exception('User ID not found. Please try again.');
      }
      final userId = int.tryParse(idValue.toString());
      if (userId == null) {
        throw Exception('Invalid user ID');
      }

      final response = await _authService.updateLanguageRegion(
        userId: userId,
        language: _selectedLanguage,
        region: _selectedRegion,
      );

      // Optionally refresh profile to keep provider in sync
      try {
        final profile = await _authService.getUserProfile();
        profileProvider.updateProfileData(profile);
      } catch (_) {}

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Language updated successfully'),
          backgroundColor: Colors.green.shade700,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Language & Region',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
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
              Color(0xFFF5C041),
              Color(0xFF3CA349),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE7C55E),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Language',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _DropdownField<String>(
                  value: _selectedLanguage,
                  items: _languages,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedLanguage = value);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Region',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _DropdownField<String>(
                  value: _selectedRegion,
                  items: _regions,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedRegion = value);
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSaving ? null : _savePreferences,
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save'),
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
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          borderRadius: BorderRadius.circular(8),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
