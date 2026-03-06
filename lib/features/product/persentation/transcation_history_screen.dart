import 'package:flutter/material.dart';
import 'package:get/get.dart';


class TransactionModel {
  final String id;           // Transaction ID
  final String date;         // Date of transaction
  final String? time;        // Optional Time
  final double amount;       // Amount received
  final String status;       // Paid / Pending / Failed
  final String note;         // Description / Note
  final String paymentMethod; // Payment method (UPI, Bank, Admin Transfer etc.)

  TransactionModel({
    required this.id,
    required this.date,
    this.time,
    required this.amount,
    required this.status,
    required this.note,
    required this.paymentMethod,
  });
}

class TransactionController extends GetxController {
  var transactionList = <TransactionModel>[
    TransactionModel(
      id: "TXN1001",
      date: "20 Feb 2026",
      time: "10:30 AM",
      amount: 2500,
      status: "Paid",
      note: "Weekly Payout",
      paymentMethod: "Admin Transfer",
    ),
    TransactionModel(
      id: "TXN1002",
      date: "15 Feb 2026",
      time: "11:15 AM",
      amount: 1800,
      status: "Paid",
      note: "Product Sales Settlement",
      paymentMethod: "Bank Transfer",
    ),
    TransactionModel(
      id: "TXN1003",
      date: "10 Feb 2026",
      time: "02:45 PM",
      amount: 3200,
      status: "Paid",
      note: "Admin Transfer",
      paymentMethod: "UPI",
    ),
  ].obs;
}


class TransactionHistoryScreen extends StatelessWidget {
  TransactionHistoryScreen({super.key});

  final TransactionController controller = Get.put(TransactionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Obx(
            () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.transactionList.length,
          itemBuilder: (context, index) {
            final transaction = controller.transactionList[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.green,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.note,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${transaction.date} • ${transaction.time ?? ""}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "₹${transaction.amount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ID: ${transaction.id}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: transaction.status == "Paid"
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transaction.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: transaction.status == "Paid"
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Method: ${transaction.paymentMethod}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}