import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class MyOrdersController extends GetxController {
  var orders = <OrderModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void fetchOrders() {
    isLoading.value = true;
    
    // TODO: API call to fetch orders
    Future.delayed(const Duration(seconds: 1), () {
      orders.value = [
        OrderModel(
          id: "ORD001",
          productName: "Wireless Headphones",
          productImage: "https://m.media-amazon.com/images/I/610ub5kytVL.jpg",
          price: 2999,
          quantity: 1,
          orderDate: DateTime.now().subtract(const Duration(days: 2)),
          status: OrderStatus.shipped,
        ),
        OrderModel(
          id: "ORD002",
          productName: "Smart Watch",
          productImage: "https://m.media-amazon.com/images/I/61ZjlBOp+rL._AC_UL320_.jpg",
          price: 4999,
          quantity: 2,
          orderDate: DateTime.now().subtract(const Duration(days: 5)),
          status: OrderStatus.delivered,
        ),
        OrderModel(
          id: "ORD003",
          productName: "Phone Case",
          productImage: "https://m.media-amazon.com/images/I/71GLMJ7TQiL._AC_UL320_.jpg",
          price: 499,
          quantity: 1,
          orderDate: DateTime.now().subtract(const Duration(hours: 5)),
          status: OrderStatus.processing,
        ),
      ];
      isLoading.value = false;
    });
  }
}

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrderModel {
  final String id;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final DateTime orderDate;
  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.orderDate,
    required this.status,
  });
}

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.black),
          );
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "No orders yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _buildOrderCard(order, context);
          },
        );
      }),
    );
  }

  Widget _buildOrderCard(OrderModel order, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => OrderDetailScreen(order: order));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.productImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Order ID: ${order.id}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${order.price.toStringAsFixed(0)} × ${order.quantity}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(order.orderDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  "Total: ₹${(order.price * order.quantity).toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = "Pending";
        break;
      case OrderStatus.processing:
        color = Colors.blue;
        text = "Processing";
        break;
      case OrderStatus.shipped:
        color = Colors.purple;
        text = "Shipped";
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        text = "Delivered";
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        text = "Cancelled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}

// Order Detail Screen with Timeline
class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.productImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Order ID: ${order.id}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₹${order.price.toStringAsFixed(0)} × ${order.quantity}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Order Status Timeline
            const Text(
              "Order Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildTimeline(order.status),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(OrderStatus currentStatus) {
    final statuses = [
      {"status": OrderStatus.pending, "title": "Order Placed", "subtitle": "Your order has been placed"},
      {"status": OrderStatus.processing, "title": "Processing", "subtitle": "We are preparing your order"},
      {"status": OrderStatus.shipped, "title": "Shipped", "subtitle": "Your order is on the way"},
      {"status": OrderStatus.delivered, "title": "Delivered", "subtitle": "Order delivered successfully"},
    ];

    return Column(
      children: List.generate(statuses.length, (index) {
        final statusData = statuses[index];
        final status = statusData["status"] as OrderStatus;
        final isCompleted = status.index <= currentStatus.index;
        final isLast = index == statuses.length - 1;

        return _buildTimelineItem(
          title: statusData["title"] as String,
          subtitle: statusData["subtitle"] as String,
          isCompleted: isCompleted,
          isLast: isLast,
        );
      }),
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
                color: isCompleted ? AppColors.success : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isCompleted ? AppColors.success : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.black : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
