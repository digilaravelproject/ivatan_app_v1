import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/core/constants/app_sizer.dart';
import 'package:i_vatan_app/core/helper/custom_image_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/helper/custom_buttons.dart';
import '../../../core/helper/custom_dropdown.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../../../db/shared_pref_manager.dart';
import '../../auth/widgets/auth_input_fields.dart';
import '../../job_portal/persentation/pages/delete_account_page.dart';
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
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
                          ),
                          child: ClipOval(
                            child: Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade50, // Subtle background for avatars
                              child: Obx(() {
                                Widget avatarChild;
                                if (profileController.imageFile.value != null) {
                                  avatarChild = Center(
                                    key: ValueKey(profileController.imageFile.value!.path),
                                    child: Image.file(
                                      profileController.imageFile.value!,
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                } else if (userProfile?.profilePhotoPath != null && userProfile!.profilePhotoPath!.isNotEmpty) {
                                  avatarChild = CustomImageView(
                                    key: ValueKey(userProfile!.profilePhotoPath),
                                    url: "${AppUrls.imageurl}${userProfile!.profilePhotoPath}",
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  avatarChild = const Center(
                                    key: ValueKey("placeholder"),
                                    child: Icon(Icons.person, size: 70, color: Colors.grey),
                                  );
                                }

                                return AnimatedSwitcher(
                                  duration: 400.ms,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(scale: animation, child: child),
                                    );
                                  },
                                  child: avatarChild
                                      .animate(key: ValueKey(avatarChild.key))
                                      .scale(duration: 400.ms, curve: Curves.easeOutBack)
                                      .fadeIn(),
                                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .moveY(begin: 0, end: -5, duration: 1500.ms, curve: Curves.easeInOut);
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
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
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
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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
                  readOnly: true, // Often email is not editable
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

             // const SizedBox(height: 10),
              
              // TOGGLES
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12,),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400)
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.black54),
                    const SizedBox(width: 12),
                    const Text("Private Account", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const Spacer(),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: profileController.isPrivate.value,
                        onChanged: (val) => profileController.isPrivate.value = val,
                        activeColor: AppColors.primary,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // CONTACT VISIBILITY
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.contact_phone_outlined, color: Colors.black54),
                        const SizedBox(width: 12),
                        const Text("Contact Visibility", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Column(
                      children: [
                        _buildVisibilityOption(
                          label: "Show Both (Phone & Email)",
                          value: 'both',
                          groupValue: profileController.contactVisibility.value,
                          onChanged: (val) => profileController.contactVisibility.value = val!,
                        ),
                        _buildVisibilityOption(
                          label: "Show Phone Only",
                          value: 'phone',
                          groupValue: profileController.contactVisibility.value,
                          onChanged: (val) => profileController.contactVisibility.value = val!,
                        ),
                        _buildVisibilityOption(
                          label: "Show Email Only",
                          value: 'email',
                          groupValue: profileController.contactVisibility.value,
                          onChanged: (val) => profileController.contactVisibility.value = val!,
                        ),
                        _buildVisibilityOption(
                          label: "Hide Contact Button",
                          value: 'none',
                          groupValue: profileController.contactVisibility.value,
                          onChanged: (val) => profileController.contactVisibility.value = val!,
                        ),
                      ],
                    )),
                  ],
                ),
              ),

              SizedBox(height: 16,),


              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    builder: (context) {
                      final profileTypes = [
                        {'icon': Icons.videocam_outlined, 'title': 'Creator Profile', 'type': AppUrls.creator},
                        {'icon': Icons.music_note_outlined, 'title': 'Music Profile', 'type': AppUrls.music},
                        {'icon': Icons.business_outlined, 'title': 'Business (Service based)', 'type': AppUrls.businessService},
                        {'icon': Icons.store_outlined, 'title': 'Business (Product based)', 'type': AppUrls.businessProduct},
                        {'icon': Icons.work_outline, 'title': 'Recruiter', 'type': AppUrls.recruiter},
                        {'icon': Icons.person_search_outlined, 'title': 'Applier', 'type': AppUrls.applier},
                      ];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Switch Account',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Flexible(
                              child: ListView(
                                shrinkWrap: true,
                                children: profileTypes.map((type) => ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(type['icon'] as IconData, color: AppColors.primary),
                                  ),
                                  title: Text(
                                    type['title'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                                  onTap: () {
                                    AppUrls.selectedUserType.value = type['type'] as String;
                                    Navigator.pop(context);
                                    Get.snackbar(
                                      "Account Switched", 
                                      "Switched to ${type['title']}",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: AppColors.primary.withOpacity(0.1),
                                      colorText: AppColors.primary,
                                    );
                                  },
                                )).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400)
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Text("Switch Account", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded,size: 18,)
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16,),

              GestureDetector(
                onTap: (){
                  Get.to(AccountDeleteReasonScreen());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400)
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Text("Delete Account", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded,size: 18,)
                    ],
                  ),
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

  Widget _buildCleanField({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: child,
    );
  }

  Widget _buildVisibilityOption({
    required String label,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
