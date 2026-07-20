import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/exclusive_api_service.dart';
import '../../payment/presentation/widgets/payment_webview_page.dart';

class ExclusiveController extends GetxController {
  final ExclusiveApiService _apiService = Get.put(ExclusiveApiService());

  RxBool isLoading = false.obs;
  
  // Enablement status
  RxString enablementStatus = 'not_requested'.obs; // not_requested, pending, active
  RxDouble feePaid = 0.0.obs;
  RxString paymentStatus = ''.obs;

  // Wallet
  RxString walletBalance = '0.00'.obs;
  RxList<dynamic> transactions = <dynamic>[].obs;
  RxInt currentTransactionPage = 1.obs;
  RxBool hasMoreTransactions = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkEnablementStatus();
  }

  Future<void> checkEnablementStatus() async {
    isLoading.value = true;
    try {
      final response = await _apiService.checkEnablementStatus();
      if (response != null) {
        // Handle case where API returns {"status": true} instead of a string
        if (response['status'] is bool || response['status'] == null) {
          // Fallback if backend doesn't have the string status yet
          // But don't overwrite if we manually set it to pending/active during test
          if (enablementStatus.value == 'not_requested') {
            enablementStatus.value = 'not_requested';
          }
        } else {
          enablementStatus.value = response['status'].toString();
        }
        
        if (response['fee_paid'] != null) {
           feePaid.value = double.tryParse(response['fee_paid'].toString()) ?? 0.0;
        }
        paymentStatus.value = response['payment_status']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint("Error checking enablement status: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestEnablement() async {
    isLoading.value = true;
    try {
      final response = await _apiService.requestEnablement();
      
      if (response != null && (response['success'] == true || response['status'] == true)) {
        final redirectUrl = response['redirect_url']?.toString() ?? '';
        
        if (redirectUrl.isNotEmpty) {
          // Open PhonePe Payment SDK
          final result = await Get.to<bool?>(() => PaymentWebViewPage(url: redirectUrl));
          
          if (result == true) {
            Get.snackbar(
              "Success", 
              "Payment successful! Enablement requested.",
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else if (result == false) {
            Get.snackbar(
              "Payment Failed", 
              "Payment failed on PhonePe. Please try again.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              "Payment Cancelled", 
              "Payment was cancelled or interrupted.",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
          // Fetch the latest status from the backend to sync UI
          await checkEnablementStatus();
        } else {
          // Fallback if no payment URL is provided (e.g. fee is 0)
          Get.snackbar("Success", "Enablement requested successfully.");
          await checkEnablementStatus();
        }
      } else {
         Get.snackbar("Error", response?['message'] ?? "Failed to request enablement.", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error requesting enablement: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFeature(bool isEnabled) async {
    isLoading.value = true;
    try {
      final response = await _apiService.toggleExclusiveFeature(isEnabled);
      if (response != null && response['success'] == true) {
        Get.snackbar("Success", response['message'] ?? "Feature toggled.");
        // We might want to re-check status if it affects the UI heavily
        checkEnablementStatus();
      }
    } catch (e) {
      debugPrint("Error toggling feature: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWalletBalance() async {
    try {
      final response = await _apiService.getWalletBalance();
      if (response != null && response['balance'] != null) {
        walletBalance.value = response['balance'].toString();
      }
    } catch (e) {
      debugPrint("Error fetching wallet balance: $e");
    }
  }

  Future<void> fetchTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      currentTransactionPage.value = 1;
      transactions.clear();
      hasMoreTransactions.value = true;
    }

    if (!hasMoreTransactions.value) return;

    isLoading.value = true;
    try {
      final response = await _apiService.getWalletTransactions(currentTransactionPage.value);
      if (response != null && response['data'] != null) {
        List<dynamic> newTx = response['data'];
        transactions.addAll(newTx);
        
        if (newTx.isEmpty || (response['total'] != null && transactions.length >= response['total'])) {
          hasMoreTransactions.value = false;
        } else {
          currentTransactionPage.value++;
        }
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> initiatePurchase(int postId) async {
    isLoading.value = true;
    try {
      final response = await _apiService.initiatePurchase(postId);
      if (response != null && response['success'] == true) {
        final redirectUrl = response['redirect_url']?.toString() ?? '';
        final purchaseId = response['purchase']?['id'] ?? 1; // get actual purchase ID
        
        if (redirectUrl.isNotEmpty) {
          // Open PhonePe Payment SDK
          final result = await Get.to<bool?>(() => PaymentWebViewPage(url: redirectUrl));
          
          if (result == true) {
            // Success in UI, verify it
            final verifyResp = await _apiService.verifyPurchase(purchaseId, "PAYMENT_SUCCESS_REF", "PAYMENT_SUCCESS");
            if (verifyResp != null && verifyResp['success'] == true) {
               Get.snackbar("Success", "Purchase successful! Content unlocked.", backgroundColor: Colors.green, colorText: Colors.white);
            } else {
               // Fallback optimistic
               Get.snackbar("Success", "Payment successful! It may take a moment to unlock.", backgroundColor: Colors.green, colorText: Colors.white);
            }
          } else if (result == false) {
             Get.snackbar("Payment Failed", "Purchase failed on PhonePe. Please try again.", backgroundColor: Colors.red, colorText: Colors.white);
          } else {
             Get.snackbar("Payment Cancelled", "Payment was cancelled or interrupted.", backgroundColor: Colors.orange, colorText: Colors.white);
          }
        } else {
          // No redirect URL means it could be a free post or fully paid by wallet?
          Get.snackbar("Success", "Content unlocked.");
        }
      } else {
        Get.snackbar("Error", response?['message'] ?? "Failed to initiate purchase.");
      }
    } catch (e) {
      debugPrint("Error initiating purchase: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
