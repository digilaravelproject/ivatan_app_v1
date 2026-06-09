class ProfileType {
  final String type;
  final String label;
  final String description;
  final bool isDefault;
  final bool requiresApproval;
  final bool hasSubscription;
  // Subtypes from API — key is 'sub_types' (new) or 'seller_types' (legacy fallback)
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
    // API sends 'sub_types'; old fallback data uses 'seller_types'
    final rawSubTypes = json['sub_types'] ?? json['seller_types'];
    return ProfileType(
      type: json['type'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      isDefault: json['is_default'] ?? false,
      requiresApproval: json['requires_approval'] ?? false,
      hasSubscription: json['has_subscription'] ?? false,
      sellerTypes: rawSubTypes != null ? List<String>.from(rawSubTypes) : [],
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
      'sub_types': sellerTypes,
    };
  }
}
