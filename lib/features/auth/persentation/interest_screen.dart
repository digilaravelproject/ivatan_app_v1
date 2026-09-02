import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/features/auth/persentation/registration_screen.dart';
import 'package:i_vatan_app/features/auth/persentation/verifyOtp.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_buttons.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/persentation/dashboard_page.dart';
import '../controller/intrest_controller.dart';
import '../controller/register_controller.dart';
import '../widgets/auth_input_fields.dart';

/*class InterestScreen extends StatelessWidget {
  const InterestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🖼 Background header container
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.white.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              image: const DecorationImage(
                image: AssetImage(AppAssets.imgAuthBack),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 📜 Scrollable content below header
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: const Text(
                            "Interest",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text("1. Technology",style: TextStyle(color: AppColors.black,fontSize: 18,fontWeight: FontWeight.bold),),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Web Development"),
                            Text("Software Engineering"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Web Development"),
                            Text("Software Engineering"),
                          ],
                        ),
                     


                        MyButton(
                          title: "Submit",
                          onPressed: () {
                            Get.to(VerifyOtp());
                          },
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primary],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          height: 40,
                          borderRadius: 8,
                        ),
                        const SizedBox(height: 16),

                      ],
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
}*/

import 'package:flutter/services.dart'; // For Haptics

class InterestScreen extends StatefulWidget {
  const InterestScreen({Key? key}) : super(key: key);

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> with SingleTickerProviderStateMixin {
  final InterestController controller = Get.put(InterestController());
  final RegisterController registerController = Get.find<RegisterController>();
  final Set<String> selectedItems = {};

  void toggleSelection(String item) {
    HapticFeedback.lightImpact(); // ✨ Tactile feedback
    setState(() {
      selectedItems.contains(item)
          ? selectedItems.remove(item)
          : selectedItems.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: BackButton(
          color: AppColors.white,
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "Step 1/2",
                style: TextStyle(
                  color: AppColors.premiumGold,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                const Text(
                  "Pick your interests",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We'll use this to personalize your feed and recommend people you'll love.",
                  style: TextStyle(
                    fontSize: 16, // Larger readable font
                    color: AppColors.premiumGold,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // 🔥 Categories Loop
                if (controller.interestData.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("No interests found", style: TextStyle(color: AppColors.premiumGold)),
                    ),
                  )
                else
                  for (int i = 0; i < controller.interestData.length; i++) ...[
                    _buildCategorySection(controller.interestData[i], i),
                  ],

                const SizedBox(height: 40),

                // Button Inline (No Card)
                MyButton(
                  title: selectedItems.isEmpty
                      ? "Continue"
                      : "Continue (${selectedItems.length})",
                  onPressed: () {
                    if (selectedItems.isEmpty) {
                      CustomSnackBar.showError(message: 'Pick at least one interest to start!');
                      HapticFeedback.heavyImpact();
                      return;
                    }

                    HapticFeedback.mediumImpact();
                    registerController.interestsController.text =
                        selectedItems.join(",");

                    Get.to(() => RegistrationScreen());
                  },
                  gradient: LinearGradient(
                    colors: selectedItems.isEmpty
                        ? [AppColors.premiumGold, AppColors.premiumGold]
                        : [AppColors.primary, AppColors.primaryDark],
                  ),
                  height: 52,
                  borderRadius: 12,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Animates each section in slightly delayed
  Widget _buildCategorySection(dynamic category, int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 100)), // Staggered delay
      curve: Curves.easeOutQuart,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)), // Slide up effect
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category["category"].toString().toUpperCase(),
            style: TextStyle(
              color: AppColors.premiumGold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: (category["interests"] as List<dynamic>)
                .map((item) => _buildInterestChip(item.toString()))
                .toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String item) {
    bool isSelected = selectedItems.contains(item);
    return GestureDetector(
      onTap: () => toggleSelection(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 18 : 20, vertical: 12), // Slight squeeze effect
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.premiumGold,
            width: isSelected ? 0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, color: AppColors.white, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              item,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



