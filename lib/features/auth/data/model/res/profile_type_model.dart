class ProfileType {
  final String type;
  final String label;
  final String description;
  final bool isDefault;
  final bool requiresApproval;
  final bool hasSubscription;
  final List<String> sellerTypes;

  ProfileType({
    required this.type,
    required this.label,
    required this.description,
    required this.isDefault,
    required this.requiresApproval,
    required this.hasSubscription,
    required this.sellerTypes,
  });

  factory ProfileType.fromJson(Map<String, dynamic> json) {
    return ProfileType(
      type: json['type'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      isDefault: json['is_default'] ?? false,
      requiresApproval: json['requires_approval'] ?? false,
      hasSubscription: json['has_subscription'] ?? false,
      sellerTypes: json['seller_types'] != null
          ? List<String>.from(json['seller_types'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'description': description,
      'is_default': isDefault,
      'requires_approval': requiresApproval,
      'has_subscription': hasSubscription,
      'seller_types': sellerTypes,
    };
  }
}
