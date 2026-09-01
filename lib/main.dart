import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/auth/persentation/splash_page.dart';
import 'package:i_vatan_app/route/app_pages.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';

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
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: AppColors.mainBackground,
            primaryColor: AppColors.premiumGold,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.premiumGold,
              secondary: AppColors.goldHighlight,
              surface: AppColors.mainBackground,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.mainBackground,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.premiumGold),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'DMSans',
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: AppColors.mainBackground,
              selectedItemColor: AppColors.premiumGold,
              unselectedItemColor: Colors.white54,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
              fontFamily: 'DMSans',
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: AppColors.premiumGold,
            ),
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




