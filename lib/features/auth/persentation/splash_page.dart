import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/features/auth/persentation/google_login_page.dart';
import 'package:i_vatan_app/features/dashboard/persentation/dashboard_page.dart';
import 'package:i_vatan_app/features/onbording/persentation/view/onboarding_page.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/helper/custom_image_view.dart';
import '../../../core/utils/app_decoration.dart';
import '../../../db/shared_pref_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:i_vatan_app/features/Notification/controller/notification_controller.dart';


/*class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
   // _navigateToNext();
    _askPermissionAndNavigate();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (_) => const OnboardingPage()),
    // );
   // final isLoggedIn = SharedPrefManager().isUserLogin;

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => isLoggedIn ?  DashboardPage() : const OnboardingPage(),
    //   ),
    // );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );

   *//* Navigator.pushReplacementNamed(
      context,
      OnboardingPage() as String
    ); *//*// 👈 change route if needed
  }



  void _askPermissionAndNavigate() async {
    // Check current status
    var status = await Permission.contacts.status;

    // Request permission if not granted
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }

    // Optional delay
    await Future.delayed(const Duration(seconds: 2));

    // Check login status
    final isLoggedIn = SharedPrefManager().isUserLogin;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? DashboardPage() : OnboardingPage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // App Logo / Title
            Column(
              children: [
                Center(
                  *//*child: Hero(
                    tag: AppConstants.transitionLogo,*//*
                    *//*child: Container(
                      decoration: AppDecorations.neonBorder(
                        AppColors.primary,
                        shape: BoxShape.circle,
                      ),*/



class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;


  @override
  void initState() {
    super.initState();

    // _controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 1600),
    //    // await Future.delayed(const Duration(seconds: 3));
    //
    // );
    //
    // _scaleAnimation = Tween<double>(
    //   begin: 0.1,
    //   end: 1,
    // ).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: Curves.elasticOut,
    //   ),
    // );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Scale animation (zoom in)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    /// 👇 ensure animation runs after first frame
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _controller.forward();
    // });


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //await _controller.forward(); // 👈 pehle animation
      _askPermissionAndNavigate(); // 👈 baad me navigation
    });

  //  _askPermissionAndNavigate();
  }

  void _askPermissionAndNavigate() async {
    // Check current status
    var status = await Permission.contacts.status;

    // Request permission if not granted
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }

    // Optional delay
    await Future.delayed(const Duration(seconds: 2));

    // Check login status
    final isLoggedIn = SharedPrefManager().isUserLogin;

    if (isLoggedIn) {
      try {
        Get.find<NotificationController>().initNotification();
      } catch (e) {
        print("Notification init error on Splash: $e");
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? DashboardPage() : OnboardingPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            /// 🔹 Center Logo (Animated)
            Expanded(
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: CustomImageView(
                    imagePath: AppAssets.imgAppLogo,
                    width: Get.width * 0.25,
                    height: Get.width * 0.25,
                    radius: BorderRadius.circular(Get.width * 0.07),
                  ),
                ),
              ),
            ),

            /// 🔹 Bottom Text
            Column(
              children: [
                Text(
                  "i-app",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  SharedPrefManager().isUserLogin
                      ? "Welcome, ${SharedPrefManager().user?.username ?? ""}"
                      : "from octraide",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),

            /// 🔹 Loader
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});
//
//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }
//
// class _SplashPageState extends State<SplashPage>
//     with SingleTickerProviderStateMixin {
//
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     /// 🔹 Animation
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//
//     _scaleAnimation = Tween<double>(
//       begin: 0.75,
//       end: 1.0,
//     ).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeOutBack,
//       ),
//     );
//
//     _controller.forward();
//
//    // _askPermissionAndNavigate();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _askPermissionAndNavigate() async {
//     var status = await Permission.contacts.status;
//
//     if (!status.isGranted) {
//       status = await Permission.contacts.request();
//     }
//
//     await Future.delayed(const Duration(seconds: 2));
//
//     final isLoggedIn = SharedPrefManager().isUserLogin;
//
//     if (!mounted) return;
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => isLoggedIn ? DashboardPage() : OnboardingPage(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             const Spacer(),
//
//             /// 🔹 Logo + Text with animation
//             ScaleTransition(
//               scale: _scaleAnimation,
//               child: Column(
//                 children: [
//                   CustomImageView(
//                     imagePath: AppAssets.imgAppLogo,
//                     width: Get.width * 0.25, // 👈 smaller icon
//                     height: Get.width * 0.25,
//                     radius: BorderRadius.circular(Get.width * 0.10),
//                   ),
//
//                   Spacer(),
//
//                   Text(
//                     "i-app",
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueAccent,
//                     ),
//                   ),
//
//                   const SizedBox(height: 6),
//
//                   Text(
//                     "from octraide",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const Spacer(),
//
//             /// 🔹 Loader
//             Center(
//               child: const Padding(
//                 padding: EdgeInsets.only(bottom: 40),
//                 child: CircularProgressIndicator(
//                   color: Colors.blueAccent,
//                   strokeWidth: 3,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




/*class SplashPage extends GetWidget<InitController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.imgAppLogo),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Hero(
              tag: AppConstants.transitionLogo,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: Get.width * 0.52,
                  height: Get.width * 0.52,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedBuilder(
                        animation: controller.logoController,
                        builder: (_, __) {
                          return Transform.rotate(
                            angle: controller.logoController.value * 0.5 * 3.14,
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOutBack,
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(
                                    opacity: value.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                );
                              },
                              child: SizedBox.square(
                                dimension: Get.width * 0.48,
                                child: CustomImageView(
                                  svgPath: AppAssets.bgCircleStroke,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOutBack,
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          height: Get.width * 0.44,
                          width: Get.width * 0.44,
                          padding: EdgeInsets.all(Get.width * 0.05),
                          decoration: AppDecorations.cardDecoration(context)
                              .copyWith(
                            borderRadius: BorderRadius.circular(
                              Get.width * 0.22,
                            ),
                          ),
                          child: CustomImageView(
                            imagePath: AppAssets.imgAppLogo,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).marginOnly(top: Get.height * 0.25),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// MAIN TITLE ANIMATION
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 20),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        "Your Campus Social Partner",
                        style: context.textTheme.titleSmall!.copyWith(
                          color: context.theme.primaryColorDark,
                          fontSize: 24,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// TAGLINE ANIMATION
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 15),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        "Connect ● Share ● Belong",
                        style: context.textTheme.bodySmall!.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// BOUNCING PROGRESS INDICATOR
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.3),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                      onEnd: controller._askPermissionAndNavigate,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: context.theme.colorScheme.primary,
                        size: 30,
                      ),
                    ),

                    SizedBox(height: context.mediaQueryPadding.bottom + 35),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class InitController extends GetxController
    implements GetTickerProviderStateMixin {
  late AnimationController logoController;

  @override
  void onInit() {
    _initController();
    super.onInit();
  }

  var isLoading = true.obs;

  void _askPermissionAndNavigate() async {
    var status = await Permission.contacts.status;

    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }

    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = SharedPrefManager().isUserLogin;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? DashboardPage() : OnboardingPage(),
      ),
    );
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  @override
  void didChangeDependencies(BuildContext context) {}

  void _initController() {
    logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    logoController.forward();
  }

  @override
  void dispose() {
    logoController.dispose();
    super.dispose();
  }
}*/
