/*class ReelModel {
  final int id;
  final String caption;
  final UserModel user;
  final List<MediaModel> media;
  final int likeCount;
  final int commentCount;
  final String createdAt;

  ReelModel({
    required this.id,
    required this.caption,
    required this.user,
    required this.media,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json["id"],
      caption: json["caption"] ?? "",
      user: UserModel.fromJson(json["user"]),
      media: (json["media"] as List)
          .map((e) => MediaModel.fromJson(e))
          .toList(),
      likeCount: json["like_count"] ?? 0,
      commentCount: json["comment_count"] ?? 0,
      createdAt: json["created_at"] ?? "",
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String username;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"] ?? "",
      username: json["username"] ?? "",
    );
  }
}

class MediaModel {
  final int id;
  final String url;
  final String? thumb;
  final String mimeType;

  MediaModel({
    required this.id,
    required this.url,
    required this.thumb,
    required this.mimeType,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json["id"],
      url: json["url"],
      thumb: json["thumb"],
      mimeType: json["mime_type"],
    );
  }
}*/




import 'package:get/get_rx/src/rx_types/rx_types.dart';

class ReelModel {
  final int id;
  final String uuid;
  final String caption;
  final bool isMine;
  final bool isFollowing;
  final UserModel user;
  final List<MediaModel> media;
  final ReelStats stats;
  final String createdAt;
  final String createdHuman;

  ReelModel({
    required this.id,
    required this.uuid,
    required this.caption,
    required this.isMine,
    required this.isFollowing,
    required this.user,
    required this.media,
    required this.stats,
    required this.createdAt,
    required this.createdHuman,
  });

  /// 🔥 SAFE video url getter
  String? get videoUrl =>
      media.isNotEmpty ? media.first.url : null;

  String? get thumbnail =>
      media.isNotEmpty ? media.first.thumbnail : null;

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json["id"],
      uuid: json["uuid"],
      caption: json["caption"] ?? "",
      isMine: json["is_mine"] ?? false,
      isFollowing: json["is_following"] ?? false,
      user: UserModel.fromJson(json["user"]),
      media: (json["media"] as List? ?? [])
          .map((e) => MediaModel.fromJson(e))
          .toList(),
      stats: ReelStats.fromJson(json["stats"] ?? {}),
      createdAt: json["created_at"] ?? "",
      createdHuman: json["created_human"] ?? "",
    );
  }
}


class ReelStats {
  //RxInt likeCount;
  int likeCount;
  int commentCount;
  final int shareCount;
  final int viewCount;
  bool isLiked;
  final bool isSaved;

  ReelStats({
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.viewCount,
    required this.isLiked,
    required this.isSaved,
  });

  factory ReelStats.fromJson(Map<String, dynamic> json) {
    return ReelStats(
      likeCount: json["like_count"] ?? 0,  // wrap int as RxInt
      commentCount: json["comment_count"] ?? 0,
      shareCount: json["share_count"] ?? 0,
      viewCount: json["view_count"] ?? 0,
      isLiked: json["is_liked"] ?? false, // wrap bool as RxBool
      isSaved: json["is_saved"] ?? false,
    );
  }

}



class UserModel {
  final int id;
  final String name;
  final String username;
  final String avatar;
  final bool isVerified;
  final String interests;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.isVerified,
    required this.interests,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"] ?? "",
      username: json["username"] ?? "",
      avatar: json["avatar"] ?? "",
      isVerified: json["is_verified"] ?? false,
      interests: json["interests"] ?? "",
    );
  }
}


class MediaModel {
  final int id;
  final String type;
  final String url;
  final String thumbnail;
  final String mimeType;

  MediaModel({
    required this.id,
    required this.type,
    required this.url,
    required this.thumbnail,
    required this.mimeType,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json["id"],
      type: json["type"],
      url: json["url"],
      thumbnail: json["thumbnail"] ?? json["url"],
      mimeType: json["mime_type"] ?? "",
    );
  }
}

