import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  /// Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Request notification permissions
    await _requestPermissions();
    
    // Setup message handlers
    _setupMessageHandlers();
  }
  
  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    if (kDebugMode) {
      print('Notification permission status: ${settings.authorizationStatus}');
    }
  }
  
  /// Get FCM token for this device
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }
  
  /// Setup message handlers for foreground/background
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message received: ${message.notification?.title}');
      }
      // TODO: Show local notification or in-app alert
    });
    
    // Handle when user taps notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Notification tapped: ${message.notification?.title}');
      }
      // TODO: Navigate to order details
    });
  }
  
  /// Listen for token refresh
  static void onTokenRefresh(Function(String) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }
}
