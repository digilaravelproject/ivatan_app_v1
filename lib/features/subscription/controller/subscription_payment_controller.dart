import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
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
  int? _currentProfileId;
  SubscriptionPlan? _currentPlan;
  ProfileTypeSubscription? _currentProfileTypeSub;
  String? _currentGatewaySubId;

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
        colorText: Colors.white,
      );
      return;
    }
    
    _currentProfileId = profileId;

    // 2. Call initiate subscriptions API: POST api/v1/profiles/{profileId}/subscriptions/initiate
    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.black)),
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

      if (initiateResponse != null && initiateResponse['status'] == true) {
        final data = initiateResponse['data'];
        final requiresPayment = data['requires_payment'] ?? false;
        final gateway = data['gateway'] ?? '';
        final gatewaySubId = data['gateway_subscription_id'] ?? '';
        final redirectUrl = data['redirect_url'] ?? '';
        
        _currentGatewaySubId = gatewaySubId;

        if (requiresPayment && (gateway == 'phonepe' || redirectUrl.toString().isNotEmpty)) {
          // Open PhonePe Mandate redirect page
          final result = await Get.to<bool?>(() => PaymentWebViewPage(url: redirectUrl));
          
          // Confirm purchase
          await _purchaseSubscription(
            profileId: profileId,
            planId: planId,
            paymentMethod: "phonepe",
            gatewaySubId: gatewaySubId,
          );
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
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close dialog on error
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
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

  Future<void> _purchaseSubscription({
    required int profileId,
    required int planId,
    required String paymentMethod,
    required String gatewaySubId,
  }) async {
    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.black)),
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
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
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
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.back(); // Close dialog on error
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
}
