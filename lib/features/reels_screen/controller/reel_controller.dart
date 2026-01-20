import 'package:get/get.dart';
import '../../../core/network/api_services.dart';
import '../model/reel_model.dart';

class ReelsController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ReelModel> reels = <ReelModel>[].obs;
  final ApiServices api = ApiServices();

  Future<void> fetchReels() async {
    try {
      isLoading.value = true;

      final response = await api.callGet("api/v1/posts/feed/reels");

      print("objectreelresponse : "+response.toString());

      if (response != null && response["data"] != null) {
        reels.value = (response["data"] as List)
            .map((e) => ReelModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Error fetching reels: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
