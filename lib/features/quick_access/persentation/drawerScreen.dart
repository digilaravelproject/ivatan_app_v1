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
import 'contacts.dart';
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
                        icon: CupertinoIcons.bell,
                        label: null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: CupertinoIcons.exclamationmark_triangle,
                          label: "SOS",
                          isAlert: true,
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    drawerItem(Icons.live_help_outlined, "Live Chat", () {
                      Get.to(LiveChatList());
                    }),
                    drawerItem(Icons.perm_contact_calendar_outlined, "Contact", () {
                      Get.to(ContactScreen());
                    }),
                    drawerItem(Icons.format_list_numbered, "Playlist", () {
                      Get.to(ComingSoonScreen());
                    }),
                    drawerItem(Icons.history, "History", () {
                      Get.to(HistoryScreen());
                    }),
                    drawerItem(CupertinoIcons.home, "Banking", () {
                      Get.to(ComingSoonScreen());
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
              ),
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
                      Expanded(child: _buildBottomCard("i-QuickHire", CupertinoIcons.briefcase)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildBottomCard("Universal App", CupertinoIcons.app_badge)),
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
    );
  }

  Widget drawerItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: isDestructive ? AppColors.error : AppColors.lightTextSecondary),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? AppColors.error : AppColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({required IconData icon, String? label, bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAlert ? AppColors.error.withOpacity(0.1) : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert ? AppColors.error : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isAlert ? AppColors.error : AppColors.black,
            size: 24,
          ),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isAlert ? AppColors.error : AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBottomCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.black, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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