import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../controller/login_controller.dart';
import '../../../core/helper/custom_buttons.dart';

class VerifyOtp extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const VerifyOtp({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final LoginController _controller = Get.find<LoginController>();
  final TextEditingController _otpController = TextEditingController();
  
  // Timer logic typically belongs in controller, but simple visual timer here for now
  // For this step, I'll keep it static or minimal as user asked for UI.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black, onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Icon
             // Container(
              //  padding: const EdgeInsets.all(16),
                // decoration: BoxDecoration(
                //   color: AppColors.primary.withOpacity(0.1),
                //   shape: BoxShape.circle,
                // ),
               // child:
                Image.asset(AppAssets.AppLogo,height: 100,width: 100,),
                // const Icon(
                //   Icons.lock_outline_rounded,
                //   size: 40,
                //   color: AppColors.primary,
                // ),
             // ),
              const SizedBox(height: 24),

              // Title
              const Text(
                "Verification Code",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                "We have sent the code verification to\n${widget.phoneNumber}", // Masking logic can be added if needed
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // OTP Input Field (Premium Style)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16, // Spacing to mimic individual boxes
                    color: AppColors.primary,
                  ),
                  decoration: const InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    hintText: "- - - - - -",
                    hintStyle: TextStyle(
                      letterSpacing: 16,
                      color: Colors.black12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Timer / Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  GestureDetector(
                    onTap: () {
                     // _controller.sendOTP(...); // Logic needs flow type
                    },
                    child: const Text(
                      "Resend",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // Verify Button
              Obx(() => MyButton(
                title: _controller.isLoading.value ? "Verifying..." : "Verify & Continue",
                onPressed: _controller.isLoading.value
                    ? () {}
                    : () async {
                        String otp = _otpController.text.trim();
                        if (otp.length != 6) {
                          Get.snackbar("Invalid Code", "Please enter a 6-digit code");
                          return;
                        }
                        await _controller.verifyOTP(widget.verificationId, otp, phoneNumber: widget.phoneNumber);
                      },
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                height: 52,
                borderRadius: 16,
              )),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
