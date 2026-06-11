class HistoryMeta {
  final String? nextCursor;
  final int perPage;
  final bool hasMore;

  HistoryMeta({
    this.nextCursor,
    required this.perPage,
    required this.hasMore,
  });

  factory HistoryMeta.fromJson(Map<String, dynamic> json) {
    return HistoryMeta(
      nextCursor: json['next_cursor'],
      perPage: json['per_page'] ?? 20,
      hasMore: json['has_more'] ?? false,
    );
  }
}

class HistoryPreview {
  final String? thumbnail;
  final String? caption;

  HistoryPreview({this.thumbnail, this.caption});

  factory HistoryPreview.fromJson(Map<String, dynamic> json) {
    return HistoryPreview(
      thumbnail: json['thumbnail'],
      caption: json['caption'],
    );
  }
}

class LikeHistoryItem {
  final int id;
  final String entityType;
  final int entityId;
  final HistoryPreview? preview;
  final String createdAt;
  final String createdHuman;

  LikeHistoryItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.preview,
    required this.createdAt,
    required this.createdHuman,
  });

  factory LikeHistoryItem.fromJson(Map<String, dynamic> json) {
    return LikeHistoryItem(
      id: json['id'] ?? 0,
      entityType: json['entity_type'] ?? '',
      entityId: json['entity_id'] ?? 0,
      preview: json['preview'] != null ? HistoryPreview.fromJson(json['preview']) : null,
      createdAt: json['created_at'] ?? '',
      createdHuman: json['created_human'] ?? '',
    );
  }
}

class CommentHistoryItem {
  final int id;
  final String body;
  final String entityType;
  final int entityId;
  final int? parentId;
  final HistoryPreview? preview;
  final String createdAt;
  final String createdHuman;

  CommentHistoryItem({
    required this.id,
    required this.body,
    required this.entityType,
    required this.entityId,
    this.parentId,
    this.preview,
    required this.createdAt,
    required this.createdHuman,
  });

  factory CommentHistoryItem.fromJson(Map<String, dynamic> json) {
    return CommentHistoryItem(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      entityType: json['entity_type'] ?? '',
      entityId: json['entity_id'] ?? 0,
      parentId: json['parent_id'],
      preview: json['preview'] is Map<String, dynamic> ? HistoryPreview.fromJson(json['preview']) : null,
      createdAt: json['created_at'] ?? '',
      createdHuman: json['created_human'] ?? '',
    );
  }
}

class VideoViewHistoryItem {
  final int id;
  final String postType;
  final int entityId;
  final HistoryPreview? preview;
  final String createdAt;
  final String createdHuman;

  VideoViewHistoryItem({
    required this.id,
    required this.postType,
    required this.entityId,
    this.preview,
    required this.createdAt,
    required this.createdHuman,
  });

  factory VideoViewHistoryItem.fromJson(Map<String, dynamic> json) {
    return VideoViewHistoryItem(
      id: json['id'] ?? 0,
      postType: json['post_type'] ?? '',
      entityId: json['entity_id'] ?? 0,
      preview: json['preview'] != null ? HistoryPreview.fromJson(json['preview']) : null,
      createdAt: json['created_at'] ?? '',
      createdHuman: json['created_human'] ?? '',
    );
  }
}

class PurchaseItem {
  final String title;
  final int quantity;
  final dynamic price;

  PurchaseItem({
    required this.title,
    required this.quantity,
    required this.price,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      title: json['title'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: json['price'] ?? 0.0,
    );
  }
}

class PurchaseHistoryItem {
  final int orderId;
  final String orderUuid;
  final dynamic totalAmount;
  final String status;
  final List<PurchaseItem> items;
  final String createdAt;

  PurchaseHistoryItem({
    required this.orderId,
    required this.orderUuid,
    required this.totalAmount,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  factory PurchaseHistoryItem.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<PurchaseItem> parsedItems = itemsList.map((i) => PurchaseItem.fromJson(i)).toList();

    return PurchaseHistoryItem(
      orderId: json['order_id'] ?? 0,
      orderUuid: json['order_uuid'] ?? '',
      totalAmount: json['total_amount'] ?? 0.0,
      status: json['status'] ?? '',
      items: parsedItems,
      createdAt: json['created_at'] ?? '',
    );
  }
}
