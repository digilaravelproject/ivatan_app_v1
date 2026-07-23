import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../../../db/shared_pref_manager.dart';
import '../../../route/app_pages.dart';
import '../../profile/screen/profile_screen.dart';
import '../controller/chatt_controller.dart';
import 'package:intl/intl.dart';


class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChattController controller = Get.put(ChattController());
    return Container(
      color: Colors.white, // Clean White Background
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
                    backgroundImage: NetworkImage(SharedPrefManager().user!.profilePhotoPath.toString()),
                  ),
                ),
              ),
            ),
            title: const Text(
              'Groups', // Changed from i-group for consistency
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
                  color: Colors.grey.shade200,
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
                        onChanged: controller.searchedGroup,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search groups...',
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
            
            Obx(() {
              if (controller.isLoading.value) {
                return const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
              }
              if (controller.groupChatList.isEmpty) {
                 return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text("No groups found", style: TextStyle(color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                );
              }
              return Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchInboxGroup();
                  },
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: controller.filteredGroupList.length,
                    separatorBuilder: (ctx, i) => Divider(height: 1, indent: 80, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final message = controller.filteredGroupList[index];
                      return InkWell(
                        onTap: () async {
                          await Get.toNamed(
                            AppRoutes.chattingScreen,
                            arguments: message,
                          );
                          // Refresh list when returning from chat (e.g. if they left a group)
                          controller.fetchInboxGroup();
                        },
                        child: Padding(
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
                                child: message.type == "group" &&
                                    message.avatar != null &&
                                    message.avatar.toString().isNotEmpty
                                    ? Image.network(
                                  message.avatar.toString(),
                                  fit: BoxFit.cover,
                                )
                                    : message.type == "group"
                                    ? const Icon(Icons.group, color: Colors.grey)
                                    : Center(
                                  child: Text(
                                    message.name.isNotEmpty
                                        ? message.name[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              /*child: ClipOval(
                                child: message.type == "group"
                                    ? const Icon(Icons.group, color: Colors.grey)
                                    : Center(
                                        child: Text(
                                          message.name.isNotEmpty ? message.name[0].toUpperCase() : "?",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                        ),
                                      ),
                              ),*/
                            ),
                            const SizedBox(width: 14),
                            
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          message.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600, // Slightly less bold than unread message
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                       Text(
                                        formatChatDate(message.updatedAt.toString()),
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          message.lastMessage?.content ?? "No messages",
                                          style: TextStyle(
                                            color: Colors.black87, // Stronger color for readability
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (message.unreadCount! > 0)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            message.unreadCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                )
              );
            }),
          ],
        ),
      ),
    );
  }

  String formatChatDate(String dateTimeString) {
    final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    final DateTime now = DateTime.now();

    final DateTime today =
    DateTime(now.year, now.month, now.day);
    final DateTime yesterday =
    today.subtract(const Duration(days: 1));

    final DateTime messageDate =
    DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      /// Today → show time
      return DateFormat('hh:mm a').format(dateTime);
    } else if (messageDate == yesterday) {
      /// Yesterday
      return "Yesterday";
    } else {
      /// Older → show date
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

}
