import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/custom_buttons.dart';
import '../../../core/helper/custom_dropdown.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../../../db/shared_pref_manager.dart';
import '../../job_portal/persentation/pages/delete_account_page.dart';
import '../../auth/widgets/profile_type_selector.dart';
import '../controller/settings_controller.dart';
import '../../subscription/controller/subscription_controller.dart';
import '../../subscription/persentation/profile_plans_screen.dart';
import '../../subscription/data/model/profile_switch_request.dart';

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
              /*Container(
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

              const SizedBox(height: 16,),*/

              // EMPLOYER TOGGLE
            /*  Obx(() => Container(
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
              */

              // _buildCleanField(
              //   child: CustomSearchableDropdown(
              //     label: "Page Category",
              //     items: profileController.pageCategoryList,
              //     controller: profileController.pageCategoryController,
              //     onChanged: (value) {
              //       profileController.selectedPageCategory.value = value;
              //     },
              //   ),
              // ),

              _buildCleanField(
                child: ProfileTypeSelector(
                  label: "Profile Type",
                  controller: profileController.profileTypeController,
                  profileTypes: profileController.profileTypes,
                  onSelected: (profileType, sellerType) {
                    profileController.switchProfileType(profileType, sellerType);
                  },
                ),
              ),

              // SELLER TOGGLE
              /*Obx(() => Container(
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
              )),*/

            //  const SizedBox(height: 16,),

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
                      //const Spacer(),
                     // const Icon(Icons.arrow_forward_ios_rounded,size: 18,)
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

              Obx(() {
                if (profileController.isLoadingSwitchRequests.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  );
                }

                if (profileController.switchRequests.isEmpty) {
                  return const SizedBox(height: 30);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 40),
                    const Text(
                      "Switch Progress Tracker",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: profileController.switchRequests.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final req = profileController.switchRequests[index];
                        return _buildSwitchRequestCard(req, profileController);
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  // Returns a display icon for each profile type from the API
  IconData _profileTypeIcon(String type) {
    switch (type) {
      case 'seller': return Icons.storefront_rounded;
      case 'employer': return Icons.business_center_rounded;
      case 'music': return Icons.music_note_rounded;
      case 'creator': return Icons.video_camera_back_rounded;
      case 'personal': return Icons.person_rounded;
      default: return Icons.verified_user_rounded;
    }
  }

  // Returns raw API type as a display label — seller gets subtype context
  String _profileTypeLabel(String type, String? subType) {
    if (type == 'seller') {
      final sub = subType ?? '';
      if (sub == 'product') return 'Product Seller';
      if (sub == 'service') return 'Service Provider';
      return 'Product & Service Seller';
    }
    // All other types: capitalize first letter of raw API value
    if (type.isEmpty) return type;
    return type[0].toUpperCase() + type.substring(1);
  }

  Widget _buildSwitchRequestCard(ProfileSwitchRequest req, SettingsController profileController) {
    final profileLabel = _profileTypeLabel(req.toProfileType, req.profileSubType);
    final profileIcon = _profileTypeIcon(req.toProfileType);

    final isApproved = req.status == 'approved' || req.status == 'active';
    final isRejected = req.status == 'rejected';

    // Status colour palette
    Color accentColor;
    Color statusBgColor;
    Color statusTextColor;
    IconData statusIcon;
    String statusText;

    if (isApproved) {
      accentColor = const Color(0xFF10B981);
      statusBgColor = const Color(0xFFD1FAE5);
      statusTextColor = const Color(0xFF065F46);
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Approved';
    } else if (isRejected) {
      accentColor = const Color(0xFFEF4444);
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFF991B1B);
      statusIcon = Icons.cancel_rounded;
      statusText = 'Rejected';
    } else {
      accentColor = const Color(0xFFF59E0B);
      statusBgColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFD97706);
      statusIcon = Icons.hourglass_top_rounded;
      statusText = 'Pending';
    }

    return GestureDetector(
      onTap: () async {
        final toType = req.toProfileType;
        // Employer has no subscription plan — show admin approval dialog
        if (toType == 'employer') {
          profileController.showAdminApprovalDialog(profileLabel);
        } else {
          // For all other types (including ecommerce, seller, music, etc.)
          // try to fetch their subscription plans from the API
          try {
            final subscriptionController = Get.put(SubscriptionController());
            final updatedSub = await subscriptionController.fetchPlansForProfileType(toType);
            if (updatedSub != null) {
              Get.to(() => ProfilePlansScreen(profileTypeSub: updatedSub));
            } else {
              // No plans found — treat as approval-only flow
              profileController.showAdminApprovalDialog(profileLabel);
            }
          } catch (e) {
            Get.snackbar('Error', 'Could not load plans: $e', snackPosition: SnackPosition.TOP);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(width: 4, color: accentColor),

                // Main card content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // Type icon circle
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor.withOpacity(0.25), width: 1.5),
                          ),
                          child: Icon(profileIcon, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),

                        // Label + notes
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                profileLabel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              if (req.userNotes != null && req.userNotes!.trim().isNotEmpty)
                                Text(
                                  req.userNotes!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                )
                              else
                                Text(
                                  'Tap to view details',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Status pill + chevron
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusTextColor.withOpacity(0.3), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, color: statusTextColor, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusTextColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.grey.shade400,
                              size: 11,
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
      ),
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
