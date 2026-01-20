/*class PostResponse {
  final List<PostData> data;
  final Links links;
  final Meta meta;

  PostResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => PostData.fromJson(item))
          .toList() ??
          [],
      links: json['links'] != null ? Links.fromJson(json['links']) : Links.empty(),
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : Meta.empty(),
    );
  }
}

// --------------------- DATA MODEL ---------------------

class PostData {
  final int id;
  final String type;
  final String caption;
  final PostUser user;
  final List<PostMedia> media;
  final int likeCount;
  final int commentCount;
  final String createdAt;

  PostData({
    required this.id,
    required this.type,
    required this.caption,
    required this.user,
    required this.media,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory PostData.fromJson(Map<String, dynamic> json) {
    return PostData(
      id: json['id'] ?? 0,
      type: json['type'] ?? "",
      caption: json['caption'] ?? "",
      user: json['user'] != null ? PostUser.fromJson(json['user']) : PostUser.empty(),
      media: (json['media'] as List<dynamic>?)
          ?.map((item) => PostMedia.fromJson(item))
          .toList() ??
          [],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      createdAt: json['created_at'] ?? "",
    );
  }
}

// --------------------- USER MODEL ---------------------

class PostUser {
  final int id;
  final String name;
  final String username;

  PostUser({required this.id, required this.name, required this.username});

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      username: json['username'] ?? "",
    );
  }

  factory PostUser.empty() => PostUser(id: 0, name: "", username: "");
}

// --------------------- MEDIA MODEL ---------------------

class PostMedia {
  final int id;
  final String url;
  final String thumbnail;
  final String mimeType;

  PostMedia({
    required this.id,
    required this.url,
    required this.thumbnail,
    required this.mimeType,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json['id'] ?? 0,
      url: json['url'] ?? "",
      thumbnail: json['thumbnail'] ?? "",
      mimeType: json['mime_type'] ?? "",
    );
  }
}

// --------------------- LINKS MODEL ---------------------

class Links {
  final String first;
  final String last;
  final String prev;
  final String next;

  Links({
    required this.first,
    required this.last,
    required this.prev,
    required this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'] ?? "",
      last: json['last'] ?? "",
      prev: json['prev']?.toString() ?? "",
      next: json['next']?.toString() ?? "",
    );
  }

  factory Links.empty() => Links(first: "", last: "", prev: "", next: "");
}

// --------------------- META MODEL ---------------------

class Meta {
  final int currentPage;
  final int from;
  final int lastPage;
  final int to;
  final int total;

  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.to,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'] ?? 0,
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  factory Meta.empty() =>
      Meta(currentPage: 0, from: 0, lastPage: 0, to: 0, total: 0);
}*/


class TrendingResponse {
  List<TrendingPost> data;
  Links links;
  Meta meta;

  TrendingResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory TrendingResponse.fromJson(Map<String, dynamic> json) => TrendingResponse(
    data: List<TrendingPost>.from(json["data"].map((x) => TrendingPost.fromJson(x))),
    links: Links.fromJson(json["links"]),
    meta: Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "links": links.toJson(),
    "meta": meta.toJson(),
  };
}

// post
class TrendingPost {
  int id;
  String uuid;
  String type;
  String? caption;
  String visibility;
  bool isMine;
  bool isFollowing;
  User user;
  List<Media> media;
  Stats stats;
  DateTime createdAt;
  String createdHuman;

  TrendingPost({
    required this.id,
    required this.uuid,
    required this.type,
    this.caption,
    required this.visibility,
    required this.isMine,
    required this.isFollowing,
    required this.user,
    required this.media,
    required this.stats,
    required this.createdAt,
    required this.createdHuman,
  });

  factory TrendingPost.fromJson(Map<String, dynamic> json) => TrendingPost(
    id: json["id"],
    uuid: json["uuid"],
    type: json["type"],
    caption: json["caption"],
    visibility: json["visibility"],
    isMine: json["is_mine"],
    isFollowing: json["is_following"],
    user: User.fromJson(json["user"]),
    media: List<Media>.from(json["media"].map((x) => Media.fromJson(x))),
    stats: Stats.fromJson(json["stats"]),
    createdAt: DateTime.parse(json["created_at"]),
    createdHuman: json["created_human"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "type": type,
    "caption": caption,
    "visibility": visibility,
    "is_mine": isMine,
    "is_following": isFollowing,
    "user": user.toJson(),
    "media": List<dynamic>.from(media.map((x) => x.toJson())),
    "stats": stats.toJson(),
    "created_at": createdAt.toIso8601String(),
    "created_human": createdHuman,
  };
}

// user
class User {
  int id;
  String name;
  String username;
  String avatar;
  bool isVerified;
  String interests;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.isVerified,
    required this.interests,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    username: json["username"],
    avatar: json["avatar"],
    isVerified: json["is_verified"],
    interests: json["interests"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "username": username,
    "avatar": avatar,
    "is_verified": isVerified,
    "interests": interests,
  };
}

// media
class Media {
  int id;
  String type;
  String url;
  String thumbnail;
  String mimeType;
  dynamic aspectRatio;

  Media({
    required this.id,
    required this.type,
    required this.url,
    required this.thumbnail,
    required this.mimeType,
    this.aspectRatio,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    id: json["id"],
    type: json["type"],
    url: json["url"],
    thumbnail: json["thumbnail"],
    mimeType: json["mime_type"],
    aspectRatio: json["aspect_ratio"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "url": url,
    "thumbnail": thumbnail,
    "mime_type": mimeType,
    "aspect_ratio": aspectRatio,
  };
}

// stats
class Stats {
  int likeCount;
  int commentCount;
  int shareCount;
  int viewCount;
  bool isLiked;
  bool isSaved;

  Stats({
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.viewCount,
    required this.isLiked,
    required this.isSaved,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    likeCount: json["like_count"],
    commentCount: json["comment_count"],
    shareCount: json["share_count"],
    viewCount: json["view_count"],
    isLiked: json["is_liked"],
    isSaved: json["is_saved"],
  );

  Map<String, dynamic> toJson() => {
    "like_count": likeCount,
    "comment_count": commentCount,
    "share_count": shareCount,
    "view_count": viewCount,
    "is_liked": isLiked,
    "is_saved": isSaved,
  };
}

// links
class Links {
  String first;
  String? last;
  String? prev;
  String? next;

  Links({
    required this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    first: json["first"],
    last: json["last"],
    prev: json["prev"],
    next: json["next"],
  );

  Map<String, dynamic> toJson() => {
    "first": first,
    "last": last,
    "prev": prev,
    "next": next,
  };
}

// meta
class Meta {
  int currentPage;
  String currentPageUrl;
  int from;
  String path;
  int perPage;
  int to;

  Meta({
    required this.currentPage,
    required this.currentPageUrl,
    required this.from,
    required this.path,
    required this.perPage,
    required this.to,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"],
    currentPageUrl: json["current_page_url"],
    from: json["from"],
    path: json["path"],
    perPage: json["per_page"],
    to: json["to"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "current_page_url": currentPageUrl,
    "from": from,
    "path": path,
    "per_page": perPage,
    "to": to,
  };
}
