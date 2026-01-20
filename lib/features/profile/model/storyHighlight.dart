import '../../dashboard/model/story_model.dart';

class HighlightStoryModel {
  final int id;
  final String title;
  final String cover_media_url;
  final int? coverMediaId;
  final List<StoryModel> stories;
  final String createdAt;

  HighlightStoryModel({
    required this.id,
    required this.title,
    required this.cover_media_url,
    required this.coverMediaId,
    required this.stories,
    required this.createdAt,
  });

  factory HighlightStoryModel.fromJson(Map<String, dynamic> json) {
    return HighlightStoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      cover_media_url: json["cover_media_url"] ,
      coverMediaId: json['cover_media_id'],
      createdAt: json['created_at'] ?? "",
      stories: json['stories'] != null
          ? List<StoryModel>.from(
        json['stories'].map((x) => StoryModel.fromJson(x)),
      )
          : [],
    );
  }
}

class HighlightStory {
  final int id;
  final String type;
  final String caption;
  final String mediaUrl;
  final String thumbnailUrl;
  final String mimeType;
  final int likeCount;
  final int viewCount;
  final bool isLiked;
  final bool isViewed;
  final String expiresAt;
  final String createdAtHuman;
  final String createdAt;

  HighlightStory({
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
    required this.expiresAt,
    required this.createdAtHuman,
    required this.createdAt,
  });

  factory HighlightStory.fromJson(Map<String, dynamic> json) {
    return HighlightStory(
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
      expiresAt: json['expires_at'] ?? "",
      createdAtHuman: json['created_at_human'] ?? "",
      createdAt: json['created_at'] ?? "",
    );
  }
}
