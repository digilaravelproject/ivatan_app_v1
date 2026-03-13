import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../repository/order_repository.dart';
import '../../model/order_model.dart';
import '../../../../core/network/api_services.dart';
import '../../../product/data/repository/marketplace_repository.dart';

class SellerOrderDetailController extends GetxController {
  final int orderId;
  final OrderRepository repository = OrderRepositoryImpl();
  
  var order = Rxn<OrderModel>();
  var isLoading = true.obs;

  SellerOrderDetailController({required this.orderId});

  @override
  void onInit() {
    super.onInit();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    isLoading.value = true;
    try {
      final response = await repository.getSellerOrderDetails(orderId);
      if (response != null && response['success'] == true) {
        order.value = OrderModel.fromJson(response['data'] ?? {});
        
        // Resolve product details if they are missing titles/images
        if (order.value?.items != null) {
          await _resolveProductDetails(order.value!.items!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching seller order details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String status) async {
    try {
      final response = await repository.updateSellerOrderStatus(orderId, status);
      if (response != null && response['success'] == true) {
        Get.snackbar(
          'Success',
          response['message'] ?? 'Order status updated to $status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
        // Refetch to ensure all details are up-to-date
        await fetchOrderDetails();
      } else {
        Get.snackbar(
          'Error',
          response?['message'] ?? 'Failed to update order status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to connect to server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _resolveProductDetails(List<OrderItem> items) async {
    final MarketplaceRepository marketRepo = MarketplaceRepository(apiServices: Get.find<ApiServices>());
    
    for (var item in items) {
      if (item.itemId != null && (item.title == null || item.image == null)) {
        final product = await marketRepo.getProductById(item.itemId.toString());
        if (product != null) {
          item.title = product.title;
          item.image = product.coverImage;
          order.refresh(); // Update UI
        }
      }
    }
  }
}
