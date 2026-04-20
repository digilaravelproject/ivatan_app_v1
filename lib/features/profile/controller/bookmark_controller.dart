import 'package:get/get.dart';
import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';
import '../../dashboard/model/post_model.dart';

class BookmarkController extends GetxController {
  final ApiServices api = ApiServices();
  RxList<PostItem> bookmarkedPosts = <PostItem>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookmarks();
  }

  Future<void> fetchBookmarks() async {
    try {
      isLoading.value = true;
      final response = await api.callGet(AppUrls.myBookmarks);
      
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        // The API returns an array of bookmark objects, each containing a 'post' object.
        bookmarkedPosts.value = data.map((json) {
          return PostItem.fromJson(json['post']);
        }).toList();
      }
    } catch (e) {
      print("Error fetching bookmarks: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBookmark(int postId) async {
     try {
      final response = await api.callPost(AppUrls.bookmarkPost(postId));
      if (response != null && response['success'] == true) {
        // If un-bookmarked, remove from list
        if (response['is_bookmarked'] == false) {
          bookmarkedPosts.removeWhere((p) => p.id == postId);
        }
      }
    } catch (e) {
      print("Error toggling bookmark: $e");
    }
  }
}
