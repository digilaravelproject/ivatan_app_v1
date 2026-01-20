import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/custom_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/login_controller.dart';
import '../widgets/auth_input_fields.dart';

class VerifyOtp extends StatelessWidget {
  final String verificationId;
  final String phoneNumber;

  const VerifyOtp({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoginController _controller = Get.find<LoginController>();
    final TextEditingController _otpController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
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
                          "Enter the OTP",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Please enter the OTP sent to $phoneNumber",
                          style: const TextStyle(
                            color: AppColors.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),

                        CustomTextField(
                          controller: _otpController,
                          labelText: "OTP",
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 20),

                        Obx(
                          () => MyButton(
                            title:
                                _controller.isLoading.value
                                    ? "Verifying..."
                                    : "Verify",
                            onPressed:
                                _controller.isLoading.value
                                    ? null
                                    : () async {
                                      String otp = _otpController.text.trim();
                                      if (otp.length != 6) {
                                        Get.snackbar(
                                          "Error",
                                          "Enter valid 6-digit OTP",
                                        );
                                        return;
                                      }
                                      await _controller.verifyOTP(
                                        verificationId,
                                        otp,
                                      );
                                    },
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primary],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            height: 40,
                            borderRadius: 8,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                           // _controller.sendOTP(); // Re-send OTP
                          },
                          child: const Text(
                            "Try Another Way",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
