import 'package:flutter/material.dart';
import '../services/auth_service.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class CountryViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];
  List<dynamic> societies = [];
  final String baseUrl = 'https://legacycarry.com/api';

  bool isLoadingCountries = false;
  bool isLoadingStates = false;
  bool isLoadingCities = false;
  bool isLoadingSocieties = false;

  // Fetch countries
  Future<void> fetchCountries() async {
    isLoadingCountries = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://legacycarry.com/api/countries'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Extract the countries array
        countries = List<Map<String, dynamic>>.from(data['countries']);
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      debugPrint('❌ Error fetching countries: $e');
    }

    isLoadingCountries = false;
    notifyListeners();
  }

  // Fetch states based on country id
  Future<void> fetchStates(int countryId) async {
    isLoadingStates = true;
    states = [];
    cities = [];
    notifyListeners();

    try {
      final country = countries.firstWhere((c) => c['id'] == countryId);
      states = List<Map<String, dynamic>>.from(country['states']);
    } catch (e) {
      debugPrint('❌ Error fetching states: $e');
    }

    isLoadingStates = false;
    notifyListeners();
  }

  // Fetch cities based on state id
  Future<void> fetchCities(int stateId) async {
    isLoadingCities = true;
    cities = [];
    notifyListeners();

    try {
      final state = states.firstWhere((s) => s['id'] == stateId);
      cities = List<Map<String, dynamic>>.from(state['cities']);
    } catch (e) {
      debugPrint('❌ Error fetching cities: $e');
    }

    isLoadingCities = false;
    notifyListeners();
  }


  Future<void> fetchSocieties() async {
    isLoadingSocieties = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/societies'));
      final data = json.decode(response.body);
      societies = data['data'] ?? [];
    } catch (e) {
      debugPrint("❌ Error fetching societies: $e");
      societies = [];
    }
    isLoadingSocieties = false;
    notifyListeners();
  }

  Future<bool> createSociety({
    required String name,
    required String address,
    required String city,
    required String state,
    required String pincode,
  }) async {
    final url = Uri.parse('$baseUrl/societies-create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'address': address,
          'city': city,
          'state': state,
          'pincode': pincode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Society created successfully: ${response.body}");
        // Optionally, refresh societies list
        fetchSocieties();
        return true;
      } else {
        debugPrint("❌ Failed to create society: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Exception creating society: $e");
      return false;
    }
  }

}




// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
//
// class CountryViewModel extends ChangeNotifier {
//   final AuthService _authService = AuthService();
//
//   List<dynamic> _countries = [];
//   bool _isLoading = false;
//   List<Map<String, dynamic>> _states = [];
//   String _error = '';
//
//   List<dynamic> get countries => _countries;
//   bool get isLoading => _isLoading;
//
//   Future<void> fetchCountries() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final response = await _authService.getCountries(); // <- make sure this method exists
//       _countries = response;
//       debugPrint("✅ Countries fetched: $_countries");
//     } catch (e) {
//       debugPrint("❌ Error fetching countries: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//   Future<void> loadStates(int countryId) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final result = await _authService.getStates(countryId);
//       _states = List<Map<String, dynamic>>.from(result);
//       _error = '';
//     } catch (e) {
//       _error = e.toString();
//     }
//
//     _isLoading = false;
//     notifyListeners();
//   }
// }
//
