import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/chat_message_controller.dart';

class ChattingScreen extends GetWidget<ChatMessagesController> {
  const ChattingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Obx(() {
        if (controller.isProfileLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Colors.black87),
          );
        }
        final profile = controller.chatProfile.value;
        if (profile == null) {
          return Center(child: Text("Data Not Found"));
        } else {
          return Scaffold(
            backgroundColor: AppColors.transparent,
            appBar: AppBar(
              backgroundColor: AppColors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.theme.primaryColor,

                    backgroundImage: (profile.avatar != null && profile.avatar!.isNotEmpty)
                        ? NetworkImage(profile.avatar!)
                        : null,   // <- If no image, null

                    child: (profile.avatar == null || profile.avatar!.isEmpty)
                        ? Text(
                      profile.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                        : null,
                  ),

                  /*  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.theme.primaryColor,
                    backgroundImage: profile.avatar,
                    // child: Text(
                    //   profile.name.substring(0, 1),
                    //   style: const TextStyle(
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: 14,
                    //   ),
                    // ),
                  ),*/
                  const SizedBox(width: 10),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.black87),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
            ),
            body: Column(
              children: [
                Divider(color: Color(0xFF464747)),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (controller.messages.isEmpty) {
                      return Center(
                        child: Text(
                          "No Conversation Yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == controller.messages.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(children: [const SizedBox(width: 8)]),
                          );
                        }
                        final message = controller.messages[index];
                        /*return GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity! > 0) {}
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment:
                                  (message.isMine)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!(message.isMine))
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: context.theme.primaryColor,
                                    child: Text(
                                      profile.name.substring(0, 1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                if (!(message.isMine)) const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment:
                                      (message.isMine)
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.6,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (message.isMine ?? false)
                                                ? const Color(0xFF00BCD4)
                                                : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        message.content.toString(),
                                        style: TextStyle(
                                          color:
                                              (message.isMine ?? false)
                                                  ? Colors.white
                                                  : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          formatChatTime(
                                            message.createdAt.toString(),
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11,
                                          ),
                                        ),
                                        if (message.isMine) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.done_all,
                                            size: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                if (message.isMine) const SizedBox(width: 8),
                                if (message.isMine)
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey.shade800,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );*/
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,

                          // TAP = reply to message
                          onTap: () {
                            // onReply(message); // <-- Add your reply logic here
                          },

                          // LONG PRESS = show context menu (delete, copy, etc.)
                          onLongPress: () {
                            showDeleteMessageDialog(
                              context,
                              message.id.toString(),
                            ); // <-- You define
                          },

                          // SWIPE TO REPLY
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity == null) return;

                            // Swipe Right → Reply (for both sender/receiver)
                            if (details.primaryVelocity! > 0) {
                              // onReply(message);
                            }

                            // Swipe Left → maybe future action
                            // if (details.primaryVelocity! < 0) {}
                          },

                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment:
                                  message.isMine
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // LEFT SIDE AVATAR (other user)
                                if (!message.isMine)
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: context.theme.primaryColor,
                                    child: Text(
                                      profile.name.substring(0, 1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),

                                if (!message.isMine) const SizedBox(width: 8),

                                // MESSAGE BUBBLE
                                Column(
                                  crossAxisAlignment:
                                      message.isMine
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.6,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            message.isMine
                                                ? const Color(0xFF00BCD4)
                                                : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        message.content.toString(),
                                        style: TextStyle(
                                          color:
                                              message.isMine
                                                  ? Colors.white
                                                  : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // MESSAGE TIME + TICKS
                                    Row(
                                      children: [
                                        Text(
                                          formatChatTime(
                                            message.createdAt.toString(),
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11,
                                          ),
                                        ),

                                        if (message.isMine) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.done_all,
                                            size: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),

                                if (message.isMine) const SizedBox(width: 8),

                                // RIGHT SIDE AVATAR (me)
                                if (message.isMine)
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey.shade800,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(0, -1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.cyan.shade400,
                            ),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                controller: controller.messageController,
                                decoration: const InputDecoration(
                                  hintText: 'Type your message',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.cyan,
                            child: Obx(() {
                              if (controller.isSendingMessage.value) {
                                return SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeAlign: 1,
                                  ),
                                );
                              } else {
                                return IconButton(
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: controller.sendMessage,
                                );
                              }
                            }),
                          ),
                        ],
                      ),
                      SizedBox(height: context.mediaQueryPadding.bottom),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  String formatChatTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString).toLocal();

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));

    DateTime messageDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    String timeFormat = DateFormat("h:mm a").format(dateTime); // 10:15 AM

    // Today
    if (messageDate == today) {
      return "Today, $timeFormat";
    }

    // Yesterday
    if (messageDate == yesterday) {
      return "Yesterday, $timeFormat";
    }

    // Older Dates
    String dateFormat = DateFormat(
      "d MMMM yyyy",
    ).format(dateTime); // 18 October 2025
    return "$dateFormat, $timeFormat";
  }

  Future<void> showDeleteMessageDialog(
    BuildContext context,
    String messageId,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Delete Message",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            "Do you want to delete this message?",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            // Delete for Me
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteMessage(messageId, deleteForEveryOne: false);
              },
              child: const Text(
                "Delete for Me",
                style: TextStyle(color: Colors.red),
              ),
            ),

            // Delete for Everyone
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteMessage(messageId, deleteForEveryOne: true);
              },
              child: const Text(
                "Delete for Everyone",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),

            // Cancel
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
