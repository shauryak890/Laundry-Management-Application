import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/models/user_model.dart';

/// A mock implementation of Firebase services for development and testing
class MockFirebaseService {
  // Singleton pattern
  static final MockFirebaseService _instance = MockFirebaseService._internal();
  factory MockFirebaseService() => _instance;
  MockFirebaseService._internal();

  // Mock user data
  final String _mockUserId = 'mock-user-123';
  final String _mockUserName = 'Test User';
  final String _mockUserEmail = 'test@example.com';
  final String _mockUserPhone = '+919876543210';

  // Mock authentication state
  bool _isAuthenticated = true;
  final _authStateController = StreamController<bool>.broadcast();

  // Getters
  String? get currentUserId => _isAuthenticated ? _mockUserId : null;
  bool get isAuthenticated => _isAuthenticated;
  Stream<bool> get authStateChanges => _authStateController.stream;
  
  // Mock user
  UserModel get currentUser => UserModel(
    id: _mockUserId,
    name: _mockUserName,
    email: _mockUserEmail,
    phoneNumber: _mockUserPhone,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  // Initialize the service
  Future<void> initialize() async {
    debugLog('Initializing MockFirebaseService');
    _isAuthenticated = true;
    _authStateController.add(_isAuthenticated);
  }

  // Mock sign in
  Future<UserModel> signIn({required String email, required String password}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    _isAuthenticated = true;
    _authStateController.add(_isAuthenticated);
    debugLog('User signed in: $email');
    return currentUser;
  }

  // Mock sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = false;
    _authStateController.add(_isAuthenticated);
    debugLog('User signed out');
  }

  // Mock register
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _isAuthenticated = true;
    _authStateController.add(_isAuthenticated);
    debugLog('User registered: $email');
    return currentUser;
  }

  // Mock password reset
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 700));
    debugLog('Password reset email sent to: $email');
  }

  // Mock update profile
  Future<UserModel> updateProfile({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    debugLog('User profile updated: $name');
    return currentUser;
  }

  // Mock upload profile image
  Future<String> uploadProfileImage(String filePath) async {
    await Future.delayed(const Duration(seconds: 2));
    const mockImageUrl = 'https://example.com/profile-image.jpg';
    debugLog('Profile image uploaded: $mockImageUrl');
    return mockImageUrl;
  }

  // Debug print helper
  void debugLog(String message) {
    debugPrint('MockFirebaseService: $message');
  }

  // Dispose resources
  void dispose() {
    _authStateController.close();
    debugLog('MockFirebaseService disposed');
  }
}
