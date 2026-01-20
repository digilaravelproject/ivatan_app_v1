class VideoResponse {
  final List<RelatedVideoModel> data;
  final Links links;
  final Meta meta;

  VideoResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory VideoResponse.fromJson(Map<String, dynamic> json) => VideoResponse(
    data: (json['data'] as List<dynamic>?)
        ?.map((e) => RelatedVideoModel.fromJson(e))
        .toList() ??
        [],
    links: Links.fromJson(json['links'] ?? {}),
    meta: Meta.fromJson(json['meta'] ?? {}),
  );
}

class RelatedVideoModel {
  final int id;
  final String uuid;
  final String? type;
  final String? caption;
  final String? visibility;
  final bool isMine;
  final bool isFollowing;
  final UserModel user;
  final List<MediaModel> media;
  final ReelStats stats;
  final String? createdAt;
  final String? createdHuman;

  RelatedVideoModel({
    required this.id,
    required this.uuid,
    this.type,
    this.caption,
    this.visibility,
    required this.isMine,
    required this.isFollowing,
    required this.user,
    required this.media,
    required this.stats,
    this.createdAt,
    this.createdHuman,
  });

  factory RelatedVideoModel.fromJson(Map<String, dynamic> json) => RelatedVideoModel(
    id: json['id'] ?? 0,
    uuid: json['uuid'] ?? '',
    type: json['type'],
    caption: json['caption'],
    visibility: json['visibility'],
    isMine: json['is_mine'] ?? false,
    isFollowing: json['is_following'] ?? false,
    user: UserModel.fromJson(json['user'] ?? {}),
    media: (json['media'] as List<dynamic>?)
        ?.map((e) => MediaModel.fromJson(e))
        .toList() ??
        [],
    stats: ReelStats.fromJson(json['stats'] ?? {}),
    createdAt: json['created_at'],
    createdHuman: json['created_human'],
  );
}

class UserModel {
  final int id;
  final String name;
  final String username;
  final String? avatar;
  final bool isVerified;
  final String? interests;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatar,
    required this.isVerified,
    this.interests,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    username: json['username'] ?? '',
    avatar: json['avatar'],
    isVerified: json['is_verified'] ?? false,
    interests: json['interests'],
  );
}

class MediaModel {
  final int id;
  final String? type;
  final String? url;
  final String? thumbnail;
  final String? mimeType;
  final double? aspectRatio;

  MediaModel({
    required this.id,
    this.type,
    this.url,
    this.thumbnail,
    this.mimeType,
    this.aspectRatio,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) => MediaModel(
    id: json['id'] ?? 0,
    type: json['type'],
    url: json['url'],
    thumbnail: json['thumbnail'],
    mimeType: json['mime_type'],
    aspectRatio: (json['aspect_ratio'] != null)
        ? (json['aspect_ratio'] as num).toDouble()
        : null,
  );
}

class ReelStats {
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int viewCount;
  final bool isLiked;
  final bool isSaved;

  ReelStats({
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.viewCount,
    required this.isLiked,
    required this.isSaved,
  });

  factory ReelStats.fromJson(Map<String, dynamic> json) => ReelStats(
    likeCount: json['like_count'] ?? 0,
    commentCount: json['comment_count'] ?? 0,
    shareCount: json['share_count'] ?? 0,
    viewCount: json['view_count'] ?? 0,
    isLiked: json['is_liked'] ?? false,
    isSaved: json['is_saved'] ?? false,
  );
}

class Links {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  Links({this.first, this.last, this.prev, this.next});

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    first: json['first'],
    last: json['last'],
    prev: json['prev'],
    next: json['next'],
  );
}

class Meta {
  final int currentPage;
  final String? currentPageUrl;
  final int from;
  final String? path;
  final int perPage;
  final int to;

  Meta({
    required this.currentPage,
    this.currentPageUrl,
    required this.from,
    this.path,
    required this.perPage,
    required this.to,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json['current_page'] ?? 0,
    currentPageUrl: json['current_page_url'],
    from: json['from'] ?? 0,
    path: json['path'],
    perPage: json['per_page'] ?? 0,
    to: json['to'] ?? 0,
  );
}
