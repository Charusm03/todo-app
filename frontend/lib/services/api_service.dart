import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class ApiService {
  // Multiple base URLs to try
  static const List<String> baseUrls = [
    'http://10.0.2.2:3000/api', // Android emulator
    'http://127.0.0.1:3000/api', // iOS simulator/localhost
    'http://192.168.1.100:3000/api', // Replace with YOUR actual IP
    'http://192.168.0.100:3000/api', // Alternative IP range
    'http://localhost:3000/api', // Localhost fallback
  ];

  static String? _workingUrl;

  static Map<String, String> _getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Find a working URL
  static Future<String> _findWorkingUrl() async {
    if (_workingUrl != null) return _workingUrl!;

    for (String baseUrl in baseUrls) {
      try {
        print('Testing connection to: $baseUrl');
        final response = await http
            .get(
              Uri.parse('$baseUrl/health'),
              headers: _getHeaders(),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          _workingUrl = baseUrl;
          print('✅ Connected successfully to: $baseUrl');
          return baseUrl;
        }
      } catch (e) {
        print('❌ Failed to connect to: $baseUrl - $e');
        continue;
      }
    }

    throw Exception('Cannot connect to any server URL. Please check:\n'
        '1. Your backend server is running on port 3000\n'
        '2. Update the IP address in baseUrls list\n'
        '3. Check your network connection');
  }

  // Make HTTP request with automatic URL detection
  static Future<http.Response> _makeRequest(
    String endpoint,
    String method, {
    Map<String, String>? headers,
    String? body,
  }) async {
    String baseUrl = await _findWorkingUrl();

    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      http.Response response;

      print('Making $method request to: $uri');

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 10));
          break;
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: body)
              .timeout(const Duration(seconds: 10));
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: body)
              .timeout(const Duration(seconds: 10));
          break;
        case 'PATCH':
          response = await http
              .patch(uri, headers: headers, body: body)
              .timeout(const Duration(seconds: 10));
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 10));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('Response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Request failed: $e');
      _workingUrl = null; // Reset so it tries again next time
      rethrow;
    }
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await _makeRequest(
        '/auth/login',
        'POST',
        headers: _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await _makeRequest(
        '/auth/register',
        'POST',
        headers: _getHeaders(),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Todo endpoints (rest of your existing code remains the same)
  static Future<List<Todo>> getTodos(String token) async {
    try {
      final response = await _makeRequest(
        '/todos',
        'GET',
        headers: _getHeaders(token: token),
      );

      final data = _handleResponse(response);
      final List<dynamic> todosJson = data['todos'] ?? [];

      return todosJson.map((json) => Todo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch todos: ${e.toString()}');
    }
  }

  static Future<Todo> createTodo(
    String token,
    String title,
    String description,
  ) async {
    try {
      final response = await _makeRequest(
        '/todos',
        'POST',
        headers: _getHeaders(token: token),
        body: json.encode({
          'title': title,
          'description': description,
        }),
      );

      final data = _handleResponse(response);
      return Todo.fromJson(data['todo']);
    } catch (e) {
      throw Exception('Failed to create todo: ${e.toString()}');
    }
  }

  static Future<Todo> updateTodo(
    String token,
    int todoId,
    String title,
    String description,
    bool completed,
  ) async {
    try {
      final response = await _makeRequest(
        '/todos/$todoId',
        'PUT',
        headers: _getHeaders(token: token),
        body: json.encode({
          'title': title,
          'description': description,
          'completed': completed,
        }),
      );

      final data = _handleResponse(response);
      return Todo.fromJson(data['todo']);
    } catch (e) {
      throw Exception('Failed to update todo: ${e.toString()}');
    }
  }

  static Future<Todo> toggleTodo(String token, int todoId) async {
    try {
      final response = await _makeRequest(
        '/todos/$todoId/toggle',
        'PATCH',
        headers: _getHeaders(token: token),
      );

      final data = _handleResponse(response);
      return Todo.fromJson(data['todo']);
    } catch (e) {
      throw Exception('Failed to toggle todo: ${e.toString()}');
    }
  }

  static Future<void> deleteTodo(String token, int todoId) async {
    try {
      final response = await _makeRequest(
        '/todos/$todoId',
        'DELETE',
        headers: _getHeaders(token: token),
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete todo: ${e.toString()}');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      String errorMessage =
          data['error'] ?? data['message'] ?? 'Unknown error occurred';
      throw Exception(errorMessage);
    }
  }
}
