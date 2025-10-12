// views/login_screen.dart
import 'package:flutter/material.dart';
import 'package:legacy_carry/views/employe/select_type_screen.dart';
import 'package:legacy_carry/views/viewmodels/login_viewmodel.dart';
import 'package:legacy_carry/views/viewmodels/post_job_viewmodel.dart';
import 'package:provider/provider.dart';

import '../viewmodels/send_otp_viewmodel.dart';
import 'enter_otp_screen.dart';



class _PostAJobOne extends StatelessWidget {
  const _PostAJobOne({super.key});

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

class _PostAJobOneContentState extends State<_PostAJobOneScreenContent> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<SendOtpViewModel>(context);
    final phoneController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              'resources/image/bg_leaves.png',
              fit: BoxFit.cover,
            ),
          ),

        ],
      ),
    );
  }
}
