import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:3000/api'; // Change to your server IP

  // For Android emulator use: http://10.0.2.2:3000/api
  // For physical device use: http://YOUR_COMPUTER_IP:3000/api

  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    String? token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication
  static Future<Map<String, dynamic>> register(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      return {
        'success': response.statusCode == 201,
        'data': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'success': false,
        'data': {'error': 'Network error'}
      };
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      Map<String, dynamic> result = {
        'success': response.statusCode == 200,
        'data': jsonDecode(response.body),
      };

      if (result['success']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['data']['token']);
        await prefs.setString('username', result['data']['user']['username']);
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'data': {'error': 'Network error'}
      };
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
  }

  // Todos
  static Future<List<dynamic>> getTodos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createTodo(String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: await _getHeaders(),
        body: jsonEncode({'title': title, 'description': description}),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateTodo(
      int id, String title, String description, bool isCompleted) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'title': title,
          'description': description,
          'is_completed': isCompleted,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteTodo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/todos/$id'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
