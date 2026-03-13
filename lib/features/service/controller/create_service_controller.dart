import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../repository/service_repository.dart';
import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../model/service_model.dart';
import 'service_controller.dart';

class CreateServiceController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ApiServices apiServices = Get.find<ApiServices>();
  final ServiceRepository repository = Get.put(ServiceRepositoryImpl());

  var coverImage = Rx<File?>(null);
  var additionalImages = <File>[].obs;
  var isLoading = false.obs;

  // For editing
  var isEdit = false.obs;
  var serviceId = 0.obs;
  var existingCoverImageUrl = ''.obs;
  var existingImages = <ServiceImage>[].obs;
  var status = 'pending'.obs;

  void initForEdit(ServiceModel service) {
    isEdit.value = true;
    serviceId.value = service.id;
    existingCoverImageUrl.value = AppUrls.getFullImageUrl(service.coverImage);
    existingImages.assignAll(service.images);
    status.value = service.status;
  }

  Future<void> pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      coverImage.value = File(image.path);
    }
  }

  void removeCoverImage() {
    coverImage.value = null;
    existingCoverImageUrl.value = '';
  }

  Future<void> pickAdditionalImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      additionalImages.addAll(images.map((img) => File(img.path)));
    }
  }

  void removeAdditionalImage(int index) {
    if (index >= 0 && index < additionalImages.length) {
      additionalImages.removeAt(index);
    }
  }

  void removeExistingImage(int index) {
    if (index >= 0 && index < existingImages.length) {
      existingImages.removeAt(index);
    }
  }

  Future<void> submitService({
    required String title,
    required String description,
    required String price,
    required String discountPrice,
    required String stock,
  }) async {
    if (title.isEmpty || price.isEmpty) {
      Get.snackbar("Error", "Title and Price are required",
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      Map<String, dynamic>? response;
      if (isEdit.value) {
        response = await repository.updateService(
          id: serviceId.value,
          title: title,
          description: description,
          price: double.tryParse(price) ?? 0.0,
          discountPrice: discountPrice.isNotEmpty ? double.tryParse(discountPrice) : null,
          stock: stock.isNotEmpty ? int.tryParse(stock) : 0,
          status: status.value,
          coverImage: coverImage.value,
          additionalImages: additionalImages.isNotEmpty ? additionalImages : null,
        );
      } else {
        Map<String, dynamic> body = {
          "title": title,
          "description": description,
          "price": double.tryParse(price) ?? 0.0,
          "discount_price": discountPrice.isNotEmpty ? double.tryParse(discountPrice) : null,
        };

        if (coverImage.value != null) {
          body["cover_image"] = coverImage.value;
        }

        for (int i = 0; i < additionalImages.length; i++) {
          body["images[$i]"] = additionalImages[i];
        }

        response = await apiServices.callPost(
          AppUrls.sellerServices,
          data: body,
          isFormData: true,
        );
      }

      if (response != null) {
        if (response['success'] == true) {
          Get.find<ServiceController>().fetchServices();
          Get.back();
          Get.snackbar("Success", response['message'] ?? "Operation successful",
              backgroundColor: AppColors.success, colorText: Colors.white);
        } else {
          // Handle specific validation errors
          String errorMsg = response['message'] ?? "Something went wrong";
          if (response['errors'] != null && response['errors'] is Map) {
            Map errors = response['errors'];
            if (errors.isNotEmpty) {
              var firstKey = errors.keys.first;
              var firstErrorList = errors[firstKey];
              if (firstErrorList is List && firstErrorList.isNotEmpty) {
                errorMsg = firstErrorList.first.toString();
              }
            }
          }
          Get.snackbar("Error", errorMsg,
              backgroundColor: AppColors.error, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
