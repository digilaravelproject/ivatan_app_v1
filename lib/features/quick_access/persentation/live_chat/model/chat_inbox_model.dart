import 'chat_message_model.dart';

class ChatInboxModel {
  final int id;
  final String uuid;
  final String type;
  final String name;
  final String? avatar;
  final bool isOnline;
  final bool isAdmin;
  final int unreadCount;
  final int participantsCount;
  final String chatMode;
  final String description;
  final ChatMessageModel? lastMessage;
  final String lastMessageAt;
  
  // New fields from /api/v1/live-chat-groups endpoint
  final String? slug;
  final bool? isActive;
  final int? chatId;
  final bool? isBanned;
  final bool? isMuted;
  final String? createdAt;

  ChatInboxModel({
    required this.id,
    required this.uuid,
    required this.type,
    required this.name,
    this.avatar,
    required this.isOnline,
    required this.isAdmin,
    required this.unreadCount,
    required this.participantsCount,
    required this.chatMode,
    required this.description,
    this.lastMessage,
    required this.lastMessageAt,
    this.slug,
    this.isActive,
    this.chatId,
    this.isBanned,
    this.isMuted,
    this.createdAt,
  });

  factory ChatInboxModel.fromJson(Map<String, dynamic> json) {
    return ChatInboxModel(
      id: json['id'] ?? json['chat_id'] ?? 0,
      uuid: json['uuid'] ?? "",
      type: json['type'] ?? "group",
      name: json['name'] ?? "Unknown Chat",
      avatar: json['avatar'],
      isOnline: json['is_online'] ?? false,
      isAdmin: json['is_admin'] == 1 || json['is_admin'] == true,
      unreadCount: json['unread_count'] ?? 0,
      participantsCount: json['participants_count'] ?? 0,
      chatMode: json['chat_mode'] ?? "everyone",
      description: json['description'] ?? "",
      lastMessage: json['last_message'] != null
          ? ChatMessageModel.fromJson(json['last_message'])
          : null,
      lastMessageAt: json['last_message_at'] ?? json['updated_at'] ?? "",
      slug: json['slug'],
      isActive: json['is_active'],
      chatId: json['chat_id'],
      isBanned: json['is_banned'],
      isMuted: json['is_muted'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'type': type,
      'name': name,
      'avatar': avatar,
      'is_online': isOnline,
      'is_admin': isAdmin,
      'unread_count': unreadCount,
      'participants_count': participantsCount,
      'chat_mode': chatMode,
      'description': description,
      'last_message': lastMessage?.toJson(),
      'last_message_at': lastMessageAt,
      'slug': slug,
      'is_active': isActive,
      'chat_id': chatId,
      'is_banned': isBanned,
      'is_muted': isMuted,
      'created_at': createdAt,
    };
  }
}
