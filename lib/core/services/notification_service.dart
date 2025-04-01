import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permissions (iOS and web)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false, // Set to true for less intrusive permission request on iOS
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // Get FCM Token (used to send notifications to specific devices)
    String? token = await getFCMToken();
    if (kDebugMode) {
      print("FirebaseMessaging Token: $token");
    }
    // TODO: Save this token to the user's profile in Firestore to target them

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print('Message also contained a notification: ${message.notification}');
        }
        // TODO: Show a local notification using flutter_local_notifications
        // or update UI based on the message data
      }
    });

    // Handle background/terminated messages (when user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
       if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
         print('Message data: ${message.data}');
       }
        // TODO: Navigate to a specific screen based on message.data
        // e.g., if it's a leave approval notification, go to the leave screen.
    });

     // Handle initial message (if app was opened from terminated state via notification)
     RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
     if (initialMessage != null) {
        if (kDebugMode) {
         print('App opened from terminated state via notification!');
         print('Message data: ${initialMessage.data}');
        }
         // TODO: Handle navigation based on initialMessage.data
     }

  }

  Future<String?> getFCMToken() async {
    // Use APNS token for iOS, FCM token otherwise
    String? token;
     if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        token = await _firebaseMessaging.getAPNSToken();
        if (token == null) {
           // Wait a bit and retry for APNS token
           await Future.delayed(const Duration(seconds: 1));
           token = await _firebaseMessaging.getAPNSToken();
        }
     }
     // Get standard FCM token for Android/Web
     token ??= await _firebaseMessaging.getToken();
    return token;
  }

  // TODO: Add methods to subscribe/unsubscribe from topics (e.g., 'announcements_all', 'announcements_rh')
  Future<void> subscribeToTopic(String topic) async {
     await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) print('Subscribed to topic: $topic');
  }

   Future<void> unsubscribeFromTopic(String topic) async {
     await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) print('Unsubscribed from topic: $topic');
   }
}

// Provider (can go in core/providers/firebase_providers.dart or here)
// final notificationServiceProvider = Provider<NotificationService>((ref) {
//    final service = NotificationService();
//    service.initialize(); // Initialize when provider is first read
//    return service;
// });