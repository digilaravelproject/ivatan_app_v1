import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../controller/notification_controller.dart';
import '../data/model/notification_response_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationController _controller = Get.find<NotificationController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Rebuild to update active/inactive tab badge styling
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchNotificationsList();
      _controller.fetchUnreadNotificationsList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Categories helper to get icon and color theme
  Map<String, dynamic> _getCategoryDetails(String category) {
    switch (category.toLowerCase()) {
      case 'follow':
        return {
          'icon': Icons.person_add_rounded,
          'color': const Color(0xFF3B82F6), // Blue
          'bg': const Color(0xFFDBEAFE),
          'label': 'Follow',
        };
      case 'comment':
        return {
          'icon': Icons.comment_rounded,
          'color': const Color(0xFF10B981), // Emerald
          'bg': const Color(0xFFD1FAE5),
          'label': 'Comment',
        };
      case 'like':
        return {
          'icon': Icons.favorite_rounded,
          'color': const Color(0xFFEF4444), // Red
          'bg': const Color(0xFFFEE2E2),
          'label': 'Like',
        };
      case 'leave':
        return {
          'icon': Icons.calendar_today_rounded,
          'color': const Color(0xFFF59E0B), // Gold/Amber
          'bg': const Color(0xFFFEF3C7),
          'label': 'Leaves',
        };
      case 'attendance':
        return {
          'icon': Icons.location_on_rounded,
          'color': const Color(0xFF10B981), // Emerald
          'bg': const Color(0xFFD1FAE5),
          'label': 'Attendance',
        };
      case 'announcement':
        return {
          'icon': Icons.campaign_rounded,
          'color': const Color(0xFF3B82F6), // Blue
          'bg': const Color(0xFFDBEAFE),
          'label': 'Updates',
        };
      case 'job':
        return {
          'icon': Icons.business_center_rounded,
          'color': const Color(0xFF8B5CF6), // Purple
          'bg': const Color(0xFFEDE9FE),
          'label': 'Careers',
        };
      case 'chat':
      default:
        return {
          'icon': Icons.forum_rounded,
          'color': const Color(0xFFEC4899), // Pink
          'bg': const Color(0xFFFCE7F3),
          'label': 'Chats',
        };
    }
  }

  // Group notifications into Today, Yesterday, and Older
  Map<String, List<NotificationApiItem>> _groupNotifications(List<NotificationApiItem> items) {
    final Map<String, List<NotificationApiItem>> grouped = {
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var item in items) {
      DateTime parsedTime;
      try {
        parsedTime = DateTime.parse(item.createdAt).toLocal();
      } catch (e) {
        parsedTime = DateTime.now();
      }
      
      final itemDate = DateTime(parsedTime.year, parsedTime.month, parsedTime.day);
      if (itemDate == today) {
        grouped['Today']!.add(item);
      } else if (itemDate == yesterday) {
        grouped['Yesterday']!.add(item);
      } else {
        grouped['Earlier']!.add(item);
      }
    }

    // Clean up empty categories
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  // Format relative time
  String _formatRelativeTime(String dateStr) {
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(dateStr).toLocal();
    } catch (e) {
      return '';
    }
    
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  // Show detailed bottom sheet on clicking a notification card
  void _showNotificationDetail(NotificationApiItem item) {
    final bool wasUnread = item.readAt == null;

    // Mark as read locally immediately on click
    final updatedItem = NotificationApiItem(
      id: item.id,
      type: item.type,
      innerData: item.innerData,
      readAt: DateTime.now().toIso8601String(), // Local read confirmation
      createdAt: item.createdAt,
    );

    // Update in controller list (All tab)
    final index = _controller.notificationsList.indexWhere((n) => n.id == item.id);
    if (index != -1) {
      _controller.notificationsList[index] = updatedItem;
    }
    
    // Remove from unread list (Unread tab)
    _controller.unreadNotificationsList.removeWhere((n) => n.id == item.id);

    if (wasUnread) {
      _controller.markNotificationAsRead(item.id);
    }

    final payload = item.innerData?.payload;
    if (payload == null) return;

    final details = _getCategoryDetails(item.innerData?.category ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Category Icon & Tag)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: details['bg'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(details['icon'], color: details['color'], size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details['label'].toString().toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: details['color'],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRelativeTime(item.createdAt),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Actor info if available
            if (payload.actorName != null && payload.actorName!.isNotEmpty) ...[
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: payload.actorAvatar != null && payload.actorAvatar!.isNotEmpty
                        ? NetworkImage(payload.actorAvatar!)
                        : null,
                    radius: 20,
                    child: payload.actorAvatar == null || payload.actorAvatar!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    payload.actorName!,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Title
            Text(
              payload.title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Body
            Text(
              payload.message,
              style: GoogleFonts.outfit(
                fontSize: 15,
                height: 1.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 30),

            // Actions Block
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Dismiss',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          splashRadius: 22,
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Obx(() {
            final hasUnread = _controller.unreadNotificationsList.isNotEmpty;
            if (!hasUnread) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  _controller.markAllNotificationsAsRead();
                  CustomSnackBar.showSuccess(message: 'All notifications marked as read');
                },
                icon: const Icon(
                  Icons.done_all_rounded,
                  size: 16,
                  color: Color(0xFF0891B2),
                ),
                label: Text(
                  'Mark all read',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0891B2),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Dynamic Tab Bar
          // Custom Pill/Segmented Tab Bar Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(3),
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: isDark ? const Color(0xFF22D3EE) : const Color(0xFF0E7490),
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('All'),
                      const SizedBox(width: 4),
                      Obx(() {
                        final count = _controller.notificationsList.length;
                        if (count == 0) return const SizedBox.shrink();
                        final isActive = _tabController.index == 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isActive
                                ? (isDark ? const Color(0xFF22D3EE).withOpacity(0.15) : const Color(0xFFECFEFF))
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: isActive
                                  ? (isDark ? const Color(0xFF22D3EE) : const Color(0xFF0891B2))
                                  : (isDark ? Colors.white70 : Colors.black54),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Unread'),
                      const SizedBox(width: 4),
                      Obx(() {
                        final count = _controller.unreadNotificationsList.length;
                        if (count == 0) return const SizedBox.shrink();
                        final isActive = _tabController.index == 1;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isActive
                                ? (isDark ? const Color(0xFF22D3EE).withOpacity(0.15) : const Color(0xFFECFEFF))
                                : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: isActive
                                  ? (isDark ? const Color(0xFF22D3EE) : const Color(0xFF0891B2))
                                  : (isDark ? Colors.red.shade200 : Colors.red.shade800),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: All Notifications
                Obx(() {
                  if (_controller.isListLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_controller.notificationsList.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return RefreshIndicator(
                    onRefresh: () => _controller.fetchNotificationsList(),
                    child: _buildNotificationList(_controller.notificationsList, isDark),
                  );
                }),

                // Tab 2: Unread Notifications
                Obx(() {
                  if (_controller.isUnreadListLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_controller.unreadNotificationsList.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return RefreshIndicator(
                    onRefresh: () => _controller.fetchUnreadNotificationsList(),
                    child: _buildNotificationList(_controller.unreadNotificationsList, isDark),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationApiItem> items, bool isDark) {
    final grouped = _groupNotifications(items);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: grouped.keys.length,
      itemBuilder: (context, sectionIndex) {
        final sectionName = grouped.keys.elementAt(sectionIndex);
        final sectionItems = grouped[sectionName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header (Today, Yesterday, Earlier)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
              child: Text(
                sectionName,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                ),
              ),
            ),

            // Section Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sectionItems.length,
              itemBuilder: (context, itemIndex) {
                final item = sectionItems[itemIndex];
                return _buildNotificationCard(item, isDark);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationApiItem item, bool isDark) {
    final payload = item.innerData?.payload;
    if (payload == null) return const SizedBox.shrink();

    final details = _getCategoryDetails(item.innerData?.category ?? '');
    final isRead = item.readAt != null;

    return GestureDetector(
      onTap: () => _showNotificationDetail(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead 
                ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                : (isDark ? const Color(0xFF262626) : const Color(0xFFF0FDF4)), // Soft green highlight for unread
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead 
                  ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100)
                  : (isDark ? AppColors.accent.withOpacity(0.3) : AppColors.accent.withOpacity(0.2)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread indicator dot
              if (!isRead)
                Container(
                  margin: const EdgeInsets.only(top: 14, right: 8),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              
              // Category Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: details['bg'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  details['icon'],
                  color: details['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Content Block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          details['label'].toString().toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: details['color'],
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          _formatRelativeTime(item.createdAt),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      payload.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payload.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 72,
              color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up!',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'No new notifications. We will notify you when something updates!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
