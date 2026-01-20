import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/helper/logger_helper.dart';
import '../features/auth/binding/auth_binding.dart';
import '../features/auth/persentation/login_screen.dart';
import '../features/auth/persentation/new_password.dart';
import '../features/auth/persentation/splash_page.dart';
import '../features/dashboard/persentation/dashboard_page.dart';
import '../features/messages/binding/chat_binding.dart';
import '../features/messages/persentation/chatting_screen.dart';

class AppRoutes {
  AppRoutes._();

  /// --------- AUTH -----------///
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String forgetPassword = '/forgetPassword';
  static const String verifyEmail = '/verifyEmail';
  static const String OnboardingPage = '/OnboardingPage';
  static const String NewPasswordPage = '/NewPasswordPage';

  /// --------- DASHBOARD -----------///
  static const String dashboard = '/dashboard';
  static const String navigationScreen = '/navigationScreen';
  static const String chattingScreen = '/chattingScreen';

  /// --------- TREES -----------///
  static const String treesList = '/treesList';
  static const String addTrees = '/addTrees';

  /// -------- Get Pages ------- ///
  static final appPages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashPage(),
      transition: Transition.cupertino,
    ),
    // GetPage(
    //   name: AppRoutes.OnboardingPage,
    //   page: () => OnboardingPage(),
    //   transition: Transition.cupertino,
    // ),
    GetPage(
      name: AppRoutes.login,
     // middlewares: [AuthMiddleware()],
      page: () => LoginPage(),
      binding: AuthBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.chattingScreen,
      page: () => ChattingScreen(),
      binding: ChatBinding(),
      transition: Transition.cupertino,
    ),
 /*   GetPage(
      name: AppRoutes.signUp,
      page: () => RegisterPage(),
      binding: AuthBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => ForgetPasswordPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => VerifyEmailPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => BusinessDashboardScreen(),
      transition: Transition.cupertino,
    ),*/
    GetPage(
      name: AppRoutes.navigationScreen,
      page: () => DashboardPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.NewPasswordPage,
      page: () => NewPassword(),
      transition: Transition.cupertino,
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // if (SharedPrefManager().isUserLogin) {
    //   printMessage("UserId: ${SharedPrefManager().user?.id ?? "N/A"}");
    //   return const RouteSettings(name: AppRoutes.dashboard);
    // }
    return null;
  }
}
