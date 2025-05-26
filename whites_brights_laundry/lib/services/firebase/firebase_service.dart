import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// A simplified mock Firebase service that works on all platforms including Windows
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._();
  static FirebaseService get instance => _instance;
  FirebaseService._();

  // Check if Firebase is supported on the current platform
  static bool get isFirebaseSupported {
    if (kIsWeb) return true;
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) return true;
    return false;
  }

  // Mock data for development
  bool _isInitialized = false;
  final Map<String, dynamic> _mockData = {};
  final _random = math.Random();

  // Initialize Firebase with platform checks
  static Future<void> initializeFirebase() async {
    debugPrint('Using mock Firebase implementation for Windows development');
    
    // Initialize mock data for development
    FirebaseService._instance._initializeMockData();
    FirebaseService._instance._isInitialized = true;
    
    debugPrint('Mock Firebase initialized successfully');
  }
  
  // Initialize mock data for development
  void _initializeMockData() {
    _mockData['users'] = {
      'mock-user-id': {
        'id': 'mock-user-id',
        'name': 'Test User',
        'email': 'test@example.com',
        'phoneNumber': '+919876543210',
        'createdAt': DateTime.now().toString(),
        'updatedAt': DateTime.now().toString(),
      }
    };
    
    _mockData['orders'] = {};
    _mockData['services'] = {};
    _mockData['addresses'] = {};
    _mockData['riders'] = {};
    
    // Add a mock user for development
    _mockData['currentUser'] = {
      'uid': 'mock-user-id',
      'email': 'test@example.com',
      'displayName': 'Test User',
    };
    
    debugPrint('Mock data initialized for development');
  }

  // Mock auth service
  MockAuth get auth {
    _checkInitialized();
    return MockAuth(_mockData);
  }

  // Mock firestore service
  MockFirestore get firestore {
    _checkInitialized();
    return MockFirestore(_mockData);
  }

  // Mock messaging service
  MockMessaging get messaging {
    _checkInitialized();
    return MockMessaging();
  }

  // Mock storage service
  MockStorage get storage {
    _checkInitialized();
    return MockStorage();
  }

  // Check if Firebase is initialized
  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call initializeFirebase() first.');
    }
  }

  // Request notification permissions with mock implementation
  Future<void> requestNotificationPermissions() async {
    if (!_isInitialized) {
      debugPrint('Firebase not initialized. Cannot request notification permissions.');
      return;
    }
    
    debugPrint('Mock: Notification permissions granted automatically for development');
  }

  // Get current user ID
  String? get currentUserId {
    if (!_isInitialized) return null;
    return _mockData['currentUser']?['uid'];
  }

  // Check if user is logged in
  bool get isUserLoggedIn {
    if (!_isInitialized) return false;
    return _mockData['currentUser'] != null;
  }
}

// Mock Auth implementation
class MockAuth {
  final Map<String, dynamic> _mockData;
  
  MockAuth(this._mockData);
  
  dynamic get currentUser => _mockData['currentUser'];
  
  Stream<dynamic> authStateChanges() {
    return Stream.value(currentUser);
  }
  
  Future<dynamic> signInWithEmailAndPassword({required String email, required String password}) async {
    debugPrint('Mock: signInWithEmailAndPassword called with $email');
    return {'user': currentUser};
  }
  
  Future<dynamic> createUserWithEmailAndPassword({required String email, required String password}) async {
    debugPrint('Mock: createUserWithEmailAndPassword called with $email');
    return {'user': currentUser};
  }
  
  Future<void> signOut() async {
    debugPrint('Mock: signOut called');
  }
}

// Mock Firestore implementation
class MockFirestore {
  final Map<String, dynamic> _mockData;
  
  MockFirestore(this._mockData);
  
  MockCollection collection(String path) {
    if (!_mockData.containsKey(path)) {
      _mockData[path] = {};
    }
    return MockCollection(_mockData, path);
  }
}

class MockCollection {
  final Map<String, dynamic> _mockData;
  final String _collectionPath;
  
  MockCollection(this._mockData, this._collectionPath);
  
  MockDocumentReference doc([String? path]) {
    return MockDocumentReference(_mockData, _collectionPath, path ?? 'mock-id');
  }
  
  MockQuery where(String field, {dynamic isEqualTo}) {
    return MockQuery(_mockData, _collectionPath, field, isEqualTo);
  }
  
  Future<MockQuerySnapshot> get() async {
    return MockQuerySnapshot(_mockData, _collectionPath);
  }
  
  Stream<MockQuerySnapshot> snapshots() {
    return Stream.value(MockQuerySnapshot(_mockData, _collectionPath));
  }
}

class MockQuery {
  final Map<String, dynamic> _mockData;
  final String _collectionPath;
  final String _field;
  final dynamic _isEqualTo;
  
  MockQuery(this._mockData, this._collectionPath, this._field, this._isEqualTo);
  
  Future<MockQuerySnapshot> get() async {
    return MockQuerySnapshot(_mockData, _collectionPath, _field, _isEqualTo);
  }
  
  Stream<MockQuerySnapshot> snapshots() {
    return Stream.value(MockQuerySnapshot(_mockData, _collectionPath, _field, _isEqualTo));
  }
}

class MockDocumentReference {
  final Map<String, dynamic> _mockData;
  final String _collectionPath;
  final String _docId;
  
  MockDocumentReference(this._mockData, this._collectionPath, this._docId);
  
  Future<void> set(Map<String, dynamic> data) async {
    if (!_mockData.containsKey(_collectionPath)) {
      _mockData[_collectionPath] = {};
    }
    _mockData[_collectionPath][_docId] = data;
    debugPrint('Mock: set $_collectionPath/$_docId with data');
  }
  
  Future<void> update(Map<String, dynamic> data) async {
    if (_mockData.containsKey(_collectionPath) && 
        _mockData[_collectionPath].containsKey(_docId)) {
      _mockData[_collectionPath][_docId].addAll(data);
      debugPrint('Mock: update $_collectionPath/$_docId with data');
    }
  }
  
  Future<MockDocumentSnapshot> get() async {
    return MockDocumentSnapshot(_mockData, _collectionPath, _docId);
  }
  
  Stream<MockDocumentSnapshot> snapshots() {
    return Stream.value(MockDocumentSnapshot(_mockData, _collectionPath, _docId));
  }
}

class MockDocumentSnapshot {
  final Map<String, dynamic> _mockData;
  final String _collectionPath;
  final String _docId;
  
  MockDocumentSnapshot(this._mockData, this._collectionPath, this._docId);
  
  bool get exists {
    return _mockData.containsKey(_collectionPath) && 
           _mockData[_collectionPath].containsKey(_docId);
  }
  
  Map<String, dynamic> data() {
    if (exists) {
      return Map<String, dynamic>.from(_mockData[_collectionPath][_docId]);
    }
    return {};
  }
  
  String get id => _docId;
}

class MockQuerySnapshot {
  final Map<String, dynamic> _mockData;
  final String _collectionPath;
  final String? _field;
  final dynamic _isEqualTo;
  
  MockQuerySnapshot(this._mockData, this._collectionPath, [this._field, this._isEqualTo]);
  
  List<MockQueryDocumentSnapshot> get docs {
    if (!_mockData.containsKey(_collectionPath)) {
      return [];
    }
    
    final collection = _mockData[_collectionPath] as Map<String, dynamic>;
    
    if (_field != null && _isEqualTo != null) {
      // Filter by field
      return collection.entries
          .where((entry) => entry.value[_field] == _isEqualTo)
          .map((entry) => MockQueryDocumentSnapshot(entry.key, entry.value))
          .toList();
    } else {
      // Return all documents
      return collection.entries
          .map((entry) => MockQueryDocumentSnapshot(entry.key, entry.value))
          .toList();
    }
  }
}

class MockQueryDocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;
  
  MockQueryDocumentSnapshot(this._id, this._data);
  
  String get id => _id;
  
  Map<String, dynamic> data() => Map<String, dynamic>.from(_data);
}

// Mock Messaging implementation
class MockMessaging {
  Future<String> getToken() async {
    return 'mock-fcm-token';
  }
  
  Future<Map<String, dynamic>> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool provisional = false,
  }) async {
    return {'authorizationStatus': 'authorized'};
  }
}

// Mock Storage implementation
class MockStorage {
  MockReference ref([String? path]) {
    return MockReference(path ?? 'default');
  }
}

class MockReference {
  final String _path;
  
  MockReference(this._path);
  
  Future<String> getDownloadURL() async {
    return 'https://example.com/mock-image.jpg';
  }
  
  MockUploadTask putFile(dynamic file) {
    debugPrint('Mock: putFile called for path: $_path');
    return MockUploadTask();
  }
}

class MockUploadTask {
  Future<MockTaskSnapshot> get future async => MockTaskSnapshot();
}

class MockTaskSnapshot {
  MockReference get ref => MockReference('default');
}
