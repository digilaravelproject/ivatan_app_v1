import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/subscription_controller.dart';
import '../controller/subscription_payment_controller.dart';
import '../data/model/subscription_models.dart';

class PlanDetailsScreen extends StatefulWidget {
  final ProfileTypeSubscription profileTypeSub;
  final SubscriptionPlan plan;

  const PlanDetailsScreen({
    super.key,
    required this.profileTypeSub,
    required this.plan,
  });

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  late SubscriptionController _controller;
  late SubscriptionPaymentController _paymentController;
  late SubscriptionPlan _plan;
  bool _isLoadingDetails = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
    _controller = Get.isRegistered<SubscriptionController>()
        ? Get.find<SubscriptionController>()
        : Get.put(SubscriptionController());
    _paymentController = Get.put(SubscriptionPaymentController());
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      setState(() {
        _isLoadingDetails = true;
        _errorMsg = null;
      });
      final fresh = await _controller.fetchPlanDetails(_plan.id);
      if (fresh != null && mounted) {
        setState(() {
          // Preserve local subscription status and features from the
          // already-loaded plans list if API returns empty
          _plan = fresh.copyWith(
            status: _plan.status,
            features: fresh.features.isNotEmpty ? fresh.features : _plan.features,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoadingDetails = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = _plan.status == 'active';
    final isPending   = _plan.status == 'pending';
    final isAnyStatus = isSubscribed || isPending;

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: BackButton(
          color: AppColors.white,
          onPressed: () => Get.back(),
        ),
        title: Text(
          _plan.name,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_isLoadingDetails)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(isSubscribed, isPending, isAnyStatus),
      ),
    );
  }

  Widget _buildBody(bool isSubscribed, bool isPending, bool isAnyStatus) {
    if (_isLoadingDetails) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumHeaderCard(_plan),
                  const SizedBox(height: 16),
                  const Text(
                    "Plan Features",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  const SizedBox(height: 16),
                  // Skeleton loaders
                  ...List.generate(3, (_) => _buildSkeletonFeatureItem()),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              const Text("Failed to load plan details", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(_errorMsg!, style: TextStyle(fontSize: 12, color: AppColors.premiumGold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetails,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.transparent),
                child: const Text("Retry", style: TextStyle(color: AppColors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumHeaderCard(_plan),
                const SizedBox(height: 16),

                const Text(
                  "Plan Features",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _plan.features.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => _buildFeatureItem(_plan.features[index]),
                ),

                const SizedBox(height: 16),

                if (isAnyStatus) _buildSubscriptionStatusGuide(isPending),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Subscribe button — shown only if NOT active/pending
        if (!isAnyStatus)
          Obx(() {
            final loading = _paymentController.isLoading.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          await _paymentController.initiateSubscriptionPayment(
                            profileTypeSub: widget.profileTypeSub,
                            plan: _plan,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Subscribe Now",
                          style: TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            );
          }),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Skeleton loading item
  // ─────────────────────────────────────────────
  Widget _buildSkeletonFeatureItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(color: AppColors.premiumGold, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: 140, color: AppColors.premiumGold),
                const SizedBox(height: 6),
                Container(height: 10, width: 220, color: AppColors.premiumGold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Premium gold header card
  // ─────────────────────────────────────────────
  Widget _buildPremiumHeaderCard(SubscriptionPlan plan) {
    final isSubscribed = plan.status == 'active';
    final isPending    = plan.status == 'pending';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F0F15), Color(0xFF1E1F29)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.35),
              width: 1.2,
            ),
          ),
          child: Stack(
            children: [
              // Ambient glow blobs
              Positioned(
                right: -40, top: -40,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      const Color(0xFFD4AF37).withOpacity(0.12),
                      const Color(0xFFD4AF37).withOpacity(0.0),
                    ]),
                  ),
                ),
              ),
              Positioned(
                left: -30, bottom: -30,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      const Color(0xFFFFF099).withOpacity(0.08),
                      const Color(0xFFFFF099).withOpacity(0.0),
                    ]),
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1),
                        ),
                        child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4AF37), size: 20),
                      ),
                      const Spacer(),
                      // Live status pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSubscribed
                                    ? const Color(0xFF10B981)
                                    : (isPending ? const Color(0xFFF59E0B) : AppColors.white),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isSubscribed ? "Subscribed" : (isPending ? "Pending Approval" : "Not Subscribed"),
                              style: TextStyle(
                                color: isSubscribed
                                    ? const Color(0xFF10B981)
                                    : (isPending ? const Color(0xFFF59E0B) : AppColors.white),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Plan name — golden shader
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFF099), Color(0xFFD4AF37), Color(0xFFFFF099)],
                        ).createShader(bounds),
                        child: Text(
                          plan.name,
                          style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                      if (plan.isPopular) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF099), Color(0xFFD4AF37)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "MOST POPULAR",
                            style: TextStyle(color: AppColors.white, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price — metallic gold gradient text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFF099), Color(0xFFD4AF37), Color(0xFF9F7A1A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          plan.price,
                          style: const TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "/ ${plan.period}",
                        style: const TextStyle(fontSize: 12, color: AppColors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    plan.description,
                    style: const TextStyle(color: AppColors.white, fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Feature row
  // ─────────────────────────────────────────────
  Widget _buildFeatureItem(PlanFeature feature) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: AppColors.premiumGold, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: AppColors.black, size: 11),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
              if (feature.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  feature.description,
                  style: TextStyle(fontSize: 12, color: AppColors.premiumGold, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Status guide card
  // ─────────────────────────────────────────────
  Widget _buildSubscriptionStatusGuide(bool isPending) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.premiumGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.premiumGold),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPending ? Icons.watch_later_outlined : Icons.check_circle_outline_rounded,
            color: isPending ? const Color(0xFFD97706) : Colors.green,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Subscription Status",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.premiumGold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isPending
                      ? "This plan is subscribed but pending approval from admin."
                      : "This plan is active and approved by admin. You can manage your subscription from the store details.",
                  style: TextStyle(fontSize: 13, color: AppColors.premiumGold, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
