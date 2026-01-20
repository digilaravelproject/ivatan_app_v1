
class UserStoryGroup {
  final StoryUser user;
  final List<StoryModel> stories;
  final bool hasUnseen;

  UserStoryGroup({
    required this.user,
    required this.stories,
    required this.hasUnseen,
  });

  factory UserStoryGroup.fromJson(Map<String, dynamic> json) {
    return UserStoryGroup(
      user: StoryUser.fromJson(json['user']),
      stories: (json['stories'] as List)
          .map((s) => StoryModel.fromJson(s))
          .toList(),
      hasUnseen: json['has_unseen'] ?? false,
    );
  }
}


class StoryModel {
  final int id;
  final String type;
  final String caption;
  final String mediaUrl;
  final String thumbnailUrl;
  final String mimeType;
  int likeCount;
  final int viewCount;
  bool isLiked;
  final bool isViewed;
  final bool is_mine;
  final String expiresAt;
  final String createdAt;
  final String createdAtHuman;

  StoryModel({
    required this.id,
    required this.type,
    required this.caption,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.mimeType,
    required this.likeCount,
    required this.viewCount,
    required this.isLiked,
    required this.isViewed,
    required this.is_mine,
    required this.expiresAt,
    required this.createdAt,
    required this.createdAtHuman,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? "",
      caption: json['caption'] ?? "",
      mediaUrl: json['media_url'] ?? "",
      thumbnailUrl: json['thumbnail_url'] ?? "",
      mimeType: json['mime_type'] ?? "",
      likeCount: json['like_count'] ?? 0,
      viewCount: json['view_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isViewed: json['is_viewed'] ?? false,
      is_mine: json['is_mine'] ?? false,
      expiresAt: json['expires_at'] ?? "",
      createdAt: json['created_at'] ?? "",
      createdAtHuman: json['created_at_human'] ?? "",
    );
  }
}


class StoryUser {
  final int id;
  final String username;
  final String name;
  final String avatar;
  final bool isVerified;

  StoryUser({
    required this.id,
    required this.username,
    required this.name,
    required this.avatar,
    required this.isVerified,
  });

  factory StoryUser.fromJson(Map<String, dynamic> json) {
    return StoryUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? "",
      name: json['name'] ?? "",
      avatar: json['avatar'] ?? "",
      isVerified: json['is_verified'] ?? false,
    );
  }
}


