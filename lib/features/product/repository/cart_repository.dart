import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';
import 'package:get/get.dart';

abstract class CartRepository {
  Future<Map<String, dynamic>?> getCart();

  Future<Map<String, dynamic>?> addToCart({
    required String itemType,
    required int itemId,
    required int quantity,
    bool showErrorToast = true,
  });

  Future<Map<String, dynamic>?> updateCartQuantity({
    required int cartItemId,
    required int quantity,
    bool showErrorToast = true,
  });

  Future<Map<String, dynamic>?> deleteCartItem({
    required int cartItemId,
    bool showErrorToast = true,
  });

  Future<Map<String, dynamic>?> clearAllCart({
    bool showErrorToast = true,
  });

  Future<Map<String, dynamic>?> checkout({
    required Map<String, dynamic> checkoutData,
    bool showErrorToast = true,
  });
}

class CartRepositoryImpl implements CartRepository {
  final ApiServices apiServices = Get.find<ApiServices>();

  @override
  Future<Map<String, dynamic>?> getCart() async {
    const String endpoint = AppUrls.cart;
    final response = await apiServices.callGet(
      endpoint,
      showErrorToast: false,
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>?> addToCart({
    required String itemType,
    required int itemId,
    required int quantity,
    bool showErrorToast = true,
  }) async {
    const String endpoint = AppUrls.cart;
    
    Map<String, dynamic> body = {
      "item_type": itemType,
      "item_id": itemId,
      "quantity": quantity,
    };

    final response = await apiServices.callPost(
      endpoint,
      data: body,
      showErrorToast: showErrorToast,
      isFormData: false,
    );

    return response;
  }

  @override
  Future<Map<String, dynamic>?> updateCartQuantity({
    required int cartItemId,
    required int quantity,
    bool showErrorToast = true,
  }) async {
    final String endpoint = "${AppUrls.cart}/$cartItemId";

    Map<String, dynamic> body = {
      "quantity": quantity,
    };

    final response = await apiServices.callPost(
      endpoint,
      data: body,
      showErrorToast: showErrorToast,
      isFormData: false,
    );

    return response;
  }

  @override
  Future<Map<String, dynamic>?> deleteCartItem({
    required int cartItemId,
    bool showErrorToast = true,
  }) async {
    final String endpoint = "${AppUrls.cart}/$cartItemId";

    final response = await apiServices.callDelete(
      endpoint,
    );

    return response;
  }

  @override
  Future<Map<String, dynamic>?> clearAllCart({
    bool showErrorToast = true,
  }) async {
    const String endpoint = AppUrls.cart;

    final response = await apiServices.callDelete(
      endpoint,
    );

    return response;
  }

  @override
  Future<Map<String, dynamic>?> checkout({
    required Map<String, dynamic> checkoutData,
    bool showErrorToast = true,
  }) async {
    const String endpoint = AppUrls.checkout;
    final response = await apiServices.callPost(
      endpoint,
      data: checkoutData,
      showErrorToast: showErrorToast,
      isFormData: false,
    );
    return response;
  }
}
