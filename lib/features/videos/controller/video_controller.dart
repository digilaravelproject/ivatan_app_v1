import 'package:get/get.dart';

import '../../../../core/network/api_services.dart';
import '../../dashboard/controller/follow_controller.dart';
import '../../dashboard/model/post_model.dart';
import '../../search/model/mixed_feed_model.dart';
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

  @override
  void onInit() {
    super.onInit();
    fetchVideo();
    fetchRelatedVideos(110);
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

        if (loadMore) {
          posts.addAll(model.data);
          filteredList.addAll(model.data);
        } else {
          posts.value = model.data;
          filteredList.value = model.data;
          if (posts.isNotEmpty) {
            currentVideo.value = posts.firstWhere(
                  (video) => video.id == videoId,
              orElse: () => posts.first,
            );
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

  Future<void> fetchRelatedVideos(int videoId) async {
    try {
      isLoading.value = true;

      final response =
      await api.callGet("api/v1/posts/video/110/related");

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
    if (query.isEmpty) {
      filteredList.assignAll(posts); // agar search empty hai, pura data wapas aa jaye
    } else {
      filteredList.assignAll(
        posts.where((post) =>
        post.user.name.toLowerCase().contains(query.toLowerCase()) ||
            post.user.username.toLowerCase().contains(query.toLowerCase())
        ).toList(),
      );
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