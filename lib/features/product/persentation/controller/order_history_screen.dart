import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';

enum OrderStatus { pending, accepted, completed }

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });
}

class Order {
  final String id;
  final String customerName;
  final String customerPhone;
  final String address;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String? notes;

  Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.notes,
  });
}

class OrdersController extends GetxController {
  // Single list of all orders
  var allOrders = <Order>[
    // Pending
    Order(
      id: "ORD1001",
      customerName: "Rahul Kumar",
      customerPhone: "9876543210",
      address: "MG Road, Bhopal",
      items: [
        OrderItem(productName: "Product A", quantity: 2, price: 500),
        OrderItem(productName: "Product B", quantity: 1, price: 300),
      ],
      totalAmount: 1300,
      status: OrderStatus.pending,
      notes: "Deliver between 10AM-12PM",
    ),
    // Accepted
    Order(
      id: "ORD1002",
      customerName: "Anjali Singh",
      customerPhone: "9123456780",
      address: "Indore City Center",
      items: [
        OrderItem(productName: "Product C", quantity: 1, price: 700),
      ],
      totalAmount: 700,
      status: OrderStatus.accepted,
    ),
    // Completed
    Order(
      id: "ORD1003",
      customerName: "Vikas Sharma",
      customerPhone: "9988776655",
      address: "Bhopal Airport Road",
      items: [
        OrderItem(productName: "Product D", quantity: 3, price: 200),
      ],
      totalAmount: 600,
      status: OrderStatus.completed,
    ),
  ].obs;

  // Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return allOrders.where((order) => order.status == status).toList();
  }

  // Accept order -> show snackbar only
  void acceptOrder(String orderId) {
    Get.snackbar(
      'Order Accepted',
      'Order $orderId has been accepted.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  // Reject order -> show snackbar only
  void rejectOrder(String orderId, {String reason = "No reason provided"}) {
    Get.snackbar(
      'Order Rejected',
      'Order $orderId rejected. Reason: $reason',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}




class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});

  final OrdersController controller = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Orders'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ordersList(OrderStatus.pending),
            _ordersList(OrderStatus.accepted),
            _ordersList(OrderStatus.completed),
          ],
        ),
      ),
    );
  }

  Widget _ordersList(OrderStatus status) {
    final orders = controller.getOrdersByStatus(status);
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _orderCard(order);
      },
    );
  }

  Widget _orderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ID + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.id,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(order.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Customer Info
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(order.customerName)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(order.customerPhone),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(order.address)),
                  ],
                ),
                const SizedBox(height: 12),
                // Items
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: order.items
                        .map(
                          (item) => Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.productName)),
                            Text('${item.quantity}x'),
                            const SizedBox(width: 8),
                            Text(
                                '₹${(item.price * item.quantity).toStringAsFixed(0)}'),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount',
                        style: TextStyle(color: Colors.grey.shade600)),
                    Text('₹${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (order.notes != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(child: Text(order.notes!)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (order.status == OrderStatus.pending)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.acceptOrder(order.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.rejectOrder(order.id);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
    }
  }
}