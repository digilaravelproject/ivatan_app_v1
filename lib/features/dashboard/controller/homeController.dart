import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import '../../subscription/data/model/profile_config_model.dart';

import '../../../core/helper/custom_snack_bar.dart';
import 'package:video_compress/video_compress.dart';
import '../../../core/network/api_services.dart';
import '../../../route/app_pages.dart';
import '../../auth/data/model/res/user_model.dart';
import '../../search/controller/mixed_feed_controller.dart';
import '../model/post_model.dart';
import '../model/story_model.dart';
import '../persentation/greetingDialog.dart';
import 'follow_controller.dart';
import '../../reels_screen/controller/short_play_controller.dart';
import '../../videos/controller/video_controller.dart';
import '../../profile/controller/ownpostController.dart';
import 'settings_controller.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/widgets/custom_dialog.dart';
import 'package:i_vatan_app/features/Notification/controller/notification_controller.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  RxBool isLoading = false.obs;
  RxList<PostItem> posts = <PostItem>[].obs;
  RxBool isStoryLoading = false.obs;

  RxList<UserStoryGroup> storyData = <UserStoryGroup>[].obs;
  final FollowController followController = Get.put(FollowController());

  final TextEditingController reasonController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  RxBool isSubmitting = false.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  RxBool showStories = false.obs;
  var currentUser = Rxn<UserModel>();

  final ApiServices api = Get.put(ApiServices());
  RxBool isMoreDataAvailable = true.obs;

  int currentPage = 1;
  int lastPage = 1;

  // Background Upload Progress
  RxBool isUploading = false.obs;
  RxBool isCompressing = false.obs;
  RxDouble uploadProgress = 0.0.obs;
  RxnString lastUploadType = RxnString();

  // Trim settings for Reels
  RxDouble trimStartTime = 0.0.obs; // In milliseconds
  RxDouble trimDuration = 0.0.obs;  // In milliseconds

  RxInt unreadNotificationCount = 0.obs;
  Rxn<ProfileConfigModel> profileConfig = Rxn<ProfileConfigModel>();

  void loadCachedProfileConfig() {
    final cached = SharedPrefManager().profileConfig;
    if (cached != null) {
      try {
        profileConfig.value = ProfileConfigModel.fromJson(cached);
      } catch (e) {
        print("Error loading cached profile config: $e");
      }
    }
  }

  Future<void> fetchProfileConfig() async {
    try {
      final response = await api.callGet(AppUrls.profileConfig);
      print("Profile Config API Response: $response");
      if (response != null && response['status'] == true) {
        final configModel = ProfileConfigModel.fromJson(response);
        profileConfig.value = configModel;
        await SharedPrefManager().saveProfileConfig(response);
      }
    } catch (e) {
      print("Error fetching profile config in HomeController: $e");
    }
  }

  Future<void> fetchUnreadNotificationCount() async {
    try {
      final response = await api.callGet(AppUrls.unreadCount);
      if (response != null && response['success'] == true) {
        unreadNotificationCount.value = response['unread'] as int? ?? 0;
      }
    } catch (e) {
      print("Error fetching unread count in HomeController: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadCurrentUser();
    loadCachedProfileConfig();
    fetchPosts();
    fetchStories();
    fetchUnreadNotificationCount();
    fetchProfileConfig();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchProfileConfig();
    }
  }



  void showWelcomeDialog(BuildContext context) async{
    GreetingDialogHelper.showGreetingDialogIfNeeded(
      context,
      userName: currentUser.value?.name ?? 'User',
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



  void loadCurrentUser() {
    final userData = SharedPrefManager().user;
    if (userData is UserModel) {
      currentUser.value = userData;
    } else {
      currentUser.value = null;
    }
  }

  void refreshUser() {
    loadCurrentUser();
  }

  void openDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  void closeDrawer() {
    Get.back();
  }

  String? nextPageUrl;

  Future<void> fetchPosts({bool loadMore = false}) async {
    if (isLoading.value) return;

    if (!loadMore) {
      posts.clear();
      nextPageUrl = "${AppUrls.feedPostImages}?page=1";
      isMoreDataAvailable.value = true;
    } else {
      if (!isMoreDataAvailable.value || nextPageUrl == null) return;
    }

    try {
      isLoading.value = true;

      final response = await api.callGet(nextPageUrl!);

      print("POST API Response: $response");

      if (response == null || response["data"] == null) {
        isMoreDataAvailable.value = false;
        return;
      }

      // Add new posts
      List<PostItem> fetchedPosts =
          (response["data"] as List)
              .where((e) => e is Map)
              .map((e) => PostItem.fromJson(e))
              .toList();

      // ✅ Sync follow status with FollowController map
      for (var post in fetchedPosts) {
        followController.setInitialFollowStatus(post.user.id, post.is_following);
      }

      posts.addAll(fetchedPosts);
      posts.refresh();

      // Pagination handling using links.next
      String? nextLink = response["links"]?["next"];

      if (nextLink == null) {
        isMoreDataAvailable.value = false;
        nextPageUrl = null;
      } else {
        nextPageUrl = nextLink.replaceFirst("https://www.ivatan.in/", "");
      }
    } catch (e) {
      print("ERROR in fetchPosts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadMediaInBackground(String endpoint, Map<String, dynamic> body) async {
    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;
      isCompressing.value = false;
      lastUploadType.value = body['type']?.toString();

      // Check for video and compress if needed
      File? videoToCompress;
      String? videoKey;
      int? videoIndexInList;

      body.forEach((key, value) {
        if (value is File) {
          final pathLower = value.path.toLowerCase();
          if (pathLower.endsWith(".mp4") ||
              pathLower.endsWith(".mov") ||
              pathLower.endsWith(".m4v") ||
              pathLower.endsWith(".3gp") ||
              pathLower.endsWith(".mkv") ||
              pathLower.endsWith(".avi")) {
            videoToCompress = value;
            videoKey = key;
          }
        } else if (value is List) {
          for (int i = 0; i < value.length; i++) {
            final item = value[i];
            if (item is File) {
              final pathLower = item.path.toLowerCase();
              if (pathLower.endsWith(".mp4") ||
                  pathLower.endsWith(".mov") ||
                  pathLower.endsWith(".m4v") ||
                  pathLower.endsWith(".3gp") ||
                  pathLower.endsWith(".mkv") ||
                  pathLower.endsWith(".avi")) {
                videoToCompress = item;
                videoKey = key;
                videoIndexInList = i;
                break;
              }
            }
          }
        }
      });

      if (videoToCompress != null) {
        isCompressing.value = true;
        print("STARTING BACKGROUND COMPRESSION: ${videoToCompress!.path}");
        
        bool shouldTrim = trimDuration.value > 0;
        
        final info = await VideoCompress.compressVideo(
          videoToCompress!.path,
          quality: VideoQuality.MediumQuality, // Reduced from HighestQuality for faster upload
          deleteOrigin: false,
          startTime: shouldTrim ? (trimStartTime.value / 1000).toInt() : null,
          duration: shouldTrim ? (trimDuration.value / 1000).toInt() : null,
        );

        if (info != null && info.path != null) {
          final compressedFile = File(info.path!);
          if (videoIndexInList != null) {
            (body[videoKey!] as List)[videoIndexInList!] = compressedFile;
          } else {
            body[videoKey!] = compressedFile;
          }
          print("BACKGROUND COMPRESSION COMPLETE: ${info.path}");
        }
        isCompressing.value = false;
      }

      final response = await api.callPostWithProgress(
        endpoint,
        data: body,
        onSendProgress: (sent, total) {
          if (total > 0) {
            uploadProgress.value = sent / total;
          }
        },
      );

      if (response != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        CustomSnackBar.showSuccess(message: response.data["message"] ?? "Upload successful!");
        fetchPosts(); // Refresh home feed
        
        // Refresh Discover videos list if VideoController is registered
        if (Get.isRegistered<VideoController>()) {
          Get.find<VideoController>().fetchVideo();
        }
        
        // Refresh reels/clips list if ShortPlayController is registered
        if (Get.isRegistered<ShortPlayController>()) {
          Get.find<ShortPlayController>().fetchReels();
        }
        
        // Refresh user's own profile post/video tabs if registered
        final currentUsername = SharedPrefManager().user?.username;
        if (currentUsername != null && currentUsername.isNotEmpty) {
          final List<String> filters = ["posts", "videos"];
          for (var filter in filters) {
            final tag = "${currentUsername}_$filter";
            if (Get.isRegistered<OwnPostController>(tag: tag)) {
              Get.find<OwnPostController>(tag: tag).fetchOwnPosts(
                username: currentUsername,
                filterType: filter,
              );
            }
          }
          if (Get.isRegistered<OwnPostController>(tag: currentUsername)) {
            Get.find<OwnPostController>(tag: currentUsername).fetchOwnPosts(
              username: currentUsername,
              filterType: "posts",
            );
          }
        }
      } else {
        CustomSnackBar.showError(message: "Upload failed. Please try again.");
      }
    } catch (e) {
      print("BACKGROUND UPLOAD ERROR: $e");
      CustomSnackBar.showError(message: "An error occurred during upload.");
    } finally {
      trimStartTime.value = 0.0;
      trimDuration.value = 0.0;
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }
  Future<void> fetchStories() async {
    isStoryLoading.value = true;

    final response = await api.callGet(AppUrls.storyFeed);
    print("storydata : " + response.toString());

    if (response != null &&
        response["data"] != null &&
        response["data"] is List) {
      storyData.value =
          response["data"]
              .map<UserStoryGroup>((e) => UserStoryGroup.fromJson(e))
              .toList();
    } else {
      storyData.clear();
    }

    isStoryLoading.value = false;
  }

  void removeStory(int storyId) {
    for (var group in storyData) {
      group.stories.removeWhere((s) => s.id == storyId);
    }
    storyData.removeWhere((group) => group.stories.isEmpty);
    storyData.refresh();
  }

  Future<void> likePost(int postId, int index) async {
    try {
      final response = await api.callPost(
        AppUrls.likePost(postId),
        data: {},
      );

      print("likeResponse : $response");

      if (response != null &&
          response["data"] != null &&
          response["data"]["is_liked"] != null &&
          response["data"]["likes_count"] != null) {
        bool newLikeStatus = response["data"]["is_liked"];
        int newCount = response["data"]["likes_count"];

        posts[index].stats.isLiked = newLikeStatus;
        posts[index].stats.likeCount = newCount;

        posts.refresh();
      }
    } catch (e) {
      print("Like Error: $e");
    }
  }

  Future<void> toggleFollowForPostUser(int userId) async {
    try {
      await followController.toggleFollow(userId);
      
      // 1️⃣ Sync with current Home feed posts
      for (var post in posts) {
        if (post.user.id == userId) {
          post.is_following = followController.isUserFollowing(userId).value;
        }
      }
      posts.refresh();

      // 2️⃣ Sync with SettingsController (Profile screen)
      // Check if SettingsController with this user's tag is registered
      // Usually the user's username is the tag. In HomeController we might not 
      // have the username easily for all tags, so we can iterate or check active ones.
      // But typically, only ONE profile is open at a time.
      if (Get.isRegistered<SettingsController>()) {
         // Generic check (might need logic for tagged ones if multiple exist)
         // For now, if any SettingsController exists and matches the ID, refresh it.
         final settings = Get.find<SettingsController>();
         if (settings.userProfile.value?.id == userId) {
           await settings.fetchUserDetails(settings.userProfile.value?.username ?? "");
         }
      }

      // 3️⃣ Sync with PostController (Search/Trending Feed)
      if (Get.isRegistered<PostController>()) {
        final postController = Get.find<PostController>();
        
        // Sync trending posts
        for (var post in postController.posts) {
          if (post.user.id == userId) {
            post.isFollowing = followController.isUserFollowing(userId).value;
          }
        }
        postController.posts.refresh();

        // Sync interested posts
        for (var post in postController.intrestedPostList) {
          if (post.user.id == userId) {
            post.isFollowing = followController.isUserFollowing(userId).value;
          }
        }
        postController.intrestedPostList.refresh();
      }

      // 4️⃣ Sync with ShortPlayController (Reels)
      if (Get.isRegistered<ShortPlayController>()) {
        final shortPlayController = Get.find<ShortPlayController>();
        for (var reel in shortPlayController.reelsList) {
          if (reel.user.id == userId) {
            // we don't have a direct is_following reactive field in ReelModel 
            // but the UI uses FollowController.isUserFollowing map which IS reactive.
            // Still, refreshing the list can help if anything else depends on it.
          }
        }
        shortPlayController.reelsList.refresh();
      }
      
    } catch (e) {
      print("Follow Error: $e");
    }
  }

  void updateCommentCount(int postId, bool increase) {
    int index = posts.indexWhere((p) => p.id == postId);

    if (index != -1) {
      if (increase) {
        posts[index].stats.commentCount++;
      } else {
        if (posts[index].stats.commentCount > 0) {
          posts[index].stats.commentCount--;
        }
      }

      posts.refresh(); // UI update
    }
  }

  Future<void> logout() async {
    try {
      await Get.find<NotificationController>().deleteTokenOnLogout();
    } catch (e) {
      print("Error deleting token on logout: $e");
    }

    try {
      // API call pehle
      final response = await api.callDelete(AppUrls.logout);
      print("logout response : $response");
      final msg = response?["message"] ?? "Logout successful";
      CustomSnackBar.showSuccess(message: msg);
    } catch (e) {
      print("Logout API error (ignored): $e");
      CustomSnackBar.showSuccess(message: "Logged out successfully");
    } finally {
      // API success ho ya fail — local data hamesha clear hoga
      SharedPrefManager().userLogOut();

      // Navigate to login
      Future.delayed(const Duration(milliseconds: 200), () {
        Get.offAllNamed(AppRoutes.login);
      });
    }
  }

  Future<void> likeStory(int storyId) async {
    try {
      final response = await api.callPost(
        AppUrls.likeStory(storyId),
        data: {},
      );

      print("likeResponse : $response");

      if (response != null && response["success"] == true) {
        int newCount = response["like_count"] ?? 0;

        // Find the story by ID in all groups
        bool updated = false;
        for (var group in storyData) {
          for (var story in group.stories) {
            if (story.id == storyId) {
              story.isLiked = !story.isLiked; // toggle like
              // story.likesCount = newCount;    // update count
              updated = true;
              break;
            }
          }
          if (updated) break;
        }

        storyData.refresh();
      }
    } catch (e) {
      print("Like Error: $e");
    }
  }

  Future<void> blockUser(int userId) async {
    CustomDialog.showConfirmation(
      title: "Block User",
      message: "Are you sure you want to block this user? They will no longer see your content or interact with you.",
      confirmText: "Block",
      confirmColor: Colors.redAccent,
      icon: Icons.block,
      onConfirm: () async {
        try {
          final response = await api.callPost(AppUrls.blockUser(userId), data: {});
          if (response != null && response["success"] == true) {
            // Remove all posts from this user from the feed
            posts.removeWhere((p) => p.user.id == userId);
            posts.refresh();
            CustomSnackBar.showSuccess(message: response["message"] ?? "User blocked successfully.");
          }
        } catch (e) {
          print("Block User Error: $e");
        }
      },
    );
  }

  Future<void> markInterested(int postId) async {
    CustomDialog.showConfirmation(
      title: "Interested?",
      message: "Would you like to see more content similar to this post?",
      confirmText: "Yes",
      icon: Icons.star_border_rounded,
      onConfirm: () async {
        try {
          final response = await api.callPost(AppUrls.markInterested(postId), data: {});
          if (response != null && response["success"] == true) {
            CustomSnackBar.showSuccess(message: response["message"] ?? "Post marked as interested.");
          }
        } catch (e) {
          print("Interested Error: $e");
        }
      },
    );
  }

  Future<void> markNotInterested(int postId) async {
    CustomDialog.showConfirmation(
      title: "Not Interested?",
      message: "Are you sure you want to hide this post? We will show you less content like this.",
      confirmText: "Hide",
      confirmColor: Colors.redAccent,
      icon: Icons.visibility_off_outlined,
      onConfirm: () async {
        try {
          final response = await api.callPost(AppUrls.markNotInterested(postId), data: {});
          if (response != null && response["success"] == true) {
            // Remove the specific post from the feed
            posts.removeWhere((p) => p.id == postId);
            posts.refresh();
            CustomSnackBar.showSuccess(message: response["message"] ?? "Post marked as not interested.");
          }
        } catch (e) {
          print("Not Interested Error: $e");
        }
      },
    );
  }

  void openReportBottomSheet({required int postId}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.report_gmailerrorred_rounded, color: Colors.redAccent, size: 28),
                const SizedBox(width: 10),
                const Text(
                  "Report Post",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Your report is anonymous. If someone is in immediate danger, call the local emergency services. Don't wait.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            /// Reason
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: "Why are you reporting this post?",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Description
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Provide additional details (optional)",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.redAccent.withOpacity(0.6),
                  ),
                  onPressed:
                      isSubmitting.value ? null : () => submitReport(postId),
                  child:
                      isSubmitting.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "Submit Report",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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

  Future<void> submitReport(int postId) async {
    if (reasonController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please provide a reason for the report.");
      return;
    }

    try {
      isSubmitting.value = true;

      final body = {
        "reason": reasonController.text.trim(),
        "description": descriptionController.text.trim(),
      };

      final response = await api.callPost(
        AppUrls.reportPost(postId),
        data: body,
      );

      if (response != null && response["success"] == true) {
        Get.back(); // close bottom sheet

        Get.snackbar("Report Submitted", "Thank you for letting us know.");

        reasonController.clear();
        descriptionController.clear();
      } else {
        Get.snackbar("Error", "Failed to report post. Please try again later.");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong.");
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> toggleBookmark(int postId) async {
    try {
      final response = await api.callPost(AppUrls.bookmarkPost(postId), data: {});
      
      if (response != null && response["success"] == true) {
        int index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          // Toggle the local state based on API response
          posts[index].stats.isSaved = response["is_bookmarked"] ?? !posts[index].stats.isSaved;
          posts.refresh(); // Reactive UI update
        }
        
        CustomSnackBar.showSuccess(
          message: response["message"] ?? (response["is_bookmarked"] == true ? "Post bookmarked" : "Bookmark removed")
        );
      }
    } catch (e) {
      print("Bookmark Error: $e");
    }
  }
}
