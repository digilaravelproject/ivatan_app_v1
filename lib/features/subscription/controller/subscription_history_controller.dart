import 'package:get/get.dart';
import '../../../../core/network/api_services.dart';
import '../../../../core/network/app_urls.dart';
import '../data/model/subscription_history_model.dart';

class SubscriptionHistoryController extends GetxController {
  final ApiServices _api = ApiServices();

  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var historyList = <SubscriptionHistoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubscriptionHistory();
  }

  Future<void> fetchSubscriptionHistory() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final response = await _api.callGet(AppUrls.subscriptionHistory);
      if (response != null) {
        final parsedResponse = SubscriptionHistoryResponse.fromJson(response);
        if (parsedResponse.status) {
          historyList.value = parsedResponse.history;
        } else {
          hasError.value = true;
          errorMessage.value = parsedResponse.message.isNotEmpty 
              ? parsedResponse.message 
              : 'Failed to retrieve subscription history.';
        }
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load subscription history. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
