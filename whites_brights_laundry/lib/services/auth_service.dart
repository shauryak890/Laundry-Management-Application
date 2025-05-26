import 'package:flutter/material.dart';

// Mock class for User in development mode
class MockUser {
  final String uid;
  final String phoneNumber;
  final String displayName;
  
  MockUser({
    required this.uid,
    required this.phoneNumber,
    this.displayName = 'User',
  });
}

// Mock class for UserCredential in development mode
class MockUserCredential {
  final MockUser user;
  
  MockUserCredential({required this.user});
}

// Development-only mock implementation of AuthService
class AuthService {
  // Mock user
  MockUser? _currentUser;
  
  // Stream controller for auth state changes
  final _authStateController = Stream<MockUser?>.value(null);
  
  // Stream to listen to auth state changes
  Stream<MockUser?> get authStateChanges => _authStateController;
  
  // Current user
  MockUser? get currentUser => _currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;
  
  // Set mock user for development
  void setMockUser(MockUser user) {
    _currentUser = user;
  }
  
  // Mock phone authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function onVerificationCompleted,
    required Function onVerificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Always succeed in dev mode, send a mock verification ID
      final verificationId = 'mock-verification-id-${DateTime.now().millisecondsSinceEpoch}';
      codeSent(verificationId, null);
      
    } catch (e) {
      debugPrint('Error in mock verifyPhoneNumber: $e');
      rethrow;
    }
  }
  
  // Mock sign in with credential
  Future<MockUserCredential> signInWithCredential(String verificationId, String smsCode) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a mock user
      final user = MockUser(
        uid: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: '+1234567890',
      );
      
      _currentUser = user;
      
      return MockUserCredential(user: user);
    } catch (e) {
      debugPrint('Error in mock signInWithCredential: $e');
      rethrow;
    }
  }
  
  // Mock sign out
  Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentUser = null;
    } catch (e) {
      debugPrint('Error in mock signOut: $e');
      rethrow;
    }
  }
}
