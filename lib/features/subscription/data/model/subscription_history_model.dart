class SubscriptionHistoryResponse {
  final bool status;
  final String message;
  final List<SubscriptionHistoryItem> history;

  SubscriptionHistoryResponse({
    required this.status,
    required this.message,
    required this.history,
  });

  factory SubscriptionHistoryResponse.fromJson(Map<String, dynamic> json) {
    final historyList = json['data']?['history'] as List? ?? [];
    return SubscriptionHistoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      history: historyList.map((e) => SubscriptionHistoryItem.fromJson(e)).toList(),
    );
  }
}

class SubscriptionHistoryItem {
  final int id;
  final int userId;
  final int? profileId;
  final int subscriptionPlanId;
  final String startsAt;
  final String? endsAt;
  final String? nextBillingAt;
  final bool autoRenew;
  final String status;
  final String? cancelledAt;
  final String? cancellationReason;
  final String? gatewaySubscriptionId;
  final String? gatewayOrderId;
  final String? gatewayPaymentId;
  final dynamic gatewayResponse;
  final String createdAt;
  final String updatedAt;
  final SubscriptionHistoryPlan? plan;
  final SubscriptionHistoryProfile? profile;

  SubscriptionHistoryItem({
    required this.id,
    required this.userId,
    this.profileId,
    required this.subscriptionPlanId,
    required this.startsAt,
    this.endsAt,
    this.nextBillingAt,
    required this.autoRenew,
    required this.status,
    this.cancelledAt,
    this.cancellationReason,
    this.gatewaySubscriptionId,
    this.gatewayOrderId,
    this.gatewayPaymentId,
    this.gatewayResponse,
    required this.createdAt,
    required this.updatedAt,
    this.plan,
    this.profile,
  });

  factory SubscriptionHistoryItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      profileId: json['profile_id'],
      subscriptionPlanId: json['subscription_plan_id'] ?? 0,
      startsAt: json['starts_at'] ?? '',
      endsAt: json['ends_at'],
      nextBillingAt: json['next_billing_at'],
      autoRenew: json['auto_renew'] is bool
          ? json['auto_renew']
          : (json['auto_renew'] == 1 || json['auto_renew'] == '1'),
      status: json['status'] ?? '',
      cancelledAt: json['cancelled_at'],
      cancellationReason: json['cancellation_reason'],
      gatewaySubscriptionId: json['gateway_subscription_id']?.toString(),
      gatewayOrderId: json['gateway_order_id']?.toString(),
      gatewayPaymentId: json['gateway_payment_id']?.toString(),
      gatewayResponse: json['gateway_response'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      plan: json['plan'] != null ? SubscriptionHistoryPlan.fromJson(json['plan']) : null,
      profile: json['profile'] != null ? SubscriptionHistoryProfile.fromJson(json['profile']) : null,
    );
  }
}

class SubscriptionHistoryPlan {
  final int id;
  final String profileType;
  final String name;
  final String slug;
  final String description;
  final String price;
  final String currency;
  final int durationDays;
  final List<String> features;
  final bool isActive;
  final bool isDefault;
  final int sortOrder;
  final String? gatewayPlanId;
  final String createdAt;
  final String updatedAt;

  SubscriptionHistoryPlan({
    required this.id,
    required this.profileType,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.features,
    required this.isActive,
    required this.isDefault,
    required this.sortOrder,
    this.gatewayPlanId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionHistoryPlan.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'] as List? ?? [];
    return SubscriptionHistoryPlan(
      id: json['id'] ?? 0,
      profileType: json['profile_type'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      currency: json['currency'] ?? 'INR',
      durationDays: json['duration_days'] ?? 0,
      features: rawFeatures.map((e) => e.toString()).toList(),
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['is_active'] == 1 || json['is_active'] == '1'),
      isDefault: json['is_default'] is bool
          ? json['is_default']
          : (json['is_default'] == 1 || json['is_default'] == '1'),
      sortOrder: json['sort_order'] ?? 0,
      gatewayPlanId: json['gateway_plan_id']?.toString(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class SubscriptionHistoryProfile {
  final int id;
  final int userId;
  final String type;
  final String status;
  final bool isActive;
  final bool isDefault;
  final String? approvedAt;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  SubscriptionHistoryProfile({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.isActive,
    required this.isDefault,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SubscriptionHistoryProfile.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryProfile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['is_active'] == 1 || json['is_active'] == '1'),
      isDefault: json['is_default'] is bool
          ? json['is_default']
          : (json['is_default'] == 1 || json['is_default'] == '1'),
      approvedAt: json['approved_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }
}
