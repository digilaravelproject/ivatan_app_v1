import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import '../controller/live_chat_list_controller.dart';
import '../model/chat_inbox_model.dart';
import 'live_group_chat_screen.dart';

// =========================================================================
// 🎨 LIVE CHAT GROUPS LIST SCREEN (TYPE-SAFE MODULE LAYER)
// =========================================================================
class LiveChatList extends StatelessWidget {
  const LiveChatList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveChatListController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.menu_rounded,
            color: Colors.black54,
            size: 24,
          ),
        ),
        title: Text(
          "Live Chat Groups",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.black87,
              size: 24,
            ),
            onPressed: () => controller.fetchGroups(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Premium Search Bar Below Header
          _buildSearchBar(controller),

          // Groups Feed List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.filteredGroups.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              if (controller.filteredGroups.isEmpty) {
                return _buildEmptyState(controller);
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => controller.fetchGroups(),
                child: ListView.builder(
                  itemCount: controller.filteredGroups.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final group = controller.filteredGroups[index];
                    return _buildGroupRow(context, group, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(LiveChatListController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(21),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Search groups...",
                  hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            Obx(() => controller.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      controller.searchController.clear();
                      controller.searchQuery.value = "";
                    },
                    child: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }



  Widget _buildGroupRow(BuildContext context, ChatInboxModel group, LiveChatListController controller) {
    final lastMsg = group.lastMessage;
    final isMuted = false;
    final unreadCount = group.unreadCount;
    final chatId = group.id;
    final groupName = group.name;
    final groupType = group.type;

    String senderName = "";
    String content = "No messages yet";
    String timeString = "";

    if (lastMsg != null) {
      if (lastMsg.messageType == 'image') {
        content = lastMsg.content.isNotEmpty && !lastMsg.content.startsWith("Sending Image...")
            ? "📷 ${lastMsg.content}"
            : "📷 Image";
      } else if (lastMsg.messageType == 'file') {
        content = lastMsg.content.isNotEmpty && !lastMsg.content.startsWith("Sending File...")
            ? "📄 ${lastMsg.content}"
            : "📄 Document";
      } else {
        content = lastMsg.content;
      }
      
      if (lastMsg.sender != null) {
        senderName = lastMsg.sender!.name;
      }

      final currentUserId = SharedPrefManager().user?.id;
      final senderId = lastMsg.sender?.id;
      if (currentUserId != null && senderId != null && currentUserId.toString() == senderId.toString()) {
        senderName = "You";
      }

      timeString = controller.formatTime(lastMsg.createdAt);
    } else {
      timeString = controller.formatTime(group.lastMessageAt);
    }

    final avatarColor = controller.getAvatarColor(chatId, groupName);

    return InkWell(
      onTap: () {
        Get.to(
          () => const LiveGroupChatScreen(),
          arguments: {
            'chat_id': chatId,
            'name': groupName,
            'avatar': "",
            'avatar_color': avatarColor,
            'chat_mode': group.chatMode,
            'participants_count': group.participantsCount,
            'is_admin': group.name == "Announcements" ? false : true,
            'is_muted': isMuted,
            'is_banned': false,
            'description': group.description
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: avatarColor,
              child: Icon(
                groupType == "group" ? Icons.groups_rounded : Icons.campaign_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          groupName,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Show time where participant count was
                      Text(
                        timeString,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: GoogleFonts.poppins(fontSize: 13),
                            children: [
                              if (senderName.isNotEmpty)
                                TextSpan(
                                  text: "$senderName: ",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              TextSpan(
                                text: content,
                                style: GoogleFonts.poppins(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Show unread count where time was
                      if (unreadCount > 0) 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$unreadCount",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Removed the separate unread count section since it's now shown in message row
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(LiveChatListController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey[350]),
          const SizedBox(height: 12),
          Text(
            "No live chat groups found",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
