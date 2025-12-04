import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  /// Initialize Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      
      // Request notification permissions
      await _requestPermissions();
      
      // Setup message handlers
      _setupMessageHandlers();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing Firebase: $e');
      }
      // Don't rethrow - allow app to continue without notifications
    }
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
      debugPrint('Notification permission status: ${settings.authorizationStatus}');
    }
  }
  
  /// Get FCM token for this device
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting FCM token: $e');
      }
      return null;
    }
  }
  
  /// Setup message handlers for foreground/background
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Foreground message received: ${message.notification?.title}');
      }
      // TODO: Show local notification or in-app alert
    });
    
    // Handle when user taps notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Notification tapped: ${message.notification?.title}');
      }
      // TODO: Navigate to order details
    });
  }
  
  /// Listen for token refresh
  static void onTokenRefresh(Function(String) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }
}
