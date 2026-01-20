import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../core/network/api_services.dart';
import '../../search/model/mixed_feed_model.dart';

/*
class ImagePostController extends GetxController {

  final int postId;
  ImagePostController({required this.postId});

  RxBool isLoading = false.obs;
  //RxList<TrendingPost> imagePosts = <TrendingPost>[].obs;
  Rx<TrendingPost?> imagePosts = Rx<TrendingPost?>(null);
 // RxList<TrendingPost> intrestedPostList =<TrendingPost>[].obs;
  final ApiServices api = Get.put(ApiServices());

  @override
  void onInit() {
    super.onInit();
    fetchTrending();
  }

  Future<void> fetchTrending() async {
    try {
      isLoading.value = true;

      final response = await api.callGet("/api/v1/posts/$postId");


      print("API Response: $response");

      if (response != null) {
        // Assuming response is JSON map for single post
        imagePosts.value = TrendingPost.fromJson(response);
      }

    } catch (e) {
      print("Fetch Posts Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

}
*/

class ImagePostController extends GetxController {
  final int postId;
  ImagePostController({required this.postId});

  RxBool isLoading = false.obs;
  Rx<TrendingPost?> post = Rx<TrendingPost?>(null);

  final ApiServices api = Get.put(ApiServices());

  RxBool isLiked = false.obs;
  RxInt likeCount = 0.obs;
  RxInt commentCount = 0.obs;
  RxInt shareCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPost();
  }

  Future<void> fetchPost() async {
    try {
      isLoading.value = true;
      final response = await api.callGet("api/v1/posts/$postId");

      if (response != null) {
        post.value = TrendingPost.fromJson(response);

        // Initialize like/comment/share counts
        isLiked.value = post.value!.stats.isLiked;
        likeCount.value = post.value!.stats.likeCount;
        commentCount.value = post.value!.stats.commentCount;
        shareCount.value = post.value!.stats.shareCount;
      }
    } catch (e) {
      print("Fetch Post Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleLike() {
    if (post.value == null) return;

    isLiked.value = !isLiked.value;
    likeCount.value += isLiked.value ? 1 : -1;
    // Optional: call API to update like
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

        // 🟢 Update ONLY clicked post
        post.value!.stats.isLiked = newLikeStatus;
        post.value!.stats.likeCount = newCount;

        // 🔄 Refresh only that post
        post.refresh();
      }
    } catch (e) {
      print("Like Error: $e");
    }
  }

  void updateCommentCount({bool increase = true}) {
    if (post.value == null) return;

    if (increase) {
      post.value!.stats.commentCount++;
    } else {
      if (post.value!.stats.commentCount > 0) {
        post.value!.stats.commentCount--;
      }
    }

    // 🔄 UI refresh
    post.refresh();
  }


  void share() {
    // Implement share functionality
  }
}
