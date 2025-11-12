import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = "https://overtureiot.broan-nutone.com/overturev2/api/v1/ciaq/oauth/token";

  // Login user
  Future<bool> loginUser(String username, String password) async {
    var headers = {
      'ngrok-skip-browser-warning': '1',
      'Authorization':
      'Basic YnJvYW4tY2lhcS1hcHAuY2xpZW50LmU0OGJmY2U5YjA0NzQ1OWE4OGVjYzQyZGFlZGQ1M2UzOjdlZTc1NmJjY2QzYWUwMzFlZjUzZDFhOTM4ZWJmMDdmOTA1Zjg4MTllNzdmNzliZjAyNTc5NDUxNTk0MWVjNzA=',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    var body = {
      "grant_type": "password",
      "username": username,
      "password": password,
    };

    try {
      var response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String accessToken = data['access_token'];

        // Save token locally
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);

        print("✅ Login successful. Token saved.");
        return true;
      } else {
        print("❌ Login failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error: $e");
      return false;
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Logout user
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_email');
    await prefs.remove('user_password');
    print("🚪 Logged out, token cleared.");
  }

  // New method to save user credentials
  Future<void> _saveUserCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', username);
    await prefs.setString('user_password', password);
    print("✅ User credentials saved.");
  }

}
