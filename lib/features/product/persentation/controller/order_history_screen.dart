import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/app_urls.dart';
import '../../repository/order_repository.dart';
import '../../model/order_model.dart';
import '../../../product/data/repository/marketplace_repository.dart';
import '../../../../core/network/api_services.dart';
import '../seller_order_detail_screen.dart';

class SellerOrdersController extends GetxController {
  final OrderRepository repository = OrderRepositoryImpl();
  
  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  
  // Status filter: accepted, rejected, shipped, delivered, cancelled
  var selectedStatus = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders({int page = 1, bool isRefresh = false}) async {
    if (page == 1) {
      isLoading.value = true;
      // Clear orders to ensure loading state shows when switching filters
      orders.clear();
    } else {
      isMoreLoading.value = true;
    }

    try {
      final response = await repository.getSellerOrders(
        page: page, 
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value
      );
      
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data']['data'] ?? [];
        List<OrderModel> fetchedOrders = data.map((json) => OrderModel.fromJson(json)).toList();

        // Apply local filtering just in case the backend ignores the status parameter
        if (selectedStatus.value.isNotEmpty && selectedStatus.value != 'all') {
          fetchedOrders = fetchedOrders.where((order) {
            final orderStatus = order.status?.toLowerCase() ?? 'pending';
            return orderStatus == selectedStatus.value.toLowerCase();
          }).toList();
        }

        if (page == 1) {
          orders.assignAll(fetchedOrders);
        } else {
          orders.addAll(fetchedOrders);
        }

        currentPage.value = response['data']['current_page'] ?? 1;
        lastPage.value = response['data']['last_page'] ?? 1;

        // Automatically load more if we filtered out everything on this page but there are more pages
        if (fetchedOrders.isEmpty && currentPage.value < lastPage.value) {
          fetchOrders(page: currentPage.value + 1);
        }
      }
    } catch (e) {
      debugPrint('Error fetching seller orders: $e');
    } finally {
      // Only set loading to false if we aren't automatically fetching the next page
      if (currentPage.value >= lastPage.value || orders.isNotEmpty) {
        isLoading.value = false;
        isMoreLoading.value = false;
      }
    }
  }

  void loadMore() {
    if (currentPage.value < lastPage.value && !isMoreLoading.value) {
      fetchOrders(page: currentPage.value + 1);
    }
  }

  void updateFilter(String status) {
    if (selectedStatus.value != status) {
      selectedStatus.value = status;
      fetchOrders(page: 1);
    }
  }

  void refreshOrders() {
    fetchOrders(page: 1, isRefresh: true);
  }
}




class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final SellerOrdersController controller = Get.put(SellerOrdersController());
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text(
          'Orders History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.orders.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.black));
              }

              if (controller.orders.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async => controller.refreshOrders(),
                color: AppColors.black,
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.orders.length + (controller.isMoreLoading.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < controller.orders.length) {
                      final order = controller.orders[index];
                      return _orderCard(order);
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(color: AppColors.black, strokeWidth: 2)),
                      );
                    }
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ["all", "accepted", "rejected", "shipped", "delivered", "cancelled"];
    return Container(
      height: 60,
      width: double.infinity,
      color: AppColors.transparent,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Obx(() {
            bool isSelected = (controller.selectedStatus.value.isEmpty && filter == "all") || (controller.selectedStatus.value == filter);
            return GestureDetector(
              onTap: () {
                if (filter == "all") {
                  controller.updateFilter("");
                } else {
                  controller.updateFilter(filter);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.premiumGold : AppColors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.premiumGold),
                ),
                child: Center(
                  child: Text(
                    filter.capitalizeFirst!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.black : AppColors.white,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.premiumGold),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(fontSize: 16, color: AppColors.premiumGold),
          ),
          if (controller.selectedStatus.value.isNotEmpty)
            TextButton(
              onPressed: () => controller.updateFilter(controller.selectedStatus.value),
              child: const Text("Clear Filter", style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
    );
  }

  Widget _orderCard(OrderModel order) {
    return GestureDetector(
      onTap: () {
        if (order.id != null) {
          Get.to(() => SellerOrderDetailScreen(orderId: order.id!));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.premiumGold),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order.id}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.white),
                ),
                _statusBadge(order.status ?? 'pending'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.premiumGold,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: order.buyer?.profilePhotoPath != null
                      ? Image.network((AppUrls.imageurl+order.buyer!.profilePhotoPath!), fit: BoxFit.cover)
                      : Icon(Icons.person, color: AppColors.premiumGold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.buyer?.name ?? 'Unknown Buyer',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.white),
                      ),
                      Text(
                        order.buyer?.phone ?? '',
                        style: TextStyle(color: AppColors.premiumGold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${double.parse(order.totalAmount ?? '0').toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      order.createdAt != null ? DateFormat('dd MMM').format(order.createdAt!) : '',
                      style: TextStyle(color: AppColors.premiumGold, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            if (order.items != null && order.items!.isNotEmpty)
              ...order.items!.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.premiumGold, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title ?? "Product #${item.itemId}",
                        style: TextStyle(fontSize: 13, color: AppColors.premiumGold, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "x${item.quantity}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
      )
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'accepted': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      case 'shipped': color = Colors.purple; break;
      case 'delivered': color = Colors.blue; break;
      case 'cancelled': color = AppColors.premiumGold; break;
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













/*
if (order.status == OrderStatus.pending)
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
border: Border(
top: BorderSide(color: AppColors.premiumGold),
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
foregroundColor: AppColors.white,
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
),*/
