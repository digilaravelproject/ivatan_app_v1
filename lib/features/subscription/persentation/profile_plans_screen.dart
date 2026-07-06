import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/model/subscription_models.dart';
import 'plan_details_screen.dart';

class ProfilePlansScreen extends StatefulWidget {
  final ProfileTypeSubscription profileTypeSub;

  const ProfilePlansScreen({
    super.key,
    required this.profileTypeSub,
  });

  @override
  State<ProfilePlansScreen> createState() => _ProfilePlansScreenState();
}

class _ProfilePlansScreenState extends State<ProfilePlansScreen> {
  SubscriptionPlan? selectedPlan;

  @override
  void initState() {
    super.initState();
    // Default select the first plan or the active plan if one exists
    if (widget.profileTypeSub.plans.isNotEmpty) {
      selectedPlan = widget.profileTypeSub.plans.firstWhereOrNull(
        (p) => p.isSubscribed,
      ) ?? widget.profileTypeSub.plans.first;
    } else {
      selectedPlan = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profileTypeSub.plans.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(
            color: Colors.black,
            onPressed: () => Get.back(),
          ),
          title: Text(
            "${widget.profileTypeSub.label} Plans",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.style_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No plans available here",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "This profile type doesn't have any subscription plans.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => Get.back(),
        ),
        title: Text(
          "${widget.profileTypeSub.label} Plans",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
                    const Center(
                      child: Text(
                        "Choose a plan that fits your business needs.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.profileTypeSub.plans.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final plan = widget.profileTypeSub.plans[index];
                        final isCurrentlySelected = selectedPlan?.id == plan.id;
                        
                        return _buildPlanCard(plan, isCurrentlySelected);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedPlan == null
                      ? null
                      : () {
                          Get.to(() => PlanDetailsScreen(
                            profileTypeSub: widget.profileTypeSub,
                            plan: selectedPlan!,
                          ));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "View Plan Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, bool isSelected) {
    // Check if the plan is active/subscribed
    final isActive = plan.status == 'active';
    final isPending = plan.status == 'pending';
    
    // Highlights if active, pending, or user selected
    final shouldHighlight = isSelected || isActive || isPending;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = plan;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: shouldHighlight ? const Color(0xFFD4AF37) : Colors.grey.shade200,
            width: shouldHighlight ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: shouldHighlight ? const Color(0xFFD4AF37).withOpacity(0.02) : Colors.transparent,
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                          children: [
                            TextSpan(
                              text: plan.price,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            TextSpan(
                              text: " / ${plan.period}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Badges (MOST POPULAR, SUBSCRIBED, PENDING)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isActive)
                      _buildPlanBadge("SUBSCRIBED & APPROVED", Colors.black, Colors.white)
                    else if (isPending)
                      _buildPlanBadge("PENDING APPROVAL", const Color(0xFFFEF3C7), const Color(0xFFD97706))
                    else if (plan.isPopular)
                      _buildPlanBadge("MOST POPULAR", Colors.black, Colors.white),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              plan.description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildPlanBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
