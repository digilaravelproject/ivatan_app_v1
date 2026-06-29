import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/app_urls.dart';
import '../model/order_model.dart';
import 'controller/seller_order_detail_controller.dart';

class SellerOrderDetailScreen extends StatelessWidget {
  final int orderId;

  const SellerOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerOrderDetailController(orderId: orderId), tag: orderId.toString());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Received Order Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.black),
          );
        }

        final order = controller.order.value;
        if (order == null) {
          return const Center(child: Text("Order not found"));
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchOrderDetails(),
          color: AppColors.black,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: 24),
                _buildBuyerDetails(order),
                const SizedBox(height: 24),
                _buildOrderItems(order.items ?? []),
                const SizedBox(height: 24),
                _buildPaymentSummary(order),
                const SizedBox(height: 40),
              ],
            ),
          ),
          );
      //  );
      }),
      bottomNavigationBar: Obx(() {
        final order = controller.order.value;
        if (order == null || controller.isLoading.value) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _showStatusUpdateBottomSheet(context, controller, order.status ?? 'pending'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("UPDATE STATUS", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order #${order.id}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                order.createdAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt!) : '',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          _buildStatusChip(order.status ?? 'pending'),
        ],
      ),
    );
  }

  Widget _buildBuyerDetails(OrderModel order) {
    if (order.buyer == null && order.address == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Buyer Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.buyer != null) ...[
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: order.buyer!.profilePhotoPath != null
                          ? Image.network(AppUrls.getFullImageUrl(order.buyer!.profilePhotoPath!), fit: BoxFit.cover)
                          : const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.buyer!.name ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (order.buyer!.phone != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  order.buyer!.phone!,
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                          if (order.buyer!.email != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  order.buyer!.email!,
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 16),
              ],
              if (order.address != null) ...[
                const Text(
                  "Shipping Address",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  order.address!.name ?? (order.buyer?.name ?? ''),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "${order.address!.addressLine1}${order.address!.addressLine2 != null ? ', ${order.address!.addressLine2}' : ''}",
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                ),
                Text(
                  "${order.address!.city}, ${order.address!.state} - ${order.address!.postalCode}",
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                ),
                if (order.address!.phone != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        order.address!.phone!,
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ],
              if (order.address == null && order.buyer == null)
                const Text("No buyer details available"),
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
          "Ordered Items (${items.length})",
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.image != null
                  ? Image.network(
                      AppUrls.getFullImageUrl(item.image),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                    )
                  : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? "Product #${item.itemId}",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${double.tryParse(item.price ?? '0')?.toStringAsFixed(0)}",
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Qty: ${item.quantity}",
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSummaryRow("Payment Status", (order.paymentStatus ?? 'pending').toUpperCase(), 
                  isGreen: order.paymentStatus?.toLowerCase() == 'paid'),
              const Divider(height: 24),
              _buildSummaryRow("Total Amount", "₹${double.tryParse(order.totalAmount ?? '0')?.toStringAsFixed(0)}", 
                  isBold: true, fontSize: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, double fontSize = 14, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: fontSize,
              color: isGreen ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'accepted': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      case 'shipped': color = Colors.purple; break;
      case 'delivered': color = Colors.blue; break;
      case 'cancelled': color = Colors.grey; break;
      default: color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showStatusUpdateBottomSheet(BuildContext context, SellerOrderDetailController controller, String currentStatus) {
    final List<String> statuses = ['accepted', 'rejected', 'processing','paid','shipped', 'delivered', 'cancelled',];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          child: Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20 + MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Update Order Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              ...statuses.map((status) => ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                title: Text(
                  status.capitalizeFirst!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: status == currentStatus ? FontWeight.bold : FontWeight.normal,
                    color: status == currentStatus ? AppColors.black : Colors.black87,
                  ),
                ),
                trailing: status == currentStatus 
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  : null,
                onTap: () {
                  Get.back();
                  if (status != currentStatus) {
                    _showConfirmationDialog(context, controller, status);
                  }
                },
              )),
            //  const SizedBox(height: 20),
            ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, SellerOrderDetailController controller, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Confirm Update", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to update the order status to ${status.toUpperCase()}?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.updateOrderStatus(status);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text("Yes, Update"),
            ),
          ],
        );
      },
    );
  }
}
