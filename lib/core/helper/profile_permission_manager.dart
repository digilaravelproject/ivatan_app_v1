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
        final pType = up.profileType?.toLowerCase().trim();
        if (pType != null && pType.isNotEmpty) return pType;
        if (up.isSeller == true) return 'ecommerce';
        if (up.isEmployer == true) return 'employer';
      }
    } catch (_) {}

    // 2. Direct active profile type from active_profile in API response / SharedPref!
    final activeType = SharedPrefManager().activeProfileType;
    if (activeType != null && activeType.isNotEmpty) {
      return activeType.toLowerCase().trim();
    }

    // 3. Fallback to UserModel (available immediately upon login!)
    final user = SharedPrefManager().user;
    if (user != null) {
      final pType = user.profileType?.toLowerCase().trim();
      if (pType != null && pType.isNotEmpty) return pType;
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

    // 6. If user is logged in and not employer/seller, default profile is 'personal'
    return 'personal';
  }

  /// Get the current ecommerce subtype (e.g. 'product', 'service', 'both')
  static String? get ecommerceSubType {
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

  /// Check if exclusive content was purchased (via SharedPreferences, active controller, or backend config)
  static bool get isExclusivePurchased {
    try {
      if (!SharedPrefManager().isUserLogin || _isAuthScreen) return false;

      // 1. Controller check: payment status is success or status is active/approved
      if (Get.isRegistered<ExclusiveController>()) {
        final ec = Get.find<ExclusiveController>();
        final isPaid = (ec.isPaymentSuccessful || ec.isFullyActive) &&
            ec.paymentStatus.value.toLowerCase() != 'none' &&
            ec.enablementStatus.value.toLowerCase() != 'none';
        if (isPaid) {
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

  /// Check if golden theme should be displayed:
  /// - Login / Registration / Auth screens: ALWAYS WHITE (false)
  /// - Not logged in: ALWAYS WHITE (false)
  /// - Exclusive content purchased: GOLDEN (true)
  /// - Current active profile is Personal: GOLDEN (true)
  /// - Otherwise (employer, ecommerce/seller, music, content creation bina purchase ke) -> WHITE (false)
  static bool get isGoldEligible {
    try {
      // 1. Login, Registration, and Auth screens are ALWAYS WHITE
      if (!SharedPrefManager().isUserLogin || _isAuthScreen) {
        return false;
      }

      // 2. Agar exclusive content ke liye purchase kiya hai -> golden dikhega
      if (isExclusivePurchased) return true;

      // 3. Agar current profile Personal Profile hai -> golden dikhega
      if (isCurrentProfile(ProfileType.personal)) return true;

      // 4. Otherwise (employer, ecommerce/seller, music, etc.) -> white hi dikhega
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