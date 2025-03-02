import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String tokenPrefix = "user_token_";

  // Save a JWT token for a specific user
  static Future<void> saveUserToken(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("$tokenPrefix$email", token);
  }

  // Get a JWT token for a specific user
  static Future<String?> getUserToken(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("$tokenPrefix$email");
  }

  // Remove a JWT token when logging out
  static Future<void> removeUserToken(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("$tokenPrefix$email");
  }
}
