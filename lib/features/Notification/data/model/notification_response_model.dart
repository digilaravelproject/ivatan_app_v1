class NotificationsResponseModel {
  final bool success;
  final NotificationsData? data;

  NotificationsResponseModel({
    required this.success,
    this.data,
  });

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? NotificationsData.fromJson(json['data']) : null,
    );
  }
}

class NotificationsData {
  final int currentPage;
  final List<NotificationApiItem> data;
  final int lastPage;
  final int total;

  NotificationsData({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<NotificationApiItem> dataList = list.map((i) => NotificationApiItem.fromJson(i)).toList();

    return NotificationsData(
      currentPage: json['current_page'] ?? 1,
      data: dataList,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

class NotificationApiItem {
  final String id;
  final String type;
  final NotificationInnerData? innerData;
  final String? readAt;
  final String createdAt;

  NotificationApiItem({
    required this.id,
    required this.type,
    this.innerData,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationApiItem.fromJson(Map<String, dynamic> json) {
    return NotificationApiItem(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      innerData: json['data'] != null ? NotificationInnerData.fromJson(json['data']) : null,
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class NotificationInnerData {
  final String category;
  final NotificationPayload? payload;
  final String? sentAt;

  NotificationInnerData({
    required this.category,
    this.payload,
    this.sentAt,
  });

  factory NotificationInnerData.fromJson(Map<String, dynamic> json) {
    return NotificationInnerData(
      category: json['category'] ?? '',
      payload: json['payload'] != null ? NotificationPayload.fromJson(json['payload']) : null,
      sentAt: json['sent_at'],
    );
  }
}

class NotificationPayload {
  final String title;
  final String message;
  final int? actorId;
  final String? actorName;
  final String? actorAvatar;

  NotificationPayload({
    required this.title,
    required this.message,
    this.actorId,
    this.actorName,
    this.actorAvatar,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      actorId: json['actor_id'],
      actorName: json['actor_name'],
      actorAvatar: json['actor_avatar'],
    );
  }
}
