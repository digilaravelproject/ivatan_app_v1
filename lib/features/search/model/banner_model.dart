class BannerResponse {
  final bool success;
  final String message;
  final List<BannerModel> data;

  BannerResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => BannerModel.fromJson(e))
          .toList(),
    );
  }
}

class BannerModel {
  final int id;
  final String title;
  final String type;
  final String mediaUrl;
  final DateTime createdAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.type,
    required this.mediaUrl,
    required this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      mediaUrl: json['media_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
