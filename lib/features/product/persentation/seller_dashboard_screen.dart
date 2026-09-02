import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/product/persentation/transcation_history_screen.dart';
import 'package:i_vatan_app/features/product/persentation/controller/seller_dashboard_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../db/shared_pref_manager.dart';
import 'bank_details_screen.dart';
import 'controller/order_history_screen.dart';


class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerDashboardController());
    
    // Static data (can keep for now or remove if not used elsewhere)
    final recentOrders = [
      {
        'id': 'ORD001',
        'customer': 'Ramesh Gupta',
        'amount': 450.0,
      },
      {
        'id': 'ORD002',
        'customer': 'Sita Sharma',
        'amount': 1250.0,
      },
      {
        'id': 'ORD003',
        'customer': 'Rahul Yadav',
        'amount': 780.0,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        title: const Text('Seller Dashboard', style: TextStyle(color: AppColors.white)),
      ),
      body: RefreshIndicator(color: AppColors.white, 
        onRefresh: () => controller.fetchDashboardStats(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    border: Border.all(color: AppColors.premiumGold),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome back,',
                                style: TextStyle(color: AppColors.white, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('${SharedPrefManager().user?.username} 👋',
                                style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('${SharedPrefManager().user?.occupation}',
                                style: TextStyle(color: AppColors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.premiumGold.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storefront, color: AppColors.premiumGold, size: 32),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
  
              // Stats Grid
              const Text(
                'Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
              const SizedBox(height: 16),
          Obx(() => GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Total Products',
                controller.totalProducts.value.toString(),
                Icons.inventory,
                Colors.blue,
              ),
              _buildStatCard(
                'Total Orders',
                controller.totalOrders.value.toString(),
                Icons.shopping_cart,
                Colors.green,
              ),
              _buildStatCard(
                'Total Earnings',
                '₹${controller.totalRevenue.value.toStringAsFixed(0)}',
                Icons.currency_rupee,
                Colors.orange,
              ),
              _buildStatCard(
                'Pending Orders',
                controller.pendingOrders.value.toString(),
                Icons.pending_actions,
                Colors.red,
              ),
            ],
          )),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _actionButton('Orders', Icons.list_alt, Colors.blue,
                          () {Get.to(OrdersScreen());},
                    )),
                const SizedBox(width: 12),
                Expanded(
                    child: _actionButton('Bank', Icons.account_balance, Colors.green,
                          () {Get.to(BankDetailsScreen());},)),
                const SizedBox(width: 12),
                Expanded(
                    child: _actionButton('History', Icons.history, Colors.orange,
                          () {Get.to(TransactionHistoryScreen());},)),
              ],
            ),
            const SizedBox(height: 16),

            // Recent Orders
           /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Orders',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            //const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentOrders.length,
              itemBuilder: (context, index) {
                final order = recentOrders[index];
                return _recentOrderCard(order);
              },
            ),*/
          ],
        ),
      ),
      )
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.black,
        border: Border.all(color: AppColors.premiumGold.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.premiumGold.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color,VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.black,
          border: Border.all(color: AppColors.premiumGold.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.premiumGold,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.white)),
          ],
        ),
      ),
    );
  }

  Widget _recentOrderCard(Map order) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.black,
          border: Border.all(color: AppColors.premiumGold.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.premiumGold,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.receipt, color: Colors.blue.shade400, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order['id'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(order['customer'],
                      style: TextStyle(fontSize: 12, color: AppColors.premiumGold)),
                ],
              ),
            ),
            Text('₹${order['amount'].toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}







class SellerDashboard1 extends StatelessWidget {
  const SellerDashboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seller Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller Profile Section
            _buildSellerProfile(),
            const SizedBox(height: 20),

            // Stats Cards
            _buildStatsGrid(),
            const SizedBox(height: 25),

            // Sales Chart Header
            const Text(
              'Sales Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Sales Chart
            _buildSalesChart(),
            const SizedBox(height: 25),

            // Recent Orders Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Recent Orders List
            _buildRecentOrders(),
            const SizedBox(height: 25),

            // Top Products Header
            const Text(
              'Top Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Top Products List
            _buildTopProducts(),
          ],
        ),
      ),
    );
  }

  // Seller Profile Widget
  Widget _buildSellerProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.transparent,
            backgroundImage: NetworkImage(
              'https://via.placeholder.com/150', // Replace with actual image URL
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'John\'s Store',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since Jan 2024',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.8 (250 reviews)',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 12,
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

  // Stats Grid Widget
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Products',
          '156',
          Icons.inventory,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Orders',
          '1,234',
          Icons.shopping_cart,
          Colors.green,
        ),
        _buildStatCard(
          'Total Earnings',
          '₹45,678',
          Icons.currency_rupee,
          Colors.orange,
        ),
        _buildStatCard(
          'Pending Orders',
          '23',
          Icons.pending_actions,
          Colors.red,
        ),
      ],
    );
  }

  // Individual Stat Card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.black,
        border: Border.all(color: AppColors.premiumGold.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.premiumGold.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sales Chart Widget
  Widget _buildSalesChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.black,
        border: Border.all(color: AppColors.premiumGold.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Sales',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.premiumGold.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '+12.5%',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartBar('Mon', 40, Colors.blue),
                _buildChartBar('Tue', 60, Colors.blue),
                _buildChartBar('Wed', 45, Colors.blue),
                _buildChartBar('Thu', 80, Colors.blue),
                _buildChartBar('Fri', 70, Colors.blue),
                _buildChartBar('Sat', 90, Colors.blue),
                _buildChartBar('Sun', 55, Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Individual Chart Bar
  Widget _buildChartBar(String day, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 25,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // Recent Orders Widget
  Widget _buildRecentOrders() {
    final orders = [
      {'customer': 'Rajesh Kumar', 'amount': '₹1,299', 'status': 'Delivered', 'items': 3},
      {'customer': 'Priya Singh', 'amount': '₹2,499', 'status': 'Processing', 'items': 2},
      {'customer': 'Amit Patel', 'amount': '₹899', 'status': 'Shipped', 'items': 1},
      {'customer': 'Neha Gupta', 'amount': '₹3,599', 'status': 'Pending', 'items': 4},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.premiumGold.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'customer',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order['items']} items • ${order['amount']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.premiumGold.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.premiumGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'status',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Status Color Helper
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Processing':
        return Colors.orange;
      case 'Shipped':
        return Colors.blue;
      case 'Pending':
        return Colors.red;
      default:
        return AppColors.premiumGold;
    }
  }

  // Top Products Widget
  Widget _buildTopProducts() {
    final products = [
      {'name': 'Wireless Headphones', 'sales': '234 sold', 'revenue': '₹46,800', 'trend': '+15%'},
      {'name': 'Smart Watch', 'sales': '189 sold', 'revenue': '₹56,700', 'trend': '+8%'},
      {'name': 'Phone Case', 'sales': '156 sold', 'revenue': '₹7,800', 'trend': '+22%'},
      {'name': 'Power Bank', 'sales': '98 sold', 'revenue': '₹19,600', 'trend': '+5%'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.premiumGold.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          product['sales']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.premiumGold.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.premiumGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product['revenue']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.premiumGold.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  product['trend']!,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
