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

 // final profileController = Get.put(SettingsController(userName: currentUserName));
  //final user = SharedPrefManager().user;

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(
      SettingsController(userName: currentUserName!),
      tag: currentUserName, // avoid duplicates
    );
   // bool isPrivate = false;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
              child: Icon(CupertinoIcons.back)),
          title: Text("Settings", style: TextStyle(color: AppColors.black)),
        ),
        body:Obx((){
          final userProfile = profileController.userProfile.value;
          return   SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(() {
                    return Stack(
                      children: [
                        // Profile Image
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: profileController.imageFile.value != null
                                ? Image.file(
                              profileController.imageFile.value!,
                              fit: BoxFit.cover,
                            )
                                : CustomImageView(
                              url:  userProfile?.profilePhotoPath != null && userProfile!.profilePhotoPath!.isNotEmpty
                                  ? "${AppUrls.imageurl}${userProfile!.profilePhotoPath}"
                                  : "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",

                             // url: userProfile?.profilePhotoPath ?? "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                              // "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Camera Icon bottom-right
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => profileController.showPickerOptions(),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera,
                                size: 20,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  ),

                  Text(
                    userProfile?.name ?? "Guest User",
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    userProfile?.email ?? "Guest User",
                    style: TextStyle(color: AppColors.black),
                  ),
                  SizedBox(height: AppSizer.deviceHeight3),
                  profileOptionTile1(
                    leadingIcon: CupertinoIcons.news_solid,
                    title: "Edit Name",
                    expandedFields: [
                      AuthInputFieldsBorder(
                        label: "Name ",
                        textInputType: TextInputType.text,
                        controller: profileController.nameController,
                        //  validator: profileController.validateEmail,
                      ),
                      SizedBox(height: 10),
                      AuthInputFieldsBorder(
                        label: "Username",
                        textInputType: TextInputType.text,
                        controller: profileController.usernameController,
                        //  validator: profileController.validateEmail,
                      ),
                      SizedBox(height: 10),
                      AuthInputFieldsBorder(
                         label:  "Email",
                        textInputType: TextInputType.emailAddress,
                        controller: profileController.emailController,
                        // validator: profileController.validateEmail,
                      ),
                    ],
                  ),

                  SizedBox(height: 15),

                  profileOptionTile1(
                    leadingIcon: CupertinoIcons.news_solid,
                    title: "Bio",
                    expandedFields: [
                      AuthInputFieldsBorder(
                          label:  "Bio",
                        textInputType: TextInputType.text,
                        controller: profileController.bioController,
                        //validator: profileController.validateEmail,
                      ),
                    ],
                  ),

                  SizedBox(height: 15),
                  profileOptionTile1(
                    leadingIcon: CupertinoIcons.news_solid,
                    title: "Occupation",
                    expandedFields: [
                      AuthInputFieldsBorder(
                         label: "Occupation",
                        textInputType: TextInputType.text,
                        controller: profileController.occupationController,
                        //validator: profileController.validateEmail,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  profileOptionTile1(
                    leadingIcon: CupertinoIcons.news_solid,
                    title: "Language",
                    expandedFields: [
                      AuthInputFieldsBorder(
                         label: "Language",
                        textInputType: TextInputType.text,
                        controller: profileController.languageController,
                        //validator: profileController.validateEmail,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  customToggleTile(
                    title: "Private Account",
                    icon: Icons.lock_outline,
                    initialValue: profileController.isPrivate.value,
                    onChanged: (val) => profileController.isPrivate.value = val,
                  ),

                  /*SizedBox(height: 15),
                customToggleTile(
                  title: "Switch Account",
                  icon: Icons.visibility_outlined,
                  initialValue: true,
                  onChanged: (val) {
                    print("Online Status Toggle: $val");
                  },
                ),*/

                  SizedBox(height: 30),

                  // UPDATE button ko is tarah replace karo:

                  Obx(
                        () => profileController.isLoading.value
                        ? Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade400],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    )
                        : MyButton(
                      title: "UPDATE",
                      onPressed: () {
                        profileController.updateProfile();
                      },
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primary],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      height: 40,
                      borderRadius: 8,
                    ),
                  ),

                  /*MyButton(
                  title: "UPDATE",
                  onPressed: () {
                     profileController.updateProfile();
                  },
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  height: 40,
                  borderRadius: 8,
                ),*/
                  SizedBox(height: 15),
                ],
              ),
            ),
          );
        })

      ),
    );
  }



  Widget profileOptionTile({
    required IconData leadingIcon,
    required String title,
    IconData trailingIcon = CupertinoIcons.forward,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.neutralGray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(leadingIcon, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(trailingIcon, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget profileOptionTile1({
    required IconData leadingIcon,
    required String title,
    IconData trailingIcon = CupertinoIcons.forward,
    required List<Widget> expandedFields, // <-- NEW
  }) {
    final RxBool isOpen = false.obs;

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => isOpen.value = !isOpen.value,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.neutralGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(leadingIcon, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isOpen.value ? CupertinoIcons.chevron_up : trailingIcon,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child:
                isOpen.value
                    ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(children: expandedFields),
                    )
                    : const SizedBox(),
          ),
        ],
      );
    });
  }

  Widget customToggleTile({
    required String title,
    required IconData icon,
    required bool initialValue,
    required Function(bool) onChanged,
  }) {
    final RxBool toggle = initialValue.obs;

    return Obx(() {
      return GestureDetector(
        onTap: () {
          toggle.value = !toggle.value;
          onChanged(toggle.value);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.neutralGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black, size: 22),

              SizedBox(width: 12),

              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Spacer(),

              // Toggle switch
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 55,
                height: 28,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: toggle.value ? Colors.black : AppColors.gray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Align(
                  alignment:
                      toggle.value
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: toggle.value ? Colors.blue : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
