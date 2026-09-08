import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/iconoir.dart';

import '../controller/navigationController.dart';
import '../controller/homeController.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/network/app_urls.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final DashboardController controller = Get.put(DashboardController());
  DateTime? lastPressed;


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (lastPressed == null ||
            now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;
          Get.snackbar(
            "Exit App",
            "Press again to exit",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.transparent,
            colorText: AppColors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 2),
          );
          return false;
        }
        return true;
      },
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_app.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          extendBody: false,
          backgroundColor: AppColors.transparent,
          body: Stack(
            children: [
              PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: controller.onPageChanged,
                children: controller.screenList,
              ),

              // Global Upload Progress
              _buildGlobalUploadProgress(),
            ],
          ),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _item(context, Iconsax.home_2, Iconsax.home_2_copy, 0, label: "Home"),
                _item(context, Iconsax.search_normal, Iconsax.search_normal_copy, 1, label: "Search"),
                _item(context, Iconsax.video_play, Iconsax.video_play_copy, 2, isCenter: true),
                _item(context, Iconsax.video, Iconsax.video_copy, 3, label: "Video"),
                _item(context, Iconsax.user, Iconsax.user_copy, 4, imageUrl: controller.userProfileImage, label: "Profile"),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildGlobalUploadProgress() {
    final homeController = Get.find<HomeController>();
    return Obx(() {
      if (!homeController.isUploading.value) return const SizedBox.shrink();

      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            boxShadow: [
              BoxShadow(
                color: AppColors.white.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    homeController.isCompressing.value
                        ? "Compressing video..."
                        : "Sharing your ${homeController.lastUploadType.value ?? 'post'}...",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.white,
                    ),
                  )),
                  Obx(() => Text(
                    "${(homeController.uploadProgress.value * 100).toInt()}%",
                    style: const TextStyle(
                      color: AppColors.premiumGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Obx(() => LinearProgressIndicator(
                  value: homeController.uploadProgress.value,
                  backgroundColor: AppColors.mainBackground,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.premiumGold),
                  minHeight: 3,
                )),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _item(BuildContext context, dynamic iconDataSelected, dynamic iconDataUnselected, int index, {String? imageUrl, String label = "", bool isCenter = false}) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final color = isSelected ? AppColors.premiumGold : Colors.white60;

      if (isCenter) {
        return GestureDetector(
          onTap: () => controller.changeIndex(index),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.premiumGold.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.premiumGold.withOpacity(0.8), width: 1.5),
                color: const Color(0xFF1A1A1A),
              ),
              child: Icon(
                iconDataSelected ?? Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      }

      return Expanded(
        child: GestureDetector(
          onTap: () => controller.changeIndex(index),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 65,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (index == 4)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.premiumGold : AppColors.transparent,
                            width: 1.2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: ClipOval(
                            child: (imageUrl != null && imageUrl.isNotEmpty)
                                ? Image.network(
                                    AppUrls.getFullImageUrl(imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(AppAssets.imgAppLogo, fit: BoxFit.cover),
                                  )
                                : Image.asset(AppAssets.imgAppLogo, fit: BoxFit.cover),
                          ),
                        ),
                      )
                    else
                      Icon(
                        isSelected ? iconDataSelected : iconDataUnselected,
                        size: 22,
                        color: color,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.premiumGold.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.premiumGold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Business Dashboard',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.premiumGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_vert_rounded, color: AppColors.white),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedBusiness(),
            const SizedBox(height: 24),
            _buildTabButtons(),
            const SizedBox(height: 24),
            _buildOtherBusinessesCard(),
            const SizedBox(height: 24),
            _buildOtherBusinessesSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBusiness() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD63384).withOpacity(0.05),
            const Color(0xFFE85D9A).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD63384).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD63384), Color(0xFFE85D9A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star_rounded, color: AppColors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Featured',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sadhna Pharmacy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Product Business',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.premiumGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created 4 days ago',
                          style: TextStyle(
                            color: AppColors.premiumGold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD63384),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.contact_mail_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'SEND ENQUIRY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.premiumGold,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD63384), Color(0xFFE85D9A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD63384).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    shadowColor: AppColors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'All Businesses',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'My Business',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherBusinessesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white,
              AppColors.premiumGold.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.white.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD63384), Color(0xFFE85D9A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD63384).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.business_rounded,
                color: AppColors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Other Businesses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore more opportunities',
                    style: TextStyle(
                      color: AppColors.premiumGold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD63384), Color(0xFFE85D9A)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '2',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherBusinessesSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Other Businesses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xFFD63384),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                label: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Color(0xFFD63384),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildBusinessCard(
          'Cipla Industry',
          'Product Business',
          'Pune, Maharashtra',
          'Nov 4, 2025',
          true,
        ),
        _buildBusinessCard(
          'Mcure Pharma',
          'Product Business',
          'Pune, Maharashtra',
          'Nov 4, 2025',
          true,
        ),
      ],
    );
  }

  Widget _buildBusinessCard(
      String name,
      String type,
      String location,
      String date,
      bool isActive,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isActive ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.premiumGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: AppColors.premiumGold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.premiumGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Created $date',
                      style: TextStyle(
                        color: AppColors.premiumGold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: AppColors.premiumGold,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(
                          Icons.remove_red_eye_rounded,
                          size: 18,
                          color: AppColors.premiumGold,
                        ),
                        label: Text(
                          'View Details',
                          style: TextStyle(
                            color: AppColors.premiumGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:i_vatan_app/core/theme/app_colors.dart';
//
// import '../controller/navigationController.dart';
//
//
// class DashboardPage extends StatelessWidget {
//   DashboardPage({super.key});
//
//   final DashboardController controller =
//   Get.put(DashboardController());
//
//   DateTime? lastPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         final now = DateTime.now();
//         if (lastPressed == null ||
//             now.difference(lastPressed!) > const Duration(seconds: 2)) {
//           lastPressed = now;
//           Get.snackbar(
//             "Exit App",
//             "Press again to exit",
//             snackPosition: SnackPosition.BOTTOM,
//           );
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         extendBody: true,
//         backgroundColor: AppColors.transparent,
//         body: PageView(
//           controller: controller.pageController,
//           physics: const NeverScrollableScrollPhysics(),
//           onPageChanged: controller.onPageChanged,
//           children: controller.screenList,
//         ),
//
//
//
//         floatingActionButton: Container(
//           height: 50, // size of the circular button
//           width: 50,
//           decoration: BoxDecoration(
//             color: AppColors.black,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.white,
//                 blurRadius: 4,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: FloatingActionButton(
//             onPressed: () => controller.changeIndex(2),
//             backgroundColor: AppColors.transparent, // make button circular with container color
//             elevation: 0,
//             child: const Icon(Icons.slow_motion_video, size: 30,color: AppColors.white,),
//           ),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//
//         bottomNavigationBar: BottomAppBar(
//           shape: const CircularNotchedRectangle(),
//           notchMargin: 6,
//           height: 65, // Add this line to control the overall height
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 0.0), // Optional: adjust padding
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(children: [
//                   _item(context, Icons.home, "Home", 0),
//                   _item(context, Icons.search, "Search", 1),
//                 ]),
//                 Row(children: [
//                   _item(context, Icons.video_collection_outlined, "Videos", 3),
//                   _item(context, Icons.person, "Profile", 4),
//                 ]),
//               ],
//             ),
//           ),
//         ),
//
//       ),
//     );
//   }
//
//   Widget _item(BuildContext context, IconData icon, String label, int index) {
//     return Obx(() {
//       final isSelected = controller.selectedIndex.value == index;
//       final color = isSelected ? AppColors.black : AppColors.premiumGold;
//
//       return InkWell(
//         onTap: () => controller.changeIndex(index),
//         child: SizedBox(
//           width: 70,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, color: color, size: 22), // Reduce icon size
//               const SizedBox(height: 2), // Add spacing
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: color,
//                   fontSize: 11, // Reduce font size
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
// }
//
//
// class BusinessDashboardScreen extends StatelessWidget {
//   const BusinessDashboardScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.transparent,
//       appBar: AppBar(
//         backgroundColor: AppColors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.white),
//           onPressed: () {},
//         ),
//         title: const Text(
//           'Business Dashboard',
//           style: TextStyle(
//             color: AppColors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Divider(height: 1),
//             _buildFeaturedBusiness(),
//             const SizedBox(height: 20),
//             _buildTabButtons(),
//             const SizedBox(height: 20),
//             _buildOtherBusinessesCard(),
//             const SizedBox(height: 20),
//             _buildOtherBusinessesSection(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFeaturedBusiness() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Text(
//                     'Sadhna Pharmacy',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     'Product Business',
//                     style: TextStyle(
//                       color: AppColors.premiumGold,
//                       fontSize: 14,
//                     ),
//                   ),
//                   SizedBox(height: 3),
//                   Text(
//                     'Created 4 days ago',
//                     style: TextStyle(
//                       color: AppColors.premiumGold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//               ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFD63384),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 30,
//                    // vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'ENQUIRY',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Featured Business',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTabButtons() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         children: [
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFD63384),
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Text(
//                 'All Businesses',
//                 style: TextStyle(
//                   color: AppColors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: OutlinedButton(
//               onPressed: () {},
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 side: const BorderSide(color: Color(0xFFD63384), width: 2),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: const Text(
//                 'My Business',
//                 style: TextStyle(
//                   color: Color(0xFFD63384),
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOtherBusinessesCard() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: AppColors.premiumGold.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFFD63384), Color(0xFFE85D9A)],
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.business,
//                 color: AppColors.white,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Text(
//                     'Other Businesses',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 3),
//                   Text(
//                     'Explore more business opportunities',
//                     style: TextStyle(
//                       color: AppColors.premiumGold,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Text(
//               '2',
//               style: TextStyle(
//                 fontSize: 40,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFFD63384),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOtherBusinessesSection() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Other Businesses',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {},
//                 child: const Text(
//                   'View all',
//                   style: TextStyle(
//                     color: AppColors.premiumGold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 10),
//         _buildBusinessCard(
//           'Cipla Industry',
//           'Product Business',
//           'Pune, Maharashtra',
//           'Nov 4, 2025',
//         ),
//         _buildBusinessCard(
//           'Mcure Pharma',
//           'Product Business',
//           'Pune, Maharashtra',
//           'Nov 4, 2025',
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBusinessCard(
//       String name,
//       String type,
//       String location,
//       String date,
//       ) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.premiumGold.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             name,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             type,
//             style: const TextStyle(
//               color: AppColors.premiumGold,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 3),
//           Text(
//             location,
//             style: const TextStyle(
//               color: AppColors.premiumGold,
//               fontSize: 13,
//             ),
//           ),
//           const SizedBox(height: 3),
//           Text(
//             'Created $date',
//             style: const TextStyle(
//               color: AppColors.premiumGold,
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(height: 15),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.green[100],
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: const Text(
//                   'ACTIVE',
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {},
//                 child: const Text(
//                   'See detail',
//                   style: TextStyle(
//                     color: AppColors.premiumGold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
// }