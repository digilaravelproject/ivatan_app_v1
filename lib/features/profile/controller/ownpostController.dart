import 'package:get/get.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';

import '../../../core/network/api_services.dart';
import '../../dashboard/controller/follow_controller.dart';
import '../../dashboard/controller/homeController.dart';
import '../../dashboard/model/post_model.dart';
import 'package:i_vatan_app/features/dashboard/controller/homeController.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../../core/helper/custom_snack_bar.dart';
import 'package:flutter/material.dart';

class OwnPostController extends GetxController {

  final String filterType;
  final String UserName;

  OwnPostController({required this.filterType,required this.UserName});

  RxBool isLoading = false.obs;
  RxList<PostItem> posts = <PostItem>[].obs;
  RxBool isStoryLoading = false.obs;


  final ApiServices api = Get.put(ApiServices());

  RxBool isMoreDataAvailable = true.obs; // next page available?

  int currentPage = 1;
  int lastPage = 1;

  @override
  void onInit() {
    fetchOwnPosts(filterType: filterType, username : UserName);
    super.onInit();
  }


/*
  Future<void> fetchOwnPosts({bool loadMore = false, String? filterType, String? username}) async {
    if (isLoading.value) return;

    if (!loadMore) {
      currentPage = 1;
      posts.clear();
      isMoreDataAvailable.value = true;
    } else {
      if (!isMoreDataAvailable.value) return;
      currentPage++;
    }

    try {
      isLoading.value = true;

      final response = await api.callGet(
          "api/v1/posts/user/$username?filter=$filterType&page=$currentPage");

      print("POST API Response: $response");

      if (response == null || response["data"] == null) {
        isMoreDataAvailable.value = false;
        return;
      }

      lastPage = response["meta"]?["last_page"] ?? currentPage;

      if (response["data"] is List) {
        List<PostItem> fetchedPosts = (response["data"] as List)
            .where((e) => e is Map)
            .map((e) => PostItem.fromJson(e))
            .toList();

        posts.addAll(fetchedPosts);
      }

      if (currentPage >= lastPage) {
        isMoreDataAvailable.value = false;
      }
    } catch (e) {
      print("ERROR in fetchPosts: $e");
    } finally {
      isLoading.value = false;
    }
  }
*/

  Future<void> fetchOwnPosts({bool loadMore = false, String? filterType, String? username}) async {
    if (isLoading.value) return;

    // Use passed values or fallback to class variables
    final String targetUser = username ?? UserName;
    final String targetFilter = filterType ?? this.filterType;

    if (!loadMore) {
      currentPage = 1;
      posts.clear();
      isMoreDataAvailable.value = true;
    } else {
      if (!isMoreDataAvailable.value) return;
      currentPage++;
    }

    try {
      isLoading.value = true;

      final response = await api.callGet(
          "api/v1/posts/user/$targetUser?filter=$targetFilter&page=$currentPage"
      );

      print("POST API Response: $response");

      if (response == null || response["data"] == null) {
        isMoreDataAvailable.value = false;
        return;
      }

      // fetched posts
      if (response["data"] is List) {
        List<PostItem> fetchedPosts = (response["data"] as List)
            .where((e) => e is Map)
            .map((e) => PostItem.fromJson(e))
            .toList();

        posts.addAll(fetchedPosts);
      }

      // check if next page exists from links.next
      if (response["links"] != null && response["links"]["next"] != null) {
        isMoreDataAvailable.value = true;
      } else {
        isMoreDataAvailable.value = false;
      }

    } catch (e) {
      print("ERROR in fetchPosts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Interaction Methods for FeedPostWidget
  
  // Getter for FollowController to support FeedPostWidget
  FollowController get followController => Get.find<HomeController>().followController;

  Future<void> likePost(int postId, int index) async {
    // 1. Optimistic Update
    final post = posts[index];
    final bool currentLiked = post.stats.isLiked ?? false;
    final int currentCount = post.stats.likeCount ?? 0;

    post.stats.isLiked = !currentLiked;
    post.stats.likeCount = currentLiked ? (currentCount - 1) : (currentCount + 1);
    posts.refresh(); // Trigger GetX update

    try {
      // 2. API Call
      await api.callPost("api/v1/posts/$postId/like", data: {});
    } catch (e) {
      // Revert if failed
      post.stats.isLiked = currentLiked;
      post.stats.likeCount = currentCount;
      posts.refresh();
      print("Error liking post: $e");
    }
  }

  Future<void> toggleFollowForPostUser(int userId) async {
    final HomeController homeController = Get.find<HomeController>();
    await homeController.toggleFollowForPostUser(userId);
    posts.refresh();
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
    final HomeController homeController = Get.find<HomeController>();
    homeController.openReportBottomSheet(postId: postId);
  }

  Future<void> toggleBookmark(int postId) async {
    try {
      final response = await api.callPost(AppUrls.bookmarkPost(postId), data: {});
      
      if (response != null && response["success"] == true) {
        int index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          bool isBookmarked = response["is_bookmarked"] ?? !posts[index].stats.isSaved;
          posts[index].stats.isSaved = isBookmarked;
          posts.refresh();
        }
        
        CustomSnackBar.showSuccess(
          message: response["message"] ?? (response["is_bookmarked"] == true ? "Post bookmarked" : "Bookmark removed")
        );

        // Sync with HomeController feed if it exists to maintain global state
        if (Get.isRegistered<HomeController>()) {
          final home = Get.find<HomeController>();
          int homeIndex = home.posts.indexWhere((p) => p.id == postId);
          if (homeIndex != -1) {
             home.posts[homeIndex].stats.isSaved = response["is_bookmarked"] ?? true;
             home.posts.refresh();
          }
        }
      }
    } catch (e) {
      print("Bookmark Error: $e");
    }
  }
}