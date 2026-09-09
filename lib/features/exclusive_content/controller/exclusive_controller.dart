import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../db/shared_pref_manager.dart';
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

  bool get isPaymentSuccessful {
    final ps = paymentStatus.value.toLowerCase();
    return ps == 'success' || ps == 'completed' || ps == 'paid' || ps == 'captured';
  }

  bool get isFullyActive {
    final es = enablementStatus.value.toLowerCase();
    return es == 'active' || es == 'approved';
  }

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
        final data = (response['data'] is Map<String, dynamic>)
            ? response['data'] as Map<String, dynamic>
            : response;

        final rawStatus = data['status'] ?? (response['status'] is! bool ? response['status'] : null);
        if (rawStatus != null) {
          enablementStatus.value = rawStatus.toString().toLowerCase();
        }

        if (data['fee_paid'] != null) {
          feePaid.value = double.tryParse(data['fee_paid'].toString()) ?? 0.0;
        }

        final rawPaymentStatus = data['payment_status'] ?? response['payment_status'];
        if (rawPaymentStatus != null) {
          paymentStatus.value = rawPaymentStatus.toString().toLowerCase();
        }

        final bool isPurchased = (isPaymentSuccessful || isFullyActive) &&
            paymentStatus.value.toLowerCase() != 'none' &&
            enablementStatus.value.toLowerCase() != 'none';

        if (isPurchased) {
          SharedPrefManager().setExclusivePurchased(true);
        } else {
          SharedPrefManager().setExclusivePurchased(false);
        }
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
        final data = (response['data'] is Map<String, dynamic>)
            ? response['data'] as Map<String, dynamic>
            : response;
        final redirectUrl = data['redirect_url']?.toString() ?? response['redirect_url']?.toString() ?? '';
        
        if (redirectUrl.isNotEmpty) {
          // Open PhonePe Payment SDK
          final result = await Get.to<bool?>(() => PaymentWebViewPage(url: redirectUrl));
          
          if (result == true) {
            paymentStatus.value = 'success';
            SharedPrefManager().setExclusivePurchased(true);
            Get.snackbar(
              "Success", 
              "Payment successful! Enablement requested.",
              backgroundColor: Colors.green,
              colorText: AppColors.white,
            );
          } else if (result == false) {
            paymentStatus.value = 'failed';
            Get.snackbar(
              "Payment Failed", 
              "Payment failed on PhonePe. Please try again.",
              backgroundColor: Colors.red,
              colorText: AppColors.white,
            );
          } else {
            paymentStatus.value = 'cancelled';
            Get.snackbar(
              "Payment Cancelled", 
              "Payment was cancelled or interrupted.",
              backgroundColor: Colors.orange,
              colorText: AppColors.white,
            );
          }
          // Fetch the latest status from the backend to sync UI
          await checkEnablementStatus();
        } else {
          // Fallback if no payment URL is provided (e.g. fee is 0)
          paymentStatus.value = 'success';
          SharedPrefManager().setExclusivePurchased(true);
          Get.snackbar("Success", "Enablement requested successfully.");
          await checkEnablementStatus();
        }
      } else {
         Get.snackbar("Error", response?['message'] ?? "Failed to request enablement.", backgroundColor: Colors.red, colorText: AppColors.white);
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
  Future<bool> initiatePurchase(int postId) async {
    isLoading.value = true;
    bool isSuccess = false;
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
               Get.snackbar("Success", "Purchase successful! Content unlocked.", backgroundColor: Colors.green, colorText: AppColors.white);
               isSuccess = true;
            } else {
               // Fallback optimistic
               Get.snackbar("Success", "Payment successful! It may take a moment to unlock.", backgroundColor: Colors.green, colorText: AppColors.white);
               isSuccess = true;
            }
          } else if (result == false) {
             Get.snackbar("Payment Failed", "Purchase failed on PhonePe. Please try again.", backgroundColor: Colors.red, colorText: AppColors.white);
          } else {
             Get.snackbar("Payment Cancelled", "Payment was cancelled or interrupted.", backgroundColor: Colors.orange, colorText: AppColors.white);
          }
        } else {
          // No redirect URL means it could be a free post or fully paid by wallet?
          Get.snackbar("Success", "Content unlocked.");
          isSuccess = true;
        }
      } else {
        Get.snackbar("Error", response?['message'] ?? "Failed to initiate purchase.");
      }
    } catch (e) {
      debugPrint("Error initiating purchase: $e");
    } finally {
      isLoading.value = false;
    }
    return isSuccess;
  }
}
