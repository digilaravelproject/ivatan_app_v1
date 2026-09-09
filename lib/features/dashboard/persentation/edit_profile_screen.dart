import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/constants/app_sizer.dart';
import 'package:i_vatan_app/core/helper/custom_image_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/helper/custom_buttons.dart';
import '../../../core/helper/custom_dropdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../db/shared_pref_manager.dart';
import '../../auth/widgets/auth_input_fields.dart';
import '../controller/settings_controller.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});
  final String? currentUserName = SharedPrefManager().user?.username;

  @override
  Widget build(BuildContext context) {
    // Safely retrieve or initialize controller tag-based
    final profileController =
        Get.isRegistered<SettingsController>(tag: currentUserName)
            ? Get.find<SettingsController>(tag: currentUserName)
            : Get.put(
              SettingsController(userName: currentUserName ?? ""),
              tag: currentUserName,
            );

    return Scaffold(
      backgroundColor: AppColors.transparent, // Clean White Background
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back, color: AppColors.white),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        final userProfile = profileController.userProfile.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // PROFILE IMAGE SECTION
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Container(
                              width: 100,
                              height: 100,
                              color: AppColors.premiumGold.withOpacity(
                                0.1,
                              ), // Subtle background for avatars
                              child: Obx(() {
                                Widget avatarChild;
                                if (profileController.imageFile.value != null) {
                                  avatarChild = Center(
                                    key: ValueKey(
                                      profileController.imageFile.value!.path,
                                    ),
                                    child: Image.file(
                                      profileController.imageFile.value!,
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                } else if (userProfile?.profilePhotoPath !=
                                        null &&
                                    userProfile!.profilePhotoPath!.isNotEmpty) {
                                  avatarChild = CustomImageView(
                                    key: ValueKey(userProfile.profilePhotoPath),
                                    url: "${userProfile.profilePhotoPath}",
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  avatarChild = Center(
                                    key: ValueKey("placeholder"),
                                    child: Icon(
                                      Icons.person,
                                      size: 70,
                                      color: AppColors.premiumGold,
                                    ),
                                  );
                                }

                                return AnimatedSwitcher(
                                      duration: 400.ms,
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child:
                                          avatarChild
                                              .animate(
                                                key: ValueKey(avatarChild.key),
                                              )
                                              .scale(
                                                duration: 400.ms,
                                                curve: Curves.easeOutBack,
                                              )
                                              .fadeIn(),
                                    )
                                    .animate(
                                      onPlay:
                                          (controller) =>
                                              controller.repeat(reverse: true),
                                    )
                                    .moveY(
                                      begin: 0,
                                      end: -5,
                                      duration: 1500.ms,
                                      curve: Curves.easeInOut,
                                    );
                              }),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => profileController.showPickerOptions(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.white.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => profileController.showPickerOptions(),
                      child: const Text(
                        "Change Profile Photo",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "@${userProfile?.username ?? "username"}",
                style: TextStyle(color: AppColors.premiumGold, fontSize: 13),
              ),

              const SizedBox(height: 30),

              // FIELDS
              _buildCleanField(
                child: AuthInputFieldsBorder(
                  label: "Name",
                  textInputType: TextInputType.text,
                  controller: profileController.nameController,
                ),
              ),

              _buildCleanField(
                child: AuthInputFieldsBorder(
                  label: "Username",
                  textInputType: TextInputType.text,
                  controller: profileController.usernameController,
                ),
              ),

              _buildCleanField(
                child: AuthInputFieldsBorder(
                  label: "Email",
                  textInputType: TextInputType.emailAddress,
                  controller: profileController.emailController,
                  readOnly: true,
                ),
              ),

              _buildCleanField(
                child: AuthInputFieldsBorder(
                  label: "Mobile Number",
                  textInputType: TextInputType.phone,
                  controller: profileController.phoneController,
                  readOnly: true,
                ),
              ),

              _buildCleanField(
                child: AuthInputFieldsBorder(
                  label: "Bio",
                  textInputType: TextInputType.multiline,
                  controller: profileController.bioController,
                ),
              ),

              _buildCleanField(
                child: CustomSearchableDropdown(
                  label: "Occupation",
                  items: profileController.occupationList,
                  controller: profileController.occupationController,
                  onChanged: (value) {
                    profileController.selectedOccupation.value = value;
                  },
                  validator: profileController.validateOccupation,
                ),
              ),

              const SizedBox(height: 20),

              // BUTTON
              Obx(
                () =>
                    profileController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : MyButton(
                          title: "Save Changes",
                          textColor: AppColors.black,
                          onPressed: () {
                            profileController.updateProfile();
                          },
                          gradient: LinearGradient(
                            colors: [
                              AppColors.premiumGold,
                              AppColors.premiumGold,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          height: 50,
                          borderRadius: 25,
                        ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCleanField({required Widget child}) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: child);
  }
}
