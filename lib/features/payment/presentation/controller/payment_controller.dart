import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import '../widgets/payment_webview_page.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../data/repository/payment_repository.dart';

class PaymentController extends GetxController {
  final PaymentRepository repository = Get.put(PaymentRepositoryImpl());
  int? _currentOrderId;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> initiatePayment(int orderId) async {
    _currentOrderId = orderId;
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.black)),
        barrierDismissible: false,
      );

      // 1. Initiate payment on PhonePe backend
      final response = await repository.initiatePhonePePayment(orderId: orderId);
      
      Get.back(); // Close loading dialog
      
      if (response != null && response['success'] == true) {
        final redirectUrl = response['redirect_url'];
        final merchantTxnId = response['merchant_transaction_id'] ?? response['merchantTransactionId'] ?? "";
        
        if (redirectUrl != null && redirectUrl.toString().isNotEmpty) {
          // 2. Open PhonePe Hosted Checkout in WebView
          final result = await Get.to<bool?>(() => PaymentWebViewPage(url: redirectUrl));
          
          // 3. Verify Payment
          await _verifyTransaction(orderId, merchantTxnId);
        } else {
          Get.snackbar("Error", "Payment redirect URL is empty.",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", response?['message'] ?? "Failed to initiate payment",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Payment initiation error: $e');
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _verifyTransaction(int orderId, String merchantTransactionId) async {
    try {
      // Show loading indicator during verification
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.black)),
        barrierDismissible: false,
      );

      final verifyResponse = await repository.verifyPhonePePayment(
        orderId: orderId,
        merchantTransactionId: merchantTransactionId,
      );

      // Close loading dialog
      Get.back();

      if (verifyResponse != null && verifyResponse['success'] == true) {
        // Close the Cart screen BEFORE showing the success popup
        Get.back(); 

        // Show success dialog
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text("Payment Successful", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              verifyResponse['message'] ?? "Your payment has been successfully verified and the order is being processed.",
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Done"),
              ),
            ],
          ),
          barrierDismissible: false, // Force user to press Done
        );
      } else {
        Get.snackbar("Verification Failed", verifyResponse?['message'] ?? "Could not verify payment.",
            backgroundColor: Colors.red.shade600, colorText: Colors.white, duration: const Duration(seconds: 4));
      }
    } catch (e) {
      Get.back(); // Ensure loader closes on exception
      Get.snackbar("Error", "Payment verification error: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
