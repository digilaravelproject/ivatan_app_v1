import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_services.dart';
import '../../../../core/network/app_urls.dart';

class SellerDashboardController extends GetxController {
  final ApiServices apiServices = Get.find<ApiServices>();

  var isLoading = false.obs;
  var totalOrders = 0.obs;
  var pendingOrders = 0.obs;
  var totalRevenue = 0.0.obs;
  var totalProducts = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    isLoading.value = true;
    try {
      final response = await apiServices.callGet(
        AppUrls.sellerStats,
        showErrorToast: false,
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data != null) {
          totalOrders.value = (data['total_orders'] ?? 0) as int;
          pendingOrders.value = (data['pending_orders'] ?? 0) as int;
          totalRevenue.value = (double.tryParse(data['total_revenue']?.toString() ?? '0') ?? 0.0);
          totalProducts.value = (data['total_products'] ?? 0) as int;
        }
      }
    } catch (e) {
      debugPrint("Error fetching seller stats: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
