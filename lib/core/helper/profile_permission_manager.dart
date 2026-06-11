import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db/shared_pref_manager.dart';
import '../../features/dashboard/controller/homeController.dart';
import '../../features/dashboard/model/user_profile.dart';
import '../../features/subscription/data/model/profile_config_model.dart';

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

  /// Get the current active profile name (e.g. 'personal', 'content_creation', etc.)
  static String? get currentProfileName {
    return _config?.data?.userProfile?.currentProfileName;
  }

  /// Get the current ecommerce subtype (e.g. 'product', 'service', 'both')
  static String? get ecommerceSubType {
    return _config?.data?.ecommerce?.type;
  }

  static bool isCurrentProfile(ProfileType type) {
    final name = currentProfileName?.toLowerCase();
    switch (type) {
      case ProfileType.personal:
        return name == 'personal' || name == 'personal_profile';
      case ProfileType.contentCreation:
        return name == 'content_creation' || name == 'creator';
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

    return subscription?.isActive ?? false;
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
    if (type == 'product' || type == 'prodcut') return true;
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
    if (type == 'service') return true;
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
      return subType == null || subType.isEmpty || subType == 'product' || subType == 'prodcut' || subType == 'both';
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
      return subType == null || subType.isEmpty || subType == 'service' || subType == 'both';
    }
    return canProvideServices;
  }
}