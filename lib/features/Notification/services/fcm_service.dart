import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  FcmService._();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static String get deviceType {
    if (Platform.isAndroid) return "android";
    if (Platform.isIOS) return "ios";
    return "web";
  }

  static Future<void> requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  static Stream<String> get tokenRefresh {
    return _firebaseMessaging.onTokenRefresh;
  }

  static void listenForegroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("========== Foreground Notification ==========");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("Data: ${message.data}");
    });
  }

  static void listenNotificationClick({
    required Function(RemoteMessage message) onClick,
  }) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("========== Notification Click ==========");
      print("Data: ${message.data}");

      onClick(message);
    });
  }

  static Future<RemoteMessage?> getInitialMessage() async {
    return await _firebaseMessaging.getInitialMessage();
  }
}