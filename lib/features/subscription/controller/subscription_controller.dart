import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_services.dart';
import '../../../../db/shared_pref_manager.dart';
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

    // Build Subscriptions List with empty plans (which will be populated dynamically from the API)
    subscriptions.value = [
      ProfileTypeSubscription(
        id: "1",
        type: "personal",
        label: "Individual",
        icon: Icons.person_outline_rounded,
        status: isSellerUser || isEmployerUser ? 'none' : 'active',
        plansCount: 0,
        plans: const [],
      ),
      ProfileTypeSubscription(
        id: "2",
        type: "seller",
        label: "Product Seller",
        icon: Icons.shopping_bag_outlined,
        status: isSellerUser 
            ? 'active' 
            : (pendingSwitchType == 'seller' && pendingSwitchSubType == 'product' ? 'pending' : 'none'),
        plansCount: 0,
        plans: const [],
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
        plansCount: 0,
        plans: const [],
      ),
      ProfileTypeSubscription(
        id: "4",
        type: "employer",
        label: "Enterprise",
        icon: Icons.apartment_rounded,
        status: isEmployerUser 
            ? 'active' 
            : (pendingSwitchType == 'employer' ? 'pending' : 'none'),
        plansCount: 0,
        plans: const [],
      ),
      ProfileTypeSubscription(
        id: "5",
        type: "music",
        label: "Music & Creator",
        icon: Icons.library_music_outlined,
        status: (pendingSwitchType == 'music' || pendingSwitchType == 'creator') ? 'pending' : 'none',
        plansCount: 0,
        plans: const [],
      ),
    ];
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
}
