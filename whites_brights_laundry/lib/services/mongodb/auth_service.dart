import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:whites_brights_laundry/models/user_model.dart';
import 'package:whites_brights_laundry/services/mongodb/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // Current user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  
  // Auth state controller
  final _authStateController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get authStateChanges => _authStateController.stream;
  
  // Check if user is authenticated
  bool get isAuthenticated => _apiService.isAuthenticated;
  
  // Get current user ID
  String? get currentUserId => _currentUser?.id;
  
  // Initialize auth service
  Future<void> initialize() async {
    await _apiService.initialize();
    if (_apiService.isAuthenticated) {
      await _refreshCurrentUser();
    }
  }
  
  // Register new user with all required parameters
  Future<Map<String, dynamic>?> register(String name, String email, String phoneNumber, String password) async {
    try {
      final response = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      });
      
      if (response == null) return null;
      
      // Set the auth token
      if (response['token'] != null) {
        await _apiService.setAuthToken(response['token']);
      }
      
      // Create user model from response
      if (response['user'] != null) {
        _currentUser = UserModel.fromJson(response['user']);
        // Notify listeners about auth state change
        _authStateController.add(_currentUser);
      }
      
      return response;
    } catch (e) {
      debugPrint('Registration error: $e');
      return null;
    }
  }
  
  // Login user with simplified parameters
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      if (response == null) return null;
      
      // Set the auth token
      if (response['token'] != null) {
        await _apiService.setAuthToken(response['token']);
      }
      
      // Create user model from response
      if (response['user'] != null) {
        _currentUser = UserModel.fromJson(response['user']);
        // Notify listeners about auth state change
        _authStateController.add(_currentUser);
      }
      
      return response;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      await _apiService.get('/auth/logout');
      
      // Clear the auth token
      await _apiService.clearAuthToken();
      
      // Clear current user
      _currentUser = null;
      
      // Notify listeners about auth state change
      _authStateController.add(null);
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    }
  }
  
  // Get current user data
  Future<UserModel?> getUserData() async {
    if (!_apiService.isAuthenticated) return null;
    
    try {
      final response = await _apiService.get('/auth/me');
      
      // Create user model from response
      _currentUser = UserModel.fromJson(response['data']);
      
      // Notify listeners about auth state change
      _authStateController.add(_currentUser);
      
      return _currentUser;
    } catch (e) {
      debugPrint('Get user data error: $e');
      return null;
    }
  }
  
  // Update user data
  Future<UserModel> updateUserData({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiService.put('/users/profile', {
        'name': name,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      });
      
      // Create user model from response
      _currentUser = UserModel.fromJson(response['data']);
      
      // Notify listeners about auth state change
      _authStateController.add(_currentUser);
      
      return _currentUser!;
    } catch (e) {
      debugPrint('Update user data error: $e');
      rethrow;
    }
  }
  
  // Upload profile image
  Future<UserModel> uploadProfileImage(String imageUrl) async {
    try {
      final response = await _apiService.put('/users/profile/image', {
        'profileImageUrl': imageUrl,
      });
      
      // Create user model from response
      _currentUser = UserModel.fromJson(response['data']);
      
      // Notify listeners about auth state change
      _authStateController.add(_currentUser);
      
      return _currentUser!;
    } catch (e) {
      debugPrint('Upload profile image error: $e');
      rethrow;
    }
  }
  
  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId');
      return UserModel.fromJson(response['data']);
    } catch (e) {
      debugPrint('Get user by ID error: $e');
      return null;
    }
  }
  
  // Refresh current user data from API
  Future<void> _refreshCurrentUser() async {
    await getUserData();
  }
  
  // Dispose
  void dispose() {
    _authStateController.close();
  }
}
