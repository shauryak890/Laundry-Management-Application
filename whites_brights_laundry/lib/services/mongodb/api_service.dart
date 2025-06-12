import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Base URL for API
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return 'http://10.0.2.2:5000/api';
  }

  // Token storage key
  static const String _tokenKey = 'auth_token';
  String? _authToken;

  // Headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Initialize and load token if available
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    debugPrint('ApiService initialized. Token exists: ${_authToken != null}');
  }

  // Set auth token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
      );
      
      return _processResponse(response);
    } catch (e) {
      debugPrint('GET request error: $e');
      rethrow;
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      return _processResponse(response);
    } catch (e) {
      debugPrint('POST request error: $e');
      rethrow;
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      return _processResponse(response);
    } catch (e) {
      debugPrint('PUT request error: $e');
      rethrow;
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
      );
      
      return _processResponse(response);
    } catch (e) {
      debugPrint('DELETE request error: $e');
      rethrow;
    }
  }

  // Process HTTP response
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      
      try {
        return jsonDecode(response.body);
      } catch (e) {
        debugPrint('Error decoding JSON response: $e');
        debugPrint('Response body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        throw Exception('Invalid response format: ${e.toString()}');
      }
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'Server Error');
      } catch (e) {
        debugPrint('Error decoding error response: $e');
        throw Exception('Server Error: Status ${response.statusCode}');
      }
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _authToken != null;
}
