import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/creator_dashboard_controller.dart';
import '../data/model/exclusive_content_item_model.dart';
import '../data/model/exclusive_stats_model.dart';
import 'spotlight_all_screen.dart';

class CreatorDashboardView extends StatefulWidget {
  const CreatorDashboardView({Key? key}) : super(key: key);

  @override
  State<CreatorDashboardView> createState() => _CreatorDashboardViewState();
}

class _CreatorDashboardViewState extends State<CreatorDashboardView> {
  final CreatorDashboardController controller = Get.put(CreatorDashboardController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        controller.fetchExclusiveContent();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: AppColors.premiumGold.withOpacity(0.1),
        appBarTheme: AppBarTheme(backgroundColor: AppColors.premiumGold.withOpacity(0.1), elevation: 0),
        cardColor: const Color(0xFFFFFFFF),
      ),
      child: Scaffold(
        backgroundColor: AppColors.premiumGold.withOpacity(0.1),
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchDashboardStats();
            await controller.fetchExclusiveContent(isRefresh: true);
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _buildDateDropdown(),
                      const SizedBox(width: 10),
                      Obx(() => _buildDateRangeDisplay(controller.dateFrom.value, controller.dateTo.value)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoadingStats.value && controller.stats.value == null) {
                    return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                  }
                  if (controller.stats.value == null) {
                    return const SizedBox();
                  }
                  return _buildOverview(controller.stats.value!.globalStats);
                }),
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.stats.value == null) return const SizedBox();
                  return _buildSpotlight(controller.stats.value!.spotlight);
                }),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Top Performing Content",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
                      Row(
                        children: [
                          Obx(() => DropdownButton<String>(
                            value: controller.selectedSortBy.value,
                            dropdownColor: const Color(0xFFF5F5F5),
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.premiumGold),
                            style: const TextStyle(color: AppColors.premiumGold, fontSize: 12),
                            onChanged: (val) {
                              if (val != null) controller.onSortChange(val);
                            },
                            items: const [
                              DropdownMenuItem(value: 'earnings', child: Text('Sort: Earnings')),
                              DropdownMenuItem(value: 'views', child: Text('Sort: Views')),
                              DropdownMenuItem(value: 'purchases', child: Text('Sort: Purchases')),
                            ],
                          )),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.premiumGold),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.filter_alt_outlined, color: AppColors.premiumGold, size: 16),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == controller.contentItems.length) {
                        return controller.hasMoreContent.value
                            ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                            : const SizedBox(height: 80);
                      }
                      return _buildContentItem(controller.contentItems[index]);
                    },
                    childCount: controller.contentItems.length + 1,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: AppColors.premiumGold),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(() => DropdownButton<String>(
        value: controller.selectedDateRangeLabel.value,
        dropdownColor: const Color(0xFFF5F5F5),
        isDense: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 18),
        style: const TextStyle(color: AppColors.white, fontSize: 13),
        onChanged: (val) {
          if (val != null) controller.applyFilter(dateRange: val);
        },
        items: const [
          DropdownMenuItem(value: 'This Month', child: Text('This Month')),
          DropdownMenuItem(value: 'All Time', child: Text('All Time')),
        ],
      )),
    );
  }

  Widget _buildDateRangeDisplay(String? from, String? to) {
    if (from == null || to == null) return const SizedBox();
    try {
      final f = DateFormat('yyyy-MM-dd');
      final dFrom = f.parse(from);
      final dTo = f.parse(to);
      final formatter = DateFormat('MMM dd, yyyy');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          border: Border.all(color: AppColors.premiumGold),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.premiumGold, size: 14),
            const SizedBox(width: 8),
            Text(
              "${formatter.format(dFrom)} - ${formatter.format(dTo)}",
              style: const TextStyle(color: AppColors.premiumGold, fontSize: 12),
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  Widget _buildOverview(GlobalStats stats) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final formatNumber = NumberFormat.compact();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildOverviewCard(Icons.visibility_outlined, "Total Views", formatNumber.format(stats.totalViews))),
              const SizedBox(width: 12),
              Expanded(child: _buildOverviewCard(Icons.monetization_on_outlined, "Total Earnings", formatCurrency.format(stats.totalEarnings))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildOverviewCard(Icons.shopping_cart_outlined, "Total Purchases", formatNumber.format(stats.totalPurchases))),
              const SizedBox(width: 12),
              Expanded(child: _buildOverviewCard(Icons.insert_drive_file_outlined, "Total Content", formatNumber.format(stats.totalExclusiveContent))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [BoxShadow(color: AppColors.white.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.premiumGold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSpotlight(List<SpotlightItem> spotlight) {
    if (spotlight.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Spotlight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
                InkWell(
                  onTap: () {
                    Get.to(() => SpotlightAllScreen());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text("View All >", style: TextStyle(fontSize: 12, color: Colors.blue)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: spotlight.length,
              itemBuilder: (context, index) {
                return _buildSpotlightCard("Featured", spotlight[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightCard(String label, SpotlightItem item) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final formatNumber = NumberFormat.compact();
    
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [BoxShadow(color: AppColors.white.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: item.thumbnailUrl.isNotEmpty
                    ? Image.network(item.thumbnailUrl, height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 120, color: AppColors.premiumGold))
                    : Container(height: 120, color: AppColors.premiumGold),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(label, style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  item.type == 'video' ? Icons.play_circle_fill : item.type == 'reel' ? Icons.movie : Icons.image,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.visibility_outlined, color: AppColors.premiumGold, size: 14),
                    const SizedBox(width: 4),
                    Text("${formatNumber.format(item.viewsCount)} Views", style: const TextStyle(color: AppColors.premiumGold, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: AppColors.premiumGold, size: 14),
                    const SizedBox(width: 4),
                    Text("${formatNumber.format(item.purchasesCount)} Purchases", style: const TextStyle(color: AppColors.premiumGold, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.monetization_on_outlined, color: AppColors.premiumGold, size: 14),
                    const SizedBox(width: 4),
                    Text("${formatCurrency.format(item.totalEarnings)} Earnings", style: const TextStyle(color: AppColors.premiumGold, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(formatCurrency.format(item.price), style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentItem(ExclusiveContentItemModel item) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final formatNumber = NumberFormat.compact();
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    String dateStr = '';
    try {
      dateStr = formatter.format(DateTime.parse(item.createdAt));
    } catch (e) {
      dateStr = item.createdAt;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [BoxShadow(color: AppColors.white.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.thumbnailUrl.isNotEmpty
                ? Image.network(item.thumbnailUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 60, height: 60, color: AppColors.premiumGold))
                : Container(width: 60, height: 60, color: AppColors.premiumGold),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(formatCurrency.format(item.price), style: const TextStyle(color: AppColors.white, fontSize: 11)),
                    const Text("•", style: TextStyle(color: AppColors.white, fontSize: 11)),
                    Text(dateStr, style: const TextStyle(color: AppColors.white, fontSize: 11)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.premiumGold, borderRadius: BorderRadius.circular(4)),
                      child: Text(item.type.capitalizeFirst ?? item.type, style: const TextStyle(color: AppColors.white, fontSize: 9)),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Stats Columns
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Views", style: TextStyle(color: AppColors.white, fontSize: 10)),
              const SizedBox(height: 2),
              Text(formatNumber.format(item.totalViews), style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Purchases", style: TextStyle(color: AppColors.white, fontSize: 10)),
              const SizedBox(height: 2),
              Text(formatNumber.format(item.totalPurchaseCount), style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Earnings", style: TextStyle(color: AppColors.white, fontSize: 10)),
              const SizedBox(height: 2),
              Text(formatCurrency.format(item.totalEarnings), style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
