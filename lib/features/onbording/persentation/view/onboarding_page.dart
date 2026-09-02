import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/onboarding_controller.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    final pageController = PageController();

    return Scaffold(
      backgroundColor: AppColors.black, // Dark background
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            onPageChanged: controller.updatePage,
            itemCount: controller.onboardingList.length,
            itemBuilder: (context, index) {
              final item = controller.onboardingList[index];
              return GestureDetector(
                onTap: () {
                  if (index == controller.onboardingList.length - 1) {
                    controller.skipToLogin();
                  } else {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: SizedBox.expand(
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.contain, // Changed to contain so image doesn't get cut
                  ),
                ),
              );
            },
          ),
          
          // Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: controller.skipToLogin, // Directly skips to Login
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: AppColors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              ),
              child: const Text("Skip"),
            ),
          ),
        ],
      ),
    );
  }
}
