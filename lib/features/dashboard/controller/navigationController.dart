import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:i_vatan_app/features/reels_screen/persentation/reels_view.dart';

import '../../../db/shared_pref_manager.dart';
import '../../post/presentation/image_post_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../../reels_screen/controller/short_play_controller.dart';
import '../../reels_screen/persentation/reels_screen.dart';
import '../../videos/persentation/play_video_screen.dart';
import '../../videos/persentation/videos_screen.dart';
import '../persentation/dashboard_page.dart';
import '../persentation/home_screen.dart';
import '../persentation/search_screen.dart';


class NavigationController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxString viewUserName = "".obs;
  final ShortPlayController reelsController = Get.put(ShortPlayController());

  StreamSubscription<Uri>? _linkSub;

  @override
  void onInit() {
    super.onInit();

    _initDeepLinks();

   //  final AppLinks appLinks = AppLinks();
   //  _linkSub = appLinks.uriLinkStream.listen((uri) {
   //    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'post') {
   //      final postId = uri.pathSegments[1];
   //
   //      // GetX navigation use kar rahe
   // //    Get.to(() => ImagePostScreen(postId: 0,));
   //      Get.to(() => ImagePostScreen(postId: int.tryParse(postId ?? '0') ?? 0));
   //
   //    }
   //  });

  }


  void _initDeepLinks() async {
    final AppLinks appLinks = AppLinks();

    // Initial link check (jab app band ho aur link se open ho)
    try {
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }

    // Stream listener (jab app already open ho)
    _linkSub = appLinks.uriLinkStream.listen(
          (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    print('Deep link received: $uri'); // Debug ke liye

    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'post') {
      final postId = uri.pathSegments[1];
      final parsedPostId = int.tryParse(postId) ?? 0;

      if (parsedPostId > 0) {
        // Thoda delay do taaki UI ready ho jaye
        Future.delayed(Duration(milliseconds: 500), () {
          Get.to(() => ImagePostScreen(postId: parsedPostId));
        });
      }
    }
  }

  @override
  void onClose() {
    _linkSub?.cancel();
    super.onClose();
  }

  void changePage(int index, {String? username}) {
    currentIndex.value = index;
    if (index == 4) {
      viewUserName.value =
          username ?? SharedPrefManager().user?.username ?? "";
    }
  }

  Widget getCurrentPage() {
    switch (currentIndex.value) {
      case 0:
        return HomePage();
      case 1:
        return const SerachScreen();
      case 2:
        return Obx(() {
          final validReels =
          reelsController.reelsList.where((e) => e.media.isNotEmpty).toList();
          if (validReels.isEmpty) return const Center(child: Text("No reels available"));
          return ReelsView(reels: validReels);
        });
      case 3:
        return VideosScreen();
      case 4:
        return ProfileScreen(viewUserName: viewUserName.value);
      case 5:
        return VideosScreen();
      default:
        return const Center(child: Text("Home Screen"));
    }
  }
}




class DashboardController extends GetxController {
  /// Selected bottom index
  final RxInt selectedIndex = 0.obs;

  /// Profile username
  final RxString viewUserName = "".obs;

  /// PageView controller
  late PageController pageController;

  /// Reels controller
  final ShortPlayController reelsController = Get.put(ShortPlayController());

  /// Deep link
  StreamSubscription<Uri>? _linkSub;
  Uri? _pendingDeepLink;

  /// Screens (ORDER is IMPORTANT)
  late final List<Widget> screenList;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController(initialPage: selectedIndex.value);

    screenList = [
      HomePage(),              // 0
      const SerachScreen(),    // 1
      _reelsPage(),            // 2 (FAB)
      VideosScreen(),          // 3
      _profilePage(),          // 4
    ];

    _initDeepLinks();
  }

  /// 🔗 Deep link handling - COMPLETE VERSION
  void _initDeepLinks() async {
    final AppLinks appLinks = AppLinks();
    print("🔗 DashboardController initialized");

    // 1. Check for initial link (jab app band ho aur link se open ho)
    try {
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        print('📱 Initial deep link: $initialUri');
        _pendingDeepLink = initialUri;

        // App ready hone ka wait karo
        Future.delayed(Duration(milliseconds: 1000), () {
          _handleDeepLink(initialUri);
          _pendingDeepLink = null;
        });
      }
    } catch (e) {
      print('❌ Error getting initial link: $e');
    }

    // 2. Listen to stream (jab app already open ho)
    _linkSub = appLinks.uriLinkStream.listen(
          (uri) {
        print('📱 Stream deep link: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('❌ Deep link error: $err');
      },
    );
  }

  /// Handle deep link - Support both custom scheme and HTTPS
  void _handleDeepLink(Uri uri) {
    print('🔗 Deep link received: $uri');
    print('🔗 Scheme: ${uri.scheme}');
    print('🔗 Host: ${uri.host}');
    print('🔗 Path: ${uri.path}');
    print('🔗 PathSegments: ${uri.pathSegments}');

    try {
      int parsedPostId = 0;
      String? type;

      // Handle custom scheme: ivatan://post/125
      if (uri.scheme == 'ivatan' && uri.host == 'post') {
        if (uri.pathSegments.isNotEmpty) {
          parsedPostId = int.tryParse(uri.pathSegments[0]) ?? 0;
          type = uri.queryParameters['type'];
        }
      }
      // Handle HTTPS: https://ivatan.in/post/125
      else if ((uri.scheme == 'https' || uri.scheme == 'http') &&
          (uri.host == 'ivatan.in' || uri.host == 'www.ivatan.in')) {
        if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'post') {
          parsedPostId = int.tryParse(uri.pathSegments[1]) ?? 0;
          type = uri.queryParameters['type'];
        }
      }

      print('📱 Extracted PostID: $parsedPostId, Type: $type');

      if (parsedPostId > 0) {
        // Navigation ready hone ka wait karo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(Duration(milliseconds: 500), () {
            if (Get.context != null) {
              print('✅ Navigating to ImagePostScreen with postId: $parsedPostId');
              Get.to(
                    () => ImagePostScreen(postId: parsedPostId),
                preventDuplicates: true,
              );
            } else {
              print('⚠️ GetX context not ready, retrying...');
              Future.delayed(Duration(milliseconds: 1000), () {
                Get.to(
                      () => ImagePostScreen(postId: parsedPostId),
                  preventDuplicates: true,
                );
              });
            }
          });
        });
      } else {
        print('⚠️ Invalid postId: $parsedPostId');
      }
    } catch (e) {
      print('❌ Error handling deep link: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Bottom nav / FAB tap
  void changeIndex(int index, {String? username}) {
    selectedIndex.value = index;

    if (index == 4) {
      viewUserName.value = username ?? SharedPrefManager().user?.username ?? "";
    }

    pageController.jumpToPage(index);
  }

  /// PageView change
  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  /// 🔁 Reels page
  Widget _reelsPage() {
    return Obx(() {
      final validReels = reelsController.reelsList
          .where((e) => e.media.isNotEmpty)
          .toList();

      if (validReels.isEmpty) {
        return const Center(child: Text("No reels available"));
      }

      return ReelsView(reels: validReels);
    });
  }

  /// 👤 Profile page
  Widget _profilePage() {
    return Obx(() => ProfileScreen(viewUserName: viewUserName.value));
  }

  @override
  void onClose() {
    _linkSub?.cancel();
    pageController.dispose();
    super.onClose();
  }
}

/*
class DashboardController extends GetxController {
  /// Selected bottom index
  final RxInt selectedIndex = 0.obs;

  /// Profile username
  final RxString viewUserName = "".obs;

  /// PageView controller
  late PageController pageController;

  /// Reels controller
  final ShortPlayController reelsController =
  Get.put(ShortPlayController());

  /// Deep link
  StreamSubscription<Uri>? _linkSub;

  /// Screens (ORDER is IMPORTANT)
  late final List<Widget> screenList;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController(initialPage: selectedIndex.value);

    screenList = [
      HomePage(),        // 0
      const SerachScreen(),    // 1
      _reelsPage(),            // 2 (FAB)
      VideosScreen(),          // 3
      _profilePage(),          // 4
    ];

    _initDeepLinks();
  }

  /// 🔗 Deep link handling (same as NavigationController)
  void _initDeepLinks() {
    final AppLinks appLinks = AppLinks();
    print("dashboardcontroller : "+appLinks.toString());
    _linkSub = appLinks.uriLinkStream.listen((uri) {
      if (uri.pathSegments.length >= 2 &&
          uri.pathSegments[0] == 'post') {
        final postId = int.tryParse(uri.pathSegments[1]) ?? 0;

        Get.to(() => ImagePostScreen(postId: postId));
      }
    });
  }

  /// Bottom nav / FAB tap
  void changeIndex(int index, {String? username}) {
    selectedIndex.value = index;

    if (index == 4) {
      viewUserName.value =
          username ?? SharedPrefManager().user?.username ?? "";
    }

    pageController.jumpToPage(index);
  }

  /// PageView change
  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  /// 🔁 Reels page (same logic as getCurrentPage case 2)
  Widget _reelsPage() {
    return Obx(() {
      final validReels = reelsController.reelsList
          .where((e) => e.media.isNotEmpty)
          .toList();

      if (validReels.isEmpty) {
        return const Center(child: Text("No reels available"));
      }

      return ReelsView(reels: validReels);
    });
  }

  /// 👤 Profile page (username reactive)
  Widget _profilePage() {
    return Obx(() =>
        ProfileScreen(viewUserName: viewUserName.value));
  }

  @override
  void onClose() {
    _linkSub?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
*/
