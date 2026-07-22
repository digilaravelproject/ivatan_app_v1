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
        title: const Text("All Spotlight Content", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
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
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                              ? Image.network(item.thumbnailUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey.shade200))
                              : Container(color: Colors.grey.shade200),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
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
                          style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.visibility_outlined, color: Colors.grey, size: 12),
                                const SizedBox(width: 4),
                                Text(formatNumber.format(item.viewsCount), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.shopping_cart_outlined, color: Colors.grey, size: 12),
                                const SizedBox(width: 4),
                                Text(formatNumber.format(item.purchasesCount), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(formatCurrency.format(item.price), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12)),
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
