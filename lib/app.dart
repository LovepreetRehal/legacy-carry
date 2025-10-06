import 'package:flutter/material.dart';
import 'views/employe/login_screen.dart';
import 'views/employe/home_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
  };
}
