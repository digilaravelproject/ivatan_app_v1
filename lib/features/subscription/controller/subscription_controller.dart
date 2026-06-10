import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_services.dart';
import '../../../../core/network/app_urls.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../dashboard/controller/settings_controller.dart';
import '../data/model/subscription_models.dart';

class SubscriptionController extends GetxController {
  final ApiServices api = ApiServices();

  var isLoading = false.obs;
  var subscriptions = <ProfileTypeSubscription>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeSubscriptions();
  }

  void initializeSubscriptions() {
    final user = SharedPrefManager().user;
    final isSellerUser = user?.isSeller ?? false;
    final isEmployerUser = user?.isEmployer ?? false;

    // Check if user has a pending switch request in local database or settings
    final pendingSwitchType = user?.profileType;
    final pendingSwitchSubType = user?.profileSubType;

    // 1. Plan Features
    final premiumBusinessFeatures = [
      PlanFeature(title: "Advanced Analytics", description: "Detailed insights and performance analytics."),
      PlanFeature(title: "Unlimited Listings", description: "Add unlimited products, services or listings."),
      PlanFeature(title: "Priority Support", description: "Get priority email and chat support."),
      PlanFeature(title: "Custom Branding", description: "Use your own branding and custom domain."),
      PlanFeature(title: "Verified Badge", description: "Show verified badge on your profile."),
      PlanFeature(title: "API Access", description: "Integrate with our powerful APIs."),
      PlanFeature(title: "Reports & Exports", description: "Export data and generate reports."),
    ];

    final standardBusinessFeatures = [
      PlanFeature(title: "Basic Analytics", description: "Insights into listing performance."),
      PlanFeature(title: "Email Support", description: "Get email support within 24 hours."),
      PlanFeature(title: "Unlimited Listings", description: "Add unlimited products, services or listings."),
      PlanFeature(title: "Verified Badge", description: "Show verified badge on your profile."),
    ];

    final basicBusinessFeatures = [
      PlanFeature(title: "Limited Analytics", description: "Very basic performance statistics."),
      PlanFeature(title: "Community Support", description: "Get community support from forums."),
      PlanFeature(title: "10 Listings", description: "List up to 10 products or services."),
    ];

    final freePlanFeatures = [
      PlanFeature(title: "Basic Access", description: "Standard features for individual listings."),
      PlanFeature(title: "1 Listing", description: "List 1 product or service active."),
    ];

    final employerPremiumFeatures = [
      PlanFeature(title: "Unlimited Job Posts", description: "Post as many job openings as needed."),
      PlanFeature(title: "Candidate Matching", description: "AI-based recommendations for candidates."),
      PlanFeature(title: "Resume Exports", description: "Download candidate resumes directly."),
      PlanFeature(title: "Priority Support", description: "Priority recruiter assistance."),
    ];

    final musicPremiumFeatures = [
      PlanFeature(title: "Unlimited Playlists", description: "Create and publish unlimited playlists."),
      PlanFeature(title: "Ad-free Streaming", description: "No advertisements between audio tracks."),
      PlanFeature(title: "High Fidelity Audio", description: "Access standard high-quality playback format."),
    ];

    final creatorPremiumFeatures = [
      PlanFeature(title: "Monetization Support", description: "Enable subscriber-only content access."),
      PlanFeature(title: "Advanced Stats", description: "In-depth insights into subscriber behaviors."),
      PlanFeature(title: "Verified Badge", description: "Golden badge for content authenticity."),
    ];

    // 2. Build Subscriptions List
    subscriptions.value = [
      ProfileTypeSubscription(
        id: "1",
        type: "personal",
        label: "Individual",
        icon: Icons.person_outline_rounded,
        status: isSellerUser || isEmployerUser ? 'none' : 'active',
        plansCount: 1,
        plans: [
          SubscriptionPlan(
            id: "personal_free",
            name: "Free Plan",
            price: "₹0",
            period: "month",
            description: "Default personal profile features.",
            status: isSellerUser || isEmployerUser ? 'none' : 'active',
            features: [PlanFeature(title: "Basic Access", description: "Feed access, standard messaging, and uploads.")],
          ),
        ],
      ),
      ProfileTypeSubscription(
        id: "2",
        type: "seller",
        label: "Product Seller",
        icon: Icons.shopping_bag_outlined,
        status: isSellerUser 
            ? 'active' 
            : (pendingSwitchType == 'seller' && pendingSwitchSubType == 'product' ? 'pending' : 'none'),
        plansCount: 4,
        plans: [
          SubscriptionPlan(
            id: "seller_premium",
            name: "Premium Business",
            price: "₹2,499",
            period: "month",
            description: "Best for growing businesses looking for advanced tools and priority support.",
            isPopular: true,
            status: isSellerUser 
                ? 'active' 
                : (pendingSwitchType == 'seller' && pendingSwitchSubType == 'product' ? 'pending' : 'none'),
            features: premiumBusinessFeatures,
          ),
          SubscriptionPlan(
            id: "seller_standard",
            name: "Standard Business",
            price: "₹1,499",
            period: "month",
            description: "Perfect for small businesses starting their journey.",
            features: standardBusinessFeatures,
          ),
          SubscriptionPlan(
            id: "seller_basic",
            name: "Basic Business",
            price: "₹799",
            period: "month",
            description: "Get started with essential tools to grow your business.",
            features: basicBusinessFeatures,
          ),
          SubscriptionPlan(
            id: "seller_free",
            name: "Free Plan",
            price: "₹0",
            period: "month",
            description: "For individuals exploring our platform.",
            features: freePlanFeatures,
          ),
        ],
      ),
      ProfileTypeSubscription(
        id: "3",
        type: "seller",
        subType: "service",
        label: "Service Provider",
        icon: Icons.business_center_outlined,
        status: isSellerUser 
            ? 'active' 
            : (pendingSwitchType == 'seller' && pendingSwitchSubType == 'service' ? 'pending' : 'none'),
        plansCount: 3,
        plans: [
          SubscriptionPlan(
            id: "service_premium",
            name: "Premium Services",
            price: "₹1,999",
            period: "month",
            description: "Best for professional service providers requiring priority support.",
            isPopular: true,
            status: isSellerUser 
                ? 'active' 
                : (pendingSwitchType == 'seller' && pendingSwitchSubType == 'service' ? 'pending' : 'none'),
            features: premiumBusinessFeatures,
          ),
          SubscriptionPlan(
            id: "service_standard",
            name: "Standard Services",
            price: "₹999",
            period: "month",
            description: "Perfect for growing service businesses.",
            features: standardBusinessFeatures,
          ),
          SubscriptionPlan(
            id: "service_free",
            name: "Free Plan",
            price: "₹0",
            period: "month",
            description: "Basic features for independent service providers.",
            features: freePlanFeatures,
          ),
        ],
      ),
      ProfileTypeSubscription(
        id: "4",
        type: "employer",
        label: "Enterprise",
        icon: Icons.apartment_rounded,
        status: isEmployerUser 
            ? 'active' 
            : (pendingSwitchType == 'employer' ? 'pending' : 'none'),
        plansCount: 2,
        plans: [
          SubscriptionPlan(
            id: "employer_premium",
            name: "Premium Employer",
            price: "₹4,999",
            period: "month",
            description: "Best for recruitment agencies and enterprise hirers.",
            isPopular: true,
            status: isEmployerUser 
                ? 'active' 
                : (pendingSwitchType == 'employer' ? 'pending' : 'none'),
            features: employerPremiumFeatures,
          ),
          SubscriptionPlan(
            id: "employer_basic",
            name: "Basic Employer",
            price: "₹1,999",
            period: "month",
            description: "For small business owners wishing to hire candidates.",
            features: [
              PlanFeature(title: "5 Job Posts", description: "Post up to 5 job openings."),
              PlanFeature(title: "Resume Search", description: "Search candidate profiles directly."),
              PlanFeature(title: "Email Support", description: "Get response within 48 hours."),
            ],
          ),
        ],
      ),
      ProfileTypeSubscription(
        id: "5",
        type: "music",
        label: "Music & Creator",
        icon: Icons.library_music_outlined,
        status: (pendingSwitchType == 'music' || pendingSwitchType == 'creator') ? 'pending' : 'none',
        plansCount: 2,
        plans: [
          SubscriptionPlan(
            id: "music_premium",
            name: "Creator Premium",
            price: "₹1,299",
            period: "month",
            description: "Best for content creators and music curators.",
            isPopular: true,
            status: (pendingSwitchType == 'music' || pendingSwitchType == 'creator') ? 'pending' : 'none',
            features: creatorPremiumFeatures,
          ),
          SubscriptionPlan(
            id: "music_basic",
            name: "Creator Free",
            price: "₹0",
            period: "month",
            description: "Standard curator features to explore.",
            features: musicPremiumFeatures,
          ),
        ],
      ),
    ];
  }

  Future<void> subscribeToPlan(ProfileTypeSubscription profileTypeSub, SubscriptionPlan plan) async {
    try {
      isLoading.value = true;

      // Send exactly what the API returned — no custom mapping
      final String apiProfileType = profileTypeSub.type;
      final String? apiProfileSubType = profileTypeSub.subType?.isNotEmpty == true
          ? profileTypeSub.subType
          : null;

      final Map<String, dynamic> body = {
        "to_profile_type": apiProfileType,
        "notes": "I want to switch to ${plan.name}.",
      };
      if (apiProfileSubType != null) {
        body["profile_sub_type"] = apiProfileSubType;
      }

      final response = await api.callPost(
        "api/v1/profiles/switch",
        data: body,
      );

      if (response != null && response["status"] == true) {
        // Success: Update local state to pending
        // Update model list reactively
        final updatedList = subscriptions.map((sub) {
          if (sub.id == profileTypeSub.id) {
            // Update plan statuses
            final updatedPlans = sub.plans.map((p) {
              if (p.id == plan.id) {
                return p.copyWith(status: 'pending');
              }
              return p.copyWith(status: 'none');
            }).toList();

            return sub.copyWith(
              status: 'pending',
              plans: updatedPlans,
            );
          }
          return sub;
        }).toList();

        subscriptions.value = updatedList;

        Get.snackbar(
          "Success",
          response["message"] ?? "Approval is pending.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        // Update settings controller if registered to sync settings view
        final settingsController = _getSettingsController();
        if (settingsController != null) {
          settingsController.fetchUserDetails(settingsController.userName);
        }
      } else {
        Get.snackbar(
          "Error",
          response != null ? (response["message"] ?? "Switch request failed") : "Switch request failed",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches full plan details from GET /api/subscription-plans/{id}
  Future<SubscriptionPlan?> fetchPlanDetails(String planId) async {
    try {
      final response = await api.callGet("api/subscription-plans/$planId");
      if (response != null && response["status"] == true) {
        final planJson = response["data"]?["plan"];
        if (planJson != null) {
          return SubscriptionPlan.fromJson(planJson);
        }
      }
    } catch (e) {
      print("⚠️ Error fetching plan details for id=$planId: $e");
    }
    return null;
  }

  Future<ProfileTypeSubscription?> fetchPlansForProfileType(
    String profileType, {
    String? activePlanSlug,
    bool isSubscribedActive = false,
    int? profileId,
  }) async {
    try {
      isLoading.value = true;
      final response = await api.callGet(
        "api/subscription-plans",
        queryParams: {"profile_type": profileType},
      );

      if (response != null && response["status"] == true) {
        final rawData = response["data"];
        if (rawData != null && rawData["plans"] is List) {
          final List<SubscriptionPlan> plansList = (rawData["plans"] as List).map((planJson) {
            return SubscriptionPlan.fromJson(planJson);
          }).toList();

          final user = SharedPrefManager().user;
          final isSellerUser = user?.isSeller ?? false;
          final isEmployerUser = user?.isEmployer ?? false;
          final pendingSwitchType = user?.profileType;
          final pendingSwitchSubType = user?.profileSubType;

          String activeStatus = 'none';
          if (profileType == 'personal') {
            activeStatus = (!isSellerUser && !isEmployerUser) ? 'active' : 'none';
          } else if (profileType == 'seller') {
            activeStatus = isSellerUser ? 'active' : ((pendingSwitchType == 'seller') ? 'pending' : 'none');
          } else if (profileType == 'employer') {
            activeStatus = isEmployerUser ? 'active' : ((pendingSwitchType == 'employer') ? 'pending' : 'none');
          } else if (profileType == 'music') {
            activeStatus = (pendingSwitchType == 'music') ? 'pending' : 'none';
          } else if (profileType == 'creator') {
            activeStatus = (pendingSwitchType == 'creator') ? 'pending' : 'none';
          }

          final updatedList = subscriptions.map((sub) {
            bool isMatch = sub.type == profileType;
            if (profileType == 'seller') {
              // Match seller entries, but distinguish by subType if present
              isMatch = (sub.type == 'seller');
            } else if (profileType == 'creator') {
              isMatch = (sub.type == 'music');
            }

            if (isMatch) {
              String subStatus = activeStatus;
              // If this sub entry is for service but switch subtype is product, don't activate it
              if (sub.subType == 'service' && pendingSwitchSubType == 'product') {
                subStatus = 'none';
              } else if ((sub.subType == null || sub.subType == 'product') && pendingSwitchSubType == 'service') {
                subStatus = 'none';
              }

              if (activePlanSlug != null && activePlanSlug.isNotEmpty) {
                subStatus = isSubscribedActive ? 'active' : 'pending';
              }

              final plansForSub = plansList.map((plan) {
                String planStatus = 'none';
                if (activePlanSlug != null && activePlanSlug.isNotEmpty) {
                  if (plan.slug == activePlanSlug) {
                    planStatus = isSubscribedActive ? 'active' : 'pending';
                  }
                } else {
                  if (subStatus == 'active') {
                    if (plan.isPopular || plansList.first.id == plan.id) {
                      planStatus = 'active';
                    }
                  } else if (subStatus == 'pending') {
                    if (plan.isPopular || plansList.first.id == plan.id) {
                      planStatus = 'pending';
                    }
                  }
                }
                return plan.copyWith(status: planStatus);
              }).toList();

              return sub.copyWith(
                status: subStatus,
                plans: plansForSub,
                profileId: profileId,
              );
            }
            return sub;
          }).toList();

          subscriptions.value = updatedList;

          final returnedSub = subscriptions.firstWhereOrNull((sub) {
            if (profileType == 'seller') {
              if (pendingSwitchSubType == 'service') {
                return sub.type == 'seller' && sub.subType == 'service';
              }
              return sub.type == 'seller' && (sub.subType == null || sub.subType == 'product');
            }
            if (profileType == 'creator') {
              return sub.type == 'music';
            }
            return sub.type == profileType;
          });

          // If we found a match, return it directly with a fresh ProfileTypeSubscription
          // that includes the actual API-returned plans
          if (returnedSub != null) {
            return ProfileTypeSubscription(
              id: returnedSub.id,
              type: returnedSub.type,
              subType: returnedSub.subType,
              label: returnedSub.label,
              icon: returnedSub.icon,
              status: returnedSub.status,
              plansCount: plansList.length,
              plans: returnedSub.plans.isNotEmpty ? returnedSub.plans : plansList,
              profileId: profileId ?? returnedSub.profileId,
            );
          }
          return returnedSub;
        }
      }
    } catch (e) {
      print("⚠️ Error fetching subscription plans: $e");
    } finally {
      isLoading.value = false;
    }
    return null;
  }

  SettingsController? _getSettingsController() {
    final String? username = SharedPrefManager().user?.username;
    if (username != null && username.isNotEmpty) {
      if (Get.isRegistered<SettingsController>(tag: username)) {
        return Get.find<SettingsController>(tag: username);
      }
    }
    if (Get.isRegistered<SettingsController>()) {
      return Get.find<SettingsController>();
    }
    return null;
  }
}
