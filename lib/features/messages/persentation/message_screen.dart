import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/constants/app_assets.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:i_vatan_app/features/profile/screen/profile_screen.dart';
import 'package:i_vatan_app/route/app_pages.dart';

import '../../../core/network/app_urls.dart';
import 'package:intl/intl.dart';
import '../controller/chatt_controller.dart';
import 'dashboard.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({Key? key}) : super(key: key);

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Read', 'Unread', 'Business'];

  final Map<int, String?> filterMap = {
    0: null,
    1: 'read',
    2: 'unread',
    3: 'business',
  };

  final ChattController controller = Get.put(ChattController());
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
        backgroundColor: AppColors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: (){
               // Get.to(ProfileScreen());
                Get.to(DashboardPage());
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: Image.network(
                    AppUrls.imageurl + (SharedPrefManager().user?.profilePhotoPath ?? ""),
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppAssets.imgAppLogo, // fallback asset image
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      );
                    },
                  ),
                ),
              ),

            ),
          ),
          title: const Text(
            'i-message',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),

        ),

        body: Column(
          children: [
            // Divider(color: Colors.grey[600]),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.neutralGray,
                  borderRadius: BorderRadius.circular(16),
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
                        onChanged: controller.searchedPerson,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filters[index]),
                      selected: _selectedFilter == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = index;
                        });
                        final filterValue = filterMap[index];
                        controller.fetchInbox(filter: filterValue);
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.transparent,
                      showCheckmark: false,
                    )

                    /*FilterChip(
                      label: Text(_filters[index]),
                      selected: _selectedFilter == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = index;
                        });
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      disabledColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      pressElevation: 0,
                      clipBehavior: Clip.antiAlias,
                      side: BorderSide(color: AppColors.transparent),
                      labelStyle: TextStyle(
                        color:
                        _selectedFilter == index
                            ? AppColors.white
                            : AppColors.primary,
                        fontWeight:
                        _selectedFilter == index
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      showCheckmark: false,
                    ),*/
                  );
                }),
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.chatList.isEmpty) {
                return const Center(child: Text("No Chats Found"));
              }
              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.filteredChatList.length,
                  itemBuilder: (context, index) {
                    final message = controller.filteredChatList[index];
                    return InkWell(
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.chattingScreen,
                          arguments: message,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          // color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: AppColors.black),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey.shade300,
                              child:
                              message.type == "group"
                                  ? const Icon(
                                Icons.group,
                                color: Colors.black,
                              )
                                  : Text(
                                message.name
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message.lastMessage?.content ??
                                        "click here to chat",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatChatDate(message.updatedAt.toString()),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                if (message.unreadCount! > 0) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        message.unreadCount.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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


  Widget _buildStoryItem(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

/*class ChatScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final Color color;

  const ChatScreen({
    Key? key,
    required this.name,
    required this.avatar,
    required this.color,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {"text": "Hi Jos! How are you?", "isMe": false},
    {"text": "Oh Hello Jacob! I'm fine. You?", "isMe": true},
    {"text": "Send me the file please.", "isMe": false},
    {"text": "Sure, I will.", "isMe": true},
  ];

  Map<String, dynamic>? replyToMessage;

  void sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    messages.add({
      "text": _messageController.text,
      "isMe": true,
      "reply": replyToMessage,
    });

    replyToMessage = null;
    _messageController.clear();
    setState(() {});
  }

  void openReplyBox(Map<String, dynamic> message) {
    setState(() {
      replyToMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.color,
              child: Text(widget.avatar),
            ),
            SizedBox(width: 10),
            Text(widget.name, style: TextStyle(color: Colors.black)),
          ],
        ),
        elevation: 1,
      ),

      body: Column(
        children: [
          /// =============== REPLY PREVIEW BOX ============
          if (replyToMessage != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      replyToMessage!["text"],
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => replyToMessage = null),
                    child: Icon(Icons.close, color: Colors.black54),
                  )
                ],
              ),
            ),

          /// ================= CHAT LIST ===================
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var msg = messages[index];

                return GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      openReplyBox(msg); // RIGHT SWIPE
                    }
                  },
                  child: Align(
                    alignment:
                    msg["isMe"] ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: msg["isMe"]
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (msg["reply"] != null)
                          Container(
                            margin: EdgeInsets.only(bottom: 4),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              msg["reply"]["text"],
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ),

                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: msg["isMe"]
                                ? Colors.cyan
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            msg["text"],
                            style: TextStyle(
                              color: msg["isMe"] ? Colors.white : Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// =============== MESSAGE BOX ==================
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                offset: Offset(0, -1),
                blurRadius: 4,
              )
            ]),
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.cyan, size: 26),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.cyan,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
