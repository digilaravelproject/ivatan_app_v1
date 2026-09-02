import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/app_urls.dart';
import '../model/order_model.dart';
import 'controller/order_detail_controller.dart';

class OrderDetailScreen extends StatelessWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      OrderDetailController(orderId: orderId),
      tag: orderId.toString(),
    );

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.white),
          );
        }

        final order = controller.order.value;
        if (order == null) {
          return const Center(child: Text("Order not found"));
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchOrderDetails(),
          color: AppColors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: 24),
                _buildShippingAddress(order.address),
                const SizedBox(height: 24),
                _buildOrderItems(order.items ?? []),
                const SizedBox(height: 24),
                _buildPaymentSummary(order),
                const SizedBox(height: 24),
                _buildTimeline(order.status ?? 'pending'),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.premiumGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.premiumGold),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #${order.id}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.createdAt != null
                        ? DateFormat(
                          'dd MMM yyyy, hh:mm a',
                        ).format(order.createdAt!)
                        : '',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.premiumGold,
                    ),
                  ),
                ],
              ),
              _buildStatusChip(order.status ?? 'pending'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(AddressDetail? address) {
    if (address == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Shipping Address",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.black,
            border: Border.all(color: AppColors.premiumGold),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address.name ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${address.addressLine1}${address.addressLine2 != null ? ', ${address.addressLine2}' : ''}",
                style: TextStyle(color: AppColors.premiumGold, fontSize: 13),
              ),
              Text(
                "${address.city}, ${address.state} - ${address.postalCode}",
                style: TextStyle(color: AppColors.premiumGold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: AppColors.premiumGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    address.phone ?? '',
                    style: TextStyle(
                      color: AppColors.premiumGold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(List<OrderItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order Items (${items.length})",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildItemTile(item)),
      ],
    );
  }

  Widget _buildItemTile(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.premiumGold),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.premiumGold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  item.image != null
                      ? Image.network(
                        AppUrls.getFullImageUrl(item.image),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.broken_image,
                              color: AppColors.black,
                            ),
                      )
                      : const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.black,
                      ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? "Product ID: ${item.itemId}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${double.tryParse(item.price ?? '0')?.toStringAsFixed(0)} × ${item.quantity}",
                  style: TextStyle(color: AppColors.premiumGold, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            "₹${(double.parse(item.price ?? '0') * (item.quantity ?? 1)).toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.black,
            border: Border.all(color: AppColors.premiumGold),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                "Payment Method",
                order.payment?.gateway?.toUpperCase() ?? 'N/A',
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                "Subtotal",
                "₹${double.tryParse(order.totalAmount ?? '0')?.toStringAsFixed(0)}",
              ),
              _buildSummaryRow("Shipping Fee", "₹0", isGreen: true),
              const Divider(height: 24),
              _buildSummaryRow(
                "Total Amount",
                "₹${double.tryParse(order.totalAmount ?? '0')?.toStringAsFixed(0)}",
                isBold: true,
                fontSize: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 14,
    bool isGreen = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.premiumGold, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: fontSize,
              color: isGreen ? Colors.green : AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final statuses = [
      {
        "status": "pending",
        "title": "Order Placed",
        "subtitle": "Your order has been placed",
      },
      {
        "status": "processing",
        "title": "Processing",
        "subtitle": "We are preparing your order",
      },
      {
        "status": "shipped",
        "title": "Shipped",
        "subtitle": "Your order is on the way",
      },
      {
        "status": "delivered",
        "title": "Delivered",
        "subtitle": "Order delivered successfully",
      },
    ];

    int currentIdx = 0;
    if (currentStatus.toLowerCase() == 'processing') currentIdx = 1;
    if (currentStatus.toLowerCase() == 'shipped') currentIdx = 2;
    if (currentStatus.toLowerCase() == 'delivered') currentIdx = 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Order Tracking",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...List.generate(statuses.length, (index) {
          final isCompleted = index <= currentIdx;
          final isLast = index == statuses.length - 1;
          return _buildTimelineItem(
            title: statuses[index]["title"]!,
            subtitle: statuses[index]["subtitle"]!,
            isCompleted: isCompleted,
            isLast: isLast,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : AppColors.premiumGold,
                shape: BoxShape.circle,
              ),
              child:
                  isCompleted
                      ? const Icon(
                        Icons.check,
                        color: AppColors.white,
                        size: 16,
                      )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.success : AppColors.premiumGold,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? AppColors.white : AppColors.premiumGold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: AppColors.premiumGold),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'shipped':
        color = Colors.purple;
        break;
      case 'delivered':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = AppColors.premiumGold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.capitalizeFirst!,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
