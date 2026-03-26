import 'dart:io';

import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';
import '../model/service_model.dart';
import 'package:get/get.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getServices({int page = 1});
  Future<Map<String, dynamic>?> updateService({
    required int id,
    required String title,
    String? description,
    required double price,
    double? discountPrice,
    int? stock,
    String? status,
    File? coverImage,
    List<File>? additionalImages,
  });
  Future<Map<String, dynamic>?> deleteService(int id);
  Future<List<ServiceModel>> getMarketplaceServices({int page = 1});
  Future<ServiceModel?> getMarketplaceServiceDetail(int id);
  Future<Map<String, dynamic>?> submitEnquiry({
    required int sellerId,
    required int serviceId,
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  });
  Future<Map<String, dynamic>?> getMyEnquiries({int page = 1});
  Future<Map<String, dynamic>?> getSellerEnquiries({int page = 1});
  Future<Map<String, dynamic>?> getSellerEnquiriesStats();
  Future<Map<String, dynamic>?> updateEnquiryStatus(int id, String status, {String? replyMessage});
  Future<Map<String, dynamic>?> deleteEnquiry(int id);
}

class ServiceRepositoryImpl implements ServiceRepository {
  final ApiServices apiServices = Get.find<ApiServices>();

  @override
  Future<ServiceModel?> getMarketplaceServiceDetail(int id) async {
    final String endpoint = "${AppUrls.marketplaceServices}/$id";
    final response = await apiServices.callGet(endpoint);

    if (response != null && response['success'] == true) {
      return ServiceModel.fromJson(response['data']);
    }

    return null;
  }

  @override
  Future<List<ServiceModel>> getMarketplaceServices({int page = 1}) async {
    const String endpoint = AppUrls.marketplaceServices;
    final response = await apiServices.callGet(endpoint, queryParams: {'page': page.toString()});

    if (response != null && response['success'] == true) {
      final List dataList = response['data']['data'];
      return dataList.map((e) => ServiceModel.fromJson(e)).toList();
    }

    return [];
  }

  @override
  Future<List<ServiceModel>> getServices({int page = 1}) async {
    const String endpoint = "api/v1/services";
    final response = await apiServices.callGet(endpoint, queryParams: {'page': page.toString()});

    if (response != null && response['success'] == true) {
      final List dataList = response['data']['data'];
      return dataList.map((e) => ServiceModel.fromJson(e)).toList();
    }

    return [];
  }

  @override
  Future<Map<String, dynamic>?> updateService({
    required int id,
    required String title,
    String? description,
    required double price,
    double? discountPrice,
    int? stock,
    String? status,
    File? coverImage,
    List<File>? additionalImages,
  }) async {
    final String endpoint = "api/v1/services/$id";
    
    Map<String, dynamic> body = {
      "title": title,
      "description": description,
      "price": price,
      "discount_price": discountPrice,
      "stock": stock,
      "status": status,
    };

    if (coverImage != null) {
      body["cover_image"] = coverImage;
    }

    if (additionalImages != null && additionalImages.isNotEmpty) {
      for (int i = 0; i < additionalImages.length; i++) {
        body["images[$i]"] = additionalImages[i];
      }
    }

    final response = await apiServices.callPost(
      endpoint,
      data: body,
      isFormData: true,
    );

    return response;
  }

  @override
  Future<Map<String, dynamic>?> deleteService(int id) async {
    final String endpoint = "api/v1/services/$id";
    final response = await apiServices.callDelete(endpoint);
    return response;
  }

  @override
  Future<Map<String, dynamic>?> submitEnquiry({
    required int sellerId,
    required int serviceId,
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    const String endpoint = AppUrls.enquiries;

    Map<String, dynamic> body = {
      "seller_id": sellerId,
      "service_id": serviceId,
      "name": name,
      "email": email,
      "phone": phone,
      "subject": subject,
      "message": message,
    };

    final response = await apiServices.callPost(
      endpoint,
      data: body,
      showErrorToast: false, // Turn off generic toast to handle 422 errors manually
    );

    if (response != null && response['success'] != true) {
      String errorMessage = response['message']?.toString() ?? 'Failed to submit enquiry.';
      if (response['errors'] != null && response['errors'] is Map) {
        final errors = response['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          } else {
            errorMessage = firstError.toString();
          }
        }
      }
      throw errorMessage;
    }

    return response;
  }

  @override
  Future<Map<String, dynamic>?> getMyEnquiries({int page = 1}) async {
    final response = await apiServices.callGet(
      AppUrls.myEnquiries,
      queryParams: {'page': page.toString()},
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>?> getSellerEnquiries({int page = 1}) async {
    final response = await apiServices.callGet(
      AppUrls.sellerEnquiries,
      queryParams: {'page': page.toString()},
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>?> getSellerEnquiriesStats() async {
    final response = await apiServices.callGet(
      AppUrls.sellerEnquiriesStats,
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>?> updateEnquiryStatus(int id, String status, {String? replyMessage}) async {
    final response = await apiServices.callPost(
      AppUrls.sellerEnquiryStatusUpdate(id),
      data: {
        "status": status,
        if (replyMessage != null && replyMessage.isNotEmpty) "reply_message": replyMessage,
      },
      isFormData: true,
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>?> deleteEnquiry(int id) async {
    final response = await apiServices.callDelete(
      AppUrls.deleteEnquiry(id),
    );
    return response;
  }
}
