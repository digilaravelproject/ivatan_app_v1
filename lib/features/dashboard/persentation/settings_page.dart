import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/core/constants/app_sizer.dart';
import 'package:i_vatan_app/core/helper/custom_image_view.dart';

import '../../../core/helper/custom_buttons.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../../../db/shared_pref_manager.dart';
import '../../auth/widgets/auth_input_fields.dart';
import '../controller/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final String? currentUserName = SharedPrefManager().user?.username;

  @override
  Widget build(BuildContext context) {
    // Avoid duplicate controller tags if possible, or handle gracefully
    final profileController = Get.put(
      SettingsController(userName: currentUserName ?? ""),
      tag: currentUserName,
    );

    return Scaffold(
      backgroundColor: AppColors.white, // Clean White Background
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: const Icon(CupertinoIcons.back, color: Colors.black)),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Obx((){
        final userProfile = profileController.userProfile.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // PROFILE IMAGE SECTION
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: profileController.imageFile.value != null
                              ? Image.file(profileController.imageFile.value!, fit: BoxFit.cover)
                              : (userProfile?.profilePhotoPath != null && userProfile!.profilePhotoPath!.isNotEmpty)
                                  ? CustomImageView(
                                      url: "${AppUrls.imageurl}${userProfile!.profilePhotoPath}",
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey.shade100,
                                      child: Icon(Icons.person, size: 60, color: Colors.grey.shade400),
                                    ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => profileController.showPickerOptions(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                userProfile?.username ?? "Username",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 30),

              // FIELDS
              _buildCleanField(
                label: "Name",
                child: AuthInputFieldsBorder(
                  label: "Enter your name",
                  textInputType: TextInputType.text,
                  controller: profileController.nameController,
                ),
              ),

              _buildCleanField(
                label: "Username",
                child: AuthInputFieldsBorder(
                  label: "Enter username",
                  textInputType: TextInputType.text,
                  controller: profileController.usernameController,
                ),
              ),

              _buildCleanField(
                label: "Email",
                child: AuthInputFieldsBorder(
                  label: "Enter email",
                  textInputType: TextInputType.emailAddress,
                  controller: profileController.emailController,
                  readOnly: true, // Often email is not editable
                ),
              ),
              
              _buildCleanField(
                label: "Bio",
                child: AuthInputFieldsBorder(
                  label: "Write something about you...",
                  textInputType: TextInputType.multiline,
                  controller: profileController.bioController,
                ),
              ),
              
               _buildCleanField(
                label: "Occupation",
                child: AuthInputFieldsBorder(
                  label: "What do you do?",
                  textInputType: TextInputType.text,
                  controller: profileController.occupationController,
                ),
              ),

              const SizedBox(height: 10),
              
              // TOGGLES
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.black54),
                    const SizedBox(width: 12),
                    const Text("Private Account", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const Spacer(),
                    Switch(
                      value: profileController.isPrivate.value,
                      onChanged: (val) => profileController.isPrivate.value = val,
                      activeColor: AppColors.primary,
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // BUTTON
               Obx(
                    () => profileController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : MyButton(
                  title: "Save Changes",
                  onPressed: () {
                    profileController.updateProfile();
                  },
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primary], // Solid Primary Color
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  height: 50,
                  borderRadius: 25, // Pill shape
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCleanField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
