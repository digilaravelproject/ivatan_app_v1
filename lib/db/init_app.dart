import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// ✅ Background FCM handler — must be top-level & annotated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint("🔔 Firebase init background exception: $e");
    }
  }
  debugPrint("🔔 [background] Message received: ${message.messageId}");
}

/// ✅ Background notification tap handler — must be top-level & annotated
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
    '🔔 [background tap] Notification payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.payload != null) {
    _handleNotificationPayloadNavigation(notificationResponse.payload!);
  }
}

const String kDefaultChannelId = 'default_channel_id';
const String kDefaultChannelName = 'General Notifications';
const String kDefaultChannelDescription =
    'This channel is used for general notifications.';

Future<void> initApp() async {
  // WidgetsFlutterBinding.ensureInitialized(); is now handled in main()
  // Firebase.initializeApp() with options is now handled in main()
  
  // Register background messaging handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Future.wait([
    SharedPrefManager().init(),
    //  Get.putAsync(() async => ConnectivityManager()),
  ]);

  await _initNotifications();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  const uiStyle = SystemUiOverlayStyle(
    statusBarColor: AppColors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  );
  SystemChrome.setSystemUIOverlayStyle(uiStyle);
}

Future<void> _initNotifications() async {
  try {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 🔒 Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      provisional: false,
      carPlay: false,
    );
    debugPrint(
      "🔔 _initNotifications Notification permission status: ${settings.authorizationStatus}",
    );

    // 🔔 Foreground display options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // 🔔 Notification channel
    const AndroidNotificationChannel androidChannel =
        AndroidNotificationChannel(
          kDefaultChannelId,
          kDefaultChannelName,
          description: kDefaultChannelDescription,
          importance: Importance.high,
        );

    // 🔔 Initialization settings
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    // ✅ FIX: use top-level background callback
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(
          '🔔 [foreground tap] Notification payload: ${response.payload}',
        );
        if (response.payload != null) {
          _handleNotificationPayloadNavigation(response.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // 🔔 Create the notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    // 🔑 Get FCM token
    final String? fcmToken = await messaging.getToken();
    debugPrint('📱 FCM Token: $fcmToken');

    // 🔔 Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Foreground message received: ${message.messageId}');
      _showLocalNotification(message);
    });

    // 🔔 App opened from terminated state
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '📬 Opened app from terminated state by notification: ${initialMessage.messageId}',
      );
      _handleNotificationNavigation(initialMessage);
    }

    // 🔔 App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 onMessageOpenedApp: ${message.notification?.title}');
      _handleNotificationNavigation(message);
    });

    // ♻️ Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('🔁 FCM token refreshed: $newToken');
    });
  } catch (e, st) {
    debugPrint('❗ Error initializing notifications: $e\n$st');
  }
}

/// ✅ Local notification display
void _showLocalNotification(RemoteMessage message) async {
  String? title = message.notification?.title ?? message.data['title'];
  String? body = message.notification?.body ?? message.data['body'];

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    kDefaultChannelId,
    kDefaultChannelName,
    importance: Importance.max,
    priority: Priority.high,
    // icon: '@drawable/app_svg_logo',
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    platformDetails,
    payload: jsonEncode(message.data),
  );
}

/// ✅ Handle in-app navigation for FCM messages
void _handleNotificationNavigation(RemoteMessage message) {
  try {
    final Map<String, dynamic> data = message.data;
    final String? type = data['type'] as String?;
    debugPrint('🔔 _handleNotificationNavigation type=$type data=$data');

    if (type == 'new_message') {
      // Get.to(() => ChatScreen());
    } else if (type == 'alert') {
      Get.snackbar(
        message.notification?.title ?? data['title'] ?? 'Alert',
        message.notification?.body ?? data['body'] ?? '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: AppColors.white,
      );
    } else {
      // Get.offAll(() => HomeScreen());
    }
  } catch (e) {
    debugPrint('❗ Error handling navigation: $e');
  }
}

/// ✅ Handle notification payload navigation (from local notifications)
void _handleNotificationPayloadNavigation(String payload) {
  debugPrint('🔔 handleNotificationPayloadNavigation payload=$payload');

  try {
    final data = jsonDecode(payload);
    final String? type = data['type'];

    if (type == 'new_message') {
      // Get.to(() => ChatScreen());
    } else if (type == 'order') {
      // Get.to(() => OrderDetailsScreen(orderId: data['orderId']));
    } else {
      // Get.offAll(() => HomeScreen());
    }
  } catch (e) {
    debugPrint('❗ Error parsing payload: $e');
  }
}
