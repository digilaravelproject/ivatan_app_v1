class ExclusiveContentItemModel {
  final int id;
  final String uuid;
  final String type;
  final String caption;
  final double price;
  final String createdAt;
  final int totalViews;
  final double totalEarnings;
  final int totalPurchaseCount;
  final int totalPurchaseUsers;
  final int purchasedUserViews;
  final String thumbnailUrl;

  ExclusiveContentItemModel({
    required this.id,
    required this.uuid,
    required this.type,
    required this.caption,
    required this.price,
    required this.createdAt,
    required this.totalViews,
    required this.totalEarnings,
    required this.totalPurchaseCount,
    required this.totalPurchaseUsers,
    required this.purchasedUserViews,
    required this.thumbnailUrl,
  });

  factory ExclusiveContentItemModel.fromJson(Map<String, dynamic> json) {
    return ExclusiveContentItemModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      type: json['type'] ?? '',
      caption: json['caption'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] ?? '',
      totalViews: json['total_views'] ?? 0,
      totalEarnings: double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0.0,
      totalPurchaseCount: json['total_purchase_count'] ?? 0,
      totalPurchaseUsers: json['total_purchase_users'] ?? 0,
      purchasedUserViews: json['purchased_user_views'] ?? 0,
      thumbnailUrl: json['thumbnail_url'] ?? '',
    );
  }
}
