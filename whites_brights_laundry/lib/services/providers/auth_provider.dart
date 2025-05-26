import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String _userPhone = '';
  String _userName = 'User';
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  String get userPhone => _userPhone;
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

  // Phone number verification
  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    try {
      setLoading(true);
      setError(null);
      
      // In a real app, we would use Firebase Auth to send OTP
      // For now, we'll simulate the process
      await Future.delayed(const Duration(seconds: 2));
      
      _userPhone = phoneNumber;
      notifyListeners();
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError('Failed to send verification code: ${e.toString()}');
      return false;
    }
  }

  // OTP verification
  Future<bool> verifyOTP(String otp) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simple validation for demo purposes - we're not actually using Firebase
      if (otp.length == 6 && int.tryParse(otp) != null) {
        // Simulate successful authentication
        await Future.delayed(const Duration(seconds: 1));
        _isLoggedIn = true;
        notifyListeners();
        
        setLoading(false);
        return true;
      } else {
        setLoading(false);
        setError('Invalid OTP. Please enter a valid 6-digit code.');
        return false;
      }
    } catch (e) {
      setLoading(false);
      setError('Failed to verify OTP: ${e.toString()}');
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
    _isLoggedIn = false;
    _userPhone = '';
    notifyListeners();
  }
}
