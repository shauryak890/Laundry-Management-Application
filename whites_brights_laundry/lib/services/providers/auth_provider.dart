import 'package:flutter/material.dart';
import '../mongodb/auth_service.dart';
import '../../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  String _userId = '';
  String _userEmail = '';
  String _userName = 'User';
  String _userRole = 'user';
  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  // Getters
  String get userId => _userId;
  String get userEmail => _userEmail;
  String get userName => _userName;
  String get userRole => _userRole;
  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _userRole == 'admin';
  
  // Development mode - set login state directly (bypass authentication)
  void setDevLoginState(bool isLoggedIn) {
    _isLoggedIn = isLoggedIn;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Login with email and password
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    debugPrint('loginUser called with email: $email');
    return loginWithEmailPassword(email, password);
  }
  
  // Keep original method for backward compatibility
  Future<Map<String, dynamic>> loginWithEmailPassword(String email, String password) async {
    try {
      setLoading(true);
      setError(null);
      
      debugPrint('Attempting to login with email: $email');
      final response = await _authService.login(email, password);
      
      if (response != null) {
        final userData = response['user'];
        _userId = userData['_id'] ?? '';
        _userEmail = email;
        _userName = userData['name'] ?? 'User';
        _userRole = userData['role'] ?? 'user';
        
        debugPrint('Login successful. User role: $_userRole');
        debugPrint('isAdmin check: ${_userRole == 'admin'}');
        
        // Create user model
        _user = UserModel.fromJson(userData);
        
        _isLoggedIn = true;
        notifyListeners();
        
        setLoading(false);
        return {'success': true};
      } else {
        setLoading(false);
        setError('Invalid credentials. Please try again.');
        return {'success': false, 'message': 'Invalid credentials'};
      }
    } catch (e) {
      setLoading(false);
      setError('Login failed: ${e.toString()}');
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  // Register with email, password, phone and name
  Future<Map<String, dynamic>> registerWithEmailPassword(String name, String email, String phone, String password) async {
    try {
      setLoading(true);
      setError(null);
      
      final response = await _authService.register(name, email, phone, password);
      
      if (response != null) {
        final userData = response['user'];
        _userId = userData['_id'] ?? '';
        _userEmail = email;
        _userName = name;
        _userRole = userData['role'] ?? 'user';
        
        // Create user model
        _user = UserModel.fromJson(userData);
        
        _isLoggedIn = true;
        notifyListeners();
        
        setLoading(false);
        return {'success': true};
      } else {
        setLoading(false);
        setError('Registration failed. Please try again.');
        return {'success': false, 'message': 'Registration failed'};
      }
    } catch (e) {
      setLoading(false);
      setError('Registration failed: ${e.toString()}');
      return {'success': false, 'message': 'Registration failed: ${e.toString()}'};
    }
  }

  // Update user profile
  void updateUserProfile({String? name}) {
    if (name != null && name.isNotEmpty) {
      _userName = name;
    }
    notifyListeners();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.logout();
      _isLoggedIn = false;
      _userId = '';
      _userEmail = '';
      _userName = 'User';
      _userRole = 'user';
      _user = null;
      notifyListeners();
    } catch (e) {
      setError('Logout failed: ${e.toString()}');
    }
  }
}
