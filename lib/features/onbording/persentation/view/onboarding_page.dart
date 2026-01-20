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
      body: SafeArea(
        child: PageView.builder(
          controller: pageController,
          onPageChanged: controller.updatePage,
          itemCount: controller.onboardingList.length,
          itemBuilder: (context, index) {
            final item = controller.onboardingList[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                // 🖼 Fullscreen background image
                Image.asset(item.image, fit: BoxFit.fill),

                // 🌫 Dark overlay for text contrast
                Container(color: Colors.black.withOpacity(0.3)),

                Positioned(
                  bottom: 120,
                  left: 24,
                  right: 24,
                  child: Column(
                    children: [
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 90,
                  left: 0,
                  right: 0,
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onboardingList.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: controller.currentPage.value == index ? 8 : 8,
                          width: controller.currentPage.value == index ? 8 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                controller.currentPage.value == index
                                    ? AppColors.primary
                                    : Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 30,
                  left: 24,
                  right: 24,
                  child: MyButton(
                    title:
                        controller.currentPage.value ==
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
                      colors: [AppColors.primaryDark, AppColors.primaryLight],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    height: 40,
                    borderRadius: 10,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
