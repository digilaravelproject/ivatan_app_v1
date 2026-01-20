
class InboxResponse {
  bool status;
  String message;
  InboxData? data;

  InboxResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory InboxResponse.fromJson(Map<String, dynamic> json) {
    return InboxResponse(
      status: json["status"] ?? false,
      message: (json["message"] ?? "").toString(),
      data: json["data"] != null ? InboxData.fromJson(json["data"]) : null,
    );
  }
}

class InboxData {
  List<ChatItem> chats;
  Pagination? pagination;

  InboxData({
    required this.chats,
    this.pagination,
  });

  factory InboxData.fromJson(Map<String, dynamic> json) {
    return InboxData(
      chats: json["chats"] != null
          ? List<ChatItem>.from(
          json["chats"].map((e) => ChatItem.fromJson(e)))
          : [],
      pagination: json["pagination"] != null
          ? Pagination.fromJson(json["pagination"])
          : null,
    );
  }
}

class ChatItem {
  int chatId;
  String type;
  String groupName;
  String groupImage;
  Receiver? receiver;
  int unreadCount;
  LastMessage? lastMessage;
  String updatedAt;

  ChatItem({
    required this.chatId,
    required this.type,
    required this.groupName,
    required this.groupImage,
    this.receiver,
    required this.unreadCount,
    this.lastMessage,
    required this.updatedAt,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      chatId: json["chat_id"] ?? 0,
      type: (json["type"] ?? "").toString(),
      groupName: (json["group_name"] ?? "").toString(),
      groupImage: (json["group_image"] ?? "").toString(),
      receiver: json["receiver"] != null
          ? Receiver.fromJson(json["receiver"])
          : null,
      unreadCount: json["unread_count"] ?? 0,
      lastMessage: json["last_message"] != null
          ? LastMessage.fromJson(json["last_message"])
          : null,
      updatedAt: (json["updated_at"] ?? "").toString(),
    );
  }
}

class Receiver {
  int id;
  String name;
  String username;
  String avatar;
  bool isOnline;

  Receiver({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.isOnline,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) {
    return Receiver(
      id: json["id"] ?? 0,
      name: (json["name"] ?? "").toString(),
      username: (json["username"] ?? "").toString(),
      avatar: (json["avatar"] ?? "").toString(),
      isOnline: json["is_online"] ?? false,
    );
  }
}

class LastMessage {
  String content;
  String type;
  String createdAt;
  String timeAgo;
  bool isMine;
  String senderName;

  LastMessage({
    required this.content,
    required this.type,
    required this.createdAt,
    required this.timeAgo,
    required this.isMine,
    required this.senderName,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      content: (json["content"] ?? "").toString(),
      type: (json["type"] ?? "").toString(),
      createdAt: (json["created_at"] ?? "").toString(),
      timeAgo: (json["time_ago"] ?? "").toString(),
      isMine: json["is_mine"] ?? false,
      senderName: (json["sender_name"] ?? "").toString(),
    );
  }
}

class Pagination {
  int currentPage;
  int lastPage;
  bool hasMore;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json["current_page"] ?? 1,
      lastPage: json["last_page"] ?? 1,
      hasMore: json["has_more"] ?? false,
    );
  }
}
