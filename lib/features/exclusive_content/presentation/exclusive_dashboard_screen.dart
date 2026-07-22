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
        title: const Text("Exclusive Content"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset Status for Testing",
            onPressed: () {
              controller.enablementStatus.value = 'not_requested';
              Get.snackbar("Debug", "Status reset to Not Requested for testing");
            },
          ),
        ],
      ),
      body: Obx(() {
        // Removed full screen circular progress indicator so button can show loading state

        if (controller.enablementStatus.value == 'pending') {
          return _buildPendingState();
        } else if (controller.enablementStatus.value == 'active' || controller.enablementStatus.value == 'approved') {
          return _buildActiveState();
        } else {
          return _buildNotRequestedState();
        }
      }),
    );
  }

  Widget _buildNotRequestedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              "Become an Exclusive Creator",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Monetize your premium content by locking posts and reels. Followers will need to purchase access to view them.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const Text(
              "Note: A one-time setup fee may be required to enable this feature. You will be redirected to the payment gateway.",
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () {
                controller.requestEnablement();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: controller.isLoading.value 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text("Pay & Request Enablement"),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingState() {
    return Center(
      child: Obx(() {
        final isPaymentFailed = controller.paymentStatus.value == 'failed';
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPaymentFailed ? Icons.error_outline : Icons.hourglass_bottom, 
              size: 80, 
              color: isPaymentFailed ? Colors.red : Colors.orange
            ),
            const SizedBox(height: 20),
            Text(
              isPaymentFailed ? "Payment Failed" : "Request Pending",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              isPaymentFailed 
                  ? "Your payment was not successful. Please try again to enable exclusive content."
                  : "Your request is being reviewed by the admin. Please check back later.",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (isPaymentFailed) ...[
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: controller.isLoading.value ? null : () {
                  controller.requestEnablement();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: controller.isLoading.value 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text("Retry Payment & Request"),
              ),
            ]
          ],
        );
      }),
    );
  }

  Widget _buildActiveState() {
    return const CreatorDashboardView();
  }
}
