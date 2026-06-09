class ProfileSwitchRequest {
  final int id;
  final int userId;
  final String toProfileType;
  final String? profileSubType;
  final String status;
  final String? userNotes;
  final String? adminNotes;
  final String createdAt;

  ProfileSwitchRequest({
    required this.id,
    required this.userId,
    required this.toProfileType,
    this.profileSubType,
    required this.status,
    this.userNotes,
    this.adminNotes,
    required this.createdAt,
  });

  factory ProfileSwitchRequest.fromJson(Map<String, dynamic> json) {
    return ProfileSwitchRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      toProfileType: json['to_profile_type'] ?? '',
      profileSubType: json['profile_sub_type'],
      status: json['status'] ?? 'pending',
      userNotes: json['user_notes'],
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
