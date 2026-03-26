import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';

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
import 'settings_controller.dart';

class HomeController extends GetxController {
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

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
    fetchPosts();
    fetchStories();

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
      nextPageUrl = "api/v1/posts/feed/images?page=1";
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

      body.forEach((key, value) {
        if (value is File && (value.path.endsWith(".mp4") || value.path.endsWith(".mov") || value.path.endsWith(".m4v"))) {
          videoToCompress = value;
          videoKey = key;
        }
      });

      if (videoToCompress != null) {
        isCompressing.value = true;
        print("STARTING BACKGROUND COMPRESSION: ${videoToCompress!.path}");
        
        bool shouldTrim = trimDuration.value > 0;
        
        final info = await VideoCompress.compressVideo(
          videoToCompress!.path,
          quality: VideoQuality.HighestQuality,
          deleteOrigin: false,
          startTime: shouldTrim ? (trimStartTime.value / 1000).toInt() : null,
          duration: shouldTrim ? (trimDuration.value / 1000).toInt() : null,
        );

        if (info != null && info.path != null) {
          body[videoKey!] = File(info.path!);
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

    final response = await api.callGet("api/v1/stories/feed");
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
        "api/v1/posts/$postId/like",
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
    final response = await api.callDelete("api/v1/auth/logout");
    print("logout response : $response");

    if (response == null) return;

    final msg = response["message"] ?? "Logout successful";
    SharedPrefManager().userLogOut();
    CustomSnackBar.showSuccess(message: msg);

    // Login page par navigate
    Future.delayed(const Duration(milliseconds: 200), () {
      Get.offAllNamed(AppRoutes.login);
    });
  }

  Future<void> likeStory(int storyId) async {
    try {
      final response = await api.callPost(
        "api/v1/stories/$storyId/like",
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

  void openReportBottomSheet({required int postId}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Report",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// Reason
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: "Report Reason",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// Description
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            /// Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isSubmitting.value ? null : () => submitReport(postId),
                  child:
                      isSubmitting.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Report"),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> submitReport(int postId) async {
    if (reasonController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }

    try {
      isSubmitting.value = true;

      final body = {
        "reason": reasonController.text.trim(),
        "description": descriptionController.text.trim(),
      };

      final response = await api.callPost(
        "/api/v1/posts/$postId/report",
        data: body,
      );

      if (response != null && response["success"] == true) {
        Get.back(); // close bottom sheet

        Get.snackbar("Success", response["message"] ?? "Report submitted");

        reasonController.clear();
        descriptionController.clear();
      } else {
        Get.snackbar("Error", "Failed to report post");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isSubmitting.value = false;
    }
  }

  /*
  Future<void> likeStory(int storyId, int index) async {
    try {
      final response = await api.callPost(
        "api/v1/stories/$storyId/like",
        data: {},
      );

   //   print(object)

      print("likeResponse : $response");

      if (response != null && response["success"] == true) {

        int newCount = response["like_count"] ?? 0;

        // old value
        bool oldLikeStatus = storyData[0].stories[0].isLiked;

        // toggle
        bool newLikeStatus = !oldLikeStatus;

        // update
        storyData[0].stories[index].isLiked = newLikeStatus;
       // storyData[0].stories[storyIndex].likesCount = newCount;

        // refresh list
        storyData.refresh();
      }

    } catch (e) {
      print("Like Error: $e");
    }
  }
*/
}
