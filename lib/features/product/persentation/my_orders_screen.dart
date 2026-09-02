import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/app_urls.dart';
import 'controller/my_orders_controller.dart';
import 'order_detail_screen.dart';
import '../model/order_model.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final MyOrdersController controller = Get.put(MyOrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.black),
          );
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: AppColors.premiumGold,
                ),
                const SizedBox(height: 16),
                Text(
                  "No orders yet",
                  style: TextStyle(fontSize: 18, color: AppColors.premiumGold),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refreshOrders(),
          color: AppColors.black,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderCard(order, context);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(OrderModel order, BuildContext context) {
    // For now, take details from the first item if available
    final firstItem =
        order.items != null && order.items!.isNotEmpty
            ? order.items!.first
            : null;

    return GestureDetector(
      onTap: () {
        if (order.id != null) {
          Get.to(() => OrderDetailScreen(orderId: order.id!));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.black,
          border: Border.all(color: AppColors.premiumGold),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.premiumGold.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Order Header with Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                //  color: AppColors.premiumGold.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order #${order.id}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.createdAt != null
                              ? DateFormat(
                                'dd MMM yyyy, hh:mm a',
                              ).format(order.createdAt!)
                              : '',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.premiumGold,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusChip(order.status ?? 'pending'),
                  ],
                ),
              ),

              // Divider(color: AppColors.premiumGold),

              // Order Items
              if (order.items != null)
                ...order.items!.map((item) => _buildOrderItemTile(item)),

              // Order Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.premiumGold)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${order.items?.length ?? 0} Item${(order.items?.length ?? 0) > 1 ? 's' : ''}",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.premiumGold,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Total: ",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.premiumGold,
                            ),
                          ),
                          TextSpan(
                            text:
                                "₹${double.tryParse(order.totalAmount ?? '0')?.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItemTile(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Item Image Placeholder or Actual
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.premiumGold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  item.image != null
                      ? Image.network(
                        AppUrls.getFullImageUrl(item.image),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.black,
                            ),
                      )
                      : const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.black,
                        size: 30,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Quantity: ${item.quantity}",
                  style: TextStyle(fontSize: 12, color: AppColors.premiumGold),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${double.tryParse(item.price ?? '0')?.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          // _buildStatusChip(item.status ?? 'pending'),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text = status.capitalizeFirst ?? status;

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
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Remove the old OrderDetailScreen as we aren't using deep click yet
