import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_vatan_app/route/app_pages.dart';
import 'package:get/get.dart';

import '../../../../core/helper/profile_permission_manager.dart';
import '../../../../core/network/app_urls.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../../dashboard/persentation/edit_profile_screen.dart';
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
      backgroundColor: AppColors.black,
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
                      Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () =>  Get.to(ProfileScreen(viewUserName: SharedPrefManager().user!.username.toString(),)),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.white, width: 2),
                                ),
                                child: ClipOval(
                                  child: SharedPrefManager().user!.profilePhotoPath != null &&
                                          SharedPrefManager().user!.profilePhotoPath!.toString().isNotEmpty
                                      ? Image.network(
                                          AppUrls.getFullImageUrl(SharedPrefManager().user!.profilePhotoPath!.toString()),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.person,
                                            color: AppColors.white,
                                            size: 24,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          color: AppColors.white,
                                          size: 24,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Name
                                  Text(
                                    SharedPrefManager().user!.name.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
    
                                  // Title
                                  Text(
                                    SharedPrefManager().user!.occupation.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.premiumGold.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10,),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.premiumGold.withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),



           // const Divider(color: AppColors.premiumGold),

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
            //           border: Border.all(color: AppColors.white, width: 2),
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
            //             backgroundColor: AppColors.black,
            //             foregroundColor: AppColors.white,
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
            // const Divider(color: AppColors.premiumGold),

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
                  Divider(color: AppColors.premiumGold),
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

            //const Divider(color: AppColors.premiumGold),

            // Logout Button
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       onPressed: () {},
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: AppColors.premiumGold.withOpacity(0.1),
            //         foregroundColor: AppColors.white,
            //         padding: const EdgeInsets.symmetric(vertical: 12),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //           side: BorderSide(color: AppColors.premiumGold.withOpacity(0.3)),
            //         ),
            //         elevation: 0,
            //       ),
            //       child: Text(
            //         'Logout',
            //         style: GoogleFonts.poppins(
            //           fontSize: 14,
            //           fontWeight: FontWeight.w600,
            //           color: AppColors.white,
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
      leading: Icon(icon, color: AppColors.white, size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
      trailing: badge != null
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badge,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      )
          : null,
      onTap: onTap,
    );
  }

  bool _isRecruiter() {
    return ProfilePermissionManager.isProfileActive(ProfileType.employer);
     // SharedPrefManager().user?.isEmployer ?? false;
  }

}
