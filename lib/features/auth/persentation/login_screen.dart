import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // final LoginController controller =
  // Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.primaryColorLight,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // vsync: controller,
        // behaviour: RandomParticleBehaviour(
        //   options: ParticleOptions(
        //     maxOpacity: 0.9,
        //     minOpacity: 0.3,
        //     baseColor: context.theme.colorScheme.onPrimary,
        //     opacityChangeRate: 0.75,
        //     particleCount: 70,
        //     spawnMaxSpeed: 80,
        //     spawnMinSpeed: 30,
        //     image: Image.asset(
        //       AppAssets.imgAppLogo,
        //       height: 50,
        //       width: 50,
        //       color: context.theme.colorScheme.onPrimary,
        //     ),
        //   ),
        // ),
        child: Stack(
          children: [
            Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: AppDecorations.bottomSheetDecoration(context),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Welcome Text
                          Text(
                            "Login with i-app",
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Enter your mobile number and start connecting with i_app!",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// Phone Number Input
                          ///
                          Obx((){
                            return  Column(
                              children: [
                                AuthInputFieldsBorder(
                                  textInputType: TextInputType.phone,
                                  controller: controller.mobileController,
                                  label: "Mobile Number",
                                  validator: controller.validatePhone,
                                ),
                                if(controller.isLoginPass.value) ...[
                                  // ValueListenableBuilder(
                                  //   valueListenable:
                                  //   controller.mobileController,
                                  //   builder: (context, value, child) {
                                  //     return Text(
                                  //       'We will send OTP on \n ${controller.mobileController.text} to verify you',
                                  //       style: context.textTheme.titleMedium,
                                  //       textAlign: TextAlign.center,
                                  //     );
                                  //   },
                                  // ).marginOnly(top: 30, bottom: 11),
                                ]
                                else ...[
                                  AuthInputFieldsBorder(
                                    textInputType: TextInputType.visiblePassword,
                                    controller: controller.passwordController,
                                    label: "Password",
                                    isObscure: !controller.isPasswordVisible.value,
                                    endIcon:
                                    controller.isPasswordVisible.value
                                        ? Icons.remove_red_eye_rounded
                                        : Icons.visibility_off,
                                    onEndIconTap:
                                        () => controller.isPasswordVisible.toggle(),
                                    validator: controller.validatePassword,
                                  ).marginOnly(top: 12),
                                ]
                              ],
                            );
                          }),

                          Obx(
                                () => Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: controller.isLoginPass.value,
                                    onChanged: (v) {
                                      controller.isLoginPass.toggle();
                                    },
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Login with otp",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ).marginSymmetric(vertical: 22),


                          Obx(
                            () => MyButton(
                              title: "Login",
                              onPressed: () {
                                if (controller.isLoginPass.value) {
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
                                  controller.sendOTP(flowType: OtpFlowType.login);
                                } else {
                                  // ✅ Login with Password
                                  controller.callPasswordLogin();
                                }
                               // controller.sendOTP(flowType: OtpFlowType.login);
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
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Get.to(ForgetPassword());
                              },
                              child: const Text(
                                "Forgot your password?",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "I don’t have an account? ",
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => {Get.to(InterestScreen())},
                                child: Text(
                                  "Register",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Terms and Privacy
                          // Center(
                          //   child: RichText(
                          //     textAlign: TextAlign.center,
                          //     text: TextSpan(
                          //       style: TextStyle(
                          //         color: Colors.grey.shade500,
                          //         fontSize: 12,
                          //         height: 1.4,
                          //       ),
                          //       children: [
                          //         const TextSpan(
                          //           text: "By continuing, you agree to our\n",
                          //         ),
                          //         TextSpan(
                          //           text: "Privacy Policy",
                          //           style: TextStyle(
                          //             color: context.theme.primaryColor,
                          //             decoration: TextDecoration.underline,
                          //             fontWeight: FontWeight.w500,
                          //           ),
                          //           recognizer: TapGestureRecognizer()
                          //             ..onTap = () {
                          //               debugPrint("Privacy Policy clicked");
                          //             },
                          //         ),
                          //         const TextSpan(text: " and "),
                          //         TextSpan(
                          //           text: "Terms of Service",
                          //           style: TextStyle(
                          //             color: context.theme.primaryColor,
                          //             decoration: TextDecoration.underline,
                          //             fontWeight: FontWeight.w500,
                          //           ),
                          //           recognizer: TapGestureRecognizer()
                          //             ..onTap = () {
                          //               debugPrint("Terms of Service clicked");
                          //             },
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: context.mediaQueryPadding.bottom),
                        ],
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
