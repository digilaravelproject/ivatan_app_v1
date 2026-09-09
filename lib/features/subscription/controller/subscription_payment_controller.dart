import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/helper/profile_permission_manager.dart';
import '../../../../core/network/api_services.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../dashboard/controller/settings_controller.dart';
import '../data/model/subscription_models.dart';
import 'subscription_controller.dart';
import '../../dashboard/controller/homeController.dart';
import '../../payment/presentation/widgets/payment_webview_page.dart';

class SubscriptionPaymentController extends GetxController {
  final ApiServices api = ApiServices();
  
  var isLoading = false.obs;
  
  // Keep track of current payment context
  SubscriptionPlan? _currentPlan;
  ProfileTypeSubscription? _currentProfileTypeSub;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> initiateSubscriptionPayment({
    required ProfileTypeSubscription profileTypeSub,
    required SubscriptionPlan plan,
  }) async {
    _currentPlan = plan;
    _currentProfileTypeSub = profileTypeSub;
    
    // 1. Fetch/Determine profile_id
    int? profileId = profileTypeSub.profileId ?? _getProfileId(profileTypeSub.type);
    print("fkdfmgnfdige :"+profileId.toString());
    
    if (profileId == null) {
      isLoading.value = true;
      try {
        final settingsController = _getSettingsController();
        if (settingsController != null) {
          await settingsController.fetchProfileSwitchRequests();
          profileId = profileTypeSub.profileId ?? _getProfileId(profileTypeSub.type);
        }
      } catch (e) {
        debugPrint("⚠️ Error fetching switch requests for profile_id lookup: $e");
      } finally {
        isLoading.value = false;
      }
    }

    if (profileId == null) {
      isLoading.value = true;
      try {
        final String apiProfileType = profileTypeSub.type;
        final String apiProfileSubType = profileTypeSub.subType ?? (apiProfileType == 'seller' ? 'both' : '');
        
        final Map<String, dynamic> body = {
          "to_profile_type": apiProfileType,
          "notes": "I want to switch to $apiProfileType.",
        };
        if (apiProfileSubType.isNotEmpty) {
          body["profile_sub_type"] = apiProfileSubType;
        }
        
        final switchResponse = await api.callPost(
          "api/v1/profiles/switch",
          data: body,
        );
        
        if (switchResponse != null && switchResponse["status"] == true) {
          final settingsController = _getSettingsController();
          if (settingsController != null) {
            await settingsController.fetchProfileSwitchRequests();
            profileId = _getProfileId(profileTypeSub.type);
          }
        }
      } catch (e) {
        debugPrint("⚠️ Error dynamically creating profile switch request: $e");
      } finally {
        isLoading.value = false;
      }
    }

    if (profileId == null) {
      Get.snackbar(
        "Error",
        "Could not locate or initialize profile details. Please try again.",
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
      return;
    }
    
    // 2. Call initiate subscriptions API: POST api/v1/profiles/{profileId}/subscriptions/initiate
    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.white)),
        barrierDismissible: false,
      );

      final planId = int.tryParse(plan.id) ?? 0;
      final initiateResponse = await api.callPost(
        "api/v1/profiles/$profileId/subscriptions/initiate",
        data: {
          "subscription_plan_id": planId,
        },
      );

      // Close loading dialog
      Get.back();

      if (initiateResponse != null && (initiateResponse['status'] == true || initiateResponse['success'] == true)) {
        final data = initiateResponse['data'];
        final requiresPayment = data['requires_payment'] ?? false;
        final gateway = data['gateway'] ?? '';
        final gatewaySubId = data['gateway_subscription_id'] ?? '';
        final redirectUrl = data['redirect_url'] ?? '';
        
        if (requiresPayment && (gateway == 'phonepe' || redirectUrl.toString().isNotEmpty)) {
          // Open PhonePe Mandate redirect page
          final result = await Get.to<bool?>(() => PaymentWebViewPage(url: redirectUrl));
          
          if (result == true) {
            await _verifyAndSyncSubscription(profileId, planId, optimisticSuccess: true);
          } else if (result == false) {
            _showSubscriptionFailureDialog("Subscription payment failed on PhonePe. Please try again.");
          } else {
            // result is null (e.g. user closed WebView)
            _showSubscriptionFailureDialog("Payment was cancelled or interrupted.");
          }
        } else {
          // If no payment required (Free plan), complete it immediately
          await _purchaseSubscription(
            profileId: profileId,
            planId: planId,
            paymentMethod: "free",
            gatewaySubId: gatewaySubId,
          );
        }
      } else {
        final errorMsg = initiateResponse != null ? (initiateResponse['message'] ?? "Initiation failed") : "Initiation failed";
        Get.snackbar(
          "Initiation Failed",
          errorMsg,
          backgroundColor: Colors.red.shade600,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close dialog on error
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  int? _getProfileId(String type) {
    // 1. Try to get from active profile config in HomeController
    try {
      if (Get.isRegistered<HomeController>()) {
        final config = Get.find<HomeController>().profileConfig.value;
        if (config != null && config.data != null) {
          final t = type.toLowerCase();
          if (t == 'seller' || t == 'ecommerce') {
            if (config.data!.ecommerce != null && config.data!.ecommerce!.profileId != null) {
              return config.data!.ecommerce!.profileId;
            }
          } else if (t == 'employer') {
            if (config.data!.employer != null && config.data!.employer!.profileId != null) {
              return config.data!.employer!.profileId;
            }
          } else if (t == 'music' || t == 'music_play') {
            if (config.data!.musicPlay != null && config.data!.musicPlay!.profileId != null) {
              return config.data!.musicPlay!.profileId;
            }
          } else if (t == 'creator' || t == 'content_creation') {
            if (config.data!.contentCreation != null && config.data!.contentCreation!.profileId != null) {
              return config.data!.contentCreation!.profileId;
            }
          } else if (t == 'personal' || t == 'personal_profile') {
            if (config.data!.personalProfile != null && config.data!.personalProfile!.profileId != null) {
              return config.data!.personalProfile!.profileId;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error reading active profileId from HomeController: $e");
    }

    // 2. Fallback to settings controller switch requests
    final settingsController = _getSettingsController();
    if (settingsController != null) {
      final matchedReq = settingsController.switchRequests.firstWhereOrNull((req) {
        return req.toProfileType == type;
      });
      
      if (matchedReq != null && matchedReq.toProfileId != null) {
        return matchedReq.toProfileId;
      }
    }
    return null;
  }

  Future<void> _verifyAndSyncSubscription(int profileId, int planId, {bool optimisticSuccess = true}) async {
    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.white)),
        barrierDismissible: false,
      );

      // Short polling: 3 attempts, 2 seconds apart, to allow PhonePe webhook to process and activate
      Map<String, dynamic>? response;
      bool isSynced = false;
      
      for (int i = 0; i < 3; i++) {
        response = await api.callGet("api/v1/profiles/$profileId/subscriptions/active");
        if (response != null && (response['status'] == true || response['success'] == true)) {
          final data = response['data'];
          if (data != null) {
            isSynced = true;
            break;
          }
        }
        await Future.delayed(const Duration(seconds: 2));
      }

      Get.back(); // Close loading dialog

      String message = "Your subscription payment was successful. The subscription is being processed.";
      if (isSynced && response != null) {
        message = response['message'] ?? "Your subscription is now active.";
        _showSubscriptionSuccessDialog(profileId, planId, message, isSynced);
      } else {
        if (optimisticSuccess) {
          _showSubscriptionSuccessDialog(profileId, planId, message, false);
        } else {
          _showSubscriptionFailureDialog("Subscription could not be verified at this time.");
        }
      }
    } catch (e) {
      Get.back(); // Close loading dialog on error
      debugPrint("⚠️ Subscription verification error: $e");
      if (optimisticSuccess) {
        _showSubscriptionSuccessDialog(
          profileId,
          planId,
          "Your payment was successful. The subscription will activate shortly.",
          false,
        );
      } else {
         _showSubscriptionFailureDialog("Subscription could not be verified.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showSubscriptionSuccessDialog(int profileId, int planId, String message, bool isSynced) {
    final isGold = ProfilePermissionManager.isGoldEligible;
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isGold ? const Color(0xFFC0A062).withOpacity(0.4) : const Color(0xFF38383A),
          ),
        ),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text("Subscribed Successfully", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isGold ? const Color(0xFFC0A062) : const Color(0xFFB0B0B0),
            fontSize: 14,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              Get.back(); // Go back from plan details screen
              
              // Sync subscription view in ProfileTypes list
              if (_currentPlan != null && _currentProfileTypeSub != null) {
                final subscriptionController = Get.isRegistered<SubscriptionController>()
                    ? Get.find<SubscriptionController>()
                    : Get.put(SubscriptionController());
                
                final String targetStatus = isSynced ? 'active' : 'pending';
                
                final updatedList = subscriptionController.subscriptions.map((sub) {
                  if (sub.id == _currentProfileTypeSub!.id) {
                    final updatedPlans = sub.plans.map((p) {
                      if (p.id == _currentPlan!.id) {
                        return p.copyWith(status: targetStatus);
                      }
                      return p.copyWith(status: 'none');
                    }).toList();

                    return sub.copyWith(
                      status: targetStatus,
                      plans: updatedPlans,
                    );
                  }
                  return sub;
                }).toList();
                subscriptionController.subscriptions.value = updatedList;

                // Also trigger a refresh from the server to ensure we have the absolute latest status
                try {
                  await subscriptionController.fetchPlansForProfileType(
                    _currentProfileTypeSub!.type,
                    activePlanSlug: _currentPlan!.slug,
                    isSubscribedActive: isSynced,
                    profileId: profileId,
                  );
                } catch (e) {
                  debugPrint("Error fetching plans after subscription success: $e");
                }
              }

              // Sync Settings view
              final settingsController = _getSettingsController();
              if (settingsController != null) {
                settingsController.fetchUserDetails(settingsController.userName);
                settingsController.fetchProfileSwitchRequests();
              }

              // Sync Profile Config for dynamic permissions and gold theme
              if (Get.isRegistered<HomeController>()) {
                Get.find<HomeController>().fetchProfileConfig();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isGold ? const Color(0xFFC0A062) : AppColors.white,
              foregroundColor: AppColors.black,
              minimumSize: const Size(140, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text("Done", style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _purchaseSubscription({
    required int profileId,
    required int planId,
    required String paymentMethod,
    required String gatewaySubId,
  }) async {
    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.white)),
        barrierDismissible: false,
      );

      final Map<String, dynamic> body = {
        "subscription_plan_id": planId,
        "payment_method": paymentMethod,
      };
      if (gatewaySubId.isNotEmpty) {
        body["gateway_subscription_id"] = gatewaySubId;
      }

      final response = await api.callPost(
        "api/v1/profiles/$profileId/subscriptions",
        data: body,
      );

      // Close loading dialog
      Get.back();

      if (response != null && response['status'] == true) {
        // Success popup
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text("Subscribed Successfully", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              response['message'] ?? "Your subscription has been recorded and is active.",
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back from plan details screen
                  
                  // Sync subscription view in ProfileTypes list
                  if (_currentPlan != null && _currentProfileTypeSub != null) {
                    final subscriptionController = Get.isRegistered<SubscriptionController>()
                        ? Get.find<SubscriptionController>()
                        : Get.put(SubscriptionController());
                    final updatedList = subscriptionController.subscriptions.map((sub) {
                      if (sub.id == _currentProfileTypeSub!.id) {
                        final updatedPlans = sub.plans.map((p) {
                          if (p.id == _currentPlan!.id) {
                            return p.copyWith(status: 'pending'); // Wait approval
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
                    subscriptionController.subscriptions.value = updatedList;
                  }

                  // Sync Settings view
                  final settingsController = _getSettingsController();
                  if (settingsController != null) {
                    settingsController.fetchUserDetails(settingsController.userName);
                    settingsController.fetchProfileSwitchRequests();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.transparent,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(120, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Done"),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        final errorMsg = response != null ? (response['message'] ?? "Purchase failed") : "Purchase failed";
        Get.snackbar(
          "Subscription Failed",
          errorMsg,
          backgroundColor: Colors.red.shade600,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.back(); // Close dialog on error
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
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

  void _showSubscriptionFailureDialog(String message) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF38383A)),
        ),
        title: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            const Text("Payment Failed", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              elevation: 0,
            ),
            child: const Text("Okay", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
