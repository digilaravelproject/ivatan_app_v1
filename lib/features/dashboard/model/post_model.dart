/*
class PostResponse {
  List<PostModel> data;

  PostResponse({required this.data});

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      data: (json["data"] as List)
          .map((e) => PostModel.fromJson(e))
          .toList(),
    );
  }
}

class PostModel {
  int id;
  String type;
  String caption;
  PostUser user;
  List<PostMedia> media;
  int likeCount;
  int commentCount;
  String createdAt;

  PostModel({
    required this.id,
    required this.type,
    required this.caption,
    required this.user,
    required this.media,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json["id"],
      type: json["type"],
      caption: json["caption"],
      user: PostUser.fromJson(json["user"]),
      media:
      (json["media"] as List).map((e) => PostMedia.fromJson(e)).toList(),
      likeCount: json["like_count"],
      commentCount: json["comment_count"],
      createdAt: json["created_at"],
    );
  }
}

class PostUser {
  int id;
  String name;
  String username;

  PostUser({required this.id, required this.name, required this.username});

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json["id"],
      name: json["name"],
      username: json["username"],
    );
  }
}

class PostMedia {
  int id;
  String url;
  String thumb;
  String mimeType;
  MediaMeta meta;

  PostMedia({
    required this.id,
    required this.url,
    required this.thumb,
    required this.mimeType,
    required this.meta,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json["id"],
      url: json["url"],
      thumb: json["thumb"],
      mimeType: json["mime_type"],
      meta: MediaMeta.fromJson(json["meta"]),
    );
  }
}

class MediaMeta {
  int width;
  int height;

  MediaMeta({
    required this.width,
    required this.height,
  });

  factory MediaMeta.fromJson(Map<String, dynamic> json) {
    return MediaMeta(
      width: json["width"],
      height: json["height"],
    );
  }
}
*/

class FeedResponse {
  List<PostItem> data;

  FeedResponse({required this.data});

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      data: json["data"] != null
          ? List<PostItem>.from(
          json["data"].map((e) => PostItem.fromJson(e)))
          : [],
    );
  }
}

class PostItem {
  int id;
  String uuid;
  String type;
  String caption;
  String visibility;
  bool is_mine;
  bool is_following;
  PostUser user;
  List<PostMedia> media;
  PostStats stats;
  String createdAt;
  String createdHuman;
  bool? isPurchased;
  double? price;
  bool? hasAccess;
  bool? isExclusive;
  String? exclusiveStatus;
  String? purchaseStatus;

  PostItem({
    required this.id,
    required this.uuid,
    required this.type,
    required this.caption,
    required this.visibility,
    required this.is_mine,
    required this.is_following,
    required this.user,
    required this.media,
    required this.stats,
    required this.createdAt,
    required this.createdHuman,
    this.isPurchased,
    this.price,
    this.hasAccess,
    this.isExclusive,
    this.exclusiveStatus,
    this.purchaseStatus,
  });

  factory PostItem.fromJson(Map<String, dynamic> json) {
    return PostItem(
      id: json["id"] ?? 0,
      uuid: (json["uuid"] ?? "").toString(),
      type: (json["type"] ?? "").toString(),
      caption: (json["caption"] ?? "").toString(),
      visibility: (json["visibility"] ?? "").toString(),
      is_mine:  json["is_mine"] ?? false,
      is_following :json["is_following"] ?? false,
      user: PostUser.fromJson(json["user"] ?? {}),
      media: json["media"] != null
          ? List<PostMedia>.from(
          (json["media"] as List).map((x) => PostMedia.fromJson(x)))
          : [],
      stats: PostStats.fromJson(json["stats"] ?? {}),
      createdAt: (json["created_at"] ?? "").toString(),
      createdHuman: (json["created_human"] ?? "").toString(),
      isPurchased: json["is_purchased"],
      price: json["price"] != null ? double.tryParse(json["price"].toString()) : null,
      hasAccess: json["has_access"],
      isExclusive: json["is_exclusive"],
      exclusiveStatus: json["exclusive_status"]?.toString(),
      purchaseStatus: json["purchase_status"]?.toString(),
    );
  }
}

class PostUser {
  int id;
  String name;
  String username;
  String occupation;
  String avatar;
  bool isVerified;
  String interests;

  PostUser({
    required this.id,
    required this.name,
    required this.username,
    required this.occupation,
    required this.avatar,
    required this.isVerified,
    required this.interests
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json["id"] ?? 0,
      name: (json["name"] ?? "").toString(),
      username: (json["username"] ?? "").toString(),
        occupation: (json["occupation"] ?? "").toString(),
      avatar: (json["avatar"] ?? "").toString(),
      isVerified: json["is_verified"] ?? false,
      interests: (json["interests"] ?? "").toString()
    );
  }
}

class PostMedia {
  int id;
  String type;
  String url;
  String thumbnail;
  String mimeType;
  String aspectRatio;

  PostMedia({
    required this.id,
    required this.type,
    required this.url,
    required this.thumbnail,
    required this.mimeType,
    required this.aspectRatio,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json["id"] ?? 0,
      type: (json["type"] ?? "").toString(),
      url: (json["url"] ?? "").toString(),
      thumbnail: (json["thumbnail"] ?? "").toString(),
      mimeType: (json["mime_type"] ?? "").toString(),
      aspectRatio: (json["aspect_ratio"] ?? "").toString(),
    );
  }
}

class PostStats {
  int likeCount;
  int shareCount;
  int commentCount;
  int viewCount;
  bool isLiked;
  bool isSaved;
  bool isBlocked;

  PostStats({
    required this.likeCount,
    required this.shareCount,
    required this.commentCount,
    required this.viewCount,
    required this.isLiked,
    required this.isSaved,
    required this.isBlocked,
  });

  factory PostStats.fromJson(Map<String, dynamic> json) {
    return PostStats(
      likeCount: json["like_count"] ?? 0,
      shareCount: json["share_count"] ?? 0,
      commentCount: json["comment_count"] ?? 0,
      viewCount: json["view_count"] ?? 0,
      isLiked: json["is_liked"] ?? false,
      isSaved: json["is_saved"] ?? false,
      isBlocked: json["is_blocked"] ?? false,
    );
  }
}


/*class PostResponse {
  List<PostModel> data;

  PostResponse({required this.data});

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      data: (json["data"] is List)
          ? (json["data"] as List)
          .where((e) => e is Map)
          .map((e) => PostModel.fromJson(e))
          .toList()
          : [],
    );
  }
}

class PostModel {
  int id;
  String type;
  String caption;
  PostUser user;
  List<PostMedia> media;
  int likeCount;
  int commentCount;
  String createdAt;

  PostModel({
    required this.id,
    required this.type,
    required this.caption,
    required this.user,
    required this.media,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json["id"] ?? 0,
      type: json["type"] ?? "",
      caption: json["caption"] ?? "",
      user: (json["user"] is Map)
          ? PostUser.fromJson(json["user"])
          : PostUser(id: 0, name: "", username: ""),
      media: (json["media"] is List)
          ? (json["media"] as List)
          .where((e) => e is Map)
          .map((e) => PostMedia.fromJson(e))
          .toList()
          : [],
      likeCount: json["like_count"] ?? 2,
      commentCount: json["comment_count"] ?? 0,
      createdAt: json["created_at"] ?? "",
    );
  }
}

class PostUser {
  int id;
  String name;
  String username;

  PostUser({
    required this.id,
    required this.name,
    required this.username,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      username: json["username"] ?? "",
    );
  }
}

class PostMedia {
  int id;
  String url;
  String thumb;
  String mimeType;
  MediaMeta meta;

  PostMedia({
    required this.id,
    required this.url,
    required this.thumb,
    required this.mimeType,
    required this.meta,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json["id"] ?? 0,
      url: json["url"] ?? "",
      thumb: json["thumb"] ?? "",
      mimeType: json["mime_type"] ?? "",
      meta: (json["meta"] is Map)
          ? MediaMeta.fromJson(json["meta"])
          : MediaMeta(width: 0, height: 0),
    );
  }
}

class MediaMeta {
  int width;
  int height;

  MediaMeta({
    required this.width,
    required this.height,
  });

  factory MediaMeta.fromJson(Map<String, dynamic> json) {
    return MediaMeta(
      width: json["width"] ?? 0,
      height: json["height"] ?? 0,
    );
  }
}*/


