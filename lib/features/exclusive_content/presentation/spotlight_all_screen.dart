import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/creator_dashboard_controller.dart';
import '../data/model/exclusive_stats_model.dart';

class SpotlightAllScreen extends StatelessWidget {
  const SpotlightAllScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CreatorDashboardController controller = Get.find<CreatorDashboardController>();
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final formatNumber = NumberFormat.compact();

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Spotlight Content", style: TextStyle(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.white),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.stats.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final spotlightList = controller.stats.value!.spotlight;

        if (spotlightList.isEmpty) {
          return const Center(child: Text("No spotlight content available."));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: spotlightList.length,
          itemBuilder: (context, index) {
            final item = spotlightList[index];
            String label = "";
            if (item.type == 'reel') label = 'Reel';
            else if (item.type == 'video') label = 'Video';
            else label = 'Post';

            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.premiumGold),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.white.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: item.thumbnailUrl.isNotEmpty
                              ? Image.network(item.thumbnailUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: AppColors.premiumGold))
                              : Container(color: AppColors.premiumGold),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.visibility_outlined, color: AppColors.premiumGold, size: 12),
                                const SizedBox(width: 4),
                                Text(formatNumber.format(item.viewsCount), style: TextStyle(color: AppColors.premiumGold, fontSize: 10)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.shopping_cart_outlined, color: AppColors.premiumGold, size: 12),
                                const SizedBox(width: 4),
                                Text(formatNumber.format(item.purchasesCount), style: TextStyle(color: AppColors.premiumGold, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.premiumGold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(formatCurrency.format(item.price), style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
