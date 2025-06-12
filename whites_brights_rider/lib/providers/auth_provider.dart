import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  AuthStatus _status = AuthStatus.initial;
  String? _userId;
  String? _riderId;
  String? _name;
  String? _email;
  String? _phoneNumber;
  bool _isLoading = false;
  String? _error;

  AuthProvider({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  AuthStatus get status => _status;
  String? get userId => _userId;
  String? get riderId => _riderId;
  String? get name => _name;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.getToken();
      
      if (token != null) {
        // Verify token by fetching user profile
        await _fetchUserProfile();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      await _apiService.clearToken();
      _error = 'Session expired, please login again';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Attempting login with email: $email');
      
      // Login API call
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      if (response == null || !response.containsKey('token')) {
        throw ApiException(statusCode: 400, message: 'Invalid response from server');
      }
      
      debugPrint('Login response received: ${response.toString().substring(0, response.toString().length > 100 ? 100 : response.toString().length)}...');

      // Save token
      await _apiService.setToken(response['token']);
      debugPrint('Token saved successfully');
      
      try {
        // Fetch user details
        await _fetchUserProfile();
        debugPrint('User profile fetched: userId=$_userId, name=$_name');
        
        // Check if user is a rider
        final isRider = await _validateRiderRole();
        debugPrint('User role validation result: isRider=$isRider');
        
        if (isRider) {
          _status = AuthStatus.authenticated;
          await _saveUserData(); // Make sure to save user data
          debugPrint('Authentication successful');
          notifyListeners();
          return true;
        } else {
          _error = 'Access denied. This app is for delivery partners only.';
          debugPrint('Access denied: User is not a rider');
          await logout();
          notifyListeners();
          return false;
        }
      } catch (profileError) {
        debugPrint('Error during profile fetch or validation: $profileError');
        // Even if profile fetch fails, we can still proceed with login if we have user data from login response
        if (response.containsKey('user') && response['user'] != null) {
          final userData = response['user'];
          _userId = userData['id'];
          _name = userData['name'];
          _email = userData['email'];
          _phoneNumber = userData['phoneNumber'];
          
          // Check role directly from login response
          final role = userData['role'];
          if (role == 'rider') {
            _status = AuthStatus.authenticated;
            await _saveUserData();
            debugPrint('Authentication successful using login response data');
            notifyListeners();
            return true;
          } else {
            _error = 'Access denied. This app is for delivery partners only.';
            debugPrint('Access denied: User is not a rider (from login data)');
            await logout();
            notifyListeners();
            return false;
          }
        } else {
          throw profileError; // Re-throw if we can't recover
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (e is ApiException) {
        _error = e.message;
        debugPrint('API Exception: ${e.statusCode} - ${e.message}');
      } else {
        _error = 'Login failed. Please try again.';
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.clearToken();
      _status = AuthStatus.unauthenticated;
      _userId = null;
      _riderId = null;
      _name = null;
      _email = null;
      _phoneNumber = null;
    } catch (e) {
      _error = 'Logout failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userData = await _apiService.get('/users/me');
      
      _userId = userData['_id'];
      _name = userData['name'];
      _email = userData['email'];
      _phoneNumber = userData['phoneNumber'];
      
      // Fetch rider profile data
      await _fetchRiderProfile(_userId!);
    } catch (e) {
      rethrow; // Let the caller handle this error
    }
  }
  
  Future<void> _fetchRiderProfile(String userId) async {
    try {
      // Find rider profile by user ID
      final riders = await _apiService.get('/riders');
      
      // Check if riders data exists and is a list
      if (riders != null && riders['data'] is List && (riders['data'] as List).isNotEmpty) {
        // Safe way to find rider data without null check issues
        dynamic riderData;
        try {
          riderData = (riders['data'] as List).firstWhere(
            (r) => r['userId'] == userId || 
                  (r['userId'] is Map && r['userId']['_id'] == userId),
            orElse: () => null
          );
        } catch (e) {
          debugPrint('Error finding rider in list: $e');
          riderData = null;
        }
                       
        if (riderData != null) {
          _riderId = riderData['_id'];
          debugPrint('Rider profile found: $_riderId');
        } else {
          debugPrint('No rider profile found for user ID: $userId');
        }
      } else {
        debugPrint('No riders data available or empty list');
      }
    } catch (e) {
      debugPrint('Error fetching rider profile: $e');
      // We won't throw here as the user profile was successfully fetched
    }
  }

  Future<bool> _validateRiderRole() async {
    try {
      final userData = await _apiService.get('/users/me');
      
      // Check if user role is rider
      final role = userData['role'];
      return role == 'rider';
    } catch (e) {
      debugPrint('Error validating rider role: $e');
      return false;
    }
  }

  // Save user data to local storage for persistence
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null) await prefs.setString('userId', _userId!);
    if (_riderId != null) await prefs.setString('riderId', _riderId!);
    if (_name != null) await prefs.setString('name', _name!);
    if (_email != null) await prefs.setString('email', _email!);
    if (_phoneNumber != null) await prefs.setString('phoneNumber', _phoneNumber!);
  }

  // Load user data from local storage
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _riderId = prefs.getString('riderId');
    _name = prefs.getString('name');
    _email = prefs.getString('email');
    _phoneNumber = prefs.getString('phoneNumber');
  }
}
