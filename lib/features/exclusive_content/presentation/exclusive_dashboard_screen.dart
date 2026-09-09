import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/exclusive_controller.dart';
import 'creator_dashboard_view.dart';

class ExclusiveDashboardScreen extends StatefulWidget {
  const ExclusiveDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ExclusiveDashboardScreen> createState() => _ExclusiveDashboardScreenState();
}

class _ExclusiveDashboardScreenState extends State<ExclusiveDashboardScreen> {
  final ExclusiveController controller = Get.put(ExclusiveController());

  @override
  void initState() {
    super.initState();
    controller.checkEnablementStatus().then((_) {
      if (controller.enablementStatus.value == 'active') {
        controller.fetchWalletBalance();
        controller.fetchTransactions(isRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exclusive Content", style: TextStyle(color: AppColors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.enablementStatus.value == 'not_requested') {
          return const Center(child: CircularProgressIndicator());
        }

        // 1. If fully approved/active AND payment was successful (or no fee required):
        if (controller.isFullyActive && (controller.isPaymentSuccessful || controller.feePaid.value == 0)) {
          return _buildActiveState();
        }

        // 2. If payment is successful AND request is pending admin review:
        if (controller.enablementStatus.value == 'pending' && controller.isPaymentSuccessful) {
          return _buildPendingReviewState();
        }

        // 3. In all other cases (payment not yet made, payment failed, cancelled, or not yet succeeded):
        // UNTIL PAYMENT IS SUCCESSFUL, SHOW THE PAYMENT SCREEN!
        return _buildPaymentScreen();
      }),
    );
  }

  Widget _buildPaymentScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              "Become an Exclusive Creator",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Monetize your premium content by locking posts and reels. Followers will need to purchase access to view them.",
              style: TextStyle(fontSize: 16, color: AppColors.premiumGold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "Note: A setup fee is required to enable this feature. You will be redirected to the payment gateway to complete payment.",
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
            Obx(() {
              if (controller.paymentStatus.value == 'failed') {
                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Payment failed. Please complete the payment to proceed.",
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (controller.paymentStatus.value == 'cancelled') {
                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Payment was cancelled. Please complete payment to enable exclusive content.",
                          style: TextStyle(color: Colors.orange, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 30),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () {
                controller.requestEnablement();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.blue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading.value 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)
                    )
                  : Text(
                      controller.paymentStatus.value == 'failed' || controller.paymentStatus.value == 'cancelled'
                          ? "Retry Payment & Request"
                          : "Pay & Request Enablement", 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingReviewState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Payment Successful",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "Your payment was received successfully! Your request is being reviewed by the admin. Please check back later.",
              style: TextStyle(fontSize: 16, color: AppColors.premiumGold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                controller.checkEnablementStatus();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                backgroundColor: AppColors.cardSurface,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Check Status"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveState() {
    return const CreatorDashboardView();
  }
}
