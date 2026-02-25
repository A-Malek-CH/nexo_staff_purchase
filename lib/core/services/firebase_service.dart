import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static GoRouter? _router;

  /// Set the router reference for deep-link navigation
  static void setRouter(GoRouter router) {
    _router = router;
  }

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

  /// Navigate based on notification data
  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == 'task_assigned') {
      final taskId = data['taskId'] as String?;
      if (taskId != null) {
        _router?.push('/tasks/$taskId');
      }
    } else if (type == 'order_assigned') {
      _router?.push('/orders');
    }
  }
  
  /// Setup message handlers for foreground/background
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Foreground message received: ${message.notification?.title}');
        debugPrint('Message data: ${message.data}');
      }
      // Foreground notifications are shown by FCM automatically on Android 13+;
      // additional local notification display can be added here if needed.
    });
    
    // Handle when user taps notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Notification tapped: ${message.notification?.title}');
      }
      _handleNotificationNavigation(message.data);
    });

    // Handle when app is launched from a terminated state via notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          debugPrint('App launched from notification: ${message.notification?.title}');
        }
        _handleNotificationNavigation(message.data);
      }
    });
  }
  
  /// Stream of FCM token refresh events
  /// 
  /// Token refresh occurs when:
  /// - The app deletes Instance ID
  /// - The app is restored on a new device
  /// - The user uninstalls/reinstalls the app
  /// - The user clears app data
  /// 
  /// Consumers should listen to this stream and update the token on the backend
  /// Remember to cancel the stream subscription when no longer needed
  static Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
