import 'package:get/get.dart';

import '../../../../core/network/api_services.dart';
import '../../dashboard/controller/follow_controller.dart';
import '../../dashboard/model/post_model.dart';
import '../../search/model/mixed_feed_model.dart';
import '../../../../core/helper/custom_snack_bar.dart';
import '../../../../core/network/app_urls.dart';
import '../../dashboard/controller/homeController.dart';
import '../model/related_videoModel.dart';

class VideoController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<PostItem> posts = <PostItem>[].obs;
  RxList<PostItem> filteredList = <PostItem>[].obs; // Filtered List

  late final int videoId;
  VideoController({required this.videoId,});
  RxList<RelatedVideoModel> relatedVideoList =<RelatedVideoModel>[].obs;
  final ApiServices api = Get.put(ApiServices());
  final FollowController followController = Get.put(FollowController());

  RxBool isMoreDataAvailable = true.obs; // next page available?
  int currentPage = 1;
  int lastPage = 1;
  String? nextPageUrl;
  RxBool isMoreLoading = false.obs;

  Rx<PostItem?> currentVideo = Rx<PostItem?>(null);
  
  // Track selected filter
  RxString selectedFilter = 'none'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideo();
    fetchRelatedVideos(videoId);
  }

  Future<void> fetchVideo({bool loadMore = false}) async {
    if (loadMore) {
      if (isMoreLoading.value || !isMoreDataAvailable.value) return;
      isMoreLoading.value = true;
    } else {
      isLoading.value = true;
      currentPage = 1;
      isMoreDataAvailable.value = true;
    }

    try {
      final response = await api.callGet(
          "api/v1/posts/feed/videos?page=$currentPage");

      if (response != null && response["data"] != null) {
        final model = FeedResponse.fromJson(response);
        print("📹 API VIDEO COUNT: ${model.data.length}");

        if (loadMore) {
          posts.addAll(model.data);
          filteredList.addAll(model.data);
        } else {
          posts.value = model.data;
          filteredList.value = model.data;
          final int videoIndex = posts.indexWhere((video) => video.id == videoId);
          if (videoIndex != -1) {
            currentVideo.value = posts[videoIndex];
          } else {
            fetchSingleVideo();
          }
        }

        if (model.data.length < 10) {
          isMoreDataAvailable.value = false;
        } else {
          currentPage++;
        }
      }
    } catch (e) {
      print("Fetch Posts Error: $e");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> fetchSingleVideo() async {
    try {
      final response = await api.callGet("api/v1/posts/$videoId");
      if (response != null) {
        final map = response["data"] is Map<String, dynamic> ? response["data"] : response;
        final postItem = PostItem.fromJson(map);
        currentVideo.value = postItem;
      }
    } catch (e) {
      print("Fetch Single Video Error: $e");
    }
  }

  Future<void> fetchRelatedVideos(int videoId) async {
    try {
      isLoading.value = true;

      final response =
      await api.callGet("api/v1/posts/video/$videoId/related", showErrorToast: false);

      print("Related Videos Response: " + response.toString());

      if (response != null && response["data"] != null) {
        final model = VideoResponse.fromJson(response);
        relatedVideoList.value = model.data ?? [];
      }
    } catch (e) {
      print("Fetch Related Videos Error: $e");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> toggleFollowForPostUser(int userId) async {
    try {
      // Toggle follow through FollowController
      await followController.toggleFollow(userId);

      // ✅ Update ONLY posts where this user exists
      for (var post in posts) {
        if (post.user.id == userId) {
          post.is_following = followController.isUserFollowing(userId).value;
        }
      }

      // Refresh the posts list to update UI
      posts.refresh();
    } catch (e) {
      print("Follow Error: $e");
    }
  }

  void filterSearch(String query) {
    print("🔍 Search query: '$query'");
    print("📊 Total posts: ${posts.length}");
    
    if (query.isEmpty || query.trim().isEmpty) {
      filteredList.value = List.from(posts); // Create new list to trigger update
      print("✅ Showing all ${filteredList.length} videos");
    } else {
      final results = posts.where((post) {
        final searchQuery = query.toLowerCase();
        final userName = post.user.name.toLowerCase();
        final username = post.user.username.toLowerCase();
        final caption = (post.caption ?? '').toLowerCase();
        
        return userName.contains(searchQuery) ||
               username.contains(searchQuery) ||
               caption.contains(searchQuery);
      }).toList();
      
      filteredList.value = results;
      print("🔎 Found ${filteredList.length} matching videos");
    }
    
    filteredList.refresh(); // Force UI update
  }

  void sortByViews() {
    print("📊 Sorting by views");
    selectedFilter.value = 'views';
    filteredList.value = List.from(filteredList)
      ..sort((a, b) => b.stats.viewCount.compareTo(a.stats.viewCount));
    filteredList.refresh();
  }

  void sortByRecent() {
    print("🕐 Sorting by recent");
    selectedFilter.value = 'recent';
    filteredList.value = List.from(filteredList)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    filteredList.refresh();
  }

  void sortByLikes() {
    print("❤️ Sorting by likes");
    selectedFilter.value = 'likes';
    filteredList.value = List.from(filteredList)
      ..sort((a, b) => b.stats.likeCount.compareTo(a.stats.likeCount));
    filteredList.refresh();
  }

  void resetSort() {
    print("🔄 Resetting sort");
    selectedFilter.value = 'none';
    filteredList.value = List.from(posts);
    filteredList.refresh();
  }

  Future<void> likeVideo(int postId) async {
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

        if (currentVideo.value?.id == postId) {
          currentVideo.value!.stats.isLiked = newLikeStatus;
          currentVideo.value!.stats.likeCount = newCount;
          currentVideo.refresh();
        }

        // Also update in lists
        final index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          posts[index].stats.isLiked = newLikeStatus;
          posts[index].stats.likeCount = newCount;
          posts.refresh();
        }

        final filteredIndex = filteredList.indexWhere((p) => p.id == postId);
        if (filteredIndex != -1) {
          filteredList[filteredIndex].stats.isLiked = newLikeStatus;
          filteredList[filteredIndex].stats.likeCount = newCount;
          filteredList.refresh();
        }
      }
    } catch (e) {
      print("Like Error: $e");
    }
  }

  Future<void> toggleBookmark(int postId) async {
    try {
      final response = await api.callPost(AppUrls.bookmarkPost(postId), data: {});
      
      if (response != null && response["success"] == true) {
        bool isBookmarked = response["is_bookmarked"] ?? false;
        
        if (currentVideo.value?.id == postId) {
          currentVideo.value!.stats.isSaved = isBookmarked;
          currentVideo.refresh();
        }
        
        // Sync with HomeController feed if it exists to maintain global state
        if (Get.isRegistered<HomeController>()) {
          final home = Get.find<HomeController>();
          int index = home.posts.indexWhere((p) => p.id == postId);
          if (index != -1) {
             home.posts[index].stats.isSaved = isBookmarked;
             home.posts.refresh();
          }
        }

        CustomSnackBar.showSuccess(
          message: response["message"] ?? (isBookmarked ? "Video bookmarked" : "Bookmark removed")
        );
      }
    } catch (e) {
      print("Bookmark Error: $e");
    }
  }
}


/*  Future<void> fetchVideo({bool loadMore = false}) async {
    try {
      isLoading.value = true;
      if (!loadMore) {
        posts.clear();
        nextPageUrl = "api/v1/posts/feed/images?page=1";
        isMoreDataAvailable.value = true;
      } else {
        if (!isMoreDataAvailable.value || nextPageUrl == null) return;
      }

      final response = await api.callGet("api/v1/posts/feed/videos");

      print("cjbdkjchehiuncjw : "+response.toString());

      if (response == null || response["data"] == null) {
        isMoreDataAvailable.value = false;
        return;
      }

      if (response != null && response["data"] != null) {
        final model = FeedResponse.fromJson(response);
        posts.value = model.data ?? [];

        currentVideo.value = posts.firstWhere(
              (video) => video.id == videoId,
        //  orElse: () => null,
        ) as PostItem?;

        posts.refresh();

      }

      String? nextLink = response["links"]?["next"];

      if (nextLink == null) {
        isMoreDataAvailable.value = false;
        nextPageUrl = null;
      } else {
        nextPageUrl = nextLink.replaceFirst("https://www.ivatan.in/", "");
      }

    } catch (e) {
      print("Fetch Posts Error: $e");
    } finally {
      isLoading.value = false;
    }
  }*/