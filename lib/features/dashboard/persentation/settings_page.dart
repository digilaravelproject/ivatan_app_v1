import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/custom_buttons.dart';
import '../../../core/helper/custom_dropdown.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../../../db/shared_pref_manager.dart';
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
        title: const Text("Settings", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Obx((){
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 15),

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

              const SizedBox(height: 16,),

              // EMPLOYER TOGGLE
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12,),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400)
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_outline, color: Colors.black54),
                    const SizedBox(width: 12),
                    const Text("Employer Account", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const Spacer(),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: profileController.isEmployer.value,
                        onChanged: (val) {
                          profileController.isEmployer.value = val;
                          // If switching to employer, optionally update AppUrls globally
                          if (val) AppUrls.selectedUserType.value = AppUrls.employer;
                          profileController.updateProfile(shouldGoBack: true);
                        },
                        activeColor: AppColors.primary,
                      ),
                    )
                  ],
                ),
              )),

              const SizedBox(height: 16),
              
              _buildCleanField(
                child: CustomSearchableDropdown(
                  label: "Page Category",
                  items: profileController.pageCategoryList,
                  controller: profileController.pageCategoryController,
                  onChanged: (value) {
                    profileController.selectedPageCategory.value = value;
                  },
                ),
              ),

              // SELLER TOGGLE
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12,),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400)
                ),
                child: Row(
                  children: [
                    const Icon(Icons.store_outlined, color: Colors.black54),
                    const SizedBox(width: 12),
                    const Text("Seller Account", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const Spacer(),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: profileController.isSeller.value,
                        onChanged: (val) {
                          profileController.isSeller.value = val;
                          // If switching to seller, optionally update AppUrls globally
                          if (val) AppUrls.selectedUserType.value = AppUrls.seller;
                          profileController.updateProfile(shouldGoBack: true);
                        },
                        activeColor: AppColors.primary,
                      ),
                    )
                  ],
                ),
              )),

              const SizedBox(height: 16,),

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
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded,size: 18,)
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
