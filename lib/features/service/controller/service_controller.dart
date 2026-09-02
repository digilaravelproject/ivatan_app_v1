import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../model/enquiry_model_user.dart';
import '../model/service_model.dart';
import '../repository/service_repository.dart';

class ServiceController extends GetxController {
  final ServiceRepository repository = Get.put(ServiceRepositoryImpl());
  final String? userId;

  ServiceController({this.userId});

  var services = <ServiceModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Marketplace Services
  var marketplaceServices = <ServiceModel>[].obs;
  var isMarketplaceLoading = false.obs;
  var marketplacePage = 1;
  var hasMoreMarketplace = true.obs;
  
  // Service Detail
  var selectedService = Rx<ServiceModel?>(null);
  var isDetailLoading = false.obs;

  // Seller Enquiries
  var sellerEnquiries = <Map<String, dynamic>>[].obs;
  var isEnquiriesLoading = false.obs;
  var enquiriesTotal = 0.obs;
  var enquiriesPending = 0.obs;
  var enquiriesReplied = 0.obs;
  var enquiriesClosed = 0.obs;
  var isStatsLoading = false.obs;

  // My Enquiries (User side)
  var myEnquiries = <EnquiryUserModel>[].obs;
  var isMyEnquiriesLoading = false.obs;
  var myEnquiriesPage = 1;
  var hasMoreMyEnquiries = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (userId == null) {
      fetchServices();
    }
    fetchMarketplaceServices();
  }

  Future<void> fetchServiceDetail(int id) async {
    try {
      isDetailLoading(true);
      selectedService.value = null;
      final service = await repository.getMarketplaceServiceDetail(id);
      selectedService.value = service;
    } catch (e) {
      print('Error fetching service detail: $e');
    } finally {
      isDetailLoading(false);
    }
  }

  Future<void> fetchServices() async {
    try {
      isLoading(true);
      errorMessage('');
      final fetchedServices = await repository.getServices();
      services.assignAll(fetchedServices);
    } catch (e) {
      errorMessage('Failed to fetch services: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMarketplaceServices({bool isRefresh = false}) async {
    if (isRefresh) {
      marketplacePage = 1;
      hasMoreMarketplace(true);
    }

    if (!hasMoreMarketplace.value || isMarketplaceLoading.value) return;

    try {
      isMarketplaceLoading(true);
      errorMessage('');
      final fetchedServices = await repository.getMarketplaceServices(page: marketplacePage, userId: userId);
      
      if (isRefresh) {
        marketplaceServices.assignAll(fetchedServices);
      } else {
        marketplaceServices.addAll(fetchedServices);
      }

      if (fetchedServices.length < 10) {
        hasMoreMarketplace(false);
      } else {
        marketplacePage++;
      }
    } catch (e) {
      errorMessage('Error fetching products: $e');
      print('Error fetching marketplace services: $e');
    } finally {
      isMarketplaceLoading(false);
    }
  }

  void addService(ServiceModel service) {
    services.add(service);
  }

  void updateService(int id, ServiceModel updatedService) {
    final index = services.indexWhere((s) => s.id == id);
    if (index != -1) {
      services[index] = updatedService;
      services.refresh();
    }
  }

  Future<void> deleteService(int id) async {
    try {
      isLoading(true);
      final response = await repository.deleteService(id);
      if (response != null && response['success'] == true) {
        services.removeWhere((s) => s.id == id);
        Get.snackbar("Success", response['message'] ?? "Service deleted successfully",
            backgroundColor: AppColors.success, colorText: AppColors.white);
      } else {
        Get.snackbar("Error", response?['message'] ?? "Failed to delete service",
            backgroundColor: AppColors.error, colorText: AppColors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete service: $e",
          backgroundColor: AppColors.error, colorText: AppColors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> submitEnquiry({
    required int sellerId,
    required int serviceId,
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
    required VoidCallback onSuccess,
  }) async {
    try {
      isLoading(true);
      final response = await repository.submitEnquiry(
        sellerId: sellerId,
        serviceId: serviceId,
        name: name,
        email: email,
        phone: phone,
        subject: subject,
        message: message,
      );

      if (response != null && response['success'] == true) {
        Get.snackbar(
          "Success",
          response['message'] ?? "Enquiry submitted successfully.",
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
        );
        onSuccess();
      } else {
        Get.snackbar(
          "Error",
          response?['message'] ?? "Failed to submit enquiry",
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSellerEnquiries() async {
    try {
      isEnquiriesLoading(true);
      final response = await repository.getSellerEnquiries();
      if (response != null && (response['success'] == true || response.containsKey('data'))) {
        final dynamic rawData = (response['success'] == true && response['data'] is Map) ? response['data'] : response;
        final List data = rawData['data'] ?? [];
        sellerEnquiries.assignAll(data.map((e) => e as Map<String, dynamic>).toList());
      }
    } catch (e) {
      print('Error fetching seller enquiries: $e');
    } finally {
      isEnquiriesLoading(false);
    }
  }

  Future<void> fetchMyEnquiries({bool isRefresh = false}) async {
    if (isRefresh) {
      myEnquiriesPage = 1;
      hasMoreMyEnquiries(true);
    }

    if (!hasMoreMyEnquiries.value || isMyEnquiriesLoading.value) return;

    try {
      isMyEnquiriesLoading(true);
      final response = await repository.getMyEnquiries(page: myEnquiriesPage);
      if (response != null && (response['success'] == true || response.containsKey('data'))) {
        final dynamic rawData = (response['success'] == true && response['data'] is Map) ? response['data'] : response;
        final List data = rawData['data'] ?? [];
        final List<EnquiryUserModel> fetchedList = data.map((e) => EnquiryUserModel.fromJson(e)).toList();

        if (isRefresh) {
          myEnquiries.assignAll(fetchedList);
        } else {
          myEnquiries.addAll(fetchedList);
        }

        // Check if there are more pages
        final meta = response['meta'];
        if (meta != null) {
          final int currentPage = meta['current_page'] ?? 1;
          final int lastPage = meta['last_page'] ?? 1;
          if (currentPage >= lastPage) {
            hasMoreMyEnquiries(false);
          } else {
            myEnquiriesPage++;
          }
        } else {
          // If meta is missing, assume no more pages if fetched list is small
          if (fetchedList.length < 15) {
            hasMoreMyEnquiries(false);
          } else {
            myEnquiriesPage++;
          }
        }
      }
    } catch (e) {
      print('Error fetching my enquiries: $e');
    } finally {
      isMyEnquiriesLoading(false);
    }
  }

  Future<void> fetchSellerEnquiriesStats() async {
    try {
      isStatsLoading(true);
      final response = await repository.getSellerEnquiriesStats();
      if (response != null && response['success'] == true) {
        final data = response['data'];
        enquiriesTotal.value = data['total'] ?? 0;
        enquiriesPending.value = data['pending'] ?? 0;
        enquiriesReplied.value = data['replied'] ?? 0;
        enquiriesClosed.value = data['closed'] ?? 0;
      }
    } catch (e) {
      print('Error fetching seller enquiries stats: $e');
    } finally {
      isStatsLoading(false);
    }
  }

  Future<void> updateEnquiryStatus(int id, String status, {String? replyMessage}) async {
    try {
      isLoading(true);
      final response = await repository.updateEnquiryStatus(id, status, replyMessage: replyMessage);
      if (response != null && response['success'] == true) {
        Get.back(); // Close the sheet
        Get.snackbar(
          "Success",
          "Status updated to $status",
          backgroundColor: Colors.green,
          colorText: AppColors.white,
        );
        // Refresh everything
        fetchSellerEnquiries();
        fetchSellerEnquiriesStats();
      } else {
        Get.snackbar(
          "Error",
          response?['message'] ?? "Failed to update status",
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      print('Error updating enquiry status: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteEnquiry(int id) async {
    try {
      isLoading(true);
      final response = await repository.deleteEnquiry(id);
      if (response != null && response['success'] == true) {
        Get.back(); // Close the sheet
        Get.snackbar(
          "Success",
          "Enquiry deleted successfully",
          backgroundColor: Colors.green,
          colorText: AppColors.white,
        );
        // Refresh everything
        fetchSellerEnquiries();
        fetchSellerEnquiriesStats();
      } else {
        Get.snackbar(
          "Error",
          response?['message'] ?? "Failed to delete enquiry",
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      print('Error deleting enquiry: $e');
    } finally {
      isLoading(false);
    }
  }
}
