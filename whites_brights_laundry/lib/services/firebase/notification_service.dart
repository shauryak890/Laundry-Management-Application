import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_service.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Use FirebaseMessaging from our firebase_types.dart implementation
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Initialize notification channels and settings
  Future<void> initialize() async {
    // Request permission for iOS
    await _requestPermission();
    
    // Initialize local notifications
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_updates_channel',
      'Order Updates',
      description: 'Notifications for order status updates',
      importance: Importance.high,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    // For Windows, we'll use local notifications only
    // In a real app, these would be connected to Firebase
    debugPrint('Using mock Firebase Messaging for Windows');
    
    // Create a mock message for testing
    final mockMessage = RemoteMessage(
      data: {'orderId': 'mock-order-123'},
      notification: RemoteNotification(
        title: 'Welcome to Whites & Brights', 
        body: 'Your laundry app is now running on Windows'
      )
    );
    
    // Show a welcome notification
    _handleForegroundMessage(mockMessage);
    
    debugPrint('Notification service initialized');
  }
  
  // Request notification permission
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }
  
  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message in foreground! ${message.notification?.title}');
    
    // Show local notification
    if (message.notification != null) {
      final data = message.data;
      _showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'Whites & Brights',
        body: message.notification!.body ?? '',
        payload: data != null ? json.encode(data) : null,
      );
    }
  }
  
  // Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Got a message while in background! ${message.notification?.title}');
    
    // Handle navigation based on data payload
    final data = message.data;
    if (data != null && data.containsKey('orderId')) {
      // TODO: Navigate to order details screen
      debugPrint('Should navigate to order ${data['orderId']}');
    }
  }
  
  // Show local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'order_updates_channel',
      'Order Updates',
      channelDescription: 'Notifications for order status updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        
        if (data['orderId'] != null) {
          // TODO: Navigate to order details screen
          debugPrint('Notification tapped: navigate to order ${data['orderId']}');
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }
  
  // Subscribe to topic for order updates
  Future<void> subscribeToOrderUpdates(String userId) async {
    await _messaging.subscribeToTopic('order_updates_$userId');
    debugPrint('Subscribed to order updates for user $userId');
  }
  
  // Unsubscribe from topic
  Future<void> unsubscribeFromOrderUpdates(String userId) async {
    await _messaging.unsubscribeFromTopic('order_updates_$userId');
    debugPrint('Unsubscribed from order updates for user $userId');
  }
  
  // Show order status update notification (for simulating push notifications)
  Future<void> showOrderStatusNotification(OrderModel order) async {
    final title = 'Order Status Updated';
    final body = 'Your order #${order.id.substring(0, 8)} is now ${order.status}';
    
    await _showLocalNotification(
      id: order.id.hashCode,
      title: title,
      body: body,
      payload: json.encode({'orderId': order.id}),
    );
  }
}
