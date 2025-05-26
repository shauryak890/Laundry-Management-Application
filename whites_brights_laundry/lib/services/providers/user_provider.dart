import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/models/user_model.dart';
import 'package:whites_brights_laundry/services/firebase/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService;
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  
  // Constructor that accepts any AuthService implementation
  UserProvider({required AuthService authService}) : _authService = authService {
    // Initialize user data when provider is created
    initUserData();
    // Stream user data changes
    streamUserData();
  }
  
  // Getters
  UserModel? get user => _user;
  UserModel? get currentUser => _user; // Added for compatibility with profile_screen.dart
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  // Initialize user data from Firestore
  Future<void> initUserData() async {
    _setLoading(true);
    
    try {
      // Get user data from Firestore
      final userData = await _authService.getUserData();
      
      if (userData != null) {
        _user = userData;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to load user data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Stream user data changes
  void streamUserData() {
    _authService.getUserDataStream().listen(
      (userData) {
        if (userData != null) {
          _user = userData;
          notifyListeners();
        }
      },
      onError: (error) {
        _setError('Error streaming user data: ${error.toString()}');
      }
    );
  }
  
  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    String? email,
  }) async {
    _setLoading(true);
    
    try {
      final updatedUser = await _authService.createOrUpdateUser(
        name: name,
        phoneNumber: _user?.phoneNumber ?? '',
        email: email,
      );
      
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Update user with a complete UserModel
  Future<void> updateUser(UserModel updatedUser) async {
    _setLoading(true);
    
    try {
      // Update user in Firestore
      await _authService.updateUserData(updatedUser);
      
      // Update local user data
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update user: ${e.toString()}');
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
}
