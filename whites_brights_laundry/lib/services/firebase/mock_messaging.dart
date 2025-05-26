import 'dart:async';
import 'package:flutter/material.dart';

/// A mock implementation of FirebaseMessaging for platforms that don't support it
class FirebaseMessaging {
  // Singleton pattern
  static final FirebaseMessaging _instance = FirebaseMessaging._internal();
  static FirebaseMessaging get instance => _instance;
  FirebaseMessaging._internal();

  // Mock methods
  Future<String?> getToken() async {
    debugPrint('Mock FirebaseMessaging: getToken() called');
    return 'mock-fcm-token-12345';
  }

  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool provisional = false,
  }) async {
    debugPrint('Mock FirebaseMessaging: requestPermission() called');
    return NotificationSettings(
      authorizationStatus: AuthorizationStatus.authorized,
      alert: alert,
      badge: badge,
      sound: sound,
      provisional: provisional,
    );
  }

  Stream<String> get onTokenRefresh {
    debugPrint('Mock FirebaseMessaging: onTokenRefresh accessed');
    return Stream.value('mock-fcm-token-12345');
  }

  Future<void> subscribeToTopic(String topic) async {
    debugPrint('Mock FirebaseMessaging: subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    debugPrint('Mock FirebaseMessaging: unsubscribed from topic: $topic');
  }
}

/// Mock notification settings class
class NotificationSettings {
  final AuthorizationStatus authorizationStatus;
  final bool alert;
  final bool badge;
  final bool sound;
  final bool provisional;

  NotificationSettings({
    required this.authorizationStatus,
    required this.alert,
    required this.badge,
    required this.sound,
    required this.provisional,
  });
}

/// Mock authorization status enum
enum AuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
}
