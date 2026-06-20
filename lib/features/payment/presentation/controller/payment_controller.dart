import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/payment_webview_page.dart';
import '../../data/repository/payment_repository.dart';
import '../../../../core/network/api_services.dart';
import '../../../../core/network/app_urls.dart';

class PaymentController extends GetxController {
  final PaymentRepository repository = Get.put(PaymentRepositoryImpl());

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> initiatePayment(int orderId) async {
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
          
          if (result == true) {
            // 3. Verify Payment
            await _verifyTransaction(orderId, merchantTxnId);
          } else if (result == false) {
            Get.snackbar("Payment Failed", "Your payment failed or was cancelled on PhonePe. Please try again.",
                backgroundColor: Colors.red, colorText: Colors.white);
          } else {
            // result is null (e.g. user closed WebView)
            // Call verify transaction as a safety check in case the webhook processed it or they did pay.
            await _verifyTransaction(orderId, merchantTxnId);
          }
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

      bool isVerified = false;
      String message = "Your payment has been successfully verified and the order is being processed.";

      if (verifyResponse != null && verifyResponse['success'] == true) {
        isVerified = true;
        message = verifyResponse['message'] ?? message;
      } else {
        // Fallback: Query the order details to fetch the final status
        try {
          final apiServices = Get.find<ApiServices>();
          final orderResponse = await apiServices.callGet(AppUrls.orderDetail(orderId));
          if (orderResponse != null && orderResponse['success'] == true) {
            final orderData = orderResponse['order'];
            if (orderData != null && orderData['payment_status'] == 'paid') {
              isVerified = true;
              message = "Payment verified via order status. Order is being processed.";
            }
          }
        } catch (e) {
          debugPrint("Failed to fetch order status fallback: $e");
        }
      }

      if (isVerified) {
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
              message,
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
