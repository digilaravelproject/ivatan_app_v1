import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import '../../../core/helper/custom_snack_bar.dart';

import '../../../core/network/api_services.dart';
import '../../dashboard/controller/follow_controller.dart';
import '../model/banner_model.dart';
import '../model/mixed_feed_model.dart';

class PostController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<TrendingPost> posts = <TrendingPost>[].obs;
  RxList<BannerModel> bannersList = <BannerModel>[].obs;
  RxList<TrendingPost> intrestedPostList = <TrendingPost>[].obs;
  RxList<TrendingPost> forYouPosts = <TrendingPost>[].obs;
  final ApiServices api = Get.put(ApiServices());
  final FollowController followController = Get.find<FollowController>();

  @override
  void onInit() {
    super.onInit();
    fetchTrending();
    intrestedPost();
    banners();
    fetchForYou();
  }

  Future<void> fetchTrending() async {
    try {
      isLoading.value = true;
      final response = await api.callGet(AppUrls.feedTrending);
      if (response != null && response["data"] != null) {
        final model = TrendingResponse.fromJson(response);
        posts.value = model.data ?? [];
        for (var post in posts) {
          followController.setInitialFollowStatus(post.user.id, post.isFollowing);
        }
      }
    } catch (e) {
      print("Fetch Posts Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> banners() async {
    try {
      final response = await api.callGet(AppUrls.banners);
      if (response != null && response["data"] != null) {
        bannersList.value = (response["data"] as List)
            .map((e) => BannerModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Fetch Banners Error: $e");
    }
  }

  Future<void> intrestedPost() async {
    try {
      final response = await api.callGet(AppUrls.feedTrendingInterests);
      if (response != null && response["data"] != null) {
        final model = TrendingResponse.fromJson(response);
        intrestedPostList.value = model.data ?? [];
        for (var post in intrestedPostList) {
          followController.setInitialFollowStatus(post.user.id, post.isFollowing);
        }
      }
    } catch (e) {
      print("Fetch Interested Posts Error: $e");
    }
  }

  Future<void> fetchForYou() async {
    try {
      final response = await api.callGet(AppUrls.feedForYou);
      if (response != null && response["data"] != null) {
        final model = TrendingResponse.fromJson(response);
        forYouPosts.value = model.data ?? [];
        for (var post in forYouPosts) {
          followController.setInitialFollowStatus(post.user.id, post.isFollowing);
        }
      }
    } catch (e) {
      print("Fetch For You Error: $e");
    }
  }

  /// Pull-to-refresh
  Future<void> refreshAll() async {
    await Future.wait([
      fetchTrending(),
      intrestedPost(),
      banners(),
      fetchForYou(),
    ]);
  }

  Future<void> toggleBookmark(int postId) async {
    try {
      final response = await api.callPost(AppUrls.bookmarkPost(postId), data: {});
      
      if (response != null && response["success"] == true) {
        bool isBookmarked = response["is_bookmarked"] ?? false;
        
        void updateInList(RxList<TrendingPost> list) {
          int index = list.indexWhere((p) => p.id == postId);
          if (index != -1) {
            list[index].stats.isSaved = isBookmarked;
            list.refresh();
          }
        }
        
        updateInList(posts);
        updateInList(intrestedPostList);
        updateInList(forYouPosts);
        
        CustomSnackBar.showSuccess(
          message: response["message"] ?? (isBookmarked ? "Post bookmarked" : "Bookmark removed")
        );
      }
    } catch (e) {
      print("Bookmark Error: $e");
    }
  }
}
