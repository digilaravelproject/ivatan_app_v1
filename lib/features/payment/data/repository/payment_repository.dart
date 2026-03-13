import '../../../../core/network/api_services.dart';
import '../../../../core/network/app_urls.dart';
import 'package:get/get.dart';

abstract class PaymentRepository {
  Future<Map<String, dynamic>?> createRazorpayOrder({required int orderId});
  Future<Map<String, dynamic>?> verifyPayment({
    required int orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });
}

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiServices apiServices = Get.find<ApiServices>();

  @override
  Future<Map<String, dynamic>?> createRazorpayOrder({required int orderId}) async {
    const String endpoint = AppUrls.razorpayOrder;
    
    // User requested form-data: order_id=12
    final response = await apiServices.callPost(
      endpoint,
      data: {
        "order_id": orderId,
      },
      isFormData: true,
    );
    
    return response;
  }

  @override
  Future<Map<String, dynamic>?> verifyPayment({
    required int orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    const String endpoint = AppUrls.razorpayVerify;
    
    final response = await apiServices.callPost(
      endpoint,
      data: {
        "order_id": orderId,
        "razorpay_order_id": razorpayOrderId,
        "razorpay_payment_id": razorpayPaymentId,
        "razorpay_signature": razorpaySignature,
      },
      isFormData: true,
      showErrorToast: true,
    );
    
    return response;
  }
}
