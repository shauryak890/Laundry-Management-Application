// This is a stub implementation for platforms where Firebase is not supported
// It provides empty implementations of Firebase classes to avoid build errors

import 'package:flutter/material.dart';

// Firebase Core stubs
class Firebase {
  static Future<void> initializeApp() async {
    debugPrint('Firebase stub: initializeApp() called');
    return;
  }
}

// Firebase Auth stubs
class FirebaseAuth {
  static final FirebaseAuth _instance = FirebaseAuth._();
  static FirebaseAuth get instance => _instance;
  FirebaseAuth._();
  
  User? get currentUser => null;
  Stream<User?> authStateChanges() => Stream.value(null);
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) {
    throw UnimplementedError('Firebase Auth not supported on this platform');
  }
}

class User {
  final String uid = 'stub-user-id';
  final String? email = 'stub@example.com';
  final String? displayName = 'Stub User';
}

class UserCredential {
  final User? user = User();
}

// Firestore stubs
class FirebaseFirestore {
  static final FirebaseFirestore _instance = FirebaseFirestore._();
  static FirebaseFirestore get instance => _instance;
  FirebaseFirestore._();
  
  CollectionReference collection(String path) {
    return CollectionReference();
  }
}

class CollectionReference {
  DocumentReference doc([String? path]) {
    return DocumentReference();
  }
  
  Stream<QuerySnapshot> snapshots() {
    return Stream.value(QuerySnapshot());
  }
  
  Future<QuerySnapshot> get() {
    return Future.value(QuerySnapshot());
  }
  
  Query where(String field, {dynamic isEqualTo}) {
    return Query();
  }
}

class Query {
  Stream<QuerySnapshot> snapshots() {
    return Stream.value(QuerySnapshot());
  }
  
  Future<QuerySnapshot> get() {
    return Future.value(QuerySnapshot());
  }
}

class DocumentReference {
  Future<void> set(Map<String, dynamic> data) async {
    debugPrint('Firebase stub: set() called with data: $data');
    return;
  }
  
  Future<void> update(Map<String, dynamic> data) async {
    debugPrint('Firebase stub: update() called with data: $data');
    return;
  }
  
  Future<DocumentSnapshot> get() {
    return Future.value(DocumentSnapshot());
  }
  
  Stream<DocumentSnapshot> snapshots() {
    return Stream.value(DocumentSnapshot());
  }
}

class DocumentSnapshot {
  bool exists = false;
  Map<String, dynamic> data() => {};
  String get id => 'stub-doc-id';
}

class QuerySnapshot {
  List<QueryDocumentSnapshot> get docs => [];
}

class QueryDocumentSnapshot {
  Map<String, dynamic> data() => {};
  String get id => 'stub-doc-id';
}

// Firebase Storage stubs
class FirebaseStorage {
  static final FirebaseStorage _instance = FirebaseStorage._();
  static FirebaseStorage get instance => _instance;
  FirebaseStorage._();
  
  Reference ref([String? path]) {
    return Reference();
  }
}

class Reference {
  Future<String> getDownloadURL() {
    return Future.value('https://example.com/stub-image.jpg');
  }
  
  UploadTask putFile(dynamic file) {
    return UploadTask();
  }
}

class UploadTask {
  Future<TaskSnapshot> get future => Future.value(TaskSnapshot());
}

class TaskSnapshot {
  Reference get ref => Reference();
}

// Firebase Messaging stubs
class FirebaseMessaging {
  static final FirebaseMessaging _instance = FirebaseMessaging._();
  static FirebaseMessaging get instance => _instance;
  FirebaseMessaging._();
  
  Future<String?> getToken() async {
    return 'stub-fcm-token';
  }
  
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool provisional = false,
  }) async {
    return NotificationSettings();
  }
}

class NotificationSettings {
  final AuthorizationStatus authorizationStatus = AuthorizationStatus.authorized;
  final bool alert = true;
  final bool badge = true;
  final bool sound = true;
  final bool provisional = false;
}

enum AuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
}
