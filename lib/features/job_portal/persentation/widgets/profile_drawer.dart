import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_vatan_app/route/app_pages.dart';
import 'package:get/get.dart';

import '../../../../core/network/app_urls.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../../dashboard/persentation/settings_page.dart';
import '../../../profile/screen/profile_screen.dart';
import '../pages/create_job_page.dart';
import '../pages/delete_account_page.dart';
import '../pages/help_privacy_page.dart';
import '../pages/job_history_page.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Close Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () =>  Get.to(ProfileScreen(viewUserName: SharedPrefManager().user!.username.toString(),)),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                                image: DecorationImage(
                                  image: NetworkImage(SharedPrefManager().user!.profilePhotoPath.toString()),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              Text(
                                SharedPrefManager().user!.name.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),

                              // Title
                              Text(
                                SharedPrefManager().user!.occupation.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => SettingsScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),



           // const Divider(color: Colors.grey),

            // Profile Section
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Column(
            //     children: [
            //       // Profile Picture
            //       Container(
            //         width: 80,
            //         height: 80,
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           border: Border.all(color: Colors.black, width: 2),
            //           image: const DecorationImage(
            //             image: NetworkImage('https://i.pravatar.cc/300'),
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //       ),
            //       const SizedBox(height: 16),
            //
            //
            //
            //       const SizedBox(height: 16),
            //
            //       // Edit Profile Button
            //       SizedBox(
            //         width: double.infinity,
            //         child: ElevatedButton(
            //           onPressed: () {},
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: Colors.black,
            //             foregroundColor: Colors.white,
            //             padding: const EdgeInsets.symmetric(vertical: 12),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //             elevation: 0,
            //           ),
            //           child: Text(
            //             'Edit Profile',
            //             style: GoogleFonts.poppins(
            //               fontSize: 14,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            //
            // const Divider(color: Colors.grey),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 1),
                children: [
                  // Recruiter only items
                  if (_isRecruiter())
                    _buildDrawerItem(
                      icon: Icons.bookmark_outline,
                      title: 'Job Create',
                      onTap: () {
                        Get.to(JobCreateScreen());
                      },
                    ),
                  // if (_isRecruiter())
                  //   _buildDrawerItem(
                  //     icon: Icons.sensor_occupied,
                  //     title: 'Occupation',
                  //     onTap: () {
                  //       Get.to(ResumeFormScreen());
                  //     },
                  //   ),
                  if (_isRecruiter())
                    _buildDrawerItem(
                      icon: Icons.local_activity,
                      title: 'My Jobs',
                      onTap: () {
                        Get.toNamed(AppRoutes.myCreatedJobScreen);
                      },
                    ),
                  // Applier only items - Hide in Employer mode
                  if (!_isRecruiter())
                    _buildDrawerItem(
                      icon: Icons.history,
                      title: 'Application History',
                      onTap: () {
                        Get.to(JobHistoryScreen());
                      },
                    ),
                  const Divider(color: Colors.grey),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Privacy',
                    onTap: () {
                      Get.to(HelpPrivacyPage());
                    },
                  ),
                  // _buildDrawerItem(
                  //   icon: Icons.settings_outlined,
                  //   title: 'Settings',
                  //   onTap: () {
                  //     Get.to(AccountDeleteReasonScreen());
                  //   },
                  // ),
                ],
              ),
            ),

           // Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _buildDrawerItem(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {},
              ),
            ),

            //const Divider(color: Colors.grey),

            // Logout Button
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       onPressed: () {},
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.grey[100],
            //         foregroundColor: Colors.black,
            //         padding: const EdgeInsets.symmetric(vertical: 12),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //           side: BorderSide(color: Colors.grey[300]!),
            //         ),
            //         elevation: 0,
            //       ),
            //       child: Text(
            //         'Logout',
            //         style: GoogleFonts.poppins(
            //           fontSize: 14,
            //           fontWeight: FontWeight.w600,
            //           color: Colors.black,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: Colors.black, size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing: badge != null
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badge,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      )
          : null,
      onTap: onTap,
    );
  }

  bool _isRecruiter() {
    return SharedPrefManager().user?.isEmployer ?? false;
  }

}
