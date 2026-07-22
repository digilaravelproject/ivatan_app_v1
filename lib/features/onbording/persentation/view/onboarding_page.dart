import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/custom_buttons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controller/onboarding_controller.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    final pageController = PageController();

    return Scaffold(
      backgroundColor: Colors.black, // Ensure black background for blending
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            onPageChanged: controller.updatePage,
            itemCount: controller.onboardingList.length,
            itemBuilder: (context, index) {
              final item = controller.onboardingList[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // 🖼 Fullscreen background image
                  GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Image.asset(
                      item.image,
                      fit: index == 0 ? BoxFit.contain : BoxFit.cover, // Prevent cropping on the first image
                    ),
                  ),

                  if (index != 0) // Hide gradient for the first image
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2), // Light top
                            Colors.black.withValues(alpha: 0.8), // Dark bottom
                          ],
                          stops: const [0.5, 0.7, 1.0],
                        ),
                      ),
                    ),

                  if (index != 0) // Hide text for the first image
                    Positioned(
                      bottom: 150,
                      left: 24,
                      right: 24,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          
          // Skip Button
          Obx(() => controller.currentPage.value == 0 
            ? const SizedBox.shrink() 
            : Positioned(
                top: 50,
                right: 20,
                child: TextButton(
                  onPressed: controller.skipToLogin, // Directly skips to Login
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                  child: const Text("Skip"),
                ),
              ),
          ),

          // Indicators & Button
          Obx(() => controller.currentPage.value == 0
            ? const SizedBox.shrink()
            : Positioned(
                bottom: 40,
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    // Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onboardingList.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6, // Slightly clearer dots
                          width: controller.currentPage.value == index ? 24 : 6, // Dash effect
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: controller.currentPage.value == index
                                ? Colors.white // White for contrast on Black overlay
                                : Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Button
                    MyButton(
                        title: controller.currentPage.value ==
                                controller.onboardingList.length - 1
                            ? 'Get Started'
                            : 'Next',
                        onPressed: () {
                          if (controller.currentPage.value <
                              controller.onboardingList.length - 1) {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            controller.goToNextPage();
                          }
                        },
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight], // Primary (Black) Theme
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        height: 50, // Slightly taller
                        borderRadius: 25, // More rounded
                      ),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }
}
