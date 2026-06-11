import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:url_launcher/url_launcher.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import '../controller/live_group_chat_controller.dart';
import '../model/chat_message_model.dart';
import 'live_group_details_screen.dart';

// =========================================================================
// 🎨 LIVE GROUP CHAT SCREEN (PRESENTATION LAYER ONLY - TYPE-SAFE MODULE)
// =========================================================================
class LiveGroupChatScreen extends StatelessWidget {
  const LiveGroupChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int chatId = args['chat_id'] ?? 15;
    final String groupName = args['name'] ?? "General Discussion";
    final Color avatarColor = args['avatar_color'] ?? const Color(0xFF0F9D58);
    final int participantsCount = args['participants_count'] ?? 142;
    final String chatMode = args['chat_mode'] ?? "everyone";
    final bool isAdmin = args['is_admin'] ?? true;
    final String description = args['description'] ?? "General chat for all users. Feel free to share your thoughts.";

    final controller = Get.put(
      LiveGroupChatController(
        chatId: chatId,
        groupName: groupName,
        avatarColor: avatarColor,
        participantsCount: participantsCount,
        chatMode: chatMode,
        isAdmin: isAdmin,
        description: description,
      ),
      tag: chatId.toString(),
    );

    return WillPopScope(
      onWillPop: () async {
        if (controller.isEmojiVisible.value) {
          controller.isEmojiVisible.value = false;
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: _buildAppBar(context, controller),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.01),
              ),
            ),
            
            Column(
              children: [
                // 💬 Messages Feed
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.messages.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      );
                    }
  
                    if (controller.messages.isEmpty) {
                      return _buildEmptyState();
                    }
  
                    return ListView.builder(
                      controller: controller.scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];
                        final isMe = message.isMine;
                        
                        bool showDate = false;
                        if (index == controller.messages.length - 1) {
                          showDate = true;
                        } else {
                          final nextMessage = controller.messages[index + 1];
                          if (controller.formatMessageDate(nextMessage.createdAt) != controller.formatMessageDate(message.createdAt)) {
                            showDate = true;
                          }
                        }
  
                        // System messages styling
                        if (message.messageType == 'system' || message.sender?.name == 'System') {
                          return Column(
                             children: [
                              if (showDate) _buildDateBubble(controller.formatMessageDate(message.createdAt)),
                              _buildSystemBubble(message.content),
                            ],
                          );
                        }
  
                        return Column(
                          children: [
                            if (showDate) _buildDateBubble(controller.formatMessageDate(message.createdAt)),
                            _SwipeToReplyWrapper(
                              key: ValueKey(message.id),
                              onReply: () {
                                controller.replyingToMessage.value = message;
                                controller.focusNode.requestFocus();
                              },
                              child: _buildChatBubble(context, controller, message, isMe),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ),
  
                // 📝 Reply Preview Bar
                Obx(() {
                  if (controller.replyingToMessage.value != null) {
                    return _buildReplyPreviewBar(controller);
                  }
                  return const SizedBox.shrink();
                }),
  
                // 📷 Pending Attachment Preview Bar
                Obx(() {
                  if (controller.selectedAttachment.value != null) {
                    return _buildAttachmentPreviewBar(controller);
                  }
                  return const SizedBox.shrink();
                }),
  
  
                // ✍️ Input message bar
                _buildInputBar(context, controller),
  
                // Emoji Picker
                Obx(() => Offstage(
                  offstage: !controller.isEmojiVisible.value,
                  child: SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      textEditingController: controller.messageController,
                      onEmojiSelected: (category, emoji) {
                         // Controller updates automatically
                      },
                      config: Config(
                        height: 250,
                        checkPlatformCompatibility: true,
                        emojiViewConfig: EmojiViewConfig(
                          columns: 7,
                          emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
                          backgroundColor: const Color(0xFFF2F2F2),
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, LiveGroupChatController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      iconTheme: const IconThemeData(color: Colors.black54),
      leadingWidth: 40,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(Icons.arrow_back_rounded, color: Colors.black54, size: 24),
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Get.to(
                () => const LiveGroupDetailsScreen(),
            arguments: {
              'chat_id': controller.chatId,
              'name': controller.groupName,
              'avatar_color': controller.avatarColor,
              'participants_count': controller.participantsCount,
              'chat_mode': controller.chatMode,
              'is_admin': controller.isAdmin,
              'description': controller.description,
            },
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: controller.avatarColor,
              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.groupName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "${controller.participantsCount} participants",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    /*  actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.black54),
          onPressed: () {
            Get.to(
              () => const LiveGroupDetailsScreen(),
              arguments: {
                'chat_id': controller.chatId,
                'name': controller.groupName,
                'avatar_color': controller.avatarColor,
                'participants_count': controller.participantsCount,
                'chat_mode': controller.chatMode,
                'is_admin': controller.isAdmin,
                'description': controller.description,
              },
            );
          },
        ),
      ],*/
    );
  }

  Widget _buildDateBubble(String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        date,
        style: GoogleFonts.poppins(
          fontSize: 11.5,
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSystemBubble(String content) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          content,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(
    BuildContext context,
    LiveGroupChatController controller,
    ChatMessageModel message,
    bool isMe,
  ) {
    final senderName = message.sender?.name ?? "Unknown";
    final avatarColor = controller.getSenderColor(senderName);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageOptions(context, controller, message),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: message.sender?.avatar != null && message.sender!.avatar!.trim().isNotEmpty
                        ? Image.network(
                            message.sender!.avatar!,
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  senderName[0].toUpperCase(),
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              senderName[0].toUpperCase(),
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.black : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(isMe ? 12 : 3),
                    bottomRight: Radius.circular(isMe ? 3 : 12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          senderName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: avatarColor,
                          ),
                        ),
                      ),

                           // 💬 WhatsApp-style Quoted Reply Block
                    if (message.repliedMessage != null) ...[ 
                      GestureDetector(
                        onTap: () {}, // future: scroll to original message
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.14)
                                : Colors.black.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ── Thick Accent Left Bar ──────────────────
                                Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppColors.secondary
                                        : avatarColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                  ),
                                ),
                                // ── Quoted Content ─────────────────────────
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Sender name
                                        Text(
                                          message.repliedMessage!.sender
                                                  ?.name ??
                                              "Unknown",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isMe
                                                ? AppColors.secondary
                                                : avatarColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        // Content / media hint
                                        Row(
                                          children: [
                                            if (message.repliedMessage!
                                                    .messageType ==
                                                'image') ...[
                                              Icon(Icons.image_rounded,
                                                  size: 13,
                                                  color: isMe
                                                      ? Colors.white54
                                                      : Colors.black45),
                                              const SizedBox(width: 4),
                                            ] else if (message.repliedMessage!
                                                    .messageType ==
                                                'file') ...[
                                              Icon(
                                                  Icons
                                                      .insert_drive_file_rounded,
                                                  size: 13,
                                                  color: isMe
                                                      ? Colors.white54
                                                      : Colors.black45),
                                              const SizedBox(width: 4),
                                            ],
                                            Expanded(
                                              child: Text(
                                                message.repliedMessage!
                                                            .messageType ==
                                                        'image'
                                                    ? "Photo"
                                                    : (message.repliedMessage!
                                                                .messageType ==
                                                            'file'
                                                        ? "Document"
                                                        : (message
                                                                .repliedMessage!
                                                                .content
                                                                .isEmpty
                                                            ? "Message"
                                                            : message
                                                                .repliedMessage!
                                                                .content)),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: isMe
                                                      ? Colors.white60
                                                      : Colors.black54,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // ── Image thumbnail (if original was image) ─
                                if (message.repliedMessage!.messageType ==
                                        'image' &&
                                    message.repliedMessage!.attachmentUrl !=
                                        null)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                    child: Image.network(
                                      message.repliedMessage!.attachmentUrl!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const SizedBox.shrink(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // 💬 Body rendering based on message type
                    if (message.messageType == 'image') ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          final bool isLocal = message.attachmentUrl != null && !message.attachmentUrl!.startsWith('http');
                          if (message.attachmentUrl != null && message.attachmentUrl!.isNotEmpty) {
                            Get.to(() => FullScreenImageViewer(
                                  imageUrl: message.attachmentUrl!,
                                  isLocal: isLocal,
                                ));
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (message.attachmentUrl != null && !message.attachmentUrl!.startsWith('http'))
                              ? Image.file(
                                  File(message.attachmentUrl!),
                                  width: 220,
                                  height: 160,
                                  fit: BoxFit.cover,
                                )
                              : (message.attachmentUrl != null && message.attachmentUrl!.isNotEmpty)
                                  ? Image.network(
                                      message.attachmentUrl!,
                                      width: 220,
                                      height: 160,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: 220,
                                          height: 160,
                                          color: Colors.grey[100],
                                          child: const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 220,
                                          height: 160,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 36),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 220,
                                      height: 160,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                        ),
                      ),
                      if (message.content.isNotEmpty && !message.content.startsWith("Sending Image...")) ...[
                        const SizedBox(height: 6),
                        Text(
                          message.content,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: isMe ? Colors.white : Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ] else if (message.messageType == 'file') ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          if (message.attachmentUrl != null && message.attachmentUrl!.isNotEmpty) {
                            try {
                              final Uri uri = message.attachmentUrl!.startsWith('http')
                                  ? Uri.parse(message.attachmentUrl!)
                                  : Uri.file(message.attachmentUrl!);

                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                Clipboard.setData(ClipboardData(text: message.attachmentUrl!));
                                CustomSnackBar.showSuccess(message: "Opening file... Link copied to clipboard!");
                              }
                            } catch (e) {
                              Clipboard.setData(ClipboardData(text: message.attachmentUrl!));
                              CustomSnackBar.showSuccess(message: "File link copied to clipboard!");
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.white.withOpacity(0.12) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.insert_drive_file_rounded,
                                color: isMe ? AppColors.secondary : Colors.blue,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      message.attachmentUrl != null
                                          ? message.attachmentUrl!.split('/').last
                                          : "Document",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: isMe ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      message.status == "sending" ? "Uploading..." : "Tap to copy URL",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: isMe ? Colors.white60 : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (message.content.isNotEmpty && !message.content.startsWith("Sending File...")) ...[
                        const SizedBox(height: 6),
                        Text(
                          message.content,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: isMe ? Colors.white : Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ] else ...[
                      Text(
                        message.content,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: isMe ? Colors.white : Colors.black87,
                          height: 1.35,
                        ),
                      ),
                    ],

                    const SizedBox(height: 3),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(width: 40),
                        Text(
                          controller.formatMessageTime(message.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isMe ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.status == "sending"
                                ? Icons.access_time_rounded
                                : Icons.done_all_rounded,
                            color: message.status == "sending" ? Colors.grey[400] : AppColors.secondary,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, LiveGroupChatController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.transparent,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file_rounded, color: Colors.black54, size: 22),
                      onPressed: () => _showAttachmentSheet(context, controller),
                    ),

                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        focusNode: controller.focusNode,
                        maxLines: 4,
                        minLines: 1,
                        style: GoogleFonts.poppins(fontSize: 14.5, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14.5),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onTap: () {
                          if (controller.isEmojiVisible.value) {
                            controller.isEmojiVisible.value = false;
                          }
                        },
                      ),
                    ),

                    IconButton(
                      icon: Obx(() => Icon(
                        controller.isEmojiVisible.value
                            ? Icons.keyboard_rounded
                            : Icons.sentiment_satisfied_alt_rounded,
                        color: Colors.black54,
                        size: 24,
                      )),
                      onPressed: () {
                        if (controller.isEmojiVisible.value) {
                          controller.focusNode.requestFocus();
                          controller.isEmojiVisible.value = false;
                        } else {
                          controller.focusNode.unfocus();
                          controller.isEmojiVisible.value = true;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            GestureDetector(
              onTap: controller.sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentSheet(
    BuildContext context,
    LiveGroupChatController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Share",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentSheetItem(
                    icon: Icons.image_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFFE040FB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    label: "Gallery",
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.pickAttachment("image");
                    },
                  ),
                  _buildAttachmentSheetItem(
                    icon: Icons.camera_alt_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFFF5252)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    label: "Camera",
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.pickAttachment("camera");
                    },
                  ),
                  _buildAttachmentSheetItem(
                    icon: Icons.insert_drive_file_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    label: "Document",
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.pickAttachment("document");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentSheetItem({
    required IconData icon,
    required LinearGradient gradient,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }


  void _showMessageOptions(
    BuildContext context,
    LiveGroupChatController controller,
    ChatMessageModel message,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),

            _buildOptionRow(
              icon: Icons.reply_rounded,
              label: "Reply",
              color: Colors.black87,
              onTap: () {
                Navigator.pop(ctx);
                controller.replyingToMessage.value = message;
                controller.focusNode.requestFocus();
              },
            ),

            _buildOptionRow(
              icon: Icons.copy_rounded,
              label: "Copy",
              color: Colors.black87,
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: message.content));
                CustomSnackBar.showSuccess(message: "Message copied to clipboard!");
              },
            ),

            _buildOptionRow(
              icon: Icons.delete_outline_rounded,
              label: "Delete for me",
              color: Colors.red.shade300,
              onTap: () async {
                Navigator.pop(ctx);
                await controller.deleteMessage(message.id, deleteForEveryone: false);
                CustomSnackBar.showInfo(message: "Message deleted.");
              },
            ),

            // Only owner can delete for everyone
            if (message.isMine)
              _buildOptionRow(
                icon: Icons.delete_forever_rounded,
                label: "Delete for everyone",
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(ctx);
                  await controller.deleteMessage(message.id, deleteForEveryone: true);
                  CustomSnackBar.showSuccess(message: "Message deleted for everyone.");
                },
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "Cancel",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: color,
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
          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            "No messages yet. Say hello!",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreviewBar(LiveGroupChatController controller) {
    final replyMsg = controller.replyingToMessage.value!;
    final senderName = replyMsg.sender?.name ?? "Unknown";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[100]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Replying to $senderName",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyMsg.messageType == 'image'
                      ? "📷 Image"
                      : (replyMsg.messageType == 'file' ? "📄 Document" : replyMsg.content),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20, color: Colors.black54),
            onPressed: () {
              controller.replyingToMessage.value = null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreviewBar(LiveGroupChatController controller) {
    final attachment = controller.selectedAttachment.value!;
    final String type = controller.selectedAttachmentType.value;
    final String name = attachment.path.split('/').last;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[100]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          if (type == "image") ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                attachment,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insert_drive_file_rounded, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type == "image" ? "Selected Image" : "Selected Document",
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20, color: Colors.black54),
            onPressed: () {
              controller.selectedAttachment.value = null;
              controller.selectedAttachmentType.value = "";
            },
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 🚀 PINCH-TO-ZOOM FULL SCREEN IMAGE VIEWER
// =========================================================================
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final bool isLocal;

  const FullScreenImageViewer({super.key, required this.imageUrl, this.isLocal = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () {
              CustomSnackBar.showSuccess(message: "Image saved successfully!");
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          minScale: 0.5,
          maxScale: 4.0,
          child: isLocal
              ? Image.file(
                  File(imageUrl),
                  fit: BoxFit.contain,
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image_rounded, color: Colors.white60, size: 64),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

// =========================================================================
// 👆 SWIPE-RIGHT-TO-REPLY WRAPPER
// =========================================================================
class _SwipeToReplyWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;

  const _SwipeToReplyWrapper({
    super.key,
    required this.child,
    required this.onReply,
  });

  @override
  State<_SwipeToReplyWrapper> createState() => _SwipeToReplyWrapperState();
}

class _SwipeToReplyWrapperState extends State<_SwipeToReplyWrapper>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _triggered = false;
  late final AnimationController _snapController;
  late Animation<double> _snapAnimation;

  static const double _threshold = 72.0;
  static const double _maxDrag   = 90.0;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx < 0 && _dragOffset <= 0) return; // block left swipe
    setState(() {
      _dragOffset =
          (_dragOffset + details.delta.dx).clamp(0.0, _maxDrag);
    });

    // Haptic + trigger once the threshold is crossed
    if (_dragOffset >= _threshold && !_triggered) {
      _triggered = true;
      HapticFeedback.lightImpact();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_triggered) {
      widget.onReply();
    }
    // Snap back
    _snapAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
    )..addListener(() => setState(() => _dragOffset = _snapAnimation.value));

    _snapController.forward(from: 0);
    _triggered = false;
  }

  @override
  Widget build(BuildContext context) {
    final double iconOpacity = (_dragOffset / _threshold).clamp(0.0, 1.0);
    final double iconScale   = 0.6 + 0.4 * iconOpacity;

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Reply icon that peeks in from the left as user swipes
          Positioned(
            left: _dragOffset - 36,
            top: 0,
            bottom: 0,
            child: Center(
              child: Opacity(
                opacity: iconOpacity,
                child: Transform.scale(
                  scale: iconScale,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.reply_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // The actual bubble slides right
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
