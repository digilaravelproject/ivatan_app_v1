import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/constants/app_assets.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
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

class _MessageListScreenState extends State<MessageListScreen> with SingleTickerProviderStateMixin {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Read', 'Unread', 'Business'];

  final Map<int, String?> filterMap = {
    0: null,
    1: 'read',
    2: 'unread',
    3: 'business',
  };

  final ChattController controller = Get.put(ChattController());
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            backgroundColor: AppColors.primary, // Changed to Primary
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                 // Removed shadow for clean look
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  Get.to(DashboardPage());
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2), // White border
                  ),
                  child: ClipOval(
                    child: Image.network(
                      AppUrls.imageurl + (SharedPrefManager().user?.profilePhotoPath ?? ""),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          AppAssets.imgAppLogo,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            title: const Text(
              'Messages',
              style: TextStyle(
                color: Colors.white, // White text
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.group_add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  Get.toNamed(AppRoutes.createGroupScreen);
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            
            // Search bar with animation
            FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                )),
                  child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100, // Flat grey background
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
                            onChanged: controller.searchedPerson,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            cursorColor: AppColors.black,
                            decoration: InputDecoration(
                              hintText: 'Search messages...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filter chips - Simple & Clean
            Container(
              height: 32, // Reduced from 40
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = index;
                        });
                        final filterValue = filterMap[index];
                        controller.fetchInbox(filter: filterValue);
                      },
                      borderRadius: BorderRadius.circular(16), // Reduced from 20
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // Reduced padding
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.black : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 12, // Reduced from 13
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Chat list - Clean List Style (No Cards)
            Obx(() {
              if (controller.isLoading.value) {
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.black, 
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              if (controller.chatList.isEmpty) {
                 return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey.shade300),
                        SizedBox(height: 12),
                        Text("No messages yet", style: TextStyle(color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                );
              }
              
              return Expanded(
                child: RefreshIndicator(color: AppColors.primary,
                  onRefresh: () => controller.fetchInbox(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    itemCount: controller.filteredChatList.length,
                    separatorBuilder: (ctx, i) => Divider(height: 1, indent: 80, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                    final message = controller.filteredChatList[index];
                    final hasUnread = message.unreadCount > 0;
                    
                    return InkWell(
                      onTap: () async {
                         await Get.toNamed(AppRoutes.chattingScreen, arguments: message);
                         controller.fetchInbox(filter: filterMap[_selectedFilter]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // Avatar with online indicator
                            Stack(
                              children: [
                                Container(
                                  width: 50, 
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  child: ClipOval(
                                    child: (message.avatar != null && message.avatar.toString().isNotEmpty)
                                        ? Image.network(
                                            message.avatar.toString(),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return message.type == "group"
                                                  ? const Center(child: Icon(Icons.group, color: Colors.grey, size: 26))
                                                  : Center(
                                                      child: Text(
                                                        message.name.isNotEmpty ? message.name[0].toUpperCase() : "?",
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                                      ),
                                                    );
                                            },
                                          )
                                        : (message.type == "group"
                                            ? const Center(child: Icon(Icons.group, color: Colors.grey, size: 26))
                                            : Center(
                                                child: Text(
                                                  message.name.isNotEmpty ? message.name[0].toUpperCase() : "?",
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                                ),
                                              )),
                                  ),
                                ),
                                if (message.type != "group" && message.isOnline)
                                  Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Container(
                                      width: 13,
                                      height: 13,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                      ),
                                    ),
                                  ),
                              ],
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
                                          style: TextStyle(
                                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
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
                                          color: hasUnread ? AppColors.black : Colors.grey.shade500,
                                          fontSize: 11,
                                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          message.lastMessage == null
                                              ? "No messages"
                                              : (message.lastMessage!.messageType == "image"
                                                  ? "📷 Image"
                                                  : (message.lastMessage!.messageType == "file"
                                                      ? "📁 File"
                                                      : (message.lastMessage!.messageType == "audio"
                                                          ? "🎵 Audio"
                                                          : (message.lastMessage!.content.isNotEmpty
                                                              ? message.lastMessage!.content
                                                              : "No messages")))),
                                          style: TextStyle(
                                            color: hasUnread ? Colors.black87 : Colors.grey.shade500,
                                            fontSize: 14,
                                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (hasUnread)
                                        Container(
                                          margin: EdgeInsets.only(left: 8),
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.black, // Use primary/black for unread badge
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            message.unreadCount.toString(),
                                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  // Keep helper methods like formatChatDate...
  String formatChatDate(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));
      final DateTime messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        return DateFormat('hh:mm a').format(dateTime);
      } else if (messageDate == yesterday) {
        return "Yesterday";
      } else {
        return DateFormat('dd/MM/yy').format(dateTime); // Simplified date date format
      }
    } catch (e) {
      return "";
    }
  }


}
