import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/features/auth/persentation/verifyOtp.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_buttons.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/auth_input_fields.dart';
import '../controller/login_controller.dart';
import 'new_password.dart';

class ForgetPassword extends GetWidget<LoginController> {
  const ForgetPassword({super.key});

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
                  color: Colors.black.withOpacity(0.1),
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
              child:  Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Forget Password",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Please enter your email id we will send the otp in this email",
                            style: TextStyle(color: AppColors.lightTextSecondary),
                          ),
                          const SizedBox(height: 25),

                          // 📱 Mobile number field
                          AuthInputFieldsBorder(
                            textInputType: TextInputType.phone,
                            controller: controller.mobileController,
                            label: "Mobile Number",
                            validator: controller.validatePhone,
                          ),

                          const SizedBox(height: 20),

                          // 🔵 Login Button
                          MyButton(
                            title: "Continue",
                      onPressed: (){
                        // ✅ Login with OTP
                        if (controller.validatePhone(controller.mobileController.text) != null) {
                          if (controller.mobileController.text.isEmpty) {
                            CustomSnackBar.showError(message: "Please enter mobile number");
                            return;
                          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(controller.mobileController.text)) {
                            CustomSnackBar.showError(message: "Enter a valid 10-digit phone number");
                            return;
                          }
                          return;
                        }
                        controller.sendOTP(flowType: OtpFlowType.forgetPassword);
                      },
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primary],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      height: 40,
                      borderRadius: 8,
                      isLoading: controller.isLoading.value,
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