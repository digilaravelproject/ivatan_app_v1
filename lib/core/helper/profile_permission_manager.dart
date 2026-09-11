import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db/shared_pref_manager.dart';
import '../../features/dashboard/controller/homeController.dart';
import '../../features/dashboard/model/user_profile.dart';
import '../../features/subscription/data/model/profile_config_model.dart';
import '../../features/exclusive_content/controller/exclusive_controller.dart';
import '../../features/dashboard/controller/settings_controller.dart';

enum ProfileType {
  personal,
  contentCreation,
  employer,
  musicPlay,
  ecommerce,
}

class ProfilePermissionManager {
  /// Helper to get the active ProfileConfigModel (from HomeController state or cache)
  static ProfileConfigModel? get _config {
    try {
      if (Get.isRegistered<HomeController>()) {
        final config = Get.find<HomeController>().profileConfig.value;
        if (config != null) return config;
      }
    } catch (e) {
      debugPrint("ProfilePermissionManager: HomeController not initialized: $e");
    }

    // Fallback to cache
    final cached = SharedPrefManager().profileConfig;
    if (cached != null) {
      try {
        return ProfileConfigModel.fromJson(cached);
      } catch (e) {
        debugPrint("ProfilePermissionManager: Error parsing cached config: $e");
      }
    }
    return null;
  }

  static bool get _isAuthScreen {
    try {
      final route = Get.currentRoute.toLowerCase();
      if (route.isNotEmpty) {
        if (route == '/' ||
            route.contains('login') ||
            route.contains('signup') ||
            route.contains('register') ||
            route.contains('otp') ||
            route.contains('password') ||
            route.contains('splash') ||
            route.contains('interest') ||
            route.contains('onboarding')) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Get the current active profile name (e.g. 'personal', 'content_creation', etc.)
  static String? get currentProfileName {
    // If not logged in, no active profile
    if (!SharedPrefManager().isUserLogin) {
      return null;
    }

    final activeType = SharedPrefManager().activeProfileType?.toLowerCase().trim();
    final regType = SharedPrefManager().registeredProfileType?.toLowerCase().trim();

    // 1. Direct from SettingsController userProfile if loaded (/api/v1/users/{username})
    try {
      SettingsController? sc;
      final currentUsername = SharedPrefManager().user?.username;
      if (currentUsername != null && Get.isRegistered<SettingsController>(tag: currentUsername)) {
        sc = Get.find<SettingsController>(tag: currentUsername);
      } else if (Get.isRegistered<SettingsController>()) {
        sc = Get.find<SettingsController>();
      }
      if (sc?.userProfile.value != null) {
        final up = sc!.userProfile.value!;
        final pType = (up.activeProfile is Map ? up.activeProfile!["type"]?.toString() : null) ?? up.profileType;
        if (pType != null && pType.isNotEmpty) {
          return pType.toLowerCase().trim();
        }
      }
    } catch (_) {}

    // 2. Direct active profile type from active_profile in API response / SharedPref!
    if (activeType != null && activeType.isNotEmpty) {
      return activeType;
    }

    // 3. Fallback to registered profile type if active profile is not yet loaded
    if (regType != null && regType.isNotEmpty) {
      return regType;
    }

    // 4. Fallback to UserModel
    final user = SharedPrefManager().user;
    if (user != null) {
      final pType = (user.activeProfile is Map ? user.activeProfile!["type"]?.toString() : null) ?? user.profileType;
      if (pType != null && pType.isNotEmpty) return pType.toLowerCase().trim();
      final nonPersonal = user.nonPersonalProfileType;
      if (nonPersonal != null && nonPersonal.isNotEmpty) return nonPersonal;
      if (user.isSeller == true) return 'ecommerce';
      if (user.isEmployer == true) return 'employer';
    }

    // 4. Check active HomeController profileConfig
    try {
      if (Get.isRegistered<HomeController>()) {
        final config = Get.find<HomeController>().profileConfig.value;
        final name = config?.data?.userProfile?.currentProfileName ?? config?.data?.userProfile?.currentProfile;
        if (name != null && name.isNotEmpty) return name.toLowerCase().trim();
      }
    } catch (e) {
      debugPrint("ProfilePermissionManager: HomeController not initialized: $e");
    }

    // 5. Check cached profile config
    final cached = SharedPrefManager().profileConfig;
    if (cached != null) {
      try {
        final config = ProfileConfigModel.fromJson(cached);
        final name = config.data?.userProfile?.currentProfileName ?? config.data?.userProfile?.currentProfile;
        if (name != null && name.isNotEmpty) return name.toLowerCase().trim();
      } catch (e) {
        debugPrint("ProfilePermissionManager: Error parsing cached config: $e");
      }
    }

    if (activeType != null && activeType.isNotEmpty) {
      return activeType;
    }

    // 6. Default profile is 'personal'
    return 'personal';
  }

  /// Get the current ecommerce subtype (e.g. 'product', 'service', 'both')
  static String? get ecommerceSubType {
    final cachedSub = SharedPrefManager().registeredProfileSubType;
    if (cachedSub != null && cachedSub.isNotEmpty) return cachedSub;
    return _config?.data?.ecommerce?.type;
  }

  static bool isCurrentProfile(ProfileType type) {
    final name = currentProfileName?.toLowerCase().trim();
    if (name == null || name.isEmpty) return false;
    switch (type) {
      case ProfileType.personal:
        return name == 'personal' || name == 'personal_profile';
      case ProfileType.contentCreation:
        return name == 'content_creation' || name == 'creator' || name == 'exclusive';
      case ProfileType.employer:
        return name == 'employer';
      case ProfileType.musicPlay:
        return name == 'music_play' || name == 'music';
      case ProfileType.ecommerce:
        return name == 'ecommerce' || name == 'seller';
    }
  }

  /// Check if a specific profile type is unlocked (present in unlocked list)
  static bool isProfileUnlocked(ProfileType type) {
    final unlocked = _config?.data?.userProfile?.unlockedProfiles;
    if (unlocked == null) return false;

    String key;
    switch (type) {
      case ProfileType.personal:
        key = 'personal';
        break;
      case ProfileType.contentCreation:
        key = 'content_creation';
        break;
      case ProfileType.employer:
        key = 'employer';
        break;
      case ProfileType.musicPlay:
        key = 'music_play';
        break;
      case ProfileType.ecommerce:
        key = 'ecommerce';
        break;
    }

    return unlocked.any((p) => p.toLowerCase() == key || p.toLowerCase() == '${key}_profile');
  }

  /// Check if a specific profile type is currently set as active
  static bool isProfileActive(ProfileType type) {
    return isCurrentProfile(type);
  }

  /// Check if a specific profile has an active subscription
  static bool hasActiveSubscription(ProfileType type) {
    final data = _config?.data;
    if (data == null) return false;

    ProfileSubscriptionDetails? subscription;
    switch (type) {
      case ProfileType.personal:
        subscription = data.personalProfile?.subscription;
        break;
      case ProfileType.contentCreation:
        subscription = data.contentCreation?.subscriptionDetails;
        break;
      case ProfileType.employer:
        subscription = data.employer?.subscription;
        break;
      case ProfileType.musicPlay:
        subscription = data.musicPlay?.subscription;
        break;
      case ProfileType.ecommerce:
        subscription = data.ecommerce?.subscription;
        break;
    }

    final bool isSubActive = subscription?.isActive == true || subscription?.hasPaidSubscription == true;
    if (type == ProfileType.contentCreation) {
      return isSubActive || (data.contentCreation?.isActive == true && subscription != null);
    }
    return isSubActive;
  }

  /// Check if exclusive content was purchased or approved by admin
  static bool get isExclusivePurchased {
    try {
      if (!SharedPrefManager().isUserLogin || _isAuthScreen) return false;

      // 1. Controller check: status is active/approved by admin OR payment status is success
      if (Get.isRegistered<ExclusiveController>()) {
        final ec = Get.find<ExclusiveController>();
        final isApprovedByAdmin = ec.isFullyActive && ec.enablementStatus.value.toLowerCase() != 'none';
        final isPaid = ec.isPaymentSuccessful && ec.paymentStatus.value.toLowerCase() != 'none';
        if (isApprovedByAdmin || isPaid) {
          return true;
        }
        // If controller is active and not paid/approved, don't fall back to stale cache
        return false;
      }

      // 2. Profile config: Check if contentCreation has an active paid subscription
      final data = _config?.data;
      final sub = data?.contentCreation?.subscriptionDetails;
      if (sub?.hasPaidSubscription == true) return true;
      if (sub?.isActive == true && (sub?.price != null && sub?.price != 0 && sub?.price != "0")) {
        return true;
      }

      // 3. Fallback to SharedPref only if controller has not run yet
      return SharedPrefManager().isExclusivePurchased;
    } catch (e) {
      return false;
    }
  }

  /// Check if the currently active profile is Personal Profile AND has valid non-null subscription gateway IDs:
  /// - gateway_subscription_id
  /// - gateway_order_id
  /// - gateway_payment_id
  static bool get isActiveProfilePersonalWithGatewayIds {
    bool isValid(String? val) =>
        val != null &&
        val.toString().trim().isNotEmpty &&
        val.toString().trim().toLowerCase() != 'null' &&
        val.toString().trim().toLowerCase() != 'undefined';

    // 1. SettingsController userProfile
    try {
      SettingsController? sc;
      final currentUsername = SharedPrefManager().user?.username;
      if (currentUsername != null && Get.isRegistered<SettingsController>(tag: currentUsername)) {
        sc = Get.find<SettingsController>(tag: currentUsername);
      } else if (Get.isRegistered<SettingsController>()) {
        sc = Get.find<SettingsController>();
      }
      if (sc?.userProfile.value != null) {
        final up = sc!.userProfile.value!;
        if (up.isActiveProfilePersonal && up.hasValidPersonalSubscription) {
          return true;
        }
        if (up.activeProfile != null) {
          final t = up.activeProfile!["type"]?.toString().toLowerCase().trim();
          if (t != null && t.isNotEmpty && t != 'personal' && t != 'personal_profile') {
            return false;
          }
        }
      }
    } catch (_) {}

    // 2. HomeController currentUser
    try {
      if (Get.isRegistered<HomeController>()) {
        final cu = Get.find<HomeController>().currentUser.value;
        if (cu != null) {
          if (cu.isActiveProfilePersonal && cu.hasValidPersonalSubscription) {
            return true;
          }
          if (cu.activeProfile != null) {
            final t = cu.activeProfile!["type"]?.toString().toLowerCase().trim();
            if (t != null && t.isNotEmpty && t != 'personal' && t != 'personal_profile') {
              return false;
            }
          }
        }
      }
    } catch (_) {}

    // 3. UserModel
    final user = SharedPrefManager().user;
    if (user != null) {
      if (user.isActiveProfilePersonal && user.hasValidPersonalSubscription) {
        return true;
      }
      if (user.activeProfile != null) {
        final t = user.activeProfile!["type"]?.toString().toLowerCase().trim();
        if (t != null && t.isNotEmpty && t != 'personal' && t != 'personal_profile') {
          return false;
        }
      }
    }

    // 4. Check rawUserData directly
    final raw = SharedPrefManager().rawUserData;
    if (raw != null) {
      Map<String, dynamic> u = raw;
      if (u["user"] is Map) {
        u = u["user"] as Map<String, dynamic>;
      } else if (u["data"] is Map && (u["data"] as Map)["user"] is Map) {
        u = (u["data"] as Map)["user"] as Map<String, dynamic>;
      }

      if (u["active_profile"] is Map) {
        final ap = u["active_profile"] as Map<String, dynamic>;
        final t = ap["type"]?.toString().toLowerCase().trim();
        if (t == 'personal' || t == 'personal_profile') {
          Map<String, dynamic>? subMap;
          if (ap["active_subscription"] is Map) {
            subMap = ap["active_subscription"] as Map<String, dynamic>;
          }
          final subId = (subMap?["gateway_subscription_id"] ?? ap["gateway_subscription_id"])?.toString();
          final orderId = (subMap?["gateway_order_id"] ?? ap["gateway_order_id"])?.toString();
          final paymentId = (subMap?["gateway_payment_id"] ?? ap["gateway_payment_id"])?.toString();

          if (isValid(subId) && isValid(orderId) && isValid(paymentId)) {
            return true;
          }
        } else if (t != null && t.isNotEmpty) {
          return false;
        }
      }
    }

    // 5. Check SharedPrefManager cached gateway IDs if active profile is personal
    final activeType = SharedPrefManager().activeProfileType?.toLowerCase().trim();
    final isPersonal = activeType == null || activeType.isEmpty || activeType == 'personal' || activeType == 'personal_profile';
    if (isPersonal && SharedPrefManager().hasPersonalSubscriptionGatewayIds) {
      return true;
    }

    return false;
  }

  /// Alias for backward compatibility
  static bool get hasPersonalSubscriptionGatewayIds => isActiveProfilePersonalWithGatewayIds;

  /// Check if golden theme should be displayed:
  /// - Login / Registration / Auth screens: ALWAYS WHITE (false)
  /// - Not logged in: ALWAYS WHITE (false)
  /// - Exclusive content approved by admin (or paid): GOLDEN (true) (regardless of profile)
  /// - active_profile is Personal AND all 3 gateway IDs (gateway_subscription_id, gateway_order_id, gateway_payment_id) are non-null: GOLDEN (true)
  /// - Otherwise (null gateway IDs, employer, ecommerce/seller, music, etc.) -> WHITE (false)
  static bool get isGoldEligible {
    try {
      // 1. Login, Registration, and Auth screens are ALWAYS WHITE
      if (!SharedPrefManager().isUserLogin || _isAuthScreen) {
        return false;
      }

      // 2. Agar exclusive ke lia approve hai admin se tbhi bhi golden rhega tab to chahe jo profile rhe
      if (isExclusivePurchased) return true;

      // 3. active profiles ke andar se check karna hai:
      // jo profile current time me active hai agar o personal hai aur usme ye
      // gateway_subscription_id, gateway_order_id, gateway_payment_id id ka data aa rha hai tab golden dikhana hai
      if (isActiveProfilePersonalWithGatewayIds) {
        return true;
      }

      // 4. Otherwise (null gateway IDs, employer, ecommerce/seller, music, etc.) -> white hi rhega
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if a specific profile is active AND has an active subscription
  static bool hasAccess(ProfileType type) {
    return isProfileActive(type) && hasActiveSubscription(type);
  }

  /// Get active subscription details for a profile type
  static ProfileSubscriptionDetails? getSubscriptionDetails(ProfileType type) {
    final data = _config?.data;
    if (data == null) return null;

    switch (type) {
      case ProfileType.personal:
        return data.personalProfile?.subscription;
      case ProfileType.contentCreation:
        return data.contentCreation?.subscriptionDetails;
      case ProfileType.employer:
        return data.employer?.subscription;
      case ProfileType.musicPlay:
        return data.musicPlay?.subscription;
      case ProfileType.ecommerce:
        return data.ecommerce?.subscription;
    }
  }

  /// Specific helper: Check if content creator profile is active and has a valid subscription
  static bool get canUploadReels {
    return isProfileActive(ProfileType.contentCreation) &&
        hasActiveSubscription(ProfileType.contentCreation);
  }

  /// Specific helper: Check if employer profile is active and subscribed
  static bool get canPostJobs {
    return isProfileActive(ProfileType.employer) &&
        hasActiveSubscription(ProfileType.employer);
  }

  /// Specific helper: Check if ecommerce seller profile is active, subscribed, and type supports products
  static bool get canSellProducts {
    if (!isProfileActive(ProfileType.ecommerce)) {
      return false;
    }
    final type = _config?.data?.ecommerce?.type?.toLowerCase();
    if (type == 'product' || type == 'products' || type == 'prodcut') return true;
    if (type == 'both') {
      return hasActiveSubscription(ProfileType.ecommerce);
    }
    return false;
  }

  /// Specific helper: Check if ecommerce seller profile is active, subscribed, and type supports services
  static bool get canProvideServices {
    if (!isProfileActive(ProfileType.ecommerce)) {
      return false;
    }
    final type = _config?.data?.ecommerce?.type?.toLowerCase();
    if (type == 'service' || type == 'services') return true;
    if (type == 'both') {
      return hasActiveSubscription(ProfileType.ecommerce);
    }
    return false;
  }

  /// Specific helper: Check if music creator profile is active and subscribed
  static bool get canUploadMusic {
    return isProfileActive(ProfileType.musicPlay) &&
        hasActiveSubscription(ProfileType.musicPlay);
  }

  /// Check if a given UserData profile supports selling products (handles both own and other profiles)
  static bool canProfileSellProducts(UserData user, bool isOtherProfile) {
    if (isOtherProfile) {
      final isSellerProfile = user.profileType?.toLowerCase() == 'seller' ||
          user.profileType?.toLowerCase() == 'ecommerce' ||
          user.isSeller == true;
      if (!isSellerProfile) return false;
      final subType = user.profileSubType?.toLowerCase();
      return subType == null || subType.isEmpty || subType == 'product' || subType == 'products' || subType == 'prodcut' || subType == 'both';
    }
    return canSellProducts;
  }

  /// Check if a given UserData profile supports providing services (handles both own and other profiles)
  static bool canProfileProvideServices(UserData user, bool isOtherProfile) {
    if (isOtherProfile) {
      final isSellerProfile = user.profileType?.toLowerCase() == 'seller' ||
          user.profileType?.toLowerCase() == 'ecommerce' ||
          user.isSeller == true;
      if (!isSellerProfile) return false;
      final subType = user.profileSubType?.toLowerCase();
      return subType == null || subType.isEmpty || subType == 'service' || subType == 'services' || subType == 'both';
    }
    return canProvideServices;
  }
}