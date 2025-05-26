import 'dart:async';
import 'package:flutter/material.dart';

// This file provides mock implementations of Firebase types
// for use on platforms where Firebase is not supported

// Firebase Auth types
class User {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  
  User({
    required this.uid, 
    this.email, 
    this.displayName,
    this.phoneNumber,
  });
}

class UserCredential {
  final User? user;
  
  UserCredential({this.user});
}

class PhoneAuthCredential {
  final String verificationId;
  final String smsCode;
  
  PhoneAuthCredential({required this.verificationId, required this.smsCode});
}

class FirebaseAuthException implements Exception {
  final String code;
  final String? message;
  
  FirebaseAuthException({required this.code, this.message});
  
  @override
  String toString() => 'FirebaseAuthException: $code - $message';
}

// Firestore types

class CollectionReference<T> {
  CollectionReference<T> limit(int n) {
    return this;
  }

  CollectionReference<T> orderBy(String field, {bool descending = false}) {
    return this;
  }
  final String path;
  CollectionReference(this.path);

  DocumentReference<T> doc([String? id]) {
    return DocumentReference<T>(id ?? 'mock-doc-id');
  }

  Future<QuerySnapshot<T>> get() async {
    return QuerySnapshot<T>([]);
  }

  Future<void> set(Map<String, dynamic> data) async {
    debugPrint('Mock set data in collection $path');
  }

  Future<void> update(Map<String, dynamic> data) async {
    debugPrint('Mock update data in collection $path');
  }

  CollectionReference<T> where(String field, {dynamic isEqualTo, dynamic isNotEqualTo, dynamic isLessThan, dynamic isGreaterThan, dynamic isLessThanOrEqualTo, dynamic isGreaterThanOrEqualTo, bool? isNull}) {
    return this;
  }

  Stream<QuerySnapshot<T>> snapshots() {
    return Stream.value(QuerySnapshot<T>([]));
  }

  WriteBatch batch() {
    return WriteBatch();
  }
}

class QuerySnapshot<T> {
  final List<DocumentSnapshot<T>> docs;
  QuerySnapshot(this.docs);
}

class WriteBatch {
  void update(DocumentReference ref, Map<String, dynamic> data) {
    debugPrint('Mock batch update for document at ${ref.path}');
  }
  void set(DocumentReference ref, Map<String, dynamic> data) {
    debugPrint('Mock batch set for document at ${ref.path}');
  }
  Future<void> commit() async {
    debugPrint('Mock batch commit');
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;
  
  GeoPoint(this.latitude, this.longitude);
}

class Timestamp {
  final int seconds;
  final int nanoseconds;
  
  Timestamp(this.seconds, this.nanoseconds);
  
  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
  
  static Timestamp fromDate(DateTime dateTime) {
    return Timestamp(dateTime.millisecondsSinceEpoch ~/ 1000, 0);
  }
  
  static Timestamp now() {
    final now = DateTime.now();
    return Timestamp(now.millisecondsSinceEpoch ~/ 1000, 0);
  }
}

// Firebase Messaging types
class RemoteMessage {
  final Map<String, dynamic>? data;
  final RemoteNotification? notification;
  
  RemoteMessage({this.data, this.notification});
}

class RemoteNotification {
  final String? title;
  final String? body;
  
  RemoteNotification({this.title, this.body});
}

class NotificationSettings {
  final AuthorizationStatus authorizationStatus;
  
  NotificationSettings({required this.authorizationStatus});
}

enum AuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
}

// Additional Firebase classes needed for mock implementation

// Firebase class
class Firebase {
  static Future<FirebaseApp> initializeApp() async {
    debugPrint('Mock Firebase.initializeApp() called');
    return FirebaseApp();
  }
}

class FirebaseApp {
  final String name = 'mock-app';
  final FirebaseOptions options = FirebaseOptions(
    apiKey: 'mock-api-key',
    appId: 'mock-app-id',
    messagingSenderId: 'mock-sender-id',
    projectId: 'mock-project-id',
  );
}

class FirebaseOptions {
  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  
  FirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
  });
}

// FirebaseMessaging class with static methods
class FirebaseMessaging {
  static final FirebaseMessaging _instance = FirebaseMessaging._internal();
  static FirebaseMessaging get instance => _instance;
  FirebaseMessaging._internal();
  
  // Mock stream controllers for Firebase events
  static final StreamController<RemoteMessage> _onMessageController = 
      StreamController<RemoteMessage>.broadcast();
  
  static final StreamController<RemoteMessage> _onMessageOpenedAppController = 
      StreamController<RemoteMessage>.broadcast();
  
  // Expose streams
  static Stream<RemoteMessage> get onMessage => _onMessageController.stream;
  static Stream<RemoteMessage> get onMessageOpenedApp => _onMessageOpenedAppController.stream;
  
  Future<String?> getToken() async {
    return 'mock-fcm-token';
  }
  
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool provisional = false,
  }) async {
    return NotificationSettings(
      authorizationStatus: AuthorizationStatus.authorized,
    );
  }
  
  Future<RemoteMessage?> getInitialMessage() async {
    return null;
  }
  
  Future<void> subscribeToTopic(String topic) async {
    debugPrint('Mock subscribed to topic: $topic');
  }
  
  Future<void> unsubscribeFromTopic(String topic) async {
    debugPrint('Mock unsubscribed from topic: $topic');
  }
}

// DocumentReference implementation for Firestore
class DocumentReference<T> {
  Future<void> delete() async {
    debugPrint('Mock delete for document at $path');
  }
  final String path;
  
  DocumentReference(this.path);
  
  Future<void> set(Map<String, dynamic> data) async {
    debugPrint('Mock set data at $path');
  }
  
  Future<void> update(Map<String, dynamic> data) async {
    debugPrint('Mock update data at $path');
  }
  
  Future<DocumentSnapshot<T>> get() async {
    return DocumentSnapshot<T>(path, {});
  }
  
  Stream<DocumentSnapshot<T>> snapshots() {
    return Stream.value(DocumentSnapshot<T>(path, {}));
  }
}

// DocumentSnapshot implementation
class DocumentSnapshot<T> {
  DocumentReference<T> get reference => DocumentReference<T>(path);
  final String path;
  final Map<String, dynamic> _data;
  
  DocumentSnapshot(this.path, this._data);
  
  bool get exists => _data.isNotEmpty;
  String get id => path.split('/').last;
  
  Map<String, dynamic> data() {
    return Map<String, dynamic>.from(_data);
  }
}
