import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/job_portal/persentation/pages/job_description_page.dart';
import 'package:i_vatan_app/features/job_portal/persentation/pages/create_job_page.dart';
import 'package:i_vatan_app/features/product/persentation/add_address_screen.dart';
import '../core/helper/logger_helper.dart';
import '../features/auth/binding/auth_binding.dart';
import '../features/auth/persentation/login_screen.dart';
import '../features/auth/persentation/new_password.dart';
import '../features/auth/persentation/splash_page.dart';
import '../features/dashboard/persentation/dashboard_page.dart';
import '../features/job_portal/binding/job_binding.dart';
import '../features/job_portal/persentation/pages/job_portal_page.dart';
import '../features/job_portal/persentation/pages/my_jobs.dart';
import '../features/messages/binding/chat_binding.dart';
import '../features/messages/persentation/chatting_screen.dart';

import '../features/job_portal/binding/applicant_binding.dart';
import '../features/job_portal/persentation/pages/applicant_list.dart';
import '../features/job_portal/persentation/pages/applicant_details.dart';
import '../features/product/binding/address_binding.dart';

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



  static const String jobSearchScreen = '/JobSearchScreen';
  static const String jobDescriptionScreen = '/JobDescriptionScreen';
  static const String jobCreateScreen = '/JobCreateScreen';
  static const String applicantListScreen = '/ApplicantListScreen';
  static const String applicantDetailsScreen = '/ApplicantDetailsScreen';
  static const String myCreatedJobScreen = '/MyCreatedJobScreen';


  static const String addAddressScreen = '/AddAddressScreen';



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

    GetPage(
      name: AppRoutes.jobSearchScreen,
      page: () => JobSearchScreen(),
      binding: JobBinding(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: AppRoutes.jobDescriptionScreen,
      page: () => JobDescriptionScreen(),
      binding: JobBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.jobCreateScreen,
      page: () => const JobCreateScreen(),
      binding: JobBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.myCreatedJobScreen,
      page: () => const MyCreatedJobScreen(),
      binding: JobBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.addAddressScreen,
      page: () => const AddAddressScreen(),
      binding: AddressBinding(),
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
    GetPage(
      name: AppRoutes.applicantListScreen,
      page: () => const ApplicantList(),
      binding: ApplicantBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.applicantDetailsScreen,
      page: () => ApplicantDetail(applicationId: Get.arguments as int),
      binding: ApplicantBinding(),
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
