import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';
import 'package:get/get.dart';

abstract class OrderRepository {
  Future<Map<String, dynamic>?> getOrders({int page = 1});
  Future<Map<String, dynamic>?> getSellerOrders({int page = 1, String? status});
  Future<Map<String, dynamic>?> getOrderDetails(int orderId);
  Future<Map<String, dynamic>?> getSellerOrderDetails(int orderId);
  Future<Map<String, dynamic>?> updateSellerOrderStatus(int orderId, String status);
}

class OrderRepositoryImpl implements OrderRepository {
  final ApiServices apiServices = Get.find<ApiServices>();

  @override
  Future<Map<String, dynamic>?> getOrders({int page = 1}) async {
    const String endpoint = AppUrls.orders;
    final response = await apiServices.callGet(
      endpoint,
      queryParams: {"page": page.toString()},
      showErrorToast: false,
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>?> getSellerOrders({int page = 1, String? status}) async {
    const String endpoint = AppUrls.sellerOrders;
    Map<String, String> params = {"page": page.toString()};
    if (status != null && status.isNotEmpty) {
      params["status"] = status;
    }
    final response = await apiServices.callGet(
      endpoint,
      queryParams: params,
      showErrorToast: false,
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>?> getOrderDetails(int orderId) async {
    final String endpoint = AppUrls.orderDetail(orderId);
    final response = await apiServices.callGet(
      endpoint,
      showErrorToast: false,
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>?> getSellerOrderDetails(int orderId) async {
    final String endpoint = AppUrls.sellerOrderDetail(orderId);
    final response = await apiServices.callGet(
      endpoint,
      showErrorToast: false,
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>?> updateSellerOrderStatus(int orderId, String status) async {
    final String endpoint = AppUrls.sellerOrderStatusUpdate(orderId);
    final response = await apiServices.callPost(
      endpoint,
      data: {'status': status},
      showErrorToast: true,
    );
    return response;
  }
}
