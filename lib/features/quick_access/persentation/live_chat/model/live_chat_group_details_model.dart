class LiveChatGroupDetailModel {
  final bool status;
  final String message;
  final LiveChatGroupModel group;

  LiveChatGroupDetailModel({
    required this.status,
    required this.message,
    required this.group,
  });

  factory LiveChatGroupDetailModel.fromJson(Map<String, dynamic> json) {
    return LiveChatGroupDetailModel(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      group: LiveChatGroupModel.fromJson(json['data'] != null ? json['data']['group'] ?? {} : {}),
    );
  }
}

class LiveChatGroupModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? avatar;
  final String chatMode;
  final bool isActive;
  final int chatId;
  final CreatedByModel? createdBy;
  final String createdAt;
  final List<ParticipantModel> participants;

  LiveChatGroupModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.avatar,
    required this.chatMode,
    required this.isActive,
    required this.chatId,
    this.createdBy,
    required this.createdAt,
    required this.participants,
  });

  factory LiveChatGroupModel.fromJson(Map<String, dynamic> json) {
    var participantList = <ParticipantModel>[];
    if (json['participants'] != null && json['participants']['data'] != null) {
      final List<dynamic> pData = json['participants']['data'];
      participantList = pData.map((e) => ParticipantModel.fromJson(e)).toList();
    }
    return LiveChatGroupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      slug: json['slug'] ?? "",
      description: json['description'],
      avatar: json['avatar'],
      chatMode: json['chat_mode'] ?? "everyone",
      isActive: json['is_active'] ?? false,
      chatId: json['chat_id'] ?? 0,
      createdBy: json['created_by'] != null ? CreatedByModel.fromJson(json['created_by']) : null,
      createdAt: json['created_at'] ?? "",
      participants: participantList,
    );
  }
}

class CreatedByModel {
  final int id;
  final String name;

  CreatedByModel({
    required this.id,
    required this.name,
  });

  factory CreatedByModel.fromJson(Map<String, dynamic> json) {
    return CreatedByModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
    );
  }
}

class ParticipantModel {
  final int id;
  final ParticipantUserModel? user;
  final String role;
  final String joinedAt;
  final bool isBanned;
  final bool isMuted;
  final String? mutedUntil;

  ParticipantModel({
    required this.id,
    this.user,
    required this.role,
    required this.joinedAt,
    required this.isBanned,
    required this.isMuted,
    this.mutedUntil,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] ?? 0,
      user: json['user'] != null ? ParticipantUserModel.fromJson(json['user']) : null,
      role: json['role'] ?? "member",
      joinedAt: json['joined_at'] ?? "",
      isBanned: json['is_banned'] ?? false,
      isMuted: json['is_muted'] ?? false,
      mutedUntil: json['muted_until'],
    );
  }
}

class ParticipantUserModel {
  final int id;
  final String name;
  final String? username;
  final String? avatar;

  ParticipantUserModel({
    required this.id,
    required this.name,
    this.username,
    this.avatar,
  });

  factory ParticipantUserModel.fromJson(Map<String, dynamic> json) {
    return ParticipantUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      username: json['username'],
      avatar: json['avatar'],
    );
  }
}
