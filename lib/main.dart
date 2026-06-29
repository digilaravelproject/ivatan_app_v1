import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/auth/persentation/splash_page.dart';
import 'package:i_vatan_app/route/app_pages.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'core/network/api_services.dart';
import 'core/network/websocket_service.dart';
import 'db/init_app.dart';
import 'db/shared_pref_manager.dart';
import 'features/auth/persentation/google_login_page.dart';
import 'features/dashboard/persentation/dashboard_page.dart';
import 'features/onbording/persentation/view/onboarding_page.dart';
import 'firebase_options.dart';
import 'features/Notification/binding/notification_binding.dart';


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print("Firebase background init exception: $e");
    }
  }

  print("Background Notification");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Data: ${message.data}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print("Firebase main init exception: $e");
    }
  }

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // 2. Run other app initializations
  await initApp();
  await SharedPrefManager().init();
  Get.put(ApiServices());
  final wsService = Get.put(WebSocketService());
  await wsService.init();
  runApp(const MyApp());
//  runApp(PhoneAuthScreen());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screen) {
        return GetMaterialApp(
          title: 'iVatan',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            fontFamily: 'DMSans',
          ),
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.appPages,
          initialBinding: NotificationBinding(),
         // home: const SplashPage(),
         // getPages: AppRoutes.appPages,
        );
      },
    );
  }
}




