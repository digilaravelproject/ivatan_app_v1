import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';

import '../../../core/network/api_services.dart';
import '../../dashboard/model/post_model.dart';

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
          "api/v1/posts/user/$username?filter=$filterType&page=$currentPage"
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


}