import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/subscription_history_controller.dart';
import '../data/model/subscription_history_model.dart';

class SubscriptionHistoryScreen extends StatelessWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubscriptionHistoryController());

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(CupertinoIcons.back, color: AppColors.white),
        ),
        title: const Text(
          "Subscription History",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.historyList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.white),
          );
        }

        if (controller.hasError.value && controller.historyList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Failed to load subscription history",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.premiumGold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchSubscriptionHistory(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Retry",
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.historyList.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchSubscriptionHistory(),
            color: AppColors.white,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 64,
                        color: AppColors.premiumGold,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No Subscription History",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "You haven't subscribed to any profiles yet. Your active and past plans will appear here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.premiumGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchSubscriptionHistory(),
          color: AppColors.white,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.historyList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = controller.historyList[index];
              return _buildHistoryCard(context, item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildHistoryCard(BuildContext context, SubscriptionHistoryItem item) {
    final plan = item.plan;
    final profile = item.profile;

    final isActive = item.status.toLowerCase() == 'active';
    final isPending = item.status.toLowerCase() == 'pending';

    Color accentColor;
    Color statusBgColor;
    Color statusTextColor;

    if (isActive) {
      accentColor = const Color(0xFF10B981); // Green
      statusBgColor = const Color(0xFFD1FAE5);
      statusTextColor = const Color(0xFF065F46);
    } else if (isPending) {
      accentColor = const Color(0xFFF59E0B); // Amber
      statusBgColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFD97706);
    } else {
      accentColor = AppColors.premiumGold; // Grey / Cancelled
      statusBgColor = AppColors.premiumGold;
      statusTextColor = AppColors.premiumGold;
    }

    String startsDateStr = "";
    String endsDateStr = "";

    try {
      if (item.startsAt.isNotEmpty) {
        final startDt = DateTime.parse(item.startsAt);
        startsDateStr = DateFormat('MMM dd, yyyy').format(startDt.toLocal());
      }
      if (item.endsAt != null && item.endsAt!.isNotEmpty) {
        final endDt = DateTime.parse(item.endsAt!);
        endsDateStr = DateFormat('MMM dd, yyyy').format(endDt.toLocal());
      }
    } catch (e) {
      startsDateStr = item.startsAt;
      endsDateStr = item.endsAt ?? "";
    }

    final String planName = plan?.name ?? "Unknown Plan";
    final String priceStr =
        plan != null
            ? (plan.currency == 'INR'
                ? "₹${double.tryParse(plan.price)?.toStringAsFixed(0) ?? plan.price}"
                : "${plan.currency} ${plan.price}")
            : "Free";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.premiumGold),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: accentColor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: AppColors.premiumGold.withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(
                            _getProfileIcon(
                              profile?.type ?? plan?.profileType ?? '',
                            ),
                            size: 20,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getProfileLabel(
                              profile?.type ?? plan?.profileType ?? '',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.status.toUpperCase(),
                              style: TextStyle(
                                color: statusTextColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Plan Title and Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  planName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              Text(
                                priceStr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          if (plan?.description != null &&
                              plan!.description.isNotEmpty) ...[
                            Text(
                              plan.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.premiumGold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          const Divider(height: 1),
                          const SizedBox(height: 12),

                          // Dates and auto-renew details
                          _buildDetailRow(
                            Icons.calendar_today_outlined,
                            "Started At",
                            startsDateStr,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.event_busy_outlined,
                            "Ends At",
                            endsDateStr.isNotEmpty
                                ? endsDateStr
                                : "Lifetime (Auto-Renew)",
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.autorenew_rounded,
                            "Auto Renew",
                            item.autoRenew ? "Enabled" : "Disabled",
                          ),

                          if (item.gatewayOrderId != null &&
                              item.gatewayOrderId!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              Icons.receipt_long_outlined,
                              "Order ID",
                              item.gatewayOrderId!,
                            ),
                          ],

                          if (item.gatewaySubscriptionId != null &&
                              item.gatewaySubscriptionId!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              Icons.vpn_key_outlined,
                              "Subscription ID",
                              item.gatewaySubscriptionId!,
                            ),
                          ],

                          if (plan != null && plan.features.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            const Text(
                              "Plan Features",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children:
                                  plan.features
                                      .map(
                                        (feat) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.premiumGold,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppColors.premiumGold,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                size: 10,
                                                color: AppColors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                feat,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.premiumGold),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.premiumGold,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getProfileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'seller':
        return Icons.storefront_rounded;
      case 'employer':
        return Icons.business_center_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'creator':
        return Icons.video_camera_back_rounded;
      case 'personal':
        return Icons.person_rounded;
      default:
        return Icons.verified_user_rounded;
    }
  }

  String _getProfileLabel(String type) {
    if (type.isEmpty) return "Profile Details";
    if (type.toLowerCase() == 'seller') return "Seller Profile";
    if (type.toLowerCase() == 'employer') return "Employer Profile";
    return "${type[0].toUpperCase()}${type.substring(1)} Profile";
  }
}
