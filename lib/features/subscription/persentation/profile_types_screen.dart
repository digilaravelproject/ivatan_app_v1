import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/subscription_controller.dart';
import 'profile_plans_screen.dart';

class ProfileTypesScreen extends StatelessWidget {
  const ProfileTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubscriptionController());

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: BackButton(
          color: AppColors.white,
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile Types",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Manage subscription status and approval for all profile types.",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.premiumGold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Reactive List of Profile Types
                    Obx(() {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.subscriptions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final sub = controller.subscriptions[index];
                          return _buildProfileCard(context, sub);
                        },
                      );
                    }),
                    
                    const SizedBox(height: 14),
                    _buildStatusGuide(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic sub) {
    final hasSubscription = sub.status != 'none';
    final isActive = sub.status == 'active';

    return GestureDetector(
      onTap: () {
        Get.to(() => ProfilePlansScreen(profileTypeSub: sub));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.white.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: isActive 
                ? const Color(0xFFD4AF37) 
                : (sub.status == 'pending' ? const Color(0xFFF59E0B) : AppColors.premiumGold),
            width: hasSubscription ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: hasSubscription ? Border.all(color: const Color(0xFFD4AF37), width: 1) : null,
              ),
              child: Icon(sub.icon, color: AppColors.white, size: 18),
            ),
            const SizedBox(width: 10),
            
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${sub.plansCount} Plans",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.premiumGold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Badge & Chevron
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusBadge(sub.status),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.premiumGold,
                  size: 11,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    if (status == 'active') {
      bgColor = AppColors.white;
      textColor = AppColors.white;
      text = "Subscribed & Approved";
    } else if (status == 'pending') {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
      text = "Subscribed\nPending Approval";
    } else {
      bgColor = AppColors.premiumGold;
      textColor = AppColors.premiumGold;
      text = "No Subscription";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildStatusGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.premiumGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.premiumGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                "Status Guide",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.premiumGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildGuideItem("Subscribed & Approved", "Active and visible on the platform"),
          const SizedBox(height: 6),
          _buildGuideItem("Subscribed Pending Approval", "Awaiting validation from admin"),
          const SizedBox(height: 6),
          _buildGuideItem("No Subscription", "No active subscription for this profile type"),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• ",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.premiumGold,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, height: 1.4),
              children: [
                TextSpan(
                  text: "$title – ",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
                ),
                TextSpan(
                  text: description,
                  style: TextStyle(color: AppColors.premiumGold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
