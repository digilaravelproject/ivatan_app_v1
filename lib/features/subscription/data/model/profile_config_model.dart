class ProfileConfigModel {
  final bool? status;
  final String? message;
  final ProfileConfigData? data;

  ProfileConfigModel({
    this.status,
    this.message,
    this.data,
  });

  factory ProfileConfigModel.fromJson(Map<String, dynamic> json) {
    return ProfileConfigModel(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic> ? ProfileConfigData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ProfileConfigData {
  final UserProfileConfig? userProfile;
  final ContentCreationConfig? contentCreation;
  final EmployerConfig? employer;
  final MusicPlayConfig? musicPlay;
  final PersonalProfileConfig? personalProfile;
  final EcommerceConfig? ecommerce;

  ProfileConfigData({
    this.userProfile,
    this.contentCreation,
    this.employer,
    this.musicPlay,
    this.personalProfile,
    this.ecommerce,
  });

  factory ProfileConfigData.fromJson(Map<String, dynamic> json) {
    return ProfileConfigData(
      userProfile: json['user_profile'] is Map<String, dynamic>
          ? UserProfileConfig.fromJson(json['user_profile'])
          : null,
      contentCreation: json['content_creation'] is Map<String, dynamic>
          ? ContentCreationConfig.fromJson(json['content_creation'])
          : null,
      employer: json['employer'] is Map<String, dynamic>
          ? EmployerConfig.fromJson(json['employer'])
          : null,
      musicPlay: json['music_play'] is Map<String, dynamic>
          ? MusicPlayConfig.fromJson(json['music_play'])
          : null,
      personalProfile: json['personal_profile'] is Map<String, dynamic>
          ? PersonalProfileConfig.fromJson(json['personal_profile'])
          : null,
      ecommerce: json['ecommerce'] is Map<String, dynamic>
          ? EcommerceConfig.fromJson(json['ecommerce'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_profile': userProfile?.toJson(),
      'content_creation': contentCreation?.toJson(),
      'employer': employer?.toJson(),
      'music_play': musicPlay?.toJson(),
      'personal_profile': personalProfile?.toJson(),
      'ecommerce': ecommerce?.toJson(),
    };
  }
}

class UserProfileConfig {
  final String? userId;
  final String? fullName;
  final String? username;
  final String? email;
  final String? phone;
  final String? profilePhotoUrl;
  final String? bio;
  final String? gender;
  final String? languagePreference;
  final bool? isVerified;
  final int? followersCount;
  final int? followingCount;
  final int? postsCount;
  final int? reputationScore;
  final String? createdAt;
  final String? lastLoginAt;
  final String? currentProfileName;
  final String? firstProfile;
  final String? currentProfile;
  final List<String>? unlockedProfiles;

  UserProfileConfig({
    this.userId,
    this.fullName,
    this.username,
    this.email,
    this.phone,
    this.profilePhotoUrl,
    this.bio,
    this.gender,
    this.languagePreference,
    this.isVerified,
    this.followersCount,
    this.followingCount,
    this.postsCount,
    this.reputationScore,
    this.createdAt,
    this.lastLoginAt,
    this.currentProfileName,
    this.firstProfile,
    this.currentProfile,
    this.unlockedProfiles,
  });

  factory UserProfileConfig.fromJson(Map<String, dynamic> json) {
    return UserProfileConfig(
      userId: json['user_id']?.toString(),
      fullName: json['fullName'] as String? ?? json['full_name'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone']?.toString(),
      profilePhotoUrl: json['profile_photo_url'] as String?,
      bio: json['bio'] as String?,
      gender: json['gender'] as String?,
      languagePreference: json['language_preference'] as String?,
      isVerified: json['is_verified'] as bool?,
      followersCount: json['followers_count'] as int?,
      followingCount: json['following_count'] as int?,
      postsCount: json['posts_count'] as int?,
      reputationScore: json['reputation_score'] as int?,
      createdAt: json['created_at'] as String?,
      lastLoginAt: json['last_login_at'] as String?,
      currentProfileName: json['current_profile'] as String? ?? json['current_profile_name'] as String?,
      firstProfile: json['first_profile'] as String?,
      currentProfile: json['current_profile'] as String?,
      unlockedProfiles: json['unlocked_profiles'] is List
          ? List<String>.from(json['unlocked_profiles'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'profile_photo_url': profilePhotoUrl,
      'bio': bio,
      'gender': gender,
      'language_preference': languagePreference,
      'is_verified': isVerified,
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'reputation_score': reputationScore,
      'created_at': createdAt,
      'last_login_at': lastLoginAt,
      'current_profile_name': currentProfileName,
      'first_profile': firstProfile,
      'current_profile': currentProfile,
      'unlocked_profiles': unlockedProfiles,
    };
  }
}

class ProfileSubscriptionDetails {
  final bool? isActive;
  final String? planName;
  final String? planSlug;
  final dynamic price;
  final String? currency;
  final int? durationDays;
  final String? billingCycle;
  final List<String>? features;
  final String? startDate;
  final String? expiryDate;
  final String? nextBillingDate;
  final bool? autoRenew;
  final bool? hasPaidSubscription;

  ProfileSubscriptionDetails({
    this.isActive,
    this.planName,
    this.planSlug,
    this.price,
    this.currency,
    this.durationDays,
    this.billingCycle,
    this.features,
    this.startDate,
    this.expiryDate,
    this.nextBillingDate,
    this.autoRenew,
    this.hasPaidSubscription,
  });

  factory ProfileSubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return ProfileSubscriptionDetails(
      isActive: json['is_active'] as bool?,
      planName: json['plan_name'] as String?,
      planSlug: json['plan_slug'] as String?,
      price: json['price'],
      currency: json['currency'] as String?,
      durationDays: json['duration_days'] as int?,
      billingCycle: json['billing_cycle'] as String?,
      features: json['features'] is List ? List<String>.from(json['features']) : null,
      startDate: json['start_date'] as String?,
      expiryDate: json['expiry_date'] as String?,
      nextBillingDate: json['next_billing_date'] as String?,
      autoRenew: json['auto_renew'] as bool?,
      hasPaidSubscription: json['has_paid_subscription'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_active': isActive,
      'plan_name': planName,
      'plan_slug': planSlug,
      'price': price,
      'currency': currency,
      'duration_days': durationDays,
      'billing_cycle': billingCycle,
      'features': features,
      'start_date': startDate,
      'expiry_date': expiryDate,
      'next_billing_date': nextBillingDate,
      'auto_renew': autoRenew,
      'has_paid_subscription': hasPaidSubscription,
    };
  }
}

class ContentCreationConfig {
  final int? profileId;
  final bool? isActive;
  final String? channelName;
  final String? contentCategory;
  final String? platform;
  final String? bio;
  final int? subscribersCount;
  final ProfileSubscriptionDetails? subscriptionDetails;

  ContentCreationConfig({
    this.profileId,
    this.isActive,
    this.channelName,
    this.contentCategory,
    this.platform,
    this.bio,
    this.subscribersCount,
    this.subscriptionDetails,
  });

  factory ContentCreationConfig.fromJson(Map<String, dynamic> json) {
    return ContentCreationConfig(
      profileId: json['profile_id'] as int?,
      isActive: json['is_active'] as bool?,
      channelName: json['channel_name'] as String?,
      contentCategory: json['content_category'] as String?,
      platform: json['platform'] as String?,
      bio: json['bio'] as String?,
      subscribersCount: json['subscribers_count'] as int?,
      subscriptionDetails: json['subscription_details'] is Map<String, dynamic>
          ? ProfileSubscriptionDetails.fromJson(json['subscription_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'is_active': isActive,
      'channel_name': channelName,
      'content_category': contentCategory,
      'platform': platform,
      'bio': bio,
      'subscribers_count': subscribersCount,
      'subscription_details': subscriptionDetails?.toJson(),
    };
  }
}

class EmployerConfig {
  final int? profileId;
  final bool? isActive;
  final String? companyName;
  final String? industry;
  final String? companySize;
  final String? companyWebsite;
  final String? companyPhone;
  final String? companyAddress;
  final ProfileSubscriptionDetails? subscription;

  EmployerConfig({
    this.profileId,
    this.isActive,
    this.companyName,
    this.industry,
    this.companySize,
    this.companyWebsite,
    this.companyPhone,
    this.companyAddress,
    this.subscription,
  });

  factory EmployerConfig.fromJson(Map<String, dynamic> json) {
    return EmployerConfig(
      profileId: json['profile_id'] as int?,
      isActive: json['is_active'] as bool?,
      companyName: json['company_name'] as String?,
      industry: json['industry'] as String?,
      companySize: json['company_size'] as String?,
      companyWebsite: json['company_website'] as String?,
      companyPhone: json['company_phone'] as String?,
      companyAddress: json['company_address'] as String?,
      subscription: json['subscription'] is Map<String, dynamic>
          ? ProfileSubscriptionDetails.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'is_active': isActive,
      'company_name': companyName,
      'industry': industry,
      'company_size': companySize,
      'company_website': companyWebsite,
      'company_phone': companyPhone,
      'company_address': companyAddress,
      'subscription': subscription?.toJson(),
    };
  }
}

class MusicPlayConfig {
  final int? profileId;
  final bool? isActive;
  final String? artistName;
  final String? stageName;
  final String? genre;
  final String? label;
  final String? bio;
  final String? currentTrack;
  final String? playbackStatus;
  final int? volume;
  final ProfileSubscriptionDetails? subscription;

  MusicPlayConfig({
    this.profileId,
    this.isActive,
    this.artistName,
    this.stageName,
    this.genre,
    this.label,
    this.bio,
    this.currentTrack,
    this.playbackStatus,
    this.volume,
    this.subscription,
  });

  factory MusicPlayConfig.fromJson(Map<String, dynamic> json) {
    return MusicPlayConfig(
      profileId: json['profile_id'] as int?,
      isActive: json['is_active'] as bool?,
      artistName: json['artist_name'] as String?,
      stageName: json['stage_name'] as String?,
      genre: json['genre'] as String?,
      label: json['label'] as String?,
      bio: json['bio'] as String?,
      currentTrack: json['current_track'] as String?,
      playbackStatus: json['playback_status'] as String?,
      volume: json['volume'] as int?,
      subscription: json['subscription'] is Map<String, dynamic>
          ? ProfileSubscriptionDetails.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'is_active': isActive,
      'artist_name': artistName,
      'stage_name': stageName,
      'genre': genre,
      'label': label,
      'bio': bio,
      'current_track': currentTrack,
      'playback_status': playbackStatus,
      'volume': volume,
      'subscription': subscription?.toJson(),
    };
  }
}

class PersonalProfileConfig {
  final int? profileId;
  final bool? isActive;
  final ProfileSubscriptionDetails? subscription;

  PersonalProfileConfig({
    this.profileId,
    this.isActive,
    this.subscription,
  });

  factory PersonalProfileConfig.fromJson(Map<String, dynamic> json) {
    return PersonalProfileConfig(
      profileId: json['profile_id'] as int?,
      isActive: json['is_active'] as bool?,
      subscription: json['subscription'] is Map<String, dynamic>
          ? ProfileSubscriptionDetails.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'is_active': isActive,
      'subscription': subscription?.toJson(),
    };
  }
}

class EcommerceProduct {
  final bool? enabled;
  final int? totalProducts;
  final dynamic featuredProduct;

  EcommerceProduct({
    this.enabled,
    this.totalProducts,
    this.featuredProduct,
  });

  factory EcommerceProduct.fromJson(Map<String, dynamic> json) {
    return EcommerceProduct(
      enabled: json['enabled'] as bool?,
      totalProducts: json['total_products'] as int?,
      featuredProduct: json['featured_product'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'total_products': totalProducts,
      'featured_product': featuredProduct,
    };
  }
}

class EcommerceService {
  final bool? enabled;
  final int? totalServices;
  final List<dynamic>? activeServices;

  EcommerceService({
    this.enabled,
    this.totalServices,
    this.activeServices,
  });

  factory EcommerceService.fromJson(Map<String, dynamic> json) {
    return EcommerceService(
      enabled: json['enabled'] as bool?,
      totalServices: json['total_services'] as int?,
      activeServices: json['active_services'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'total_services': totalServices,
      'active_services': activeServices,
    };
  }
}

class EcommerceConfig {
  final int? profileId;
  final bool? isActive;
  final String? type;
  final String? sellerTypeLabel;
  final EcommerceProduct? product;
  final EcommerceService? service;
  final ProfileSubscriptionDetails? subscription;

  EcommerceConfig({
    this.profileId,
    this.isActive,
    this.type,
    this.sellerTypeLabel,
    this.product,
    this.service,
    this.subscription,
  });

  factory EcommerceConfig.fromJson(Map<String, dynamic> json) {
    return EcommerceConfig(
      profileId: json['profile_id'] as int?,
      isActive: json['is_active'] as bool?,
      type: json['type'] as String?,
      sellerTypeLabel: json['seller_type_label'] as String?,
      product: json['product'] is Map<String, dynamic> ? EcommerceProduct.fromJson(json['product']) : null,
      service: json['service'] is Map<String, dynamic> ? EcommerceService.fromJson(json['service']) : null,
      subscription: json['subscription'] is Map<String, dynamic>
          ? ProfileSubscriptionDetails.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'is_active': isActive,
      'type': type,
      'seller_type_label': sellerTypeLabel,
      'product': product?.toJson(),
      'service': service?.toJson(),
      'subscription': subscription?.toJson(),
    };
  }
}
