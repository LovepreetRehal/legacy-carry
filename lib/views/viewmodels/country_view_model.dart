import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CountryViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];
  List<dynamic> societies = [];
  List<Map<String, dynamic>> flats = [];
  final String baseUrl = 'https://legacycarry.com/api';

  bool isLoadingCountries = false;
  bool isLoadingStates = false;
  bool isLoadingCities = false;
  bool isLoadingSocieties = false;
  bool isLoadingFlats = false;

  // Fetch countries
  Future<void> fetchCountries() async {
    isLoadingCountries = true;
    notifyListeners();

    try {
      final response =
          await http.get(Uri.parse('https://legacycarry.com/api/countries'));
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
      final url = Uri.parse('$baseUrl/countries/$countryId/states');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          states = List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          if (data['states'] is List) {
            states = List<Map<String, dynamic>>.from(data['states']);
          } else if (data['data'] is List) {
            states = List<Map<String, dynamic>>.from(data['data']);
          } else {
            debugPrint(
                '❌ Unexpected states payload for country $countryId: ${response.body}');
          }
        }
      } else {
        debugPrint(
            '❌ Failed to fetch states for $countryId: ${response.statusCode}');
      }
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
      final url = Uri.parse('$baseUrl/states/$stateId/cities');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          cities = List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          if (data['cities'] is List) {
            cities = List<Map<String, dynamic>>.from(data['cities']);
          } else if (data['data'] is List) {
            cities = List<Map<String, dynamic>>.from(data['data']);
          } else {
            debugPrint(
                '❌ Unexpected cities payload for state $stateId: ${response.body}');
          }
        }
      } else {
        debugPrint(
            '❌ Failed to fetch cities for $stateId: ${response.statusCode}');
      }
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

  Future<void> fetchSocietiesByCity(int cityId) async {
    isLoadingSocieties = true;
    societies = [];
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/societies-by-cities/$cityId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          societies = List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item)),
          );
        } else if (data is Map<String, dynamic>) {
          final payload = data['societies'] ?? data['data'];
          if (payload is List) {
            societies = List<Map<String, dynamic>>.from(
              payload.map((item) => Map<String, dynamic>.from(item)),
            );
          } else {
            debugPrint(
                '❌ Unexpected societies payload for city $cityId: ${response.body}');
          }
        }
      } else {
        debugPrint(
            '❌ Failed to fetch societies for city $cityId: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching societies for city $cityId: $e');
    }

    isLoadingSocieties = false;
    notifyListeners();
  }

  void clearSocieties() {
    societies = [];
    notifyListeners();
  }

  Future<void> fetchFlatsBySociety(int societyId) async {
    isLoadingFlats = true;
    flats = [];
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/flats-by-society/$societyId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          if (data['status'] == true && data['flats'] is List) {
            flats = List<Map<String, dynamic>>.from(
              data['flats'].map((item) => Map<String, dynamic>.from(item)),
            );
          } else {
            debugPrint(
                '❌ Unexpected flats payload for society $societyId: ${response.body}');
          }
        } else if (data is List) {
          flats = List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item)),
          );
        } else {
          debugPrint(
              '❌ Unexpected flats payload for society $societyId: ${response.body}');
        }
      } else {
        debugPrint(
            '❌ Failed to fetch flats for society $societyId: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching flats for society $societyId: $e');
    }

    isLoadingFlats = false;
    notifyListeners();
  }

  void clearFlats() {
    flats = [];
    notifyListeners();
  }

  String? _lastSocietyError;

  String? get lastSocietyError => _lastSocietyError;

  Future<bool> createSociety({
    required String name,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required int cityId,
  }) async {
    _lastSocietyError = null;
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
          'city_id': cityId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Society created successfully: ${response.body}");
        // Optionally, refresh societies list
        fetchSocieties();
        return true;
      } else {
        try {
          final errorJson = json.decode(response.body);
          _lastSocietyError =
              errorJson['message'] ?? 'Failed to create society';
          debugPrint("❌ Failed to create society: ${response.body}");
        } catch (e) {
          _lastSocietyError = 'Failed to create society';
          debugPrint("❌ Failed to create society: ${response.body}");
        }
        return false;
      }
    } catch (e) {
      _lastSocietyError = 'Network error: ${e.toString()}';
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
