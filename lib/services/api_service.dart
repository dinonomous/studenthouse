import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studenthouse/services/attendance_repository.dart';
import 'package:studenthouse/services/auth_storage.dart';
import 'package:studenthouse/services/user_repository.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3001/api';

  static Future<Map<String, dynamic>> fetchAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasFetchedAttendance =
        prefs.getBool("hasFetchedAttendance") ?? false;
    final String? lastUpdated = prefs.getString("attendanceLastUpdated");

    final int? userId = await UserRepository.getCurrentUserId();

    if (userId != null && hasFetchedAttendance) {
      final List<Map<String, dynamic>> localAttendance =
          await AttendanceRepository.getAttendance(userId);
      return {
        "attendance": localAttendance,
        "cached": true,
        "lastUpdated": lastUpdated,
      };
    } else {
      final String? jwtToken = await AuthStorage.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String? regNumFromResponse;
        for (var item in responseData['user']) {
          if (item.containsKey("Registration Number:")) {
            regNumFromResponse = item["Registration Number:"];
            break;
          }
        }
        if (regNumFromResponse == null) {
          throw Exception("Registration number not found in response.");
        }

        int? newUserId = await UserRepository.getUserId(regNumFromResponse);
        if (newUserId == null) {
          throw Exception("User not found in local database.");
        }

        await AttendanceRepository.updateAttendance(responseData);
        await prefs.setBool("hasFetchedAttendance", true);
        String now = DateTime.now().toIso8601String();
        await prefs.setString("attendanceLastUpdated", now);
        final List<Map<String, dynamic>> updatedAttendance =
            await AttendanceRepository.getAttendance(newUserId);
        return {
          "attendance": updatedAttendance,
          "cached": false,
          "lastUpdated": now,
        };
      } else {
        throw Exception('Failed to load attendance');
      }
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final token = data['token'];
        // Rename API email to avoid shadowing parameter.
        final apiEmail = data['email'];
        final user = data['user'];
        await AuthStorage.saveToken(token);

        // Handle user data whether it's an Iterable or a Map.
        Map<String, String> combinedUser = {};
        if (user is Iterable) {
          for (var map in user) {
            combinedUser.addAll(Map<String, String>.from(map));
          }
        } else if (user is Map) {
          combinedUser = Map<String, String>.from(user);
        } else {
          print("DEBUG: Unexpected user format: $user");
        }
        print("DEBUG: Combined user data: $combinedUser");

        // Extract the registration number and check if user exists.
        final existingUser = await UserRepository.getUserId(
          combinedUser['Registration Number'],
        );
        print("DEBUG: Existing user ID: $existingUser");

        if (existingUser == null) {
          print("DEBUG: User not found in database, creating new user.");
          await UserRepository.setUser(combinedUser, apiEmail, password);
        } else {
          print("DEBUG: User already exists in the database.");
        }

        print("DEBUG: Token: $token");
        return token;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print("DEBUG: Error during login: $e");
      return null;
    }
  }
}
