import 'package:flutter/foundation.dart';
import 'package:whites_brights_laundry/services/firebase/auth_service.dart';
import 'package:whites_brights_laundry/services/firebase/auth_service_firebase.dart';
import 'package:whites_brights_laundry/services/firebase/firestore_service.dart';
import 'package:whites_brights_laundry/services/firebase/mock_auth_service.dart';
import 'package:whites_brights_laundry/services/firebase/mock_firestore_service.dart';

/// Factory class to provide either real or mock Firebase services
class FirebaseServiceFactory {
  // Singleton pattern
  static final FirebaseServiceFactory _instance = FirebaseServiceFactory._internal();
  factory FirebaseServiceFactory() => _instance;
  FirebaseServiceFactory._internal();

  // Configuration
  bool _useMockServices = true; // Set to true for development, false for production

  // Getters
  bool get useMockServices => _useMockServices;

  // Setters
  set useMockServices(bool value) {
    _useMockServices = value;
    debugPrint('FirebaseServiceFactory: Using ${value ? 'MOCK' : 'REAL'} services');
  }

  // Get the appropriate auth service
  AuthService getAuthService() {
    if (_useMockServices) {
      return MockAuthService();
    } else {
      return AuthServiceFirebase();
    }
  }

  // Get the appropriate firestore service
  dynamic getFirestoreService() {
    if (_useMockServices) {
      return MockFirestoreService();
    } else {
      return FirestoreService();
    }
  }

  // Initialize all services
  Future<void> initializeServices() async {
    try {
      if (_useMockServices) {
        // Initialize mock services
        await MockAuthService().initialize();
        debugPrint('Mock services initialized successfully');
      } else {
        // Initialize real Firebase services
        // This will be handled by Firebase.initializeApp() in main.dart
        debugPrint('Real Firebase services will be initialized via Firebase.initializeApp()');
      }
    } catch (e) {
      debugPrint('Error initializing services: $e');
      rethrow;
    }
  }
}
