import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_buttons.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/login_controller.dart';

class ForgetPassword extends GetWidget<LoginController> {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title
              Text(
                "Forgot Password?",
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Enter your phone number to receive an OTP",
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              // Phone number field
              IntlPhoneField(
                controller: controller.mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
                initialCountryCode: 'IN',
                onCountryChanged: (country) {
                  controller.countryCode.value = "+${country.dialCode}";
                },
                disableLengthCheck: true,
                dropdownIconPosition: IconPosition.trailing,
                flagsButtonPadding: const EdgeInsets.only(left: 12),
                showCountryFlag: true,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                keyboardType: TextInputType.phone,
                pickerDialogStyle: PickerDialogStyle(
                  backgroundColor: Colors.white,
                  searchFieldInputDecoration: InputDecoration(
                    labelText: 'Search Country',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  countryCodeStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  countryNameStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  listTilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              const SizedBox(height: 32),

              // Send OTP Button
              Obx(() => MyButton(
                title: "Send OTP",
                onPressed: () {
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
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                height: 50,
                borderRadius: 12,
                isLoading: controller.isLoading.value,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
