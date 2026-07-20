import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/exclusive_controller.dart';

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
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchWalletBalance();
        await controller.fetchTransactions(isRefresh: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text("Wallet Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    "₹${controller.walletBalance.value}",
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Exclusive Feature", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                Switch(
                  value: true, // We assume true if active, but would need a real field if toggleable
                  onChanged: (val) {
                    controller.toggleFeature(val);
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 20),

            // Transactions
            const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            if (controller.transactions.isEmpty && !controller.isLoading.value)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: Text("No transactions yet.", style: TextStyle(color: Colors.grey))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final tx = controller.transactions[index];
                  final isCredit = tx['type'] == 'credit';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCredit ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(
                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isCredit ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(tx['description'] ?? 'Transaction'),
                    subtitle: Text(tx['created_at'] != null ? tx['created_at'].toString().split('T')[0] : ''),
                    trailing: Text(
                      "${isCredit ? '+' : '-'}₹${tx['amount']}",
                      style: TextStyle(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
              if (controller.hasMoreTransactions.value)
                TextButton(
                  onPressed: () {
                    controller.fetchTransactions();
                  },
                  child: const Text("Load More"),
                ),
          ],
        ),
      ),
    );
  }
}
