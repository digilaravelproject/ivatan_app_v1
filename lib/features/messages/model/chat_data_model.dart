class ChatListModel {
  final int id;
  final String uuid;
  final String type;
  final String name;
  final dynamic avatar;
  final bool isOnline;
  final int isAdmin;
  final int unreadCount;
  final LastMessage? lastMessage;
  final DateTime updatedAt;
  final int participantsCount;
  final List<Participant> participants;

  ChatListModel({
    required this.id,
    required this.uuid,
    required this.type,
    required this.name,
    this.avatar,
    required this.isOnline,
    required this.isAdmin,
    required this.unreadCount,
    this.lastMessage,
    required this.updatedAt,
    required this.participantsCount,
    required this.participants,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) {
    return ChatListModel(
      id: json["id"] ?? 0,
      uuid: json["uuid"] ?? "",
      type: json["type"] ?? "",
      name: json["name"] ?? "",
      avatar: json["avatar"],
      isOnline: json["is_online"] ?? false,
      isAdmin: json["is_admin"] ?? 0,
      unreadCount: json["unread_count"] ?? 0,
      lastMessage:
          json["last_message"] != null
              ? LastMessage.fromJson(json["last_message"])
              : null,
      updatedAt: _safeDate(json["updated_at"]),
      participantsCount: json["participants_count"] ?? 0,
      participants:
          (json["participants"] as List? ?? [])
              .map((e) => Participant.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "type": type,
    "name": name,
    "avatar": avatar,
    "is_online": isOnline,
    "is_admin": isAdmin,
    "unread_count": unreadCount,
    "last_message": lastMessage?.toJson(),
    "updated_at": updatedAt.toIso8601String(),
    "participants_count": participantsCount,
    "participants": participants.map((x) => x.toJson()).toList(),
  };

  static DateTime _safeDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}

class LastMessage {
  final int id;
  final int chatId;
  final String content;
  final String messageType;
  final dynamic attachmentUrl;
  final dynamic meta;
  final bool isMine;
  final String status;
  final DateTime createdAt;
  final Sender? sender;

  LastMessage({
    required this.id,
    required this.chatId,
    required this.content,
    required this.messageType,
    this.attachmentUrl,
    this.meta,
    required this.isMine,
    required this.status,
    required this.createdAt,
    this.sender,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json["id"] ?? 0,
      chatId: json["chat_id"] ?? 0,
      content: json["content"] ?? "",
      messageType: json["message_type"] ?? "",
      attachmentUrl: json["attachment_url"],
      meta: json["meta"],
      isMine: json["is_mine"] ?? false,
      status: json["status"] ?? "",
      createdAt: ChatListModel._safeDate(json["created_at"]),
      sender: json["sender"] != null ? Sender.fromJson(json["sender"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "chat_id": chatId,
    "content": content,
    "message_type": messageType,
    "attachment_url": attachmentUrl,
    "meta": meta,
    "is_mine": isMine,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "sender": sender?.toJson(),
  };
}

class Sender {
  final dynamic id;
  final String name;
  final dynamic avatar;

  Sender({this.id, required this.name, this.avatar});

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json["id"],
      name: json["name"] ?? "",
      avatar: json["avatar"],
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "avatar": avatar};
}

class Participant {
  final int userId;
  final String name;
  final String avatar;
  final bool isAdmin;

  Participant({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.isAdmin,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json["user_id"] ?? 0,
      name: json["name"] ?? "",
      avatar: json["avatar"] ?? "",
      isAdmin: json["is_admin"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "name": name,
    "avatar": avatar,
    "is_admin": isAdmin,
  };
}
