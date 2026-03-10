class UserModel {
  final int id;
  final String uuid;
  final String username;
  final String occupation;
  final String name;
  final String email;
  final bool isSeller;
  final String phone;
  final String? emailVerifiedAt;
  final String? dateOfBirth;
  final String? gender;
  final String languagePreference;
  final bool twoFactorEnabled;
  final String messagingPrivacy;
  final bool isOnline;
  final String? lastSeenAt;
  final String? deviceTokens;
  final int reputationScore;
  final String? emailNotificationPreferences;
  final String accountPrivacy;
  final String? profilePhotoPath;
  final String? bio;
  final String status;
  final bool isBlocked;
  final bool isVerified;
  final String? lastLoginAt;
  final int followersCount;
  final int followingCount;
  final String? settings;
  final int postsCount;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final bool isEmployer;
  final int hideEmail;
  final int hidePhone;
  final String? countryCode;
  final String? isoCode;

  /// FIX: Interests should be List<Map>
  final List<Map<String, dynamic>> interests;

  /// FIX: Token stored separately
  final String token;

  UserModel({
    required this.id,
    required this.uuid,
    required this.username,
    required this.occupation,
    required this.name,
    required this.email,
    required this.isSeller,
    required this.phone,
    this.emailVerifiedAt,
    this.dateOfBirth,
    this.gender,
    required this.languagePreference,
    required this.twoFactorEnabled,
    required this.messagingPrivacy,
    required this.isOnline,
    this.lastSeenAt,
    this.deviceTokens,
    required this.reputationScore,
    this.emailNotificationPreferences,
    required this.accountPrivacy,
    this.profilePhotoPath,
    this.bio,
    required this.status,
    required this.isBlocked,
    required this.isVerified,
    this.lastLoginAt,
    required this.followersCount,
    required this.followingCount,
    this.settings,
    required this.postsCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isEmployer,
    required this.hideEmail,
    required this.hidePhone,
    this.countryCode,
    this.isoCode,
    required this.interests,
    required this.token,
  });

  /// FIXED PARSER – supports both API & SharedPref
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json["user"] ?? json; // <— magic line

    return UserModel(
      id: data["id"] ?? 0,
      uuid: data["uuid"] ?? "",
      username: data["username"] ?? "",
      occupation: data["occupation"] ?? "",
      name: data["name"] ?? "",
      email: data["email"] ?? "",
      isSeller: data["is_seller"] ?? false,
      phone: data["phone"] ?? "",
      emailVerifiedAt: data["email_verified_at"],
      dateOfBirth: data["date_of_birth"],
      gender: data["gender"],
      languagePreference: data["language_preference"] ?? "",
      twoFactorEnabled: data["two_factor_enabled"] ?? false,
      messagingPrivacy: data["messaging_privacy"] ?? "",
      isOnline: data["is_online"] ?? false,
      lastSeenAt: data["last_seen_at"],
      deviceTokens: data["device_tokens"],
      reputationScore: data["reputation_score"] ?? 0,
      emailNotificationPreferences: data["email_notification_preferences"],
      accountPrivacy: data["account_privacy"] ?? "",
      profilePhotoPath: data["profile_photo_path"],
      bio: data["bio"],
      status: data["status"] ?? "",
      isBlocked: data["is_blocked"] ?? false,
      isVerified: data["is_verified"] ?? false,
      lastLoginAt: data["last_login_at"],
      followersCount: data["followers_count"] ?? 0,
      followingCount: data["following_count"] ?? 0,
      settings: data["settings"],
      postsCount: data["posts_count"] ?? 0,
      createdAt: data["created_at"] ?? "",
      updatedAt: data["updated_at"] ?? "",
      deletedAt: data["deleted_at"],
      isEmployer: data["is_employer"] ?? false,
      hideEmail: data["hide_email"] ?? 0,
      hidePhone: data["hide_phone"] ?? 0,
      countryCode: data["country_code"],
      isoCode: data["iso_code"],

      interests: List<Map<String, dynamic>>.from(data["interests"] ?? []),

      token: json["token"] ?? data["token"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "username": username,
    "occupation": occupation,
    "name": name,
    "email": email,
    "is_seller": isSeller,
    "phone": phone,
    "email_verified_at": emailVerifiedAt,
    "date_of_birth": dateOfBirth,
    "gender": gender,
    "language_preference": languagePreference,
    "two_factor_enabled": twoFactorEnabled,
    "messaging_privacy": messagingPrivacy,
    "is_online": isOnline,
    "last_seen_at": lastSeenAt,
    "device_tokens": deviceTokens,
    "reputation_score": reputationScore,
    "email_notification_preferences": emailNotificationPreferences,
    "account_privacy": accountPrivacy,
    "profile_photo_path": profilePhotoPath,
    "bio": bio,
    "status": status,
    "is_blocked": isBlocked,
    "is_verified": isVerified,
    "last_login_at": lastLoginAt,
    "followers_count": followersCount,
    "following_count": followingCount,
    "settings": settings,
    "posts_count": postsCount,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "is_employer": isEmployer,
    "hide_email": hideEmail,
    "hide_phone": hidePhone,
    "country_code": countryCode,
    "iso_code": isoCode,
    "interests": interests,
    "token": token,
  };
}
