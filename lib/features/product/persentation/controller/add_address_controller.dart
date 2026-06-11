import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/api_services.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import '../cart_screen.dart';
import 'cart_controller.dart';

class AddAddressController extends GetxController {
  var selectedType = "Home".obs;
  var isLoading = false.obs;
  final ApiServices apiServices = Get.find<ApiServices>();

  // Form controllers
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressLine1Controller;
  late TextEditingController addressLine2Controller;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController pinCodeController;
  var selectedCountry = 'India'.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressLine1Controller = TextEditingController();
    addressLine2Controller = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    pinCodeController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    super.onClose();
  }

  void selectType(String type) {
    selectedType.value = type;
  }

  void setCountry(String country) {
    selectedCountry.value = country;
  }

  Future<void> saveAddress() async {
    // Validation
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your name',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }
    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your phone number',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }
    
    // Validate phone format (10-15 digits)
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    final cleanPhone = phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      Get.snackbar('Error', 'Please enter a valid phone number (10-15 digits)',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }
    if (addressLine1Controller.text.isEmpty) {
      Get.snackbar('Error', 'Please enter address line 1',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }
    if (cityController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter city',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }
    if (stateController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter state',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }
    if (pinCodeController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter PIN code',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      Map<String, dynamic> body = {
        "name": nameController.text,
        "phone": cleanPhone, // Use cleaned phone number
        "address_line1": addressLine1Controller.text,
        "address_line2": addressLine2Controller.text,
        "city": cityController.text,
        "state": stateController.text,
        "country": selectedCountry.value,
        "postal_code": pinCodeController.text,
       // "type": selectedType.value,
      };

      final response = await apiServices.callPost(
        AppUrls.addresses,
        data: body,
      );

      if (response != null && response['success'] == true) {
        final addressData = response['data'];
        
        // Add address to cart controller if available
        try {
          final cartController = Get.find<CartController>();
          cartController.addresses.add(Address.fromJson(addressData));
          cartController.selectedAddress.value = Address.fromJson(addressData);
        } catch (e) {
          print('Cart controller not found: $e');
        }

        Get.back();
        Get.snackbar(
          'Success',
          response['message'] ?? 'Address saved successfully',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Extract error message from nested errors if available
        String errorMessage = response?['message'] ?? 'Failed to save address';
        
        if (response != null && response['errors'] != null) {
          final errors = response['errors'];
          if (errors is Map && errors.isNotEmpty) {
            // Get first error field
            final firstErrorField = errors.keys.first;
            final errorList = errors[firstErrorField];
            
            if (errorList is List && errorList.isNotEmpty) {
              errorMessage = errorList[0].toString();
            }
          }
        }
        
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}