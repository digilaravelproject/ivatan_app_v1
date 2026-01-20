import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/features/auth/controller/register_controller.dart';
import 'package:i_vatan_app/features/auth/persentation/interest_screen.dart';
import 'package:i_vatan_app/features/auth/persentation/login_screen.dart';
import 'package:i_vatan_app/features/auth/persentation/verifyOtp.dart';
import 'package:i_vatan_app/route/app_pages.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/auth_input_fields.dart';

class RegistrationScreen extends GetWidget<RegisterController>  {
  RegistrationScreen({super.key});

  final RegisterController registerController = Get.find();

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
                   child: Form(
                     key: controller.formKey,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         const Text(
                           "Register",
                           style: TextStyle(
                             fontSize: 22,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                         const SizedBox(height: 6),
                         const Text(
                           "Please login with your credential",
                           style: TextStyle(color: AppColors.lightTextSecondary),
                         ),
                         const SizedBox(height: 25),
                         AuthInputFields(
                           textInputType: TextInputType.text,
                           controller: controller.nameController,
                           label: "Full NAME",
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
                         AuthInputFields(
                           textInputType: TextInputType.phone,
                           controller: controller.phoneController,
                           label: "Mobile No",
                           validator: controller.validatePhone,
                         ),
                         const SizedBox(height: 20),
                         AuthInputFields(
                           textInputType: TextInputType.name,
                           controller: controller.usernameController,
                           label: "User Name",
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
                           textInputType: TextInputType.none, // keyboard na aaye
                           controller: controller.dobController,
                           label: "Birthday",
                           validator: controller.validateDOB,
                           readOnly: true,                     // user type na kare
                           onTap: () => controller.pickDate(context),  // calendar open
                         ),
                         const SizedBox(height: 20),
                         // AuthInputFields(
                         //   textInputType: TextInputType.text,
                         //   controller: controller.occupationController,
                         //   label: "Occupation",
                         //   validator: controller.validateOccupation,
                         // ),

                         Obx(
                               () => DropdownButtonFormField<String>(
                             value: controller.selectedOccupation.value.isEmpty
                                 ? null
                                 : controller.selectedOccupation.value,
                             decoration: InputDecoration(
                               labelText: "Occupation",
                               floatingLabelStyle: TextStyle(
                                 color: Colors.blue,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                             items: controller.occupationList
                                 .map(
                                   (occupation) => DropdownMenuItem<String>(
                                 value: occupation,
                                 child: Text(occupation),
                               ),
                             )
                                 .toList(),
                             onChanged: (value) {
                               controller.selectedOccupation.value = value ?? "";
                               controller.occupationController.text = value ?? "";
                             },
                             validator: controller.validateOccupation,
                           ),
                         ),

                         const SizedBox(height: 20),
                         MyButton(
                           title: "Sign Up",
                           onPressed: () {
                             // registerController.interestsController.text =
                             //     selectedItems.join(",");
                                if (controller.formKey.currentState!.validate()) {
                                  registerController.onRegister();
                                 // Get.to(() => const InterestScreen());
                                }
                             //controller.onRegister();
                            // Get.to(InterestScreen());
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
                     
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text(
                               "Already have an account? ",
                               style: context.textTheme.bodyMedium?.copyWith(
                                 color: context.theme.colorScheme.onSurface.withValues(
                                   alpha: 0.7,
                                 ),
                               ),
                             ),
                             GestureDetector(
                               onTap: () => {
                                // Get.to(AppRoutes.login)
                                 Get.to(LoginPage())
                               },
                               child: Text(
                                 "Login",
                                 style: context.textTheme.bodyMedium?.copyWith(
                                   color: AppColors.primaryDark,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ),
                           ],
                         ),
                     
                       ],
                     ),
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
