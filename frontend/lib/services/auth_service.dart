import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);

      // Save token and user data
      await _saveAuthData(response['token'], response['user']);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response =
          await ApiService.register(username, email, password, role);

      // Save token and user data
      await _saveAuthData(response['token'], response['user']);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString != null) {
      final Map<String, dynamic> userJson = json.decode(userString);
      return User.fromJson(userJson);
    }

    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getCurrentUser();
    return token != null && user != null;
  }

  // Save authentication data
  Future<void> _saveAuthData(
      String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(userData));
  }

  // Validate token (optional - for enhanced security)
  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Try to fetch todos to validate token
      await ApiService.getTodos(token);
      return true;
    } catch (e) {
      // Token is invalid, logout user
      await logout();
      return false;
    }
  }
}
