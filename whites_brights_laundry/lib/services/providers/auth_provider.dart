import 'package:flutter/material.dart';
import '../mongodb/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String _userId = '';
  String _userEmail = '';
  String _userName = 'User';
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  // Getters
  String get userId => _userId;
  String get userEmail => _userEmail;
  String get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
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
  Future<bool> loginWithEmailPassword(String email, String password) async {
    try {
      setLoading(true);
      setError(null);
      
      final response = await _authService.login(email, password);
      
      if (response != null) {
        _userId = response['user']['_id'] ?? '';
        _userEmail = email;
        _userName = response['user']['name'] ?? 'User';
        _isLoggedIn = true;
        notifyListeners();
        
        setLoading(false);
        return true;
      } else {
        setLoading(false);
        setError('Invalid credentials. Please try again.');
        return false;
      }
    } catch (e) {
      setLoading(false);
      setError('Login failed: ${e.toString()}');
      return false;
    }
  }

  // Register with email, password, phone and name
  Future<bool> registerWithEmailPassword(String name, String email, String phone, String password) async {
    try {
      setLoading(true);
      setError(null);
      
      final response = await _authService.register(name, email, phone, password);
      
      if (response != null) {
        _userId = response['user']['_id'] ?? '';
        _userEmail = email;
        _userName = name;
        _isLoggedIn = true;
        notifyListeners();
        
        setLoading(false);
        return true;
      } else {
        setLoading(false);
        setError('Registration failed. Please try again.');
        return false;
      }
    } catch (e) {
      setLoading(false);
      setError('Registration failed: ${e.toString()}');
      return false;
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
      notifyListeners();
    } catch (e) {
      setError('Logout failed: ${e.toString()}');
    }
  }
}
