import 'package:get/get.dart';

import '../../../core/network/api_services.dart';
import '../model/banner_model.dart';
import '../model/mixed_feed_model.dart';  // your API service file

class PostController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<TrendingPost> posts = <TrendingPost>[].obs;
  RxList<BannerModel> bannersList = <BannerModel>[].obs;
  RxList<TrendingPost> intrestedPostList =<TrendingPost>[].obs;
  final ApiServices api = Get.put(ApiServices());

  @override
  void onInit() {
    super.onInit();
    fetchTrending();
    intrestedPost();
    banners();
  }


  Future<void> fetchTrending() async {
    try {
      isLoading.value = true;

      final response = await api.callGet("api/v1/posts/feed/trending");

      print("fetchTrending : "+response.toString());

      if (response != null && response["data"] != null) {
        final model = TrendingResponse.fromJson(response);
        posts.value = model.data ?? [];
      }
    } catch (e) {
      print("Fetch Posts Error: $e");
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> banners() async {
    try {
      isLoading.value = true;

      final response = await api.callGet("api/v1/banners");

      print("cjbdkjchehiuncjw : "+response.toString());

      if (response != null && response["data"] != null) {
        bannersList.value = (response["data"] as List)
            .map((e) => BannerModel.fromJson(e))
            .toList();
        // final model = TrendingResponse.fromJson(response);
        // bannersList.value = model.data ?? [];
      }
    } catch (e) {
      print("Fetch Posts Error: $e");
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> intrestedPost() async {
    try {
      isLoading.value = true;
      final response = await api.callGet("api/v1/posts/feed/trending/interests");
      print("intrestedPost : "+response.toString());
      if (response != null && response["data"] != null) {
        final model = TrendingResponse.fromJson(response);
        intrestedPostList.value = model.data ?? [];
      }
    } catch (e) {
      print("Fetch Posts Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
