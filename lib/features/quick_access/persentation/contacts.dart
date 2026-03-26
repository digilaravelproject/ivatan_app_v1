import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/core/helper/custom_image_view.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/helper/custom_serchbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/network/app_urls.dart';
import '../../../route/app_pages.dart';
import '../../messages/controller/chatt_controller.dart';
import '../../profile/screen/profile_screen.dart';
import '../model/contact_model.dart';
import 'controller/contact_controller.dart';

class ContactScreen extends StatelessWidget {
  ContactScreen({super.key});
  final ContactController contactController = Get.put(ContactController());
  final ChattController chatController = Get.put(ChattController());


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.lightBackgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: (){
                  Get.to(ProfileScreen());
                },
                child: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: CustomImageView(
                      url: AppUrls.imageurl+SharedPrefManager().user!.profilePhotoPath.toString(),
                        imagePath: AppAssets.imgAppLogo,
                      //"https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body:
        // SingleChildScrollView(
        //   child:
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.neutralGray,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.search,
                        color: AppColors.lightTextSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            print("onchange value = "+value);
                            contactController.searchedPerson(value);
                          },
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            isDense: true,              // 🔥 key point
                            contentPadding: EdgeInsets.zero, // 🔥 removes extra height
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Friends On i-Vatan (iapp)",
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Obx(() {
                        return Text(
                          contactController.syncedContacts.length.toString(),
                          style: TextStyle(
                            color: AppColors.darkTextPrimary,
                            fontSize: 16,
                          ),
                        );
                      })
                    ],
                  ),

                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: Obx(() {
                  if (contactController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (contactController.filteredContactList.isEmpty) {
                    return const Center(child: Text("No Contacts Found"));
                  }

                  return ListView.builder(
                    itemCount: contactController.filteredContactList.length,
                    itemBuilder: (context, index) {
                      final contact = contactController.filteredContactList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            // Avatar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                height: 50,
                                width: 50,
                                color: Colors.grey.shade300,
                                child: contact.avatar != null && contact.avatar!.isNotEmpty
                                    ? Image.network(
                                  contact.avatar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return  Image.asset(AppAssets.imgAppLogo);
                                  },
                                )
                                    : const Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Contact name and phone
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.name ?? "Unknown",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (contact.username != null && contact.username!.isNotEmpty)
                                    Text(
                                      contact.username!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            buildActionButton(contact)
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),




            ],
          ),
        ),
        //  ),
      ),
    );
  }

  Widget buildActionButton(SyncedContact contact) {
    return Obx(() {
      // Hide button if it's your own contact
      if (contact.is_mine.value) return SizedBox.shrink();

      // Invite button
      if (contact.is_invite.value) {
        return GestureDetector(
          onTap: () {
            final link = "https://ivatan.app/post";
            Share.share("Check this post 👇\n$link");
            // Action for Invite button
          //  contactController.sendInvite(contact.id);
            // You can also update is_invite after sending
            contact.is_invite.value = false;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.blue),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              child: Text(
                "Invite",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        );
      }

      // Determine button text and color
      String buttonText;
      Color backgroundColor;
      Color textColor = Colors.white;

      VoidCallback? onTapAction;

      if (contact.isFollowing.value) {
        buttonText = "Message";
        backgroundColor = Colors.grey;
        textColor = Colors.white;

        // Action for Message button
       // onTapAction = () {
        onTapAction= () async {
            if (contact.chat_id != null) {

              Get.toNamed(
                AppRoutes.chattingScreen,
                arguments: contact.chat_id,
              );
            } else {
              CustomSnackBar.showInfo(message: "Creating chat user id"+contact.id.toString());
              final newChatId = await chatController.createSinglePrivateChat(contact.id!.toInt());
              CustomSnackBar.showInfo(message: "Creating chat...$newChatId");
              if (newChatId != null) {
                Get.toNamed(
                  AppRoutes.chattingScreen,
                  arguments: newChatId,
                );
              } else {
                CustomSnackBar.showError(message: "Unable to start chat");
              }
            }
          };
       // };
      } else if (contact.isFollower.value) {
        buttonText = "Following";
        backgroundColor = Colors.blue;
        textColor = Colors.white;

        // Optional: onTap can do nothing or open message screen
        onTapAction = () {
        //  contactController.openMessageScreen(contact);
        };
      } else {
        buttonText = "Follow";
        backgroundColor = Colors.blue;
        textColor = Colors.white;

        // Toggle follow/unfollow
        onTapAction = () {
          contact.isFollowing.value = !contact.isFollowing.value;
          // Call controller to sync with backend
          contactController.toggleFollowForPostUser(contact.id);
        };
      }

      return GestureDetector(
        onTap: onTapAction,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            child: Text(
              buttonText,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      );
    });
  }

}



