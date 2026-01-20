import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GreetingDialogHelper {
  static const String _lastShownDateKey = 'greeting_dialog_last_shown_date';

  // Get greeting based on time with better emojis
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Get greeting emoji based on time
  static String getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '🌅';
    } else if (hour < 17) {
      return '☀️';
    } else if (hour < 21) {
      return '🌆';
    } else {
      return '🌙';
    }
  }

  // Check if dialog should be shown today
  static Future<bool> shouldShowDialogToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShownDate = prefs.getString(_lastShownDateKey);
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (lastShownDate == null || lastShownDate != todayString) {
      return true;
    }
    return false;
  }

  // Save today's date after showing dialog
  static Future<void> _saveShownDate() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await prefs.setString(_lastShownDateKey, todayString);
  }

  // Reset dialog (for testing purposes)
  static Future<void> resetDialog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastShownDateKey);
  }

  // Main function to show the dialog with date check
  static Future<void> showGreetingDialogIfNeeded(
      BuildContext context, {
        required String userName,
        required List<ActivityItem> activities,
        bool forceShow = false, // For testing
      }) async {
    if (!forceShow) {
      final shouldShow = await shouldShowDialogToday();
      if (!shouldShow) {
        debugPrint('Greeting dialog already shown today. Skipping...');
        return;
      }
    }

    await _showDialog(context, userName: userName, activities: activities);
    if (!forceShow) {
      await _saveShownDate();
    }
  }

  // Internal dialog display function
  static Future<void> _showDialog(
      BuildContext context, {
        required String userName,
        required List<ActivityItem> activities,
      }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext dialogContext) {
        return _GreetingDialogContent(
          userName: userName,
          activities: activities,
        );
      },
    );
  }
}

// Separate StatefulWidget for animation support
class _GreetingDialogContent extends StatefulWidget {
  final String userName;
  final List<ActivityItem> activities;

  const _GreetingDialogContent({
    required this.userName,
    required this.activities,
  });

  @override
  State<_GreetingDialogContent> createState() => _GreetingDialogContentState();
}

class _GreetingDialogContentState extends State<_GreetingDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    // Auto dismiss after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.85,
                maxWidth: 500,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    // Animated gradient background
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade400,
                              Colors.pink.shade300,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),

                    // Close button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Main content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header section
                        Container(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              // Greeting emoji
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    GreetingDialogHelper.getGreetingEmoji(),
                                    style: const TextStyle(fontSize: 42),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Greeting text
                              Text(
                                GreetingDialogHelper.getGreeting(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // User name
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.userName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content section
                        Flexible(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 24),

                                // Section header
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.shade400,
                                              Colors.purple.shade400,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.history_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Yesterday\'s Activity',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Activity list
                                if (widget.activities.isEmpty)
                                  _buildEmptyState()
                                else
                                  Flexible(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      shrinkWrap: true,
                                      itemCount: widget.activities.length,
                                      itemBuilder: (context, index) {
                                        return TweenAnimationBuilder(
                                          duration: Duration(
                                            milliseconds: 300 + (index * 100),
                                          ),
                                          tween: Tween<double>(begin: 0, end: 1),
                                          curve: Curves.easeOut,
                                          builder: (context, double value, child) {
                                            return Transform.translate(
                                              offset: Offset(0, 20 * (1 - value)),
                                              child: Opacity(
                                                opacity: value,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: _buildActivityItem(
                                            widget.activities[index],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                const SizedBox(height: 20),

                                // Bottom motivational section
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.amber.shade50,
                                          Colors.orange.shade50,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.amber.shade200,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.emoji_events_rounded,
                                            color: Colors.amber.shade700,
                                            size: 26,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Keep up the great work! 🚀',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No activity yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring to see your activity here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activity.color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activity.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle activity tap if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        activity.color.withOpacity(0.2),
                        activity.color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    activity.icon,
                    color: activity.color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Count badge
                if (activity.count != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    constraints: const BoxConstraints(minWidth: 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          activity.color,
                          activity.color.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: activity.color.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${activity.count}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Activity model class
class ActivityItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final int? count;

  ActivityItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.count,
  });
}

// ============================================================
// EXAMPLE USAGE
// ============================================================

/*

// 1. Basic Usage - Show dialog if not shown today
void _showGreetingDialog() async {
  await GreetingDialogHelper.showGreetingDialogIfNeeded(
    context,
    userName: 'Rajesh Kumar',
    activities: _getActivities(),
  );
}

// 2. Force show (for testing/debugging)
void _forceShowDialog() async {
  await GreetingDialogHelper.showGreetingDialogIfNeeded(
    context,
    userName: 'Rajesh Kumar',
    activities: _getActivities(),
    forceShow: true, // This will show even if already shown today
  );
}

// 3. Reset dialog status (for testing)
void _resetDialog() async {
  await GreetingDialogHelper.resetDialog();
  print('Dialog reset! Will show again on next call.');
}

// 4. Sample activities data
List<ActivityItem> _getActivities() {
  return [
    ActivityItem(
      icon: Icons.photo_library_rounded,
      title: 'Photos Viewed',
      description: 'You explored 15 amazing photos',
      color: Colors.pink,
      count: 15,
    ),
    ActivityItem(
      icon: Icons.video_library_rounded,
      title: 'Videos Watched',
      description: 'Enjoyed 8 interesting videos',
      color: Colors.red,
      count: 8,
    ),
    ActivityItem(
      icon: Icons.chat_bubble_rounded,
      title: 'Messages Sent',
      description: 'Connected with 5 friends',
      color: Colors.blue,
      count: 5,
    ),
    ActivityItem(
      icon: Icons.favorite_rounded,
      title: 'Posts Liked',
      description: 'Loved 23 awesome posts',
      color: Colors.pinkAccent,
      count: 23,
    ),
    ActivityItem(
      icon: Icons.person_add_rounded,
      title: 'New Followers',
      description: '3 people started following you',
      color: Colors.green,
      count: 3,
    ),
  ];
}

// 5. Call from initState in your HomePage
@override
void initState() {
  super.initState();

  // Show after widget is built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(seconds: 1), () {
      _showGreetingDialog();
    });
  });
}

// 6. Or create a test button
ElevatedButton(
  onPressed: () => _forceShowDialog(),
  child: const Text('Show Greeting (Force)'),
)

*/

  // import 'dart:ui';
  // import 'package:flutter/material.dart';
  //
  // /*class GreetingDialogHelper {
  //   // Get greeting based on time
  //   static String getGreeting() {
  //     final hour = DateTime.now().hour;
  //     if (hour < 12) {
  //       return '🌅 Good Morning';
  //     } else if (hour < 17) {
  //       return '☀️ Good Afternoon';
  //     } else {
  //       return '🌙 Good Evening';
  //     }
  //   }
  //
  //   // Main function to show the dialog
  //   static void showGreetingDialog(BuildContext context, {
  //     required String userName,
  //     required List<ActivityItem> activities,
  //   }) {
  //     showDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       barrierColor: Colors.black.withOpacity(0.3),
  //       builder: (BuildContext context) {
  //         // Auto dismiss after 5 seconds
  //         Future.delayed(Duration(seconds: 5000), () {
  //           if (Navigator.canPop(context)) {
  //             Navigator.of(context).pop();
  //           }
  //         }
  //         );
  //
  //         return Dialog(
  //           backgroundColor: Colors.transparent,
  //           insetPadding: EdgeInsets.all(20),
  //           child: BackdropFilter(
  //             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //             child: Container(
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.95),
  //                 borderRadius: BorderRadius.circular(30),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     blurRadius: 20,
  //                     offset: Offset(0, 10),
  //                   ),
  //                 ],
  //               ),
  //               child: Stack(
  //                 children: [
  //                   // Gradient overlay for top section
  //                   Positioned(
  //                     top: 0,
  //                     left: 0,
  //                     right: 0,
  //                     child: Container(
  //                       height: 160,
  //                       decoration: BoxDecoration(
  //                         gradient: LinearGradient(
  //                           begin: Alignment.topLeft,
  //                           end: Alignment.bottomRight,
  //                           colors: [
  //                             Colors.blue.withOpacity(0.1),
  //                             Colors.purple.withOpacity(0.1),
  //                           ],
  //                         ),
  //                         borderRadius: BorderRadius.only(
  //                           topLeft: Radius.circular(30),
  //                           topRight: Radius.circular(30),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //
  //                   // Close button
  //                   Positioned(
  //                     top: 15,
  //                     right: 15,
  //                     child: GestureDetector(
  //                       onTap: () => Navigator.of(context).pop(),
  //                       child: Container(
  //                         padding: EdgeInsets.all(8),
  //                         decoration: BoxDecoration(
  //                           color: Colors.black.withOpacity(0.1),
  //                           shape: BoxShape.circle,
  //                         ),
  //                         child: Icon(
  //                           Icons.close,
  //                           color: Colors.black54,
  //                           size: 20,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //
  //                   // Content
  //                   Padding(
  //                     padding: EdgeInsets.all(25),
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         SizedBox(height: 10),
  //
  //                         // Greeting text
  //                         Text(
  //                           getGreeting(),
  //                           style: TextStyle(
  //                             fontSize: 32,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black87,
  //                             letterSpacing: 0.5,
  //                           ),
  //                         ),
  //                         SizedBox(height: 8),
  //
  //                         Text(
  //                           userName,
  //                           style: TextStyle(
  //                             fontSize: 20,
  //                             fontWeight: FontWeight.w600,
  //                             color: Colors.blue.shade700,
  //                           ),
  //                         ),
  //
  //                         SizedBox(height: 12),
  //
  //                         // Divider with icon
  //                         Row(
  //                           children: [
  //                             Container(
  //                               padding: EdgeInsets.all(8),
  //                               decoration: BoxDecoration(
  //                                 color: Colors.blue.withOpacity(0.1),
  //                                 borderRadius: BorderRadius.circular(10),
  //                               ),
  //                               child: Icon(
  //                                 Icons.history,
  //                                 color: Colors.blue.shade700,
  //                                 size: 20,
  //                               ),
  //                             ),
  //                             SizedBox(width: 12),
  //                             Text(
  //                               'Yesterday\'s Activity',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: Colors.black87,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //
  //                         SizedBox(height: 20),
  //
  //                         // Activity list
  //                         Container(
  //                           constraints: BoxConstraints(
  //                             maxHeight: MediaQuery.of(context).size.height * 0.4,
  //                           ),
  //                           child: SingleChildScrollView(
  //                             child: Column(
  //                               children: activities.map((activity) {
  //                                 return _buildActivityItem(activity);
  //                               }).toList(),
  //                             ),
  //                           ),
  //                         ),
  //
  //                         SizedBox(height: 20),
  //
  //                         // Bottom motivational text
  //                         Container(
  //                           padding: EdgeInsets.all(12),
  //                           decoration: BoxDecoration(
  //                             gradient: LinearGradient(
  //                               colors: [
  //                                 Colors.blue.withOpacity(0.1),
  //                                 Colors.purple.withOpacity(0.1),
  //                               ],
  //                             ),
  //                             borderRadius: BorderRadius.circular(15),
  //                           ),
  //                           child: Row(
  //                             children: [
  //                               Icon(
  //                                 Icons.emoji_events,
  //                                 color: Colors.amber.shade700,
  //                                 size: 24,
  //                               ),
  //                               SizedBox(width: 10),
  //                               Expanded(
  //                                 child: Text(
  //                                   'Keep up the great work! 🚀',
  //                                   style: TextStyle(
  //                                     fontSize: 14,
  //                                     fontWeight: FontWeight.w500,
  //                                     color: Colors.black87,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  //
  //   // Activity item widget
  //   static Widget _buildActivityItem(ActivityItem activity) {
  //     return Container(
  //       margin: EdgeInsets.only(bottom: 12),
  //       padding: EdgeInsets.all(15),
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.7),
  //         borderRadius: BorderRadius.circular(15),
  //         border: Border.all(
  //           color: activity.color.withOpacity(0.3),
  //           width: 1.5,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: activity.color.withOpacity(0.1),
  //             blurRadius: 8,
  //             offset: Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         children: [
  //           // Icon container
  //           Container(
  //             padding: EdgeInsets.all(10),
  //             decoration: BoxDecoration(
  //               color: activity.color.withOpacity(0.15),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Icon(
  //               activity.icon,
  //               color: activity.color,
  //               size: 24,
  //             ),
  //           ),
  //           SizedBox(width: 15),
  //
  //           // Text content
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   activity.title,
  //                   style: TextStyle(
  //                     fontSize: 15,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.black87,
  //                   ),
  //                 ),
  //                 SizedBox(height: 4),
  //                 Text(
  //                   activity.description,
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     color: Colors.black54,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           // Count badge
  //           if (activity.count != null)
  //             Container(
  //               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //               decoration: BoxDecoration(
  //                 color: activity.color,
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //               child: Text(
  //                 '${activity.count}',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     );
  //   }
  // }
  //
  // // Activity model class
  // class ActivityItem {
  //   final IconData icon;
  //   final String title;
  //   final String description;
  //   final Color color;
  //   final int? count;
  //
  //   ActivityItem({
  //     required this.icon,
  //     required this.title,
  //     required this.description,
  //     required this.color,
  //     this.count,
  //   });
  // }*/
  //
  //
  // import 'package:shared_preferences/shared_preferences.dart';
  //
  // class GreetingDialogHelper {
  //   // SharedPreferences key for storing last shown date
  //   static const String _lastShownDateKey = 'greeting_dialog_last_shown_date';
  //
  //   // Get greeting based on time
  //   static String getGreeting() {
  //     final hour = DateTime.now().hour;
  //     if (hour < 12) {
  //       return '🌅 Good Morning';
  //     } else if (hour < 17) {
  //       return '☀️ Good Afternoon';
  //     } else {
  //       return '🌙 Good Evening';
  //     }
  //   }
  //
  //   // Check if dialog should be shown today
  //   static Future<bool> shouldShowDialogToday() async {
  //     final prefs = await SharedPreferences.getInstance();
  //     final lastShownDate = prefs.getString(_lastShownDateKey);
  //     final today = DateTime.now();
  //     final todayString = '${today.year}-${today.month}-${today.day}';
  //
  //     // If no date stored or different date, show dialog
  //     if (lastShownDate == null || lastShownDate != todayString) {
  //       return true;
  //     }
  //     return false;
  //   }
  //
  //   // Save today's date after showing dialog
  //   static Future<void> _saveShownDate() async {
  //     final prefs = await SharedPreferences.getInstance();
  //     final today = DateTime.now();
  //     final todayString = '${today.year}-${today.month}-${today.day}';
  //     await prefs.setString(_lastShownDateKey, todayString);
  //   }
  //
  //   // Main function to show the dialog with date check
  //   static Future<void> showGreetingDialogIfNeeded(BuildContext context, {
  //     required String userName,
  //     required List<ActivityItem> activities,
  //   }) async {
  //     // Check if dialog should be shown today
  //     final shouldShow = await shouldShowDialogToday();
  //
  //     if (!shouldShow) {
  //       print('Dialog already shown today. Skipping...');
  //       return;
  //     }
  //
  //     // Show dialog and save date
  //     await _showDialog(context, userName: userName, activities: activities);
  //     await _saveShownDate();
  //   }
  //
  //   // Internal dialog display function
  //   static Future<void> _showDialog(BuildContext context, {
  //     required String userName,
  //     required List<ActivityItem> activities,
  //   }) async {
  //     showDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       barrierColor: Colors.black.withOpacity(0.3),
  //       builder: (BuildContext context) {
  //         // Auto dismiss after 5 seconds
  //         Future.delayed(Duration(seconds: 500), () {
  //           if (Navigator.canPop(context)) {
  //             Navigator.of(context).pop();
  //           }
  //         });
  //
  //         return Dialog(
  //           backgroundColor: Colors.transparent,
  //           insetPadding: EdgeInsets.all(20),
  //           child: BackdropFilter(
  //             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //             child: Container(
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.95),
  //                 borderRadius: BorderRadius.circular(30),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     blurRadius: 20,
  //                     offset: Offset(0, 10),
  //                   ),
  //                 ],
  //               ),
  //               child: Stack(
  //                 children: [
  //                   // Gradient overlay for top section
  //                   Positioned(
  //                     top: 0,
  //                     left: 0,
  //                     right: 0,
  //                     child: Container(
  //                       height: 170,
  //                       decoration: BoxDecoration(
  //                         gradient: LinearGradient(
  //                           begin: Alignment.topLeft,
  //                           end: Alignment.bottomRight,
  //                           colors: [
  //                             Colors.blue.withOpacity(0.1),
  //                             Colors.purple.withOpacity(0.1),
  //                           ],
  //                         ),
  //                         borderRadius: BorderRadius.only(
  //                           topLeft: Radius.circular(30),
  //                           topRight: Radius.circular(30),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //
  //                   // Close button
  //                   Positioned(
  //                     top: 15,
  //                     right: 15,
  //                     child: GestureDetector(
  //                       onTap: () => Navigator.of(context).pop(),
  //                       child: Container(
  //                         padding: EdgeInsets.all(8),
  //                         decoration: BoxDecoration(
  //                           color: Colors.black.withOpacity(0.1),
  //                           shape: BoxShape.circle,
  //                         ),
  //                         child: Icon(
  //                           Icons.close,
  //                           color: Colors.black54,
  //                           size: 20,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //
  //                   // Content
  //                   Padding(
  //                     padding: EdgeInsets.all(25),
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         SizedBox(height: 10),
  //
  //                         // Greeting text
  //                         Text(
  //                           getGreeting(),
  //                           style: TextStyle(
  //                             fontSize: 32,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black87,
  //                             letterSpacing: 0.5,
  //                           ),
  //                         ),
  //                         SizedBox(height: 8),
  //
  //                         Text(
  //                           userName,
  //                           style: TextStyle(
  //                             fontSize: 20,
  //                             fontWeight: FontWeight.w600,
  //                             color: Colors.blue.shade700,
  //                           ),
  //                         ),
  //
  //                         SizedBox(height: 15),
  //
  //                         // Divider with icon
  //                         Row(
  //                           children: [
  //                             Container(
  //                               padding: EdgeInsets.all(8),
  //                               decoration: BoxDecoration(
  //                                 color: Colors.blue.withOpacity(0.1),
  //                                 borderRadius: BorderRadius.circular(10),
  //                               ),
  //                               child: Icon(
  //                                 Icons.history,
  //                                 color: Colors.blue.shade700,
  //                                 size: 20,
  //                               ),
  //                             ),
  //                             SizedBox(width: 12),
  //                             Text(
  //                               'Yesterday\'s Activity',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: Colors.black87,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //
  //                         SizedBox(height: 20),
  //
  //                         // Activity list
  //                         Container(
  //                           constraints: BoxConstraints(
  //                             maxHeight: MediaQuery.of(context).size.height * 0.5,
  //                           ),
  //                           child: SingleChildScrollView(
  //                             child: Column(
  //                               children: activities.map((activity) {
  //                                 return _buildActivityItem(activity);
  //                               }).toList(),
  //                             ),
  //                           ),
  //                         ),
  //
  //                         SizedBox(height: 20),
  //
  //                         // Bottom motivational text
  //                         Container(
  //                           padding: EdgeInsets.all(15),
  //                           decoration: BoxDecoration(
  //                             gradient: LinearGradient(
  //                               colors: [
  //                                 Colors.blue.withOpacity(0.1),
  //                                 Colors.purple.withOpacity(0.1),
  //                               ],
  //                             ),
  //                             borderRadius: BorderRadius.circular(15),
  //                           ),
  //                           child: Row(
  //                             children: [
  //                               Icon(
  //                                 Icons.emoji_events,
  //                                 color: Colors.amber.shade700,
  //                                 size: 24,
  //                               ),
  //                               SizedBox(width: 10),
  //                               Expanded(
  //                                 child: Text(
  //                                   'Keep up the great work! 🚀',
  //                                   style: TextStyle(
  //                                     fontSize: 14,
  //                                     fontWeight: FontWeight.w500,
  //                                     color: Colors.black87,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  //
  //   // Activity item widget
  //   static Widget _buildActivityItem(ActivityItem activity) {
  //     return Container(
  //       margin: EdgeInsets.only(bottom: 12),
  //       padding: EdgeInsets.all(15),
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.7),
  //         borderRadius: BorderRadius.circular(15),
  //         border: Border.all(
  //           color: activity.color.withOpacity(0.3),
  //           width: 1.5,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: activity.color.withOpacity(0.1),
  //             blurRadius: 8,
  //             offset: Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         children: [
  //           // Icon container
  //           Container(
  //             padding: EdgeInsets.all(10),
  //             decoration: BoxDecoration(
  //               color: activity.color.withOpacity(0.15),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Icon(
  //               activity.icon,
  //               color: activity.color,
  //               size: 24,
  //             ),
  //           ),
  //           SizedBox(width: 15),
  //
  //           // Text content
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   activity.title,
  //                   style: TextStyle(
  //                     fontSize: 15,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.black87,
  //                   ),
  //                 ),
  //                 SizedBox(height: 4),
  //                 Text(
  //                   activity.description,
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     color: Colors.black54,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           // Count badge
  //           if (activity.count != null)
  //             Container(
  //               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //               decoration: BoxDecoration(
  //                 color: activity.color,
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //               child: Text(
  //                 '${activity.count}',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     );
  //   }
  // }
  //
  // // Activity model class
  // class ActivityItem {
  //   final IconData icon;
  //   final String title;
  //   final String description;
  //   final Color color;
  //   final int? count;
  //
  //   ActivityItem({
  //     required this.icon,
  //     required this.title,
  //     required this.description,
  //     required this.color,
  //     this.count,
  //   });
  // }
  //
  //
  //
  // // Example usage and how to call it:
  // /*
  //
  //   // Call this function from your HomePage's initState or any button
  //
  //   void _showWelcomeDialog() {
  //     GreetingDialogHelper.showGreetingDialog(
  //       context,
  //       userName: 'Rajesh Kumar',
  //       activities: [
  //         ActivityItem(
  //           icon: Icons.photo_library,
  //           title: 'Photos Viewed',
  //           description: 'You explored 15 photos',
  //           color: Colors.pink,
  //           count: 15,
  //         ),
  //         ActivityItem(
  //           icon: Icons.video_library,
  //           title: 'Videos Watched',
  //           description: 'Watched 8 interesting videos',
  //           color: Colors.red,
  //           count: 8,
  //         ),
  //         ActivityItem(
  //           icon: Icons.chat_bubble,
  //           title: 'Messages Sent',
  //           description: 'Chatted with 5 friends',
  //           color: Colors.blue,
  //           count: 5,
  //         ),
  //         ActivityItem(
  //           icon: Icons.favorite,
  //           title: 'Posts Liked',
  //           description: 'You loved 23 posts',
  //           color: Colors.pinkAccent,
  //           count: 23,
  //         ),
  //         ActivityItem(
  //           icon: Icons.person_add,
  //           title: 'New Followers',
  //           description: '3 people started following you',
  //           color: Colors.green,
  //           count: 3,
  //         ),
  //         ActivityItem(
  //           icon: Icons.location_on,
  //           title: 'Places Visited',
  //           description: 'Checked in at 2 locations',
  //           color: Colors.orange,
  //           count: 2,
  //         ),
  //       ],
  //     );
  //   }
  //
  //   // Call from initState in HomePage:
  //   @override
  //   void initState() {
  //     super.initState();
  //
  //     // Show dialog after 1 second of opening the page
  //     Future.delayed(Duration(seconds: 1), () {
  //       _showWelcomeDialog();
  //     });
  //   }
  //
  //   // Or call from a button:
  //   ElevatedButton(
  //     onPressed: _showWelcomeDialog,
  //     child: Text('Show Greeting'),
  //   )
  //
  // */