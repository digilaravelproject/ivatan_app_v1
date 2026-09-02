import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import '../controller/live_chat_inbox_controller.dart';
import '../model/chat_inbox_model.dart';
import 'live_group_chat_screen.dart';

// =========================================================================
// 🎨 LIVE CHAT INBOX SCREEN (TYPE-SAFE MODULE LAYER)
// =========================================================================
class LiveChatInboxScreen extends StatelessWidget {
  const LiveChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveChatInboxController());

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.menu_rounded,
            color: AppColors.white,
            size: 24,
          ),
        ),
        title: Text(
          "Chats",
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.white, size: 24),
            onPressed: () {
              controller.fetchChats();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.white, size: 22),
            onPressed: () {
              // Action for editing
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Premium Search Bar Below Header
          _buildSearchBar(controller),

          // Inbox chats list

          // Inbox chats list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.filteredInbox.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              if (controller.filteredInbox.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(color: AppColors.primary,
                onRefresh: () => controller.fetchChats(),
                child: ListView.builder(
                  itemCount: controller.filteredInbox.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final chat = controller.filteredInbox[index];
                    return _buildInboxRow(context, chat, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(LiveChatInboxController controller) {
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
            const Icon(Icons.search_rounded, color: AppColors.premiumGold, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.white),
                decoration: InputDecoration(
                  hintText: "Search chats...",
                  hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.premiumGold.withOpacity(0.4)),
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
                    child: const Icon(Icons.close_rounded, color: AppColors.premiumGold, size: 18),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }



  Widget _buildInboxRow(BuildContext context, ChatInboxModel chat, LiveChatInboxController controller) {
    final lastMsg = chat.lastMessage;
    final isMuted = false;
    final unreadCount = chat.unreadCount;
    final chatId = chat.id;
    final chatName = chat.name;
    final chatType = chat.type;

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
      timeString = controller.formatTime(chat.lastMessageAt);
    }

    final avatarColor = controller.getAvatarColor(chatId, chatName);

    return InkWell(
      onTap: () {
        controller.markChatAsReadLocally(chatId);
        Get.to(
          () => const LiveGroupChatScreen(),
          arguments: {
            'chat_id': chatId,
            'name': chatName,
            'avatar_color': avatarColor,
            'participants_count': chat.participantsCount,
            'chat_mode': chat.chatMode,
            'is_admin': chat.isAdmin,
            'is_muted': isMuted,
            'is_banned': false,
            'description': chat.description
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
                chatType == "group" ? Icons.groups_rounded : Icons.campaign_rounded,
                color: AppColors.white,
                size: 26,
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
                          chatName,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeString,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.premiumGold.withOpacity(0.4),
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
                                style: GoogleFonts.poppins(color: AppColors.premiumGold.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (unreadCount > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "$unreadCount",
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_chat_read_rounded, size: 48, color: AppColors.premiumGold.withOpacity(0.35)),
          const SizedBox(height: 12),
          Text(
            "No chats under this category",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.premiumGold.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
