import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/features/auth/persentation/login_screen.dart';
import '../../../core/helper/custom_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../db/shared_pref_manager.dart';
import '../../../route/app_pages.dart';
import '../../dashboard/controller/homeController.dart';
import '../../dashboard/persentation/comming_soon.dart';
import '../../dashboard/persentation/settings_page.dart';
import '../../../core/network/app_urls.dart';
import '../../job_portal/persentation/pages/job_portal_page.dart';
import '../../messages/persentation/contact_screen.dart';
import 'help_center.dart';
import 'history/historyScreen.dart';
import 'live_chat/persentation/live_chat_list.dart';

class DrawerScreen extends StatelessWidget {
  DrawerScreen({super.key});
  final HomeController controller = Get.put(HomeController());


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      width: MediaQuery.of(context).size.width * 0.75, // Slightly wider for better layout
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.lightBackground,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_left_rounded,
                              color: AppColors.black,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Quick Access",
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // --- SOS & BELL ROW ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickActionButton(
                          context: context,
                          icon: CupertinoIcons.bell_fill,
                          label: null,
                          onTap: () => showComingSoonDialog(context, title: "Notifications", message: "Your notification center is being redesigned for a better experience."),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            context: context,
                            icon: CupertinoIcons.exclamationmark_shield_fill,
                            label: "SOS HELP",
                            isAlert: true,
                            onTap: () => showComingSoonDialog(context, title: "Emergency SOS", message: "Emergency services integration is coming soon to your region."),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              
              const Divider(height: 1, color: AppColors.lightDivider),
              const SizedBox(height: 10),

              // --- MENU ITEMS ---
              Column(
                children: [
                  drawerItem(Icons.live_help_outlined, "Live Chat", () {
                     Get.to(LiveChatList());
                   // showComingSoonDialog(context, title: "Live Chat", message: "Connect with community members in real-time. Feature launching soon.");
                  }),
                  drawerItem(Icons.perm_contact_calendar_rounded, "Contact", () {
                    Get.to(ContactPerson());
                  }),
                  drawerItem(Icons.format_list_numbered_rounded, "Playlist", () {
                    showComingSoonDialog(context, title: "Playlist", message: "Create and manage your favorite video playlists soon.");
                  }),
                  drawerItem(Icons.history_rounded, "History", () {
                     Get.to(HistoryScreen());
                   // showComingSoonDialog(context, title: "History", message: "View your browsing and activity history. Feature coming soon.");
                  }),
                  drawerItem(Icons.account_balance_rounded, "Banking", () {
                    showComingSoonDialog(context, title: "Banking", message: "Secure digital banking and wallet features are under development.");
                  }),
                  drawerItem(Icons.settings_outlined, "Settings", () {
                    Get.to(SettingsScreen());
                  }),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.lightDivider, indent: 20, endIndent: 20),
                  drawerItem(Icons.logout, "Logout", () {
                    _showLogoutDialog(context);
                  }, isDestructive: true),
                ],
              ),

              // --- BOTTOM SECTION ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  border: const Border(top: BorderSide(color: AppColors.lightDivider)),
                ),
                child: Column(
                  children: [
                      Row(
                      children: [
                       Expanded(child:_buildBottomCard(context, "i-QuickHire", CupertinoIcons.briefcase_fill, "Job Board", onTap: () {
                         Get.toNamed(AppRoutes.jobSearchScreen);
                       })),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBottomCard(context, "Universal App", CupertinoIcons.app_badge_fill, "Mini Apps")),
                      ],
                     ),
                     const SizedBox(height: 16),
                     GestureDetector(
                      onTap: () => Get.to(HelpCenter()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Help Center",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                     ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      splashColor: (isDestructive ? AppColors.error : AppColors.black).withOpacity(0.05),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive ? AppColors.error.withOpacity(0.1) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon, 
                size: 20, 
                color: isDestructive ? AppColors.error : AppColors.black.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isDestructive ? AppColors.error : AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({required BuildContext context, required IconData icon, String? label, bool isAlert = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isAlert ? AppColors.error : AppColors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isAlert ? AppColors.error : AppColors.black).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            if (label != null) ...[
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCard(BuildContext context, String title, IconData icon, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        Get.to(() => JobSearchScreen());
        //showComingSoonDialog(context, title: title, message: "We're building a unique $subtitle experience for you. Stay tuned!"),
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightDivider.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.black, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          backgroundColor: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.report_problem_rounded,
                  color: AppColors.accent,
                  size: 60,
                ),
                Text(
                  'Logout',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600, // Less bold
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to logout?',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  //spacing: 12,
                  children: [
                    Expanded(
                      child: MyButton(
                        onPressed: () => Navigator.pop(context),
                        type: ButtonType.outlined,
                        title: "Cancel",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MyButton(
                        onPressed: () async {
                         // await SharedPrefManager().userLogOut();
                          controller.logout();
                        },
                        title: "Logout",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}