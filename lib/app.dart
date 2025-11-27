// lib/app_routes.dart
import 'package:flutter/material.dart';

// Import screens
import 'views/dashboard/home_screen.dart';
import 'views/dashboard/edit_profie.dart';
import 'views/dashboard/messages_screen.dart';
import 'views/dashboard/my_job_screen.dart';
import 'views/dashboard/search_screen.dart';
import 'views/dashboard/settings_screen.dart';

import 'views/employe/choose_language_screen.dart';
import 'views/employe/dashboard_screen.dart';
import 'views/employe/employee_home_screen.dart';
import 'views/employe/employee_register_screen.dart';
import 'views/employe/enter_otp_screen.dart';
import 'views/employe/login_screen.dart';
import 'views/employe/professional_details_screen.dart';
import 'views/employe/select_type_screen.dart';
import 'views/employe/sign_in_with_number_screen.dart';
import 'views/employe/verify.dart';

import 'views/resident/post_a_job_one.dart';
import 'views/resident/post_a_job_two.dart';
import 'views/resident/post_a_job_three.dart';
import 'views/resident/resident_dashboard_screen.dart';
import 'views/resident/resident_home_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    // Dashboard Screens
    '/home': (context) => const HomeScreen(),
    '/edit_profile': (context) => const EditProfileScreen(),
    '/messages': (context) =>  MessagesScreen(),
    '/my_jobs': (context) => const MyJobsScreen(),
    '/search': (context) => const SearchJobsScreen(),
    '/settings': (context) => const SettingsScreen(),

    // Employee Screens
    '/login': (context) => const LoginScreen(),
    '/employee_home': (context) => const EmployeeHomeScreen(),
    '/employee_register': (context) => const EmployeeRegisterScreen(),
    // '/enter_otp': (context) => const OtpVerificationScreen(phoneNumber: ),
    '/dashboard': (context) => const DashboardScreen(),
    '/choose_language': (context) => const ChooseLanguageScreen(),
    // '/professional_details': (context) => const ProfessionalDetailsScreen(name: name, email: email, phone: phone, address: address, password: password, otp: otp),
    '/select_type': (context) => const SelectTypeScreen(),
    '/sign_in_with_number': (context) => const SignInWithNumberScreen(),
    '/verify': (context) => const OtpVerificationScreen(phoneNumber: ''),

    // Resident Screens
    '/resident_home': (context) => const ResidentHomeScreen(),
    '/resident_dashboard': (context) => const ResidentDashboardScreen(),
    '/post_job_one': (context) => const PostAJobOne(),
    // '/post_job_two': (context) => const PostJobStep2Screen(jobData: jobData),
    // '/post_job_three': (context) => const PostAJobThree(jobData: jobData),
  };
}
