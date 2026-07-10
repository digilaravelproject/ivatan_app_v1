class BlockedUserResponse {
  final bool? success;
  final List<BlockedUserModel>? data;
  final Pagination? pagination;

  BlockedUserResponse({
    this.success,
    this.data,
    this.pagination,
  });

  factory BlockedUserResponse.fromJson(Map<String, dynamic> json) => BlockedUserResponse(
        success: json["success"],
        data: json["data"] == null ? [] : List<BlockedUserModel>.from(json["data"]!.map((x) => BlockedUserModel.fromJson(x))),
        pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
      );
}

class BlockedUserModel {
  final int? id;
  final String? name;
  final String? username;
  final String? avatar;
  final bool? isVerified;
  final DateTime? blockedAt;
  final String? blockedHuman;

  BlockedUserModel({
    this.id,
    this.name,
    this.username,
    this.avatar,
    this.isVerified,
    this.blockedAt,
    this.blockedHuman,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) => BlockedUserModel(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        avatar: json["avatar"],
        isVerified: json["is_verified"],
        blockedAt: json["blocked_at"] == null ? null : DateTime.tryParse(json["blocked_at"]),
        blockedHuman: json["blocked_human"],
      );
}

class Pagination {
  final int? currentPage;
  final int? perPage;
  final int? total;
  final int? lastPage;
  final bool? hasMore;

  Pagination({
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
    this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: json["current_page"],
        perPage: json["per_page"],
        total: json["total"],
        lastPage: json["last_page"],
        hasMore: json["has_more"],
      );
}
