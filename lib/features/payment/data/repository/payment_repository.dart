import '../../../../core/network/api_services.dart';
import '../../../../core/network/app_urls.dart';
import 'package:get/get.dart';

abstract class PaymentRepository {
  Future<Map<String, dynamic>?> initiatePhonePePayment({required int orderId});
  Future<Map<String, dynamic>?> verifyPhonePePayment({
    required int orderId,
    required String merchantTransactionId,
  });
}

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiServices apiServices = Get.find<ApiServices>();

  @override
  Future<Map<String, dynamic>?> initiatePhonePePayment({required int orderId}) async {
    const String endpoint = AppUrls.phonepeCreate;
    
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
  Future<Map<String, dynamic>?> verifyPhonePePayment({
    required int orderId,
    required String merchantTransactionId,
  }) async {
    const String endpoint = AppUrls.phonepeVerify;
    
    final response = await apiServices.callPost(
      endpoint,
      data: {
        "order_id": orderId,
        "merchantTransactionId": merchantTransactionId,
      },
      isFormData: true,
      showErrorToast: true,
    );
    
    return response;
  }
}
