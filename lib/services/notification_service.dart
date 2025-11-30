import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

// Top-level function for background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static Function(Map<String, dynamic>)? _onNotificationTapCallback;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Request notification permission for Android 13+
    await Permission.notification.request();

    // Configure Firebase Messaging to show notifications in foreground
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotificationTap);

    // Handle notification tap when app was terminated
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundNotificationTap(message);
      }
    });
  }

  static Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.messageId}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // Firebase automatically shows the notification because we configured
      // setForegroundNotificationPresentationOptions above
      print('Notification displayed: ${notification.title}');
      print('Notification body: ${notification.body}');
      
      // Optional: You can also show an in-app banner using your existing packages
      // For example, using fluttertoast:
      // Fluttertoast.showToast(msg: '${notification.title}: ${notification.body}');
    }
  }

  static void _handleBackgroundNotificationTap(RemoteMessage message) {
    print('Notification tapped in background: ${message.messageId}');
    // Navigate to appropriate screen based on message data
    _navigateBasedOnNotification(message.data);
  }

  static void _onNotificationTapped(Map<String, dynamic> payload) {
    print('Notification tapped: $payload');
    // Navigate to appropriate screen based on payload
    _navigateBasedOnNotification(payload);
  }

  static void _navigateBasedOnNotification(Map<String, dynamic> data) {
    // Implement navigation logic based on notification type
    final type = data['type'];
    
    // Call the callback if set
    if (_onNotificationTapCallback != null) {
      _onNotificationTapCallback!(data);
    }
    
    switch (type) {
      case 'message':
        // Navigate to chat screen
        // Example: navigatorKey.currentState?.pushNamed('/chat', arguments: data);
        break;
      case 'like':
      case 'comment':
        // Navigate to post screen
        // Example: navigatorKey.currentState?.pushNamed('/post', arguments: data);
        break;
      case 'follow':
        // Navigate to profile screen
        // Example: navigatorKey.currentState?.pushNamed('/profile', arguments: data);
        break;
      default:
        // Navigate to notifications screen
        // Example: navigatorKey.currentState?.pushNamed('/notifications');
        break;
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // For local notifications, we'll use Fluttertoast (which you already have)
    // This is a lightweight alternative that works perfectly
    // Import at the top: import 'package:fluttertoast/fluttertoast.dart';
    
    // You can use this simple approach:
    print('Local notification: $title - $body');
    
    // Or if you want to show it as a toast:
    // Fluttertoast.showToast(
    //   msg: '$title\n$body',
    //   toastLength: Toast.LENGTH_LONG,
    //   gravity: ToastGravity.TOP,
    //   backgroundColor: Colors.black87,
    //   textColor: Colors.white,
    //   fontSize: 16.0,
    // );
  }

  static Future<void> cancelAllNotifications() async {
    // Clear FCM instance
    await _firebaseMessaging.deleteToken();
    // Get a new token
    await _firebaseMessaging.getToken();
    print('All notifications cancelled');
  }

  // Helper method to set callback for navigation
  static void setNotificationTapCallback(Function(Map<String, dynamic>) callback) {
    _onNotificationTapCallback = callback;
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}