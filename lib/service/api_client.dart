import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  final AuthService _authService = AuthService();

  Future<dynamic> get(String url, {Map<String, String>? customHeaders}) async {
    String? token = await _authService.getToken();

    if (token == null) {
      throw Exception("No token found. Please log in first.");
    }

    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (customHeaders != null) ...customHeaders,
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed GET: ${response.statusCode} - ${response.body}");
    }
  }

  // NEW: Function to perform a GET request using a provided token (This is the missing method)
  Future<dynamic> getWithToken(String url, String token, {Map<String, String>? customHeaders}) async {
    if (token.isEmpty) {
      throw Exception("Provided token is empty.");
    }

    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (customHeaders != null) ...customHeaders,
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed GET with custom token: ${response.statusCode} - ${response.body}");
    }
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    String? token = await _authService.getToken();
    if (token == null) {
      throw Exception("No token found. Please log in first.");
    }
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed POST: ${response.statusCode} - ${response.body}");
    }
  }
}