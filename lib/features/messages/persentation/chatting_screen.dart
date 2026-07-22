import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import 'package:i_vatan_app/route/app_pages.dart';
import '../controller/chat_message_controller.dart';
import '../model/individualChatModel.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:i_vatan_app/core/widgets/custom_loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ChattingScreen extends GetView<ChatMessagesController> {
  const ChattingScreen({super.key});

  // Helper method to scroll to bottom
  void _scrollToBottom(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create scroll controller for auto-scrolling to bottom
    final ScrollController scrollController = ScrollController();
    
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (controller.isEmojiVisible.value) {
          controller.isEmojiVisible.value = false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Clean White Background
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                
                if (controller.messages.isEmpty) {
                  return _buildEmptyState();
                }

                // Auto-scroll to bottom only once when messages are loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom(scrollController);
                });

                return RefreshIndicator(color: AppColors.primary,
                  onRefresh: () async {
                    final chatId = controller.chatProfile.value?.id;
                    if (chatId != null) {
                      await controller.fetchMessages(chatId);
                      // Auto-scroll to bottom after refresh
                      _scrollToBottom(scrollController);
                    }
                  },
                  child: ListView.builder(
                    controller: scrollController,
                    reverse: false, // Changed from true to false - no more bottom alignment
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      // Reverse the index to show latest messages at bottom
                      final reversedIndex = controller.messages.length - 1 - index;
                      final message = controller.messages[reversedIndex];
                      final isMe = message.isMine;
                      
                      return _buildMessageBubble(context, message, isMe);
                    },
                  ),
                );
              }),
            ),
            
            _buildInputArea(context),
            
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Clean White AppBar
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      leadingWidth: 70,
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_back, color: Colors.black),
            const SizedBox(width: 4),
            Obx(() {
              final profile = controller.chatProfile.value;
              return CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage: (profile?.avatar != null && profile!.avatar!.isNotEmpty)
                    ? NetworkImage(profile.avatar!)
                    : null,
                child: (profile?.avatar == null || profile!.avatar!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              );
            }),
          ],
        ),
      ),
      title: Obx(() {
        final profile = controller.chatProfile.value;
        final isGroup = profile?.type == "group";
        return InkWell(
          onTap: () {
            if (isGroup && profile != null) {
              Get.toNamed(AppRoutes.groupDetailsScreen, arguments: profile);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.name ?? "User",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            Text(
              isGroup
                  ? "${profile?.participantsCount ?? 0} participants"
                  : (profile?.isOnline == true ? "Online" : "Offline"),
              style: TextStyle(
                fontSize: 12,
                color: isGroup ? Colors.grey : (profile?.isOnline == true ? Colors.green : Colors.grey),
              ),
            ),
            ],
          ),
        );
      }),
      /*actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: Colors.black),
          onPressed: () {
            // Coming Soon Update
            ComingSoonDialog.show(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.black),
          onPressed: () {
            // Coming Soon Update
            ComingSoonDialog.show(context);
          },
        ),
        // IconButton(
        //   icon: const Icon(Icons.more_vert, color: Colors.black),
        //   onPressed: () {},
        // ),
      ],*/
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.waving_hand_rounded, size: 40, color: Colors.grey.shade400),
            SizedBox(height: 10),
            const Text(
              "Say Hello!\nStart a conversation.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, bool isMe) {
    final avatarUrl = message.sender?.avatar;
    final senderName = message.sender?.name;

    Widget bubble = GestureDetector(
      onLongPress: () => _showMessageOptions(context, message),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2), // Tighter spacing
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.black : Colors.grey.shade100, // Black vs Grey
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildMessageContent(context, message, isMe),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatChatTime(message.createdAt.toString()),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all, 
                    size: 14, 
                    color: message.status == "read" ? Colors.blueAccent : Colors.grey.shade500,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: bubble,
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (avatarUrl != null && avatarUrl.isNotEmpty) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                const SizedBox(width: 8),
              ] else ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 18, color: Colors.grey),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (senderName != null && senderName.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 2),
                        child: Text(
                          senderName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                    bubble,
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SafeArea( // Ensure safety on bottom
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     IconButton(
                      icon: Obx(() => Icon(
                        controller.isEmojiVisible.value 
                            ? Icons.keyboard 
                            : Icons.emoji_emotions_outlined,
                        color: Colors.grey[600],
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
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        focusNode: controller.focusNode,
                        maxLines: 5, // Reduced max lines slightly
                        minLines: 1,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: "Message...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12), // Better vertical alignment
                        ),
                        onTap: () {
                           if (controller.isEmojiVisible.value) {
                             controller.isEmojiVisible.value = false;
                           }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.attach_file, color: Colors.grey[600], size: 22),
                      onPressed: () => _showAttachmentBottomSheet(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[600], size: 22),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          controller.sendFile(File(image.path), "image");
                        }
                      }, 
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Send Button
            InkWell(
              onTap: () {
                 controller.sendMessage();
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
                child: Obx(() => controller.isSendingMessage.value 
                  ? const Center(child: SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    ))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 22) // Modern clean icon
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  /*void _showAttachmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 180,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: SizedBox(
                width: 40, 
                height: 4, 
                // decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(20),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _attachmentItem(
                    icon: Icons.insert_drive_file, 
                    color: Colors.purple, 
                    label: "Document",
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                        if (result != null && result.files.single.path != null) {
                          File file = File(result.files.single.path!);
                          controller.sendFile(file, "file");
                        }
                      } catch (e) {
                         print("Error picking file: $e");
                      }
                    }
                  ),
                  _attachmentItem(
                    icon: Icons.camera_alt, 
                    color: Colors.pink, 
                    label: "Camera",
                    onTap: () async { 
                      Navigator.pop(context);
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        controller.sendFile(File(image.path), "image");
                      }
                    }
                  ),
                  _attachmentItem(
                    icon: Icons.image, 
                    color: Colors.purpleAccent, 
                    label: "Gallery",
                    onTap: () async { 
                      Navigator.pop(context);
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        controller.sendFile(File(image.path), "image");
                      }
                    }
                  ),
                  *//*_attachmentItem(
                    icon: Icons.headphones, 
                    color: Colors.deepOrange, 
                    label: "Audio",
                    onTap: () async { 
                      Navigator.pop(context); 
                       try {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
                        if (result != null && result.files.single.path != null) {
                          File file = File(result.files.single.path!);
                          controller.sendFile(file, "audio");
                        }
                      } catch (e) {
                         print("Error picking audio: $e");
                      }
                    }
                  ),
                  _attachmentItem(
                    icon: Icons.location_on, 
                    color: Colors.green, 
                    label: "Location",
                    onTap: () { 
                      Navigator.pop(context);
                      // TODO: Implement Location Sharing
                     }
                  ),
                  _attachmentItem(
                    icon: Icons.person, 
                    color: Colors.blue, 
                    label: "Contact",
                    onTap: () { 
                      Navigator.pop(context);
                      // TODO: Implement Contact Sharing
                    }
                  ),*//*
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }*/


  void _showAttachmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 12, 
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),

            // Header with Title and Close Icon on Right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    "Share Attachment",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.black54),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attachmentItem(
                    icon: Icons.insert_drive_file_rounded,
                    color: Colors.deepPurple,
                    label: "Document",
                    onTap: () async {
                      Navigator.pop(context);

                      try {
                        FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                        if (result != null &&
                            result.files.single.path != null) {
                          controller.sendFile(
                            File(result.files.single.path!),
                            "file",
                          );
                        }
                      } catch (e) {
                        debugPrint("Error picking file: $e");
                      }
                    },
                  ),

                  _attachmentItem(
                    icon: Icons.camera_alt_rounded,
                    color: Colors.pink,
                    label: "Camera",
                    onTap: () async {
                      Navigator.pop(context);

                      final picker = ImagePicker();
                      final image = await picker.pickImage(
                        source: ImageSource.camera,
                      );

                      if (image != null) {
                        controller.sendFile(
                          File(image.path),
                          "image",
                        );
                      }
                    },
                  ),

                  _attachmentItem(
                    icon: Icons.photo_library_rounded,
                    color: Colors.blue,
                    label: "Gallery",
                    onTap: () async {
                      Navigator.pop(context);

                      final picker = ImagePicker();
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (image != null) {
                        controller.sendFile(
                          File(image.path),
                          "image",
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachmentItem({
    required IconData icon, 
    required Color color, 
    required String label, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  String formatChatTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return "";
    }
  }

  Widget _buildMessageContent(BuildContext context, ChatMessage message, bool isMe) {
    if (message.messageType == "image") {
      final String url = message.attachmentUrl ?? "";
      final String? caption = message.content;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (url.isNotEmpty)
            GestureDetector(
              onTap: () {
                Get.to(() => FullImagePreview(imageUrl: url));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (context, url) => const SizedBox(
                    width: 150,
                    height: 150,
                    child: Center(child: CustomLoadingIndicator()),
                  ),
                  errorWidget: (context, url, error) => const SizedBox(
                    width: 150,
                    height: 150,
                    child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                  ),
                  fit: BoxFit.cover,
                  width: 200,
                  height: 200,
                ),
              ),
            ),
          if (caption != null && caption.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              caption,
              style: TextStyle(
                fontSize: 15,
                color: isMe ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),
          ],
        ],
      );
    } else if (message.messageType == "file" || message.messageType == "audio") {
      final String url = message.attachmentUrl ?? "";
      final String originalName = message.meta?.originalName ?? url.split('/').last;
      final int? bytes = message.meta?.size;
      final String sizeStr = bytes != null ? _formatBytes(bytes) : "";
      final isAudio = message.messageType == "audio";

      return InkWell(
        onTap: () async {
          if (url.isNotEmpty) {
            final Uri uri = Uri.parse(url);
            try {
              bool launched = false;
              if (await canLaunchUrl(uri)) {
                launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              if (!launched) {
                launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
              }
              if (!launched) {
                CustomSnackBar.showError(message: "Could not open attachment URL");
              }
            } catch (e) {
              try {
                bool launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
                if (!launched) {
                  CustomSnackBar.showError(message: "Could not open attachment URL");
                }
              } catch (e2) {
                CustomSnackBar.showError(message: "Could not open attachment URL");
              }
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isMe ? Colors.white24 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAudio ? Icons.audiotrack : Icons.insert_drive_file,
                color: isMe ? Colors.white : Colors.black87,
                size: 28,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      originalName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (sizeStr.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sizeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.download_rounded,
                color: isMe ? Colors.white70 : Colors.grey.shade600,
                size: 20,
              ),
            ],
          ),
        ),
      );
    } else {
      // Default / Text type
      return Text(
        message.content,
        style: TextStyle(
          fontSize: 15,
          color: isMe ? Colors.white : Colors.black87,
          height: 1.3,
        ),
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  void _showMessageOptions(BuildContext context, ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).padding.bottom),
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
                // TODO: Implement reply functionality
                CustomSnackBar.showInfo(message: "Reply feature coming soon!");
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

            // Read by option - only for own messages in group chats
            if (message.isMine && controller.chatProfile.value?.type == "group")
              _buildOptionRow(
                icon: Icons.visibility_rounded,
                label: "Read by",
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(ctx);
                  _showReadReceipts(context, message);
                },
              ),

            _buildOptionRow(
              icon: Icons.delete_outline_rounded,
              label: "Delete for me",
              color: Colors.red.shade300,
              onTap: () async {
                Navigator.pop(ctx);
                await controller.deleteMessage(message.id.toString(), deleteForEveryOne: false);
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
                  await controller.deleteMessage(message.id.toString(), deleteForEveryOne: true);
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
                  child: const Text(
                    "Cancel",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
      ),
    );
  }

  void _showReadReceipts(BuildContext context, ChatMessage message) async {
    final readers = await controller.getReadReceipts(message.id);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).padding.bottom),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.visibility_rounded, color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Read by ${readers.length}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            if (readers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  "No one has read this yet",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...readers.map((reader) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: reader.avatar.isNotEmpty
                          ? NetworkImage(reader.avatar)
                          : null,
                      child: reader.avatar.isEmpty
                          ? Text(
                              reader.name.isNotEmpty
                                  ? reader.name[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reader.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            const SizedBox(height: 6),
          ],
          ),
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
              style: TextStyle(
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
}

class FullImagePreview extends StatelessWidget {
  final String imageUrl;

  const FullImagePreview({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const CustomLoadingIndicator(color: Colors.white),
            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white, size: 50),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
