import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_assets.dart';
import '../../dashboard/persentation/comming_soon.dart'; // For CustomEmptyState
import '../../../core/helper/custom_image_view.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../../../db/shared_pref_manager.dart';
import '../../../route/app_pages.dart';
import '../../profile/screen/profile_screen.dart';
import '../../quick_access/model/contact_model.dart';
import '../../quick_access/persentation/controller/contact_controller.dart';
import '../controller/chatt_controller.dart';
import '../model/chat_data_model.dart';

class ContactPerson extends StatelessWidget {
  ContactPerson({super.key});
  final ContactController contactController = Get.put(ContactController());
  final ChattController chatController = Get.put(ChattController());



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: (){
                  Get.to(ProfileScreen());
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(AppUrls.imageurl+SharedPrefManager().user!.profilePhotoPath.toString()),
                  ),
                ),
              ),
            ),
            title: const Text(
              'Contacts', // Changed from i-contact
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 0.5,
              ),
            ),
            // actions: [
            //    IconButton(
            //       icon: const Icon(
            //         Icons.search,
            //         color: Colors.white,
            //         size: 26,
            //       ),
            //       onPressed: () {},
            //     ),
            //   Container(
            //     margin: const EdgeInsets.only(right: 12),
            //     child: IconButton(
            //       icon: const Icon(
            //         Icons.more_vert,
            //         color: Colors.white,
            //         size: 26,
            //       ),
            //       onPressed: () {},
            //     ),
            //   ),
            // ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          print("onchange value = "+value);
                          contactController.searchedPerson(value);
                        },
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search contacts...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            Expanded(
              child: Obx(() {
                if (contactController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (contactController.filteredContactList.isEmpty) {
                   return Center(
                    child: CustomEmptyState(
                      title: "No Contacts Found",
                      subTitle: "Try searching for someone else",
                      icon: Icons.person_off_rounded,
                      isSmall: true,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: contactController.filteredContactList.length,
                  separatorBuilder: (ctx, i) => Divider(height: 1, indent: 80, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final contact = contactController.filteredContactList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            child: ClipOval(
                              child: contact.avatar != null && contact.avatar!.isNotEmpty
                                  ? Image.network(
                                      contact.avatar!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Image.asset(AppAssets.imgAppLogo),
                                        );
                                      },
                                    )
                                  : const Icon(Icons.person, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Contact name and phone
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.name ?? "Unknown",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (contact.username != null && contact.username!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      "@${contact.username!}", // Added @ for style
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
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
    );
  }

  Widget buildActionButton(SyncedContact contact) {
    return Obx(() {
      // Hide button if it's your own contact
      if (contact.is_mine.value) return SizedBox.shrink();

      // Determine button text and color
      String buttonText;
      Color backgroundColor;
      Color textColor = Colors.white;
      VoidCallback? onTapAction;

      // Invite button
      if (contact.is_invite.value) {
        buttonText = "Invite";
        backgroundColor = Colors.transparent; // Transparent for Outline
        textColor = Colors.blue;
        onTapAction = () {
             final link = "https://ivatan.app/post";
            Share.share("Check this post 👇\n$link");
             // contact.is_invite.value = false;
        };
      } else if (contact.isFollowing.value) {
        buttonText = "Message";
        backgroundColor = Colors.grey;
        textColor = Colors.white;

        // Action for Message button
        onTapAction= () async {
          if (contact.chat_id.isNotEmpty) {
            final chatModel = ChatListModel(
              id: int.parse(contact.chat_id),
              uuid: "",
              type: "private",
              name: contact.name,
              avatar: contact.avatar,
              isOnline: false,
              isAdmin: 0,
              unreadCount: 0,
              updatedAt: DateTime.now(),
              participantsCount: 2,
              participants: [
                Participant(
                  userId: contact.id,
                  name: contact.name,
                  avatar: contact.avatar,
                  isAdmin: false,
                )
              ],
            );
            await Get.toNamed(
              AppRoutes.chattingScreen,
              arguments: chatModel,
            );
          } else {
            CustomSnackBar.showInfo(message: "Creating chat user id ${contact.id}");
            final newChatId = await chatController.createSinglePrivateChat(contact.id!.toInt());
            CustomSnackBar.showInfo(message: "Creating chat...$newChatId");
            if (newChatId != null) {
              final chatModel = ChatListModel(
                id: int.parse(newChatId.toString()),
                uuid: "",
                type: "private",
                name: contact.name,
                avatar: contact.avatar,
                isOnline: false,
                isAdmin: 0,
                unreadCount: 0,
                updatedAt: DateTime.now(),
                participantsCount: 2,
                participants: [
                  Participant(
                    userId: contact.id,
                    name: contact.name,
                    avatar: contact.avatar,
                    isAdmin: false,
                  )
                ],
              );
              await Get.toNamed(
                AppRoutes.chattingScreen,
                arguments: chatModel,
              );
            } else {
              CustomSnackBar.showError(message: "Unable to start chat");
            }
          }
        };
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
            borderRadius: BorderRadius.circular(20), // More rounded (Stadium like)
            border: buttonText == "Invite" ? Border.all(color: Colors.blue) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            buttonText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }

}