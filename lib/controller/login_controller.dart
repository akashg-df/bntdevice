import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/login_model.dart';

class LoginController extends ControllerMVC {
  GlobalKey<FormState> loginKey = GlobalKey<FormState>();
  LoginModel loginModel = LoginModel();

  // Validate login credentials
  String validateLoginCred() {
    if (loginKey.currentState!.validate()) {
      loginKey.currentState!.save();
      return 'pass';
    } else {
      return 'fail';
    }
  }

  // Email validation
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!value.contains('@')) {
      return "Enter a valid email";
    }
    return "pass";
  }

  // Password validation
  String? passValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return "pass";
  }

  // Call API for login
  Future<bool> loginUser() async {
    var headers = {
      'Authorization':
      'Basic YnJvYW4tY2lhcS1hcHAuY2xpZW50LmU0OGJmY2U5YjA0NzQ1OWE4OGVjYzQyZGFlZGQ1M2UzOjdlZTc1NmJjY2QzYWUwMzFlZjUzZDFhOTM4ZWJmMDdmOTA1Zjg4MTllNzdmNzliZjAyNTc5NDUxNTk0MWVjNzA=',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    var body = {
      "grant_type": "password",
      "username": loginModel.userEmail,
      "password": loginModel.userPass,
    };

    try {
      var response = await http.post(
        Uri.parse(
            "https://overtureiot.broan-nutone.com/overturev2/api/v1/ciaq/oauth/token"),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String accessToken = data['access_token'];

        // Save token in local storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);

        return true;
      } else {
        debugPrint("Login failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }
}
