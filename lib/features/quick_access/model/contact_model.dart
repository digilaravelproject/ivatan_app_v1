/*
class SyncedContact {
  final String type;
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String avatar;
  bool is_mine;
  bool is_invite;
  bool isFollowing;
  final bool isFollower;


  SyncedContact({
    required this.type,
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.is_mine,
    required this.is_invite,
    required this.isFollowing,
    required this.isFollower,
  });

  factory SyncedContact.fromJson(Map<String, dynamic> json) {
    return SyncedContact(
      type: json["type"],
      id: json['id'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
      is_mine: json['is_mine'] ?? '',
      is_invite: json['is_invite'] ?? '',
      isFollowing: json['is_following'] ?? false,
      isFollower: json['is_follower'] ?? false,
    );
  }
}
*/


/*
class SyncedContact {
  final String type;
  final int? id; // nullable because unregistered contacts have null id
  final String name;
  final String? username;
  final String? email;
  final String phone;
  final String? avatar;
  bool isMine;
  bool isInvite;
  bool isFollowing;
  bool isFollower;

  SyncedContact({
    required this.type,
    this.id,
    required this.name,
    this.username,
    this.email,
    required this.phone,
    this.avatar,
    this.isMine = false,
    this.isInvite = false,
    this.isFollowing = false,
    this.isFollower = false,
  });

  factory SyncedContact.fromJson(Map<String, dynamic> json) {
    return SyncedContact(
      type: json["type"] ?? 'unregistered', // default fallback
      id: json['id'], // nullable
      name: json['name'] ?? '',
      username: json['username'],
      email: json['email'],
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      isMine: json['is_mine'] ?? false,
      isInvite: json['is_invite'] ?? false,
      isFollowing: json['is_following'] ?? false,
      isFollower: json['is_follower'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "id": id,
    "name": name,
    "username": username,
    "email": email,
    "phone": phone,
    "avatar": avatar,
    "is_mine": isMine,
    "is_invite": isInvite,
    "is_following": isFollowing,
    "is_follower": isFollower,
  };
}
*/


import 'package:get/get_rx/src/rx_types/rx_types.dart';

class SyncedContact {
  final String type;
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String avatar;
  final String chat_id;

  RxBool is_mine;
  RxBool is_invite;
  RxBool isFollowing;
  RxBool isFollower;

  SyncedContact({
    required this.type,
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.chat_id,
    required bool is_mine,
    required bool is_invite,
    required bool isFollowing,
    required bool isFollower,
  })  : is_mine = is_mine.obs,
        is_invite = is_invite.obs,
        isFollowing = isFollowing.obs,
        isFollower = isFollower.obs;

  factory SyncedContact.fromJson(Map<String, dynamic> json) {
    return SyncedContact(
      type: json["type"] ?? '',
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
      chat_id: json['chat_id'] ?? '',
      is_mine: json['is_mine'] ?? false,
      is_invite: json['is_invite'] ?? false,
      isFollowing: json['is_following'] ?? false,
      isFollower: json['is_follower'] ?? false,
    );
  }
}
