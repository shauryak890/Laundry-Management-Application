import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // For Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // For iOS simulator
  
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await _client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    
    return _processResponse(response);
  }
  
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    
    return _processResponse(response);
  }
  
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await _client.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    
    return _processResponse(response);
  }
  
  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await _client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    
    return _processResponse(response);
  }
  
  dynamic _processResponse(http.Response response) {
    debugPrint('API Response: ${response.statusCode} - ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          return decoded;
        } catch (e) {
          debugPrint('Error decoding JSON: $e');
          throw ApiException(
            statusCode: 500,
            message: 'Invalid JSON response from server',
          );
        }
      }
      return {};
    } else {
      try {
        final error = jsonDecode(response.body);
        final errorMessage = error['error'] ?? error['message'] ?? 'An unknown error occurred';
        debugPrint('API Error: ${response.statusCode} - $errorMessage');
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage,
        );
      } catch (e) {
        debugPrint('Error processing error response: $e');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Server error (${response.statusCode})',
        );
      }
    }
  }
  }

class ApiException implements Exception {
  final int statusCode;
  final String message;
  
  ApiException({required this.statusCode, required this.message});
  
  @override
  String toString() => 'ApiException: $statusCode - $message';
}
