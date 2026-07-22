import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/creator_dashboard_controller.dart';
import '../data/model/exclusive_content_item_model.dart';
import '../data/model/exclusive_stats_model.dart';

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
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0A0A0A), elevation: 0),
        cardColor: const Color(0xFF141414),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Row(
                        children: [
                          Obx(() => DropdownButton<String>(
                            value: controller.selectedSortBy.value,
                            dropdownColor: const Color(0xFF1A1A1A),
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                              border: Border.all(color: Colors.grey.shade800),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.filter_alt_outlined, color: Colors.grey, size: 16),
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
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(() => DropdownButton<String>(
        value: controller.selectedDateRangeLabel.value,
        dropdownColor: const Color(0xFF1A1A1A),
        isDense: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
        style: const TextStyle(color: Colors.white, fontSize: 13),
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
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 14),
            const SizedBox(width: 8),
            Text(
              "${formatter.format(dFrom)} - ${formatter.format(dTo)}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
          const Text("Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
        color: const Color(0xFF141414),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSpotlight(SpotlightStats spotlight) {
    if (spotlight.mostViewed == null && spotlight.mostPurchased == null && spotlight.highestEarning == null) {
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
                const Text("Spotlight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("View All >", style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                if (spotlight.mostViewed != null) _buildSpotlightCard("Most Viewed", spotlight.mostViewed!),
                if (spotlight.mostPurchased != null) _buildSpotlightCard("Most Purchased", spotlight.mostPurchased!),
                if (spotlight.highestEarning != null) _buildSpotlightCard("Highest Earning", spotlight.highestEarning!),
              ],
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
        color: const Color(0xFF141414),
        border: Border.all(color: Colors.white10),
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
                    ? Image.network(item.thumbnailUrl, height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 120, color: Colors.grey.shade900))
                    : Container(height: 120, color: Colors.grey.shade900),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  item.type == 'video' ? Icons.play_circle_fill : item.type == 'reel' ? Icons.movie : Icons.image,
                  color: Colors.white,
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
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.visibility_outlined, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text("${formatNumber.format(item.viewsCount)} Views", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text("${formatNumber.format(item.purchasesCount)} Purchases", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.monetization_on_outlined, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text("${formatCurrency.format(item.totalEarnings)} Earnings", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(formatCurrency.format(item.price), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
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
        color: const Color(0xFF141414),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.thumbnailUrl.isNotEmpty
                ? Image.network(item.thumbnailUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 60, height: 60, color: Colors.grey.shade900))
                : Container(width: 60, height: 60, color: Colors.grey.shade900),
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
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(formatCurrency.format(item.price), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(width: 6),
                    const Text("•", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(width: 6),
                    Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                      child: Text(item.type.capitalizeFirst ?? item.type, style: const TextStyle(color: Colors.white70, fontSize: 9)),
                    )
                  ],
                ),
              ],
            ),
          ),
          // Stats Columns
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Views", style: TextStyle(color: Colors.grey, fontSize: 10)),
              const SizedBox(height: 2),
              Text(formatNumber.format(item.totalViews), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Purchases", style: TextStyle(color: Colors.grey, fontSize: 10)),
              const SizedBox(height: 2),
              Text(formatNumber.format(item.totalPurchaseCount), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Earnings", style: TextStyle(color: Colors.grey, fontSize: 10)),
              const SizedBox(height: 2),
              Text(formatCurrency.format(item.totalEarnings), style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
