import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';
import 'package:get/get.dart';

abstract class FinancialRepository {
  Future<Map<String, dynamic>?> getBankDetails();
  
  Future<Map<String, dynamic>?> addBankAccount({
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    required String accountNumberConfirmation,
    required String ifscCode,
    required String accountType,
  });
}

class FinancialRepositoryImpl implements FinancialRepository {
  final ApiServices apiServices = Get.find<ApiServices>();

  @override
  Future<Map<String, dynamic>?> getBankDetails() async {
    const String endpoint = AppUrls.financial;
    
    final response = await apiServices.callGet(
      endpoint,
      showErrorToast: false,
    );

    return response;
  }
  Future<Map<String, dynamic>?> addBankAccount({
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    required String accountNumberConfirmation,
    required String ifscCode,
    required String accountType,
  }) async {
    const String endpoint = AppUrls.financial;
    
    Map<String, dynamic> body = {
      "bank_name": bankName,
      "account_holder_name": accountHolderName,
      "account_number": accountNumber,
      "account_number_confirmation": accountNumberConfirmation,
      "ifsc_code": ifscCode,
      "account_type": accountType,
    };

    final response = await apiServices.callPost(
      endpoint,
      data: body,
      showErrorToast: false, // Controller will handle errors
      isFormData: false,
    );

    return response;
  }
}
