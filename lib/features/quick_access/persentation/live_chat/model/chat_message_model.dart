class ChatMessageModel {
  final int id;
  final int chatId;
  final String content;
  final String messageType;
  final String? attachmentUrl;
  final dynamic meta;
  final bool isMine;
  final String status;
  final String createdAt;
  final int? replyTo;
  final ChatMessageModel? repliedMessage;
  final MessageSenderModel? sender;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.content,
    required this.messageType,
    this.attachmentUrl,
    this.meta,
    required this.isMine,
    required this.status,
    required this.createdAt,
    this.replyTo,
    this.repliedMessage,
    this.sender,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final int? replyToId = json['reply_to_message_id'] is int
        ? json['reply_to_message_id']
        : (json['reply_to'] is int ? json['reply_to'] : null);

    ChatMessageModel? repliedMsg;
    if (json['reply_to'] is Map<String, dynamic>) {
      // API returns sender_name as a flat string, not a nested sender object.
      // Normalise it so our recursive fromJson can parse it cleanly.
      final Map<String, dynamic> replyJson =
          Map<String, dynamic>.from(json['reply_to']);

      if (replyJson['sender'] == null && replyJson['sender_name'] != null) {
        replyJson['sender'] = {
          'id': null,
          'name': replyJson['sender_name'],
          'avatar': null,
        };
      }
      // Provide safe defaults so required fields don't throw
      replyJson['chat_id']       ??= 0;
      replyJson['message_type']  ??= 'text';
      replyJson['is_mine']       ??= false;
      replyJson['status']        ??= 'sent';
      replyJson['created_at']    ??= '';

      repliedMsg = ChatMessageModel.fromJson(replyJson);
    }

    return ChatMessageModel(
      id: json['id'] ?? 0,
      chatId: json['chat_id'] ?? 0,
      content: json['content'] ?? "",
      messageType: json['message_type'] ?? "text",
      attachmentUrl: json['attachment_url'] ?? json['attachment_path'],
      meta: json['meta'],
      isMine: json['is_mine'] ?? false,
      status: json['status'] ?? "sent",
      createdAt: json['created_at'] ?? "",
      replyTo: replyToId,
      repliedMessage: repliedMsg,
      sender: json['sender'] != null ? MessageSenderModel.fromJson(json['sender']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'content': content,
      'message_type': messageType,
      'attachment_url': attachmentUrl,
      'meta': meta,
      'is_mine': isMine,
      'status': status,
      'created_at': createdAt,
      'reply_to': replyTo,
      'sender': sender?.toJson(),
    };
  }
}

class MessageSenderModel {
  final int? id;
  final String name;
  final String? avatar;

  MessageSenderModel({
    this.id,
    required this.name,
    this.avatar,
  });

  factory MessageSenderModel.fromJson(Map<String, dynamic> json) {
    return MessageSenderModel(
      id: json['id'],
      name: json['name'] ?? "Unknown",
      avatar: json['avatar'] ?? json['profile_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}
