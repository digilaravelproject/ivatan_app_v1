import 'dart:io';

import 'package:get/get.dart';
import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';

class ExclusiveApiService {
  final ApiServices _apiServices = Get.find<ApiServices>();

  Future<Map<String, dynamic>?> checkEnablementStatus() async {
    return await _apiServices.callGet(AppUrls.exclusiveEnablementStatus);
  }

  Future<Map<String, dynamic>?> requestEnablement() async {
    return await _apiServices.callPost(AppUrls.exclusiveRequestEnablement, data: {});
  }

  Future<Map<String, dynamic>?> verifyEnablementPayment(String referenceId, String code) async {
    return await _apiServices.callPost(
      AppUrls.exclusiveVerifyEnablement,
      data: {
        "gateway_payload": {
          "providerReferenceId": referenceId,
          "code": code,
        }
      },
    );
  }

  Future<Map<String, dynamic>?> createExclusivePost({
    required String type,
    required String caption,
    required String visibility,
    required File media,
    required double price,
  }) async {
    return await _apiServices.callPost(
      AppUrls.exclusivePosts,
      isFormData: true,
      data: {
        "type": type,
        "caption": caption,
        "visibility": visibility,
        "media[]": [media],
        "price": price,
      },
    );
  }

  Future<Map<String, dynamic>?> updateExclusivePostPrice(int postId, double price) async {
    return await _apiServices.callPut(
      AppUrls.exclusiveUpdatePostPrice(postId),
      data: {
        "price": price,
      },
    );
  }

  Future<Map<String, dynamic>?> toggleExclusiveFeature(bool isEnabled) async {
    return await _apiServices.callPost(
      AppUrls.exclusiveToggle,
      data: {
        "is_enabled": isEnabled,
      },
    );
  }

  Future<Map<String, dynamic>?> getWalletBalance() async {
    return await _apiServices.callGet(AppUrls.exclusiveWalletBalance);
  }

  Future<Map<String, dynamic>?> getWalletTransactions(int page) async {
    return await _apiServices.callGet(
      AppUrls.exclusiveWalletTransactions,
      queryParams: {"page": page.toString()},
    );
  }

  Future<Map<String, dynamic>?> initiatePurchase(int postId) async {
    return await _apiServices.callPost(
      AppUrls.exclusivePurchaseInitiate(postId),
      data: {},
    );
  }

  Future<Map<String, dynamic>?> verifyPurchase(int purchaseId, String referenceId, String code) async {
    return await _apiServices.callPost(
      AppUrls.exclusivePurchaseVerify,
      data: {
        "purchase_id": purchaseId,
        "gateway_payload": {
          "providerReferenceId": referenceId,
          "code": code,
        }
      },
    );
  }
}
