import 'dart:ui';
import 'package:flutter/material.dart';

/*class GreetingDialogHelper {
  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '🌅 Good Morning';
    } else if (hour < 17) {
      return '☀️ Good Afternoon';
    } else {
      return '🌙 Good Evening';
    }
  }

  // Main function to show the dialog
  static void showGreetingDialog(BuildContext context, {
    required String userName,
    required List<ActivityItem> activities,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        // Auto dismiss after 5 seconds
        Future.delayed(Duration(seconds: 5000), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
        );

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Gradient overlay for top section
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.withOpacity(0.1),
                            Colors.purple.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),

                        // Greeting text
                        Text(
                          getGreeting(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),

                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),

                        SizedBox(height: 12),

                        // Divider with icon
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.history,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Yesterday\'s Activity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Activity list
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: activities.map((activity) {
                                return _buildActivityItem(activity);
                              }).toList(),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Bottom motivational text
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.1),
                                Colors.purple.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber.shade700,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Keep up the great work! 🚀',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Activity item widget
  static Widget _buildActivityItem(ActivityItem activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: activity.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activity.color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 24,
            ),
          ),
          SizedBox(width: 15),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Count badge
          if (activity.count != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: activity.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${activity.count}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
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
}*/


import 'package:shared_preferences/shared_preferences.dart';

class GreetingDialogHelper {
  // SharedPreferences key for storing last shown date
  static const String _lastShownDateKey = 'greeting_dialog_last_shown_date';

  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '🌅 Good Morning';
    } else if (hour < 17) {
      return '☀️ Good Afternoon';
    } else {
      return '🌙 Good Evening';
    }
  }

  // Check if dialog should be shown today
  static Future<bool> shouldShowDialogToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShownDate = prefs.getString(_lastShownDateKey);
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';

    // If no date stored or different date, show dialog
    if (lastShownDate == null || lastShownDate != todayString) {
      return true;
    }
    return false;
  }

  // Save today's date after showing dialog
  static Future<void> _saveShownDate() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    await prefs.setString(_lastShownDateKey, todayString);
  }

  // Main function to show the dialog with date check
  static Future<void> showGreetingDialogIfNeeded(BuildContext context, {
    required String userName,
    required List<ActivityItem> activities,
  }) async {
    // Check if dialog should be shown today
    final shouldShow = await shouldShowDialogToday();

    if (!shouldShow) {
      print('Dialog already shown today. Skipping...');
      return;
    }

    // Show dialog and save date
    await _showDialog(context, userName: userName, activities: activities);
    await _saveShownDate();
  }

  // Internal dialog display function
  static Future<void> _showDialog(BuildContext context, {
    required String userName,
    required List<ActivityItem> activities,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        // Auto dismiss after 5 seconds
        Future.delayed(Duration(seconds: 500), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Gradient overlay for top section
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.withOpacity(0.1),
                            Colors.purple.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),

                        // Greeting text
                        Text(
                          getGreeting(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),

                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),

                        SizedBox(height: 15),

                        // Divider with icon
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.history,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Yesterday\'s Activity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Activity list
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.5,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: activities.map((activity) {
                                return _buildActivityItem(activity);
                              }).toList(),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Bottom motivational text
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.1),
                                Colors.purple.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber.shade700,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Keep up the great work! 🚀',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Activity item widget
  static Widget _buildActivityItem(ActivityItem activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: activity.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activity.color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 24,
            ),
          ),
          SizedBox(width: 15),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Count badge
          if (activity.count != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: activity.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${activity.count}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
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



// Example usage and how to call it:
/*

  // Call this function from your HomePage's initState or any button

  void _showWelcomeDialog() {
    GreetingDialogHelper.showGreetingDialog(
      context,
      userName: 'Rajesh Kumar',
      activities: [
        ActivityItem(
          icon: Icons.photo_library,
          title: 'Photos Viewed',
          description: 'You explored 15 photos',
          color: Colors.pink,
          count: 15,
        ),
        ActivityItem(
          icon: Icons.video_library,
          title: 'Videos Watched',
          description: 'Watched 8 interesting videos',
          color: Colors.red,
          count: 8,
        ),
        ActivityItem(
          icon: Icons.chat_bubble,
          title: 'Messages Sent',
          description: 'Chatted with 5 friends',
          color: Colors.blue,
          count: 5,
        ),
        ActivityItem(
          icon: Icons.favorite,
          title: 'Posts Liked',
          description: 'You loved 23 posts',
          color: Colors.pinkAccent,
          count: 23,
        ),
        ActivityItem(
          icon: Icons.person_add,
          title: 'New Followers',
          description: '3 people started following you',
          color: Colors.green,
          count: 3,
        ),
        ActivityItem(
          icon: Icons.location_on,
          title: 'Places Visited',
          description: 'Checked in at 2 locations',
          color: Colors.orange,
          count: 2,
        ),
      ],
    );
  }

  // Call from initState in HomePage:
  @override
  void initState() {
    super.initState();

    // Show dialog after 1 second of opening the page
    Future.delayed(Duration(seconds: 1), () {
      _showWelcomeDialog();
    });
  }

  // Or call from a button:
  ElevatedButton(
    onPressed: _showWelcomeDialog,
    child: Text('Show Greeting'),
  )

*/