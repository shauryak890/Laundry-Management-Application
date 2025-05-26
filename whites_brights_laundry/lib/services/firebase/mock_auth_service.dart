import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/models/user_model.dart';
import 'package:whites_brights_laundry/services/firebase/auth_service.dart';
import 'package:whites_brights_laundry/services/firebase/mock_firebase_service.dart';
import 'package:whites_brights_laundry/services/firebase/mock_firestore_service.dart';

/// A mock implementation of the Authentication service for development and testing
class MockAuthService implements AuthService {
  // Singleton pattern
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  final _mockFirebaseService = MockFirebaseService();
  final _mockFirestoreService = MockFirestoreService();

  // Mock user data
  UserModel? _currentUser;
  final _authStateController = StreamController<UserModel?>.broadcast();

  // Getters - implementing AuthService interface
  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;
  
  @override
  UserModel? get currentUser => _currentUser;
  
  @override
  String? get currentUserId => _currentUser?.id;
  
  @override
  bool get isAuthenticated => _currentUser != null;
  
  @override
  Future<UserModel?> getUserData() async {
    return _currentUser;
  }
  
  @override
  Stream<UserModel?> getUserDataStream() {
    return _authStateController.stream;
  }

  // Initialize with a default user for development
  Future<void> initialize() async {
    // Create a mock user for development
    _currentUser = UserModel(
      id: 'mock-user-id',
      name: 'Test User',
      email: 'test@example.com',
      phoneNumber: '+919876543210',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _authStateController.add(_currentUser);
    debugPrint('MockAuthService initialized with test user');
  }

  // Sign in with email and password
  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      // In a real app, we would validate credentials
      // For mock, just return the current user or create one
      if (_currentUser == null) {
        _currentUser = UserModel(
          id: 'mock-user-id',
          name: 'Test User',
          email: email,
          phoneNumber: '+919876543210',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      _authStateController.add(_currentUser);
      return _currentUser!;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email, 
    String password, 
    String name,
    String phoneNumber,
  ) async {
    try {
      // Create a new user
      _currentUser = UserModel(
        id: 'mock-user-id',
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _authStateController.add(_currentUser);
      return _currentUser!;
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  // Sign out
  @override
  Future<void> signOut() async {
    try {
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Create or update user in Firestore
  @override
  Future<UserModel> createOrUpdateUser({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Update the current user with new data
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email ?? _currentUser!.email,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        updatedAt: DateTime.now(),
      );
      
      _authStateController.add(_currentUser);
      return _currentUser!;
    } catch (e) {
      debugPrint('Error creating/updating user: $e');
      rethrow;
    }
  }

  // Update user data
  @override
  Future<void> updateUserData(UserModel user) async {
    try {
      _currentUser = user;
      _authStateController.add(_currentUser);
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }

  // Get user by ID
  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      // In a real app, we would fetch from Firestore
      // For mock, just return the current user if IDs match
      if (_currentUser?.id == userId) {
        return _currentUser;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      rethrow;
    }
  }

  // Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
