class ChatMessagesData {
  final List<ChatMessage> data;
  final String path;
  final int perPage;
  final String? nextCursor;
  final String? nextPageUrl;
  final String? prevCursor;
  final String? prevPageUrl;

  ChatMessagesData({
    required this.data,
    required this.path,
    required this.perPage,
    this.nextCursor,
    this.nextPageUrl,
    this.prevCursor,
    this.prevPageUrl,
  });

  factory ChatMessagesData.fromJson(Map<String, dynamic> json) {
    return ChatMessagesData(
      data:
          (json['data'] as List? ?? [])
              .map((e) => ChatMessage.fromJson(e))
              .toList(),
      path: json['path'] ?? "",
      perPage: json['per_page'] ?? 0,
      nextCursor: json['next_cursor'],
      nextPageUrl: json['next_page_url'],
      prevCursor: json['prev_cursor'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}

class ChatMessage {
  final int id;
  final int chatId;
  final String content;
  final String messageType;
  final String? attachmentUrl;
  final bool isMine;
  final String status;
  final String createdAt;
  final Sender? sender;
  final ReplyTo? replyTo;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.content,
    required this.messageType,
    this.attachmentUrl,
    required this.isMine,
    required this.status,
    required this.createdAt,
    this.sender,
    this.replyTo,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      chatId: json['chat_id'] ?? 0,
      content: json['content'] ?? "",
      messageType: json['message_type'] ?? "",
      attachmentUrl: json['attachment_url'],
      isMine: json['is_mine'] ?? false,
      status: json['status'] ?? "",
      createdAt: json['created_at'] ?? "",
      sender: json['sender'] != null ? Sender.fromJson(json['sender']) : null,
      replyTo:
          json['reply_to'] != null ? ReplyTo.fromJson(json['reply_to']) : null,
    );
  }
}

class Sender {
  final int id;
  final String name;
  final String avatar;

  Sender({required this.id, required this.name, required this.avatar});

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      avatar: json['avatar'] ?? "",
    );
  }
}

class ReplyTo {
  final int id;
  final String content;
  final String senderName;

  ReplyTo({required this.id, required this.content, required this.senderName});

  factory ReplyTo.fromJson(Map<String, dynamic> json) {
    return ReplyTo(
      id: json['id'] ?? 0,
      content: json['content'] ?? "",
      senderName: json['sender_name'] ?? "",
    );
  }
}
