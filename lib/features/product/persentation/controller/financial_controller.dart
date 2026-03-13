import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../repository/financial_repository.dart';
import '../../../../core/theme/app_colors.dart';

class FinancialController extends GetxController {
  final FinancialRepository financialRepository = Get.put(FinancialRepositoryImpl());

  final holderNameController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final confirmAccountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  
  var selectedAccountType = 'savings'.obs;
  var isLoading = false.obs;
  var isFetching = false.obs;

  var bankData = <String, dynamic>{}.obs;

  final List<String> accountTypes = ['savings', 'current', 'overdraft'];

  @override
  void onInit() {
    super.onInit();
    fetchBankDetails();
  }

  Future<void> fetchBankDetails() async {
    isFetching.value = true;
    try {
      final response = await financialRepository.getBankDetails();
      if (response != null && response['success'] == true) {
        if (response['data'] != null && response['data'] is Map<String, dynamic>) {
          bankData.value = response['data'];
        } else {
          bankData.clear();
        }
      }
    } catch (e) {
      debugPrint("Error fetching bank details: $e");
    } finally {
      isFetching.value = false;
    }
  }

  Future<bool> addBankAccount() async {
    if (!_validate()) return false;

    isLoading.value = true;
    try {
      final response = await financialRepository.addBankAccount(
        bankName: bankNameController.text.trim(),
        accountHolderName: holderNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        accountNumberConfirmation: confirmAccountNumberController.text.trim(),
        ifscCode: ifscController.text.trim(),
        accountType: selectedAccountType.value,
      );

      if (response != null && response['success'] == true) {
        Get.snackbar(
          'Success',
          response['message'] ?? 'Bank account added successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _clearFields();
        fetchBankDetails(); // Refresh list after adding
        Get.back();
        return true;
      } else {
        String errorMsg = response?['message'] ?? 'Failed to add bank account';
        
        // Check for specific validation errors
        if (response?['errors'] != null && response?['errors'] is Map) {
          Map errors = response?['errors'];
          if (errors.isNotEmpty) {
            var firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMsg = firstError.first.toString();
            }
          }
        }

        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate() {
    if (holderNameController.text.isEmpty) {
      _showError('Please enter account holder name');
      return false;
    }
    if (bankNameController.text.isEmpty) {
      _showError('Please enter bank name');
      return false;
    }
    if (accountNumberController.text.isEmpty) {
      _showError('Please enter account number');
      return false;
    }
    if (accountNumberController.text != confirmAccountNumberController.text) {
      _showError('Account numbers do not match');
      return false;
    }
    if (ifscController.text.isEmpty) {
      _showError('Please enter IFSC code');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void _clearFields() {
    holderNameController.clear();
    bankNameController.clear();
    accountNumberController.clear();
    confirmAccountNumberController.clear();
    ifscController.clear();
    selectedAccountType.value = 'savings';
  }

  @override
  void onClose() {
    holderNameController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    ifscController.dispose();
    super.onClose();
  }
}
