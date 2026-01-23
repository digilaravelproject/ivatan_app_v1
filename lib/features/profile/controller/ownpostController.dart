import 'package:get/get.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';

import '../../../core/network/api_services.dart';
import '../../dashboard/controller/follow_controller.dart';
import '../../dashboard/controller/homeController.dart';
import '../../dashboard/model/post_model.dart';
import 'package:i_vatan_app/features/dashboard/controller/homeController.dart'; // Ensure absolute path if needed, or rely on relative.

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

  Future<void> toggleFollowForPostUser(int userId, int index) async {
    // Implement follow logic or proxy to HomeController if feasible
  }

  void openReportBottomSheet({required int postId}) {
     final HomeController homeController = Get.find<HomeController>();
     homeController.openReportBottomSheet(postId: postId);
  }
}