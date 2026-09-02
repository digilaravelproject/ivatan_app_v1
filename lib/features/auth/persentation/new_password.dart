import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/features/auth/persentation/registration_screen.dart';
import 'package:i_vatan_app/features/auth/persentation/verifyOtp.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/auth_input_fields.dart';
import '../controller/login_controller.dart';

class NewPassword extends GetWidget<LoginController>  {
  const NewPassword({super.key});

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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Create New Password",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "creating a new password",
                          style: TextStyle(color: AppColors.lightTextSecondary),
                        ),
                        const SizedBox(height: 25),

                        CustomTextField(
                            labelText: "New Password",
                            keyboardType: TextInputType.text,
                            controller: controller.passwordController,
                            suffixIcon: const Icon(Icons.visibility_off)
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                            labelText: "Confirm Password",
                            keyboardType: TextInputType.text,
                            controller: controller.confirmPassworController,
                            suffixIcon: const Icon(Icons.visibility_off)
                        ),

                        const SizedBox(height: 20),

                        // 🔵 Login Button
                        MyButton(
                          title: "Change Password",
                          onPressed: () {
                            controller.resetPassword();
                            //Get.to(RegistrationScreen());
                          },
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primary],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          height: 40,
                          borderRadius: 8,
                        ),
                           const SizedBox(height: 12),

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
}
