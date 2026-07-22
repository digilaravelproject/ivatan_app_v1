class ExclusiveStatsModel {
  final GlobalStats globalStats;
  final SpotlightStats spotlight;

  ExclusiveStatsModel({
    required this.globalStats,
    required this.spotlight,
  });

  factory ExclusiveStatsModel.fromJson(Map<String, dynamic> json) {
    return ExclusiveStatsModel(
      globalStats: GlobalStats.fromJson(json['global_stats'] ?? {}),
      spotlight: SpotlightStats.fromJson(json['spotlight'] ?? {}),
    );
  }
}

class GlobalStats {
  final int totalViews;
  final double totalEarnings;
  final int totalPurchases;
  final int totalExclusiveContent;

  GlobalStats({
    required this.totalViews,
    required this.totalEarnings,
    required this.totalPurchases,
    required this.totalExclusiveContent,
  });

  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    return GlobalStats(
      totalViews: json['global_total_views'] ?? 0,
      totalEarnings: double.tryParse(json['global_total_earnings']?.toString() ?? '0') ?? 0.0,
      totalPurchases: json['global_total_purchases'] ?? 0,
      totalExclusiveContent: json['global_total_exclusive_content'] ?? 0,
    );
  }
}

class SpotlightStats {
  final SpotlightItem? mostViewed;
  final SpotlightItem? mostPurchased;
  final SpotlightItem? highestEarning;

  SpotlightStats({
    this.mostViewed,
    this.mostPurchased,
    this.highestEarning,
  });

  factory SpotlightStats.fromJson(Map<String, dynamic> json) {
    return SpotlightStats(
      mostViewed: json['most_viewed'] != null ? SpotlightItem.fromJson(json['most_viewed']) : null,
      mostPurchased: json['most_purchased'] != null ? SpotlightItem.fromJson(json['most_purchased']) : null,
      highestEarning: json['highest_earning'] != null ? SpotlightItem.fromJson(json['highest_earning']) : null,
    );
  }
}

class SpotlightItem {
  final int id;
  final String uuid;
  final String type;
  final String caption;
  final double price;
  final String createdAt;
  final int viewsCount;
  final int purchasesCount;
  final double totalEarnings;
  final String thumbnailUrl;

  SpotlightItem({
    required this.id,
    required this.uuid,
    required this.type,
    required this.caption,
    required this.price,
    required this.createdAt,
    required this.viewsCount,
    required this.purchasesCount,
    required this.totalEarnings,
    required this.thumbnailUrl,
  });

  factory SpotlightItem.fromJson(Map<String, dynamic> json) {
    return SpotlightItem(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      type: json['type'] ?? '',
      caption: json['caption'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] ?? '',
      viewsCount: json['views_count'] ?? 0,
      purchasesCount: json['purchases_count'] ?? 0,
      totalEarnings: double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0.0,
      thumbnailUrl: json['thumbnail_url'] ?? '',
    );
  }
}
