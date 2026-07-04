import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/auth/widgets/custom_phone_field.dart';
import 'package:i_vatan_app/core/helper/custom_image_view.dart';
import 'package:i_vatan_app/core/utils/app_decoration.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_buttons.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/basic_text_field.dart';
import '../../../core/utils/custom_buttons.dart';
import '../controller/login_controller.dart';
import '../widgets/auth_input_fields.dart';
import 'forget_password.dart';
import 'interest_screen.dart';

class LoginPage extends GetWidget<LoginController> {
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.05),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Top decorative elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Logo/Brand section
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.1),
                                  AppColors.primaryLight.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.15),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  AppAssets.imgAppLogo,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "iVatan",
                            style: context.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Welcome Back!",
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom sheet with form
                  Expanded(
                    flex: 3,
                    child: Form(
                      key: controller.formKey,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 25,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Handle bar
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Welcome Text
                              Text(
                                "Welcome Back! 👋",
                                style: context.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  fontSize: 26,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Sign in to continue your journey",
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Input Fields
                              Obx(() {
                                return AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Column(
                                    children: [
                                      CustomPhoneField(
                                        controller: controller.mobileController,
                                        countryCode: controller.countryCode,
                                        labelText: 'Mobile Number',
                                      ),

                                      // Password Input (conditional)
                                      if (!controller.isLoginPass.value) ...[
                                        const SizedBox(height: 16),
                                        AuthInputFields(
                                          controller: controller.passwordController,
                                          label: "Password",
                                          textInputType: TextInputType.visiblePassword,
                                          isObscure: !controller.isPasswordVisible.value,
                                          endIcon: controller.isPasswordVisible.value
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          onEndIconTap: () => controller.isPasswordVisible.toggle(),
                                          validator: controller.validatePassword,
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),

                              const SizedBox(height: 20),

                              // Login method toggle
                              Obx(
                                    () => InkWell(
                                  onTap: () => controller.isLoginPass.toggle(),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: controller.isLoginPass.value
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: controller.isLoginPass.value
                                                ? AppColors.primary
                                                : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: controller.isLoginPass.value
                                            ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Login with OTP",
                                        style: context.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Login Button
                              Obx(
                                    () => MyButton(
                                  title: "Continue",
                                  onPressed: () {
                                    if (controller.isLoginPass.value) {
                                      if (controller.validatePhone(
                                          controller.mobileController.text) !=
                                          null) {
                                        if (controller.mobileController.text.isEmpty) {
                                          CustomSnackBar.showError(
                                              message: "Please enter mobile number");
                                          return;
                                        } else if (!RegExp(r'^[0-9]{10}$')
                                            .hasMatch(controller.mobileController.text)) {
                                          CustomSnackBar.showError(
                                              message:
                                              "Enter a valid 10-digit phone number");
                                          return;
                                        }
                                        return;
                                      }
                                      controller.sendOTP(flowType: OtpFlowType.login);
                                    } else {
                                      controller.callPasswordLogin();
                                    }
                                  },
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.primaryDark],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  height: 54,
                                  borderRadius: 12,
                                  isLoading: controller.isLoading.value,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Forgot Password
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Get.to(() => ForgetPassword());
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      "OR",
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Sign Up
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Register",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Get.to(() => InterestScreen());
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: context.mediaQueryPadding.bottom + 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:i_vatan_app/core/helper/custom_image_view.dart';
// import 'package:i_vatan_app/core/utils/app_decoration.dart';
//
// import '../../../core/constants/app_assets.dart';
// import '../../../core/helper/custom_buttons.dart';
// import '../../../core/helper/custom_snack_bar.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/utils/basic_text_field.dart';
// import '../../../core/utils/custom_buttons.dart';
// import '../controller/login_controller.dart';
// import '../widgets/auth_input_fields.dart';
// import 'forget_password.dart';
// import 'interest_screen.dart';
//
// class LoginPage extends GetWidget<LoginController> {
//   LoginPage({super.key});
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.theme.primaryColorLight,
//       extendBody: true,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFFFFFFFF),
//               Color(0xFFFFFFFF),
//               Color(0xFFFFFFFF),
//               Color(0xFFFFFFFF),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Stack(
//           children: [
//             Form(
//               key: controller.formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     decoration: AppDecorations.bottomSheetDecoration(context),
//                     child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Handle bar
//                           Center(
//                             child: Container(
//                               width: 50,
//                               height: 4,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade300,
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 30),
//
//                           // Welcome Text
//                           Text(
//                             "Login with i-app",
//                             style: context.textTheme.headlineSmall?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             "Enter your mobile number and start connecting with i_app!",
//                             style: context.textTheme.bodyMedium?.copyWith(
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           /// Phone Number Input
//                           ///
//                           Obx((){
//                             return  Column(
//                               children: [
//                                 AuthInputFieldsBorder(
//                                   textInputType: TextInputType.phone,
//                                   controller: controller.mobileController,
//                                   label: "Mobile Number",
//                                   validator: controller.validatePhone,
//                                 ),
//                                 if(controller.isLoginPass.value) ...[
//                                   // ValueListenableBuilder(
//                                   //   valueListenable:
//                                   //   controller.mobileController,
//                                   //   builder: (context, value, child) {
//                                   //     return Text(
//                                   //       'We will send OTP on \n ${controller.mobileController.text} to verify you',
//                                   //       style: context.textTheme.titleMedium,
//                                   //       textAlign: TextAlign.center,
//                                   //     );
//                                   //   },
//                                   // ).marginOnly(top: 30, bottom: 11),
//                                 ]
//                                 else ...[
//                                   AuthInputFieldsBorder(
//                                     textInputType: TextInputType.visiblePassword,
//                                     controller: controller.passwordController,
//                                     label: "Password",
//                                     isObscure: !controller.isPasswordVisible.value,
//                                     endIcon:
//                                     controller.isPasswordVisible.value
//                                         ? Icons.remove_red_eye_rounded
//                                         : Icons.visibility_off,
//                                     onEndIconTap:
//                                         () => controller.isPasswordVisible.toggle(),
//                                     validator: controller.validatePassword,
//                                   ).marginOnly(top: 12),
//                                 ]
//                               ],
//                             );
//                           }),
//
//                           Obx(
//                                 () => Row(
//                               children: [
//                                 SizedBox(
//                                   width: 24,
//                                   height: 24,
//                                   child: Checkbox(
//                                     value: controller.isLoginPass.value,
//                                     onChanged: (v) {
//                                       controller.isLoginPass.toggle();
//                                     },
//                                     activeColor: AppColors.primary,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Text(
//                                   "Login with otp",
//                                   style: context.textTheme.bodyMedium?.copyWith(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ).marginSymmetric(vertical: 22),
//
//
//                           Obx(
//                             () => MyButton(
//                               title: "Login",
//                               onPressed: () {
//                                 if (controller.isLoginPass.value) {
//                                   // ✅ Login with OTP
//                                   if (controller.validatePhone(controller.mobileController.text) != null) {
//                                     if (controller.mobileController.text.isEmpty) {
//                                       CustomSnackBar.showError(message: "Please enter mobile number");
//                                       return;
//                                     } else if (!RegExp(r'^[0-9]{10}$').hasMatch(controller.mobileController.text)) {
//                                       CustomSnackBar.showError(message: "Enter a valid 10-digit phone number");
//                                       return;
//                                     }
//                                     return;
//                                   }
//                                   controller.sendOTP(flowType: OtpFlowType.login);
//                                 } else {
//                                   // ✅ Login with Password
//                                   controller.callPasswordLogin();
//                                 }
//                                // controller.sendOTP(flowType: OtpFlowType.login);
//                               },
//                               gradient: const LinearGradient(
//                                 colors: [AppColors.primary, AppColors.primary],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                               height: 40,
//                               borderRadius: 8,
//                               isLoading: controller.isLoading.value,
//                             ),
//                           ),
//                           Center(
//                             child: TextButton(
//                               onPressed: () {
//                                 Get.to(ForgetPassword());
//                               },
//                               child: const Text(
//                                 "Forgot your password?",
//                                 style: TextStyle(
//                                   color: Colors.red,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "I don’t have an account? ",
//                                 style: context.textTheme.bodyMedium?.copyWith(
//                                   color: context.theme.colorScheme.onSurface
//                                       .withValues(alpha: 0.7),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () => {Get.to(InterestScreen())},
//                                 child: Text(
//                                   "Register",
//                                   style: context.textTheme.bodyMedium?.copyWith(
//                                     color: AppColors.primaryDark,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: context.mediaQueryPadding.bottom),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
