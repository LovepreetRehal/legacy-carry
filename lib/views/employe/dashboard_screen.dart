import 'package:flutter/material.dart';
import 'package:legacy_carry/views/dashboard/home_screen.dart';
import 'package:legacy_carry/views/dashboard/my_job_screen.dart';
import 'package:legacy_carry/views/dashboard/search_screen.dart';

import '../dashboard/edit_profie.dart';
import '../dashboard/messages_screen.dart';
import '../dashboard/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),    // Dashboard / Home
    const SearchJobsScreen(),
    const MyJobsScreen(),
    const MessagesScreen(),
    const SettingsScreen(),
    const EditProfileScreen(),
    // const Center(child: Text("Profile Page")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDFB139), // yellow top
              Color(0xFFB9AE3C), // mid olive
              Color(0xFF3CA349), // green bottom
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: _pages[_selectedIndex], // Show selected page
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex, // track selected
        onTap: _onItemTapped,         // handle tap
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
