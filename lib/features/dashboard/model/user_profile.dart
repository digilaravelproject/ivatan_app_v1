class UserDetailsModel {
  final bool? status;
  final String? message;
  final UserData? user;

  UserDetailsModel({this.status, this.message, this.user});

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      status: json['status'],
      message: json['message'],
      user: json['data'] != null && json['data']['user'] != null
          ? UserData.fromJson(json['data']['user'])
          : null,
    );
  }
}

/*class UserData {
  final int? id;
  final String? uuid;
  final String? username;
  final String? occupation;
  final String? name;
  final String? email;
  final bool? isSeller;
  final String? phone;
  final String? dateOfBirth;
  final String? languagePreference;
  final String? messagingPrivacy;
  final bool? isOnline;
  final String? lastLoginAt;
  final int? followersCount;
  final int? followingCount;
  final int? postsCount;
  final String? bio;
  final String? status;
  final bool? isBlocked;
  final bool? isVerified;
  final String? createdAt;
  final List<String>? interests;

  UserData({
    this.id,
    this.uuid,
    this.username,
    this.occupation,
    this.name,
    this.email,
    this.isSeller,
    this.phone,
    this.dateOfBirth,
    this.languagePreference,
    this.messagingPrivacy,
    this.isOnline,
    this.lastLoginAt,
    this.followersCount,
    this.followingCount,
    this.postsCount,
    this.bio,
    this.status,
    this.isBlocked,
    this.isVerified,
    this.createdAt,
    this.interests,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json["id"],
      uuid: json["uuid"],
      username: json["username"],
      occupation: json["occupation"],
      name: json["name"],
      email: json["email"],
      isSeller: json["is_seller"],
      phone: json["phone"],
      dateOfBirth: json["date_of_birth"],
      languagePreference: json["language_preference"],
      messagingPrivacy: json["messaging_privacy"],
      isOnline: json["is_online"],
      lastLoginAt: json["last_login_at"],
      followersCount: json["followers_count"],
      followingCount: json["following_count"],
      postsCount: json["posts_count"],
      bio: json["bio"],
      status: json["status"],
      isBlocked: json["is_blocked"],
      isVerified: json["is_verified"],
      createdAt: json["created_at"],
      interests: json["interests"] != null
          ? List<String>.from(json["interests"].map((e) => e["name"].toString()))
          : [],
      // interests: json["interests"] != null
      //     ? List<String>.from(json["interests"])
      //     : [],
    );
  }
}*/



class UserData {
  final int? id;
  final String? uuid;
  final String? username;
  final String? occupation;
  final String? name;
  final String? email;
  final bool? isSeller;
  final String? phone;
  final String? emailVerifiedAt;
  final String? dateOfBirth;
  final String? gender;
  final String? languagePreference;
  final bool? twoFactorEnabled;
  final String? messagingPrivacy;
  final bool? isOnline;
  final String? lastSeenAt;
  final String? deviceTokens;
  final int? reputationScore;
  final dynamic emailNotificationPreferences;
  final String? accountPrivacy;
  final String? profilePhotoPath;
  final String? bio;
  final String? status;
  final bool? isBlocked;
  final bool? isVerified;
  final String? lastLoginAt;
  final int? followersCount;
  final int? followingCount;
  final Map<String, dynamic>? settings;
  final int? postsCount;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final bool? isEmployer;
  final List<dynamic>? interests;
  bool? is_mine;
  bool? is_following;
  bool? is_follower;
  int? chat_id;
  String? contactVisibility; // 'both', 'phone', 'email', 'none'

  UserData({
    this.id,
    this.uuid,
    this.username,
    this.occupation,
    this.name,
    this.email,
    this.isSeller,
    this.phone,
    this.emailVerifiedAt,
    this.dateOfBirth,
    this.gender,
    this.languagePreference,
    this.twoFactorEnabled,
    this.messagingPrivacy,
    this.isOnline,
    this.lastSeenAt,
    this.deviceTokens,
    this.reputationScore,
    this.emailNotificationPreferences,
    this.accountPrivacy,
    this.profilePhotoPath,
    this.bio,
    this.status,
    this.isBlocked,
    this.isVerified,
    this.lastLoginAt,
    this.followersCount,
    this.followingCount,
    this.settings,
    this.postsCount,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isEmployer,
    this.interests,
    this.is_mine,
    this.is_following,
    this.is_follower,
    this.chat_id,
    this.contactVisibility
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json["id"],
      uuid: json["uuid"],
      username: json["username"],
      occupation: json["occupation"],
      name: json["name"],
      email: json["email"],
      isSeller: json["is_seller"] == true || json["is_seller"] == 1 || json["is_seller"] == "1",
      phone: json["phone"],
      emailVerifiedAt: json["email_verified_at"],
      dateOfBirth: json["date_of_birth"],
      gender: json["gender"],
      languagePreference: json["language_preference"],
      twoFactorEnabled: json["two_factor_enabled"] == true || json["two_factor_enabled"] == 1 || json["two_factor_enabled"] == "1",
      messagingPrivacy: json["messaging_privacy"],
      isOnline: json["is_online"],
      lastSeenAt: json["last_seen_at"],
      deviceTokens: json["device_tokens"],
      reputationScore: json["reputation_score"],
      emailNotificationPreferences: json["email_notification_preferences"],
      accountPrivacy: json["account_privacy"],
      profilePhotoPath: json["profile_photo_path"],
      bio: json["bio"],
      status: json["status"],
      isBlocked: json["is_blocked"],
      isVerified: json["is_verified"],
      lastLoginAt: json["last_login_at"],
      followersCount: json["followers_count"],
      followingCount: json["following_count"],
      settings: json["settings"],
      postsCount: json["posts_count"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      deletedAt: json["deleted_at"],
      isEmployer: json["is_employer"] == true || json["is_employer"] == 1 || json["is_employer"] == "1",
      interests: json["interests"] is List 
          ? json["interests"] 
          : [],
      is_mine: json["is_mine"],
      is_following: json["is_following"],
      is_follower: json["is_follower"],
      chat_id: json["chat_id"],
      contactVisibility: json["contact_visibility"] ?? 'both'
    );
  }
}
