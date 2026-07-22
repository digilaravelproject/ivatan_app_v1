import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/auth/widgets/custom_phone_field.dart';
import 'package:i_vatan_app/features/auth/controller/register_controller.dart';
import 'package:i_vatan_app/features/auth/persentation/login_screen.dart';

import '../../../core/helper/custom_buttons.dart';
import '../../../core/helper/custom_dropdown.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/auth_input_fields.dart';
import '../widgets/profile_type_selector.dart';

class RegistrationScreen extends GetWidget<RegisterController> {
  RegistrationScreen({super.key});

  final RegisterController registerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "Step 2/2",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  "One last step",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Fill in the details below to complete your profile.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                AuthInputFields(
                  textInputType: TextInputType.text,
                  controller: controller.nameController,
                  label: "Full Name",
                  validator: controller.validateName,
                ),
                const SizedBox(height: 20),
                AuthInputFields(
                  textInputType: TextInputType.emailAddress,
                  controller: controller.emailController,
                  label: "Email",
                  validator: controller.validateEmail,
                ),
                const SizedBox(height: 20),
                CustomPhoneField(
                  controller: controller.phoneController,
                  countryCode: controller.countryCode,
                  labelText: 'Mobile No',
                  enabled: controller.phoneController.text.isEmpty,
                  suffixIcon: controller.phoneController.text.isNotEmpty
                      ? const Icon(Icons.lock, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 20),
                AuthInputFields(
                  textInputType: TextInputType.name,
                  controller: controller.usernameController,
                  label: "Username",
                  validator: controller.validateUsername,
                ),
                const SizedBox(height: 20),
                Obx(
                  () => AuthInputFields(
                    textInputType: TextInputType.visiblePassword,
                    controller: controller.passwordController,
                    label: "Password",
                    isObscure: !controller.isPasswordObscure.value,
                    endIcon: controller.isPasswordObscure.value
                        ? Icons.remove_red_eye_rounded
                        : Icons.visibility_off,
                    onEndIconTap: () => controller.isPasswordObscure.toggle(),
                    validator: controller.validatePassword,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => AuthInputFields(
                    textInputType: TextInputType.visiblePassword,
                    controller: controller.confirmPassworController,
                    label: "Confirm Password",
                    isObscure: !controller.isPasswordObscure.value,
                    endIcon: controller.isPasswordObscure.value
                        ? Icons.remove_red_eye_rounded
                        : Icons.visibility_off,
                    onEndIconTap: () => controller.isPasswordObscure.toggle(),
                    validator: controller.validateConfirmPassword,
                  ),
                ),
                const SizedBox(height: 20),
                AuthInputFields(
                  textInputType: TextInputType.none,
                  controller: controller.dobController,
                  label: "Birthday",
                  validator: controller.validateDOB,
                  readOnly: true,
                  onTap: () => controller.pickDate(context),
                  endIcon: Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 20),

                // Occupation Dropdown (Custom Searchable)
                CustomSearchableDropdown(
                  label: "Occupation",
                  controller: controller.occupationController,
                  items: controller.occupationList,
                  onChanged: (value) {
                    controller.selectedOccupation.value = value;
                  },
                  validator: controller.validateOccupation,
                ),

                Obx(() => controller.selectedOccupation.value == "Others (Not Found! Any More creative.)"
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: AuthInputFields(
                          textInputType: TextInputType.text,
                          controller: controller.customOccupationController,
                          label: "Enter Occupation",
                          validator: controller.validateCustomOccupation,
                        ),
                      )
                    : const SizedBox.shrink()),

                const SizedBox(height: 20),

                // Profile Type Selection
                ProfileTypeSelector(
                  label: "Profile Type",
                  controller: controller.profileTypeController,
                  profileTypes: controller.profileTypes,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please select a profile type";
                    }
                    return null;
                  },
                  onSelected: (profileType, sellerType) {
                    controller.selectedProfileType.value = profileType;
                    controller.selectedSellerType.value = sellerType;
                    if (profileType.type == 'seller' && sellerType.isNotEmpty) {
                      controller.profileTypeController.text = "${profileType.label} (${sellerType.capitalizeFirst ?? sellerType})";
                      controller.sellerTypeController.text = sellerType;
                    } else {
                      controller.profileTypeController.text = profileType.label;
                      controller.sellerTypeController.clear();
                    }
                  },
                ),

                const SizedBox(height: 40),

                // Submit Button
                Obx(
                  () => MyButton(
                    title: "Create Account",
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (controller.formKey.currentState!.validate()) {
                        registerController.onRegister();
                      }
                    },
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark], // Black Gradient
                    ),
                    height: 52,
                    borderRadius: 12,
                  ),
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => LoginPage());
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
