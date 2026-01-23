import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/auth/persentation/splash_page.dart';
import 'package:i_vatan_app/route/app_pages.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'core/network/api_services.dart';
import 'db/init_app.dart';
import 'db/shared_pref_manager.dart';
import 'features/auth/persentation/google_login_page.dart';
import 'features/dashboard/persentation/dashboard_page.dart';
import 'features/onbording/persentation/view/onboarding_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await initApp();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPrefManager().init();
  Get.put(ApiServices());
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
          ),
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.appPages,
         // home: const SplashPage(),
         // getPages: AppRoutes.appPages,
        );
      },
    );
  }
}




