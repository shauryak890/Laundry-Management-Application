import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:whites_brights_laundry/models/user_model.dart';
import 'package:whites_brights_laundry/services/mongodb/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _authSubscription;
  
  // Getters
  UserModel? get user => _user;
  UserModel? get currentUser => _user; // For backward compatibility
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  // Constructor
  UserProvider() {
    // Initialize
    initUserData();
    // Stream user data changes
    streamUserData();
  }
  
  // Initialize user data
  Future<void> initUserData() async {
    _setLoading(true);
    
    try {
      await _authService.initialize();
      if (_authService.isAuthenticated) {
        final userData = await _authService.getUserData();
        if (userData != null && userData.id != null && userData.id!.length == 24) {
          _user = userData;
          notifyListeners();
        } else {
          _setError('Invalid user ID');
        }
      }
    } catch (e) {
      _setError('Failed to initialize user: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Stream user data changes
  void streamUserData() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }
  
  // Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _authService.register(name, email, phoneNumber, password);
      
      if (response != null && response['user'] != null) {
        final userData = response['user'];
        if (userData['_id'] != null && userData['_id'].toString().length == 24) {
          _user = UserModel.fromJson(userData);
          notifyListeners();
          return true;
        } else {
          _setError('Registration failed');
          return false;
        }
      } else {
        _setError('Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _authService.login(email, password);
      
      if (response != null && response['user'] != null) {
        final userData = response['user'];
        if (userData['_id'] != null && userData['_id'].toString().length == 24) {
          _user = UserModel.fromJson(userData);
          notifyListeners();
          return true;
        } else {
          _setError('Login failed');
          return false;
        }
      } else {
        _setError('Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Logout user
  Future<bool> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    
    try {
      _user = await _authService.updateUserData(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Alias for legacy UI compatibility
  Future<bool> updateUser(UserModel updatedUser) async {
    return await updateUserProfile(
      name: updatedUser.name,
      email: updatedUser.email,
      phoneNumber: updatedUser.phoneNumber,
    );
  }

  // Upload profile image
  Future<bool> uploadProfileImage(String imageUrl) async {
    _setLoading(true);
    
    try {
      _user = await _authService.uploadProfileImage(imageUrl);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to upload profile image: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Dispose
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
