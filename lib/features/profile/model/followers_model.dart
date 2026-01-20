class FollowersResponse {
  final List<UserFollower> data;
  final Links links;
  final Meta meta;

  FollowersResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory FollowersResponse.fromJson(Map<String, dynamic> json) {
    return FollowersResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => UserFollower.fromJson(e))
          .toList(),
      links: Links.fromJson(json['links'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }
}

class UserFollower {
  final int id; 
  final String username;
  final String name;
  final String? avatar;
  final bool isVerified;
  bool isFollowedByAuthUser;
  final bool isAuthUser;

  UserFollower({
    required this.id,
    required this.username,
    required this.name,
    required this.avatar,
    required this.isVerified,
    required this.isFollowedByAuthUser,
    required this.isAuthUser,
  });

  factory UserFollower.fromJson(Map<String, dynamic> json) {
    return UserFollower(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avtar'], // can be null
      isVerified: json['is_verified'] ?? false,
      isFollowedByAuthUser: json['is_followed_by_auth_user'] ?? false,
      isAuthUser: json['is_auth_user'] ?? false,
    );
  }
}

class Links {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  Links({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class Meta {
  final int currentPage;
  final String? currentPageUrl;
  final int? from;
  final String? path;
  final int perPage;
  final int? to;

  Meta({
    required this.currentPage,
    this.currentPageUrl,
    this.from,
    this.path,
    required this.perPage,
    this.to,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'] ?? 1,
      currentPageUrl: json['current_page_url'],
      from: json['from'],
      path: json['path'],
      perPage: json['per_page'] ?? 0,
      to: json['to'],
    );
  }
}
