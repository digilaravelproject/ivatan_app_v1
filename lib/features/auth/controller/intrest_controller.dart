import 'package:get/get.dart';
import '../../../core/network/api_services.dart';

class InterestController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<dynamic> interestData = <dynamic>[].obs;

  final ApiServices api = ApiServices();

  @override
  void onInit() {
    fetchInterests();
    super.onInit();
  }

  Future<void> fetchInterests() async {
    isLoading.value = true;

    final response = await api.callGet("api/interests");

    if (response != null && response["status"] == true) {
      interestData.value = response["data"];
    }

    isLoading.value = false;
  }
}
