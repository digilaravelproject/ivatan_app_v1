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
        gradient: LinearGradient(
          colors: [
            Color(0xFF1683EE),
            Color(0xFF20BDEF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      width: MediaQuery.of(context).size.width * 0.65,
    //  color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2), // optional (to give space around icon)
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(
                              color: AppColors.white,
                            ),
                            shape: BoxShape.circle,   // 🔥 makes it a perfect circle
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_left_outlined,
                            color: AppColors.primaryDark,
                            weight: 900,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      Text(
                        "Quick Access Bar",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2), // optional (to give space around icon)
                        decoration: BoxDecoration(
                        //  color: AppColors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          border: Border.all(
                            color: AppColors.white,
                            width: 1.5
                          ),),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 20),
                          child: Icon(
                            CupertinoIcons.bell,
                            color: AppColors.white,
                            weight: 900,
                            size: 24,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2), // optional (to give space around icon)
                        decoration: BoxDecoration(
                          //  color: AppColors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          border: Border.all(
                            color: AppColors.white,
                            width: 1.5
                          ),),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 5),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.bell,
                                color: AppColors.white,
                                weight: 900,
                                size: 24,
                              ),
                              SizedBox(width: 5,),
                              Text("SOS",style: TextStyle(color: AppColors.white,fontSize: 16,fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            drawerItem(Icons.live_help_outlined, "Live Chat",() {
              Get.to(LiveChatList());
            }),
            drawerItem(Icons.perm_contact_calendar_outlined, "Contact",(){
              Get.to(ContactScreen());
            }),
            drawerItem(Icons.format_list_numbered, "Playlist",(){
              Get.to(ComingSoonScreen());
            }),
            drawerItem(Icons.history, "History",(){
              Get.to(HistoryScreen());
            }),
            drawerItem(CupertinoIcons.home, "Banking",(){
              Get.to(ComingSoonScreen());

            }),
            drawerItem(Icons.settings_outlined, "Settings",(){
              Get.to(SettingsScreen());
            }),
            drawerItem(Icons.logout, "Logout",(){
              _showLogoutDialog(context);
            }),

            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(2), // optional (to give space around icon)
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                      color: AppColors.primaryDark,
                      width: 2
                    ),),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 8),
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.bell,
                          color: AppColors.primaryDark,
                          weight: 900,
                          size: 24,
                        ),
                        Text("i-QuickHire",style: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2), // optional (to give space around icon)
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                        color: AppColors.primaryDark,
                        width: 2
                    ),),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 8),
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.bell,
                          color: AppColors.primaryDark,
                          weight: 900,
                          size: 24,
                        ),
                        Text("Universal App",style: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: (){
                  Get.to(HelpCenter());
                },
                child: Container(
                  padding: const EdgeInsets.all(2), // optional (to give space around icon)
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                        color: AppColors.white,
                        width: 2
                    ),),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 15),
                    child: Row(
                      children: [
                        Text("Help Center",style: TextStyle(color: AppColors.black,
                            fontWeight: FontWeight.bold,fontSize: 18),),
                        SizedBox(width: 10,),
                        Icon(
                          Icons.support_agent_sharp,
                          color: AppColors.primaryDark,
                          weight: 900,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget drawerItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 26, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
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