import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/auth_input_fields.dart';
import '../../../core/helper/custom_buttons.dart';
import '../controller/login_controller.dart';

class NewPassword extends GetWidget<LoginController> {
  const NewPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title
              Text(
                "Create New Password",
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Please enter a strong new password.",
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.premiumGold,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              CustomTextField(
                  labelText: "New Password",
                  keyboardType: TextInputType.text,
                  controller: controller.passwordController,
                  obscureText: true,
                  suffixIcon: Icon(Icons.visibility_off, color: AppColors.premiumGold)
              ),
              const SizedBox(height: 20),

              CustomTextField(
                  labelText: "Confirm Password",
                  keyboardType: TextInputType.text,
                  controller: controller.confirmPassworController,
                  obscureText: true,
                  suffixIcon: Icon(Icons.visibility_off, color: AppColors.premiumGold)
              ),

              const SizedBox(height: 40),

              // Change Password Button
              Obx(() => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.premiumGold, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: MyButton(
                  title: controller.isLoading.value ? "Changing..." : "Change Password",
                  onPressed: () {
                    controller.resetPassword();
                  },
                  gradient: const LinearGradient(
                    colors: [AppColors.black, AppColors.black],
                  ),
                  textColor: AppColors.premiumGold,
                  height: 52,
                  borderRadius: 16,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
