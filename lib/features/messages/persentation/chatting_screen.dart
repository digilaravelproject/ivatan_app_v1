import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:i_vatan_app/core/constants/app_assets.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/widgets/coming_soon_dialog.dart';
import '../controller/chat_message_controller.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChattingScreen extends GetView<ChatMessagesController> {
  const ChattingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.isEmojiVisible.value) {
          controller.isEmojiVisible.value = false;
          return false;
        }
        return true;
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

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    final isMe = message.isMine;
                    return _buildMessageBubble(context, message, isMe);
                  },
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile?.name ?? "User",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Dark Text
              ),
            ),
            const Text(
              "Online", // Dynamic status if available
              style: TextStyle(
                fontSize: 12,
                color: Colors.green, // Accent for status
              ),
            ),
          ],
        );
      }),
      actions: [
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
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
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

  Widget _buildMessageBubble(BuildContext context, dynamic message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
            Text(
              message.content,
              style: TextStyle(
                fontSize: 15, 
                color: isMe ? Colors.white : Colors.black87,
                height: 1.3
              ),
            ),
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
                  const Icon(Icons.done_all, size: 14, color: Colors.blueAccent),
                ],
              ],
            ),
          ],
        ),
      ),
    );
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



  void _showAttachmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 280,
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
                  _attachmentItem(
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
}
