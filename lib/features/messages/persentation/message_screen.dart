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
            AppColors.primary.withOpacity(0.02),
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
                    Icons.search,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () {},
                ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () {},
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.search,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: controller.searchedPerson,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search messages...',
                              hintStyle: TextStyle(
                                color: AppColors.lightTextSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
            
            // Filter chips with improved design
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFilter = index;
                          });
                          final filterValue = filterMap[index];
                          controller.fetchInbox(filter: filterValue);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withOpacity(0.8),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.neutralGray,
                              width: isSelected ? 0 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.black,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Chat list with enhanced design
            Obx(() {
              if (controller.isLoading.value) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading messages...',
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No Chats Yet",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start a conversation with someone",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: controller.filteredChatList.length,
                  itemBuilder: (context, index) {
                    final message = controller.filteredChatList[index];
                    final hasUnread = message.unreadCount! > 0;
                    
                    return FadeTransition(
                      opacity: _animationController,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.1 * index),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOut,
                        )),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.chattingScreen,
                              arguments: message,
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: hasUnread
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.08),
                                        AppColors.primary.withOpacity(0.03),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: hasUnread ? null : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: hasUnread
                                  ? Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                      width: 1,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: hasUnread
                                      ? AppColors.primary.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Avatar with online indicator
                                Hero(
                                  tag: 'avatar_${message.name}',
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.primary.withOpacity(0.7),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.transparent,
                                          child: message.type == "group"
                                              ? Icon(
                                                  Icons.group_rounded,
                                                  color: Colors.white,
                                                  size: 30,
                                                )
                                              : Text(
                                                  message.name.substring(0, 1).toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      if (hasUnread)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: AppColors.success,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                
                                // Message content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              message.name,
                                              style: TextStyle(
                                                fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                                                fontSize: 17,
                                                color: AppColors.black,
                                                letterSpacing: -0.3,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            formatChatDate(message.updatedAt.toString()),
                                            style: TextStyle(
                                              color: hasUnread 
                                                  ? AppColors.primary 
                                                  : AppColors.lightTextSecondary,
                                              fontSize: 12,
                                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              message.lastMessage?.content ?? "Tap to start chatting",
                                              style: TextStyle(
                                                color: hasUnread 
                                                    ? AppColors.black.withOpacity(0.7)
                                                    : AppColors.lightTextSecondary,
                                                fontSize: 14,
                                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (hasUnread) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.primary,
                                                    AppColors.primary.withOpacity(0.8),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(14),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primary.withOpacity(0.4),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                message.unreadCount.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
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
        return DateFormat('dd MMM').format(dateTime);
      }
    } catch (e) {
      return "";
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
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
