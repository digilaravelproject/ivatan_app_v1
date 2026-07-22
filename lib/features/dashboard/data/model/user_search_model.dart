class UserSearchResponse {
  final bool? success;
  final String? message;
  final List<UserSearchModel>? data;

  UserSearchResponse({
    this.success,
    this.message,
    this.data,
  });

  factory UserSearchResponse.fromJson(Map<String, dynamic> json) => UserSearchResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? [] : List<UserSearchModel>.from(json["data"]!.map((x) => UserSearchModel.fromJson(x))),
      );
}

class UserSearchModel {
  final int? id;
  final String? username;
  final String? name;
  final String? avtar;
  final bool? isVerified;
  final bool? isFollowedByAuthUser;
  final bool? isAuthUser;

  UserSearchModel({
    this.id,
    this.username,
    this.name,
    this.avtar,
    this.isVerified,
    this.isFollowedByAuthUser,
    this.isAuthUser,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) => UserSearchModel(
        id: json["id"],
        username: json["username"],
        name: json["name"],
        avtar: json["avtar"],
        isVerified: json["is_verified"],
        isFollowedByAuthUser: json["is_followed_by_auth_user"],
        isAuthUser: json["is_auth_user"],
      );
}
