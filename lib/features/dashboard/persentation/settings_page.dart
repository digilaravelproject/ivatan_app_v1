import 'package:i_vatan_app/core/theme/app_colors.dart';
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
import '../../../core/helper/profile_permission_manager.dart' as ppm;
import '../controller/homeController.dart';
import '../../subscription/persentation/subscription_history_screen.dart';
import 'blocked_users_screen.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final String? currentUserName = SharedPrefManager().user?.username;

  // Using reactive variables from controller instead of static ones

  @override
  Widget build(BuildContext context) {
    // Avoid duplicate controller tags if possible, or handle gracefully
    final profileController = Get.put(
      SettingsController(userName: currentUserName ?? ""),
      tag: currentUserName,
    );

    return Scaffold(
      // backgroundColor: const Color(0xFFF8F9FA), // Clean, slightly off-white background
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.back, color: AppColors.white),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              _buildSectionHeader("Privacy"),
              const SizedBox(height: 16),

              // PRIVATE ACCOUNT TOGGLE
              Container(
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.premiumGold),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.premiumGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.premiumGold,
                    ),
                  ),
                  title: const Text(
                    "Private Account",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                  subtitle: const Text(
                    "Only approved followers can see what you share",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      height: 1.3,
                    ),
                  ),
                  trailing: CupertinoSwitch(
                    value: profileController.isPrivate.value,
                    activeColor: AppColors.primary,
                    onChanged: (val) => profileController.isPrivate.value = val,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // SHOW EMAIL TOGGLE (STATIC UI)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.premiumGold),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.email_outlined, color: Colors.blue),
                  ),
                  title: const Text(
                    "Show Email",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                  subtitle: const Text(
                    "Display your email address on your profile",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      height: 1.3,
                    ),
                  ),
                  trailing: Obx(
                    () => CupertinoSwitch(
                      value: profileController.showEmail.value,
                      activeColor: AppColors.primary,
                      onChanged:
                          (val) => profileController.showEmail.value = val,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // SHOW PHONE TOGGLE (STATIC UI)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.premiumGold),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_outlined,
                      color: Colors.green,
                    ),
                  ),
                  title: const Text(
                    "Show Phone Number",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                  subtitle: const Text(
                    "Display your phone number on your profile",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      height: 1.3,
                    ),
                  ),
                  trailing: Obx(
                    () => CupertinoSwitch(
                      value: profileController.showPhone.value,
                      activeColor: AppColors.primary,
                      onChanged:
                          (val) => profileController.showPhone.value = val,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),
              _buildSectionHeader("Profile Settings"),
              const SizedBox(height: 16),

              ProfileTypeSelector(
                  label: "Current Profile",
                  controller: profileController.profileTypeController,
                  profileTypes: profileController.profileTypes,
                  enabled: !profileController.hasPendingRequest,
                  onSelected: (profileType, sellerType) async {
                    if ((profileType.type == 'seller' ||
                            profileType.type == 'ecommerce') &&
                        sellerType == 'both') {
                      final homeController =
                          Get.isRegistered<HomeController>()
                              ? Get.find<HomeController>()
                              : Get.put(HomeController());

                      Get.dialog(
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        ),
                        barrierDismissible: false,
                      );

                      try {
                        await homeController.fetchProfileConfig();
                      } catch (e) {
                        print("Error updating profile config: $e");
                      } finally {
                        Get.back();
                      }

                      final ecommerceProfileId =
                          homeController
                              .profileConfig
                              .value
                              ?.data
                              ?.ecommerce
                              ?.profileId;

                      try {
                        final subscriptionController =
                            Get.isRegistered<SubscriptionController>()
                                ? Get.find<SubscriptionController>()
                                : Get.put(SubscriptionController());
                        final updatedSub = await subscriptionController
                            .fetchPlansForProfileType(
                              profileType.type == 'ecommerce'
                                  ? 'seller'
                                  : profileType.type,
                              profileId: ecommerceProfileId,
                            );
                        if (updatedSub != null) {
                          Get.to(
                            () =>
                                ProfilePlansScreen(profileTypeSub: updatedSub),
                          );
                        } else {
                          Get.snackbar(
                            "Error",
                            "Could not load subscription plans",
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          "Error",
                          "Something went wrong loading plans: $e",
                        );
                      }
                      return;
                    }
                    profileController.switchProfileType(
                      profileType,
                      sellerType,
                    );
                  },
                ),

              const SizedBox(height: 12),
              _buildSectionHeader("Account Actions"),
              const SizedBox(height: 16),

              _buildActionTile(
                title: "Subscription History",
                icon: Icons.history_rounded,
                color: Colors.green,
                onTap: () => Get.to(() => SubscriptionHistoryScreen()),
              ),

              const SizedBox(height: 12),

              _buildActionTile(
                title: "Delete Account",
                icon: Icons.delete_outline_rounded,
                color: Colors.red,
                onTap: () => Get.to(() => AccountDeleteReasonScreen()),
              ),

              const SizedBox(height: 12),

              _buildActionTile(
                title: "Blocked Account",
                icon: Icons.block,
                color: Colors.red,
                onTap: () => Get.to(() => BlockedUsersScreen()),
              ),

              const SizedBox(height: 40),

              // BUTTON
              Obx(
                () =>
                    profileController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : MyButton(
                          title: "Save Changes",
                          onPressed: () {
                            profileController.updateProfile();
                          },
                          textColor: AppColors.black,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.premiumGold,
                              AppColors.premiumGold,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          height: 55,
                          borderRadius: 28, // Pill shape
                          // fontSize: 16,
                          // fontWeight: FontWeight.bold,
                        ),
              ),

              Obx(() {
                if (profileController.isLoadingSwitchRequests.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.0),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.white),
                    ),
                  );
                }

                if (profileController.switchRequests.isEmpty) {
                  return const SizedBox(height: 30);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _buildSectionHeader("Switch Progress Tracker"),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: profileController.switchRequests.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final req = profileController.switchRequests[index];
                        return _buildSwitchRequestCard(req, profileController);
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.premiumGold),
          boxShadow: [
            BoxShadow(
              color: AppColors.premiumGold.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.white,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  // Returns a display icon for each profile type from the API
  IconData _profileTypeIcon(String type) {
    switch (type) {
      case 'seller':
        return Icons.storefront_rounded;
      case 'employer':
        return Icons.business_center_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'creator':
        return Icons.video_camera_back_rounded;
      case 'personal':
        return Icons.person_rounded;
      default:
        return Icons.verified_user_rounded;
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

  Widget _buildSwitchRequestCard(
    ProfileSwitchRequest req,
    SettingsController profileController,
  ) {
    final profileLabel = _profileTypeLabel(
      req.toProfileType,
      req.profileSubType,
    );
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
      onTap:
          isApproved
              ? null
              : () async {
                final toType = req.toProfileType;
                final subType = req.profileSubType;

                bool isFreeFlow =
                    toType == 'employer' ||
                    (toType == 'seller' &&
                        (subType == 'product' || subType == 'service'));

                if (isFreeFlow) {
                  profileController.showAdminApprovalDialog(profileLabel);
                } else {
                  // For all other types (including ecommerce seller-both, music, creator)
                  try {
                    final subscriptionController =
                        Get.isRegistered<SubscriptionController>()
                            ? Get.find<SubscriptionController>()
                            : Get.put(SubscriptionController());
                    final updatedSub = await subscriptionController
                        .fetchPlansForProfileType(toType);
                    if (updatedSub != null) {
                      Get.to(
                        () => ProfilePlansScreen(profileTypeSub: updatedSub),
                      );
                    } else {
                      // No plans found — treat as approval-only flow
                      profileController.showAdminApprovalDialog(profileLabel);
                    }
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Could not load plans: $e',
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                }
              },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.premiumGold),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(width: 4, color: accentColor),

                // Main card content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // Type icon circle
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accentColor.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            profileIcon,
                            color: accentColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Label + notes
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                profileLabel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (req.userNotes != null &&
                                  req.userNotes!.trim().isNotEmpty)
                                Text(
                                  req.userNotes!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.premiumGold,
                                  ),
                                )
                              else if (!isApproved)
                                Text(
                                  'Tap to view details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.premiumGold,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusTextColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: statusTextColor,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusTextColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isApproved) ...[
                              const SizedBox(height: 8),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.premiumGold,
                                size: 12,
                              ),
                            ],
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.premiumGold),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
