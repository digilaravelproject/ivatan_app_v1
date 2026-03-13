import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../data/repository/payment_repository.dart';

class PaymentController extends GetxController {
  final PaymentRepository repository = Get.put(PaymentRepositoryImpl());
  late Razorpay _razorpay;
  int? _currentOrderId;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> initiatePayment(int orderId) async {
    _currentOrderId = orderId;
    try {
      // 1. Create Razorpay order on our backend
      final response = await repository.createRazorpayOrder(orderId: orderId);
      
      if (response != null && response['success'] == true) {
        final razorpayOrderId = response['razorpay_order_id'];
        final razorpayKey = response['razorpay_key'];
        final amount = response['amount']; // Expected to be in paise or String with decimal
        final currency = response['currency'] ?? "INR";
        
        // 2. Open Razorpay Checkout
        _openCheckout(
          key: razorpayKey,
          orderId: razorpayOrderId,
          amount: amount,
          currency: currency,
          description: "Payment for Order #$orderId",
        );
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

  void _openCheckout({
    required String key,
    required String orderId,
    required dynamic amount,
    required String currency,
    required String description,
  }) {
    final user = SharedPrefManager().user;
    
    var options = {
      'key': key,
      'amount': amount, // amount should be in paise
      'name': 'Ivatan',
      'order_id': orderId,
      'description': description,
      'prefill': {
        'contact': user?.phone ?? '',
        'email': user?.email ?? '',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentOrderId == null) {
      Get.snackbar("Warning", "Payment successful, but Order ID was lost.",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      // Show loading indicator during verification
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.black)),
        barrierDismissible: false,
      );

      final verifyResponse = await repository.verifyPayment(
        orderId: _currentOrderId!,
        razorpayOrderId: response.orderId ?? "",
        razorpayPaymentId: response.paymentId ?? "",
        razorpaySignature: response.signature ?? "",
      );

      // Close loading dialog
      Get.back();

      if (verifyResponse != null && verifyResponse['success'] == true) {
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
                  // Could optionally navigate back to dashboard/home here:
                  // Get.offAllNamed(Routes.DASHBOARD);
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

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar("Payment Failed", "Error: ${response.code} - ${response.message}",
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar("External Wallet Selected", "Wallet: ${response.walletName}",
        backgroundColor: Colors.blue, colorText: Colors.white);
  }
}
