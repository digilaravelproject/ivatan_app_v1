class CommentResponse {
  final bool success;
  final String message;
  final List<CommentModel> data;

  CommentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? []
          : (json["data"] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList(),
    );
  }
}

// =============================
//     COMMENT MODEL
// =============================
class CommentModel {
  final int id;
  final String commentableType;
  final int commentableId;
  final int? parentId;
  final String body;
  final String status;
  int likesCount;
  final int totalReplyCount;
  bool is_mine;
  bool hasLiked;
  final String createdAt;
  final String createdHuman;
  final UserModel? user;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.commentableType,
    required this.commentableId,
    required this.parentId,
    required this.body,
    required this.status,
    required this.likesCount,
    required this.totalReplyCount,
    required this.is_mine,
    required this.hasLiked,
    required this.createdAt,
    required this.createdHuman,
    required this.user,
    required this.replies,
  });

/*
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json["id"] ?? 0,
      commentableType: json["commentable_type"] ?? "",
      commentableId: json["commentable_id"] ?? 0,
      parentId: json["parent_id"],
      body: json["body"] ?? "",
      status: json["status"] ?? "",
      likesCount: json["likes_count"] ?? 0,
      totalReplyCount: json["total_reply_count"] ?? 0,
      hasLiked: json["has_liked"] ?? false,
      createdAt: json["created_at"] ?? "",
      createdHuman: json["created_human"] ?? "",
      user: json["user"] == null
          ? null
          : UserModel.fromJson(json["user"]),
      replies: json["replies"] == null
          ? []
          : (json["replies"] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList(),
    );
  }
*/


  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json["id"] ?? 0,
      commentableType: json["commentable_type"]?.toString() ?? "",
      commentableId: int.tryParse(json["commentable_id"].toString()) ?? 0,
      parentId: json["parent_id"] == null
          ? null
          : int.tryParse(json["parent_id"].toString()),
      body: json["body"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      likesCount: json["likes_count"] ?? 0,
      totalReplyCount: json["total_reply_count"] ?? 0,
      is_mine: json["is_mine"] ?? false,
      hasLiked: json["has_liked"] ?? false,
      createdAt: json["created_at"]?.toString() ?? "",
      createdHuman: json["created_human"]?.toString() ?? "",
      user: json["user"] == null ? null : UserModel.fromJson(json["user"]),
      replies: json["replies"] == null
          ? []
          : (json["replies"] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList(),
    );
  }

}

// =============================
//           USER MODEL
// =============================
class UserModel {
  final int id;
  final String username;
  final String name;
  final String occupation;
  final String avtar;
  final bool isSeller;
  final bool isVerified;
  final String status;
  final int followersCount;
  final int followingCount;
  final String interests;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.occupation,
    required this.avtar,
    required this.isSeller,
    required this.isVerified,
    required this.status,
    required this.followersCount,
    required this.followingCount,
    required this.interests,
  });

/*
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? 0,
      username: json["username"] ?? "",
      name: json["name"] ?? "",
      occupation: json["occupation"] ?? "",
      avtar: json["avtar"] ?? "",
      isSeller: json["is_seller"] ?? false,
      isVerified: json["is_verified"] ?? false,
      status: json["status"] ?? "",
      followersCount: json["followers_count"] ?? 0,
      followingCount: json["following_count"] ?? 0,
      interests: json["interests"] ?? "",
    );
  }
*/


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? 0,
      username: json["username"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      occupation: json["occupation"]?.toString() ?? "",
      avtar: json["avtar"]?.toString() ?? "",
      isSeller: json["is_seller"] ?? false,
      isVerified: json["is_verified"] ?? false,
      status: json["status"]?.toString() ?? "",
      followersCount: json["followers_count"] ?? 0,
      followingCount: json["following_count"] ?? 0,
      interests: json["interests"]?.toString() ?? "",
    );
  }



}
