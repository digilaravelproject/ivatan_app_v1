import 'package:flutter/material.dart';

class PlanFeature {
  final String title;
  final String description;
  final bool isEnabled;

  PlanFeature({
    required this.title,
    required this.description,
    this.isEnabled = true,
  });
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String price;
  final String period;
  final String description;
  final bool isPopular;
  final String status; // 'active', 'pending', 'none'
  final List<PlanFeature> features;
  final String? slug; // plan slug from API

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    this.isPopular = false,
    this.status = 'none',
    required this.features,
    this.slug,
  });

  bool get isSubscribed => status != 'none';

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'] as List? ?? [];
    final parsedFeatures = rawFeatures.map((feat) {
      if (feat is Map) {
        return PlanFeature(
          title: feat['name']?.toString() ?? '',
          description: feat['description']?.toString() ?? '',
          isEnabled: feat['is_implemented'] == true || feat['is_implemented'] == 1,
        );
      } else {
        return PlanFeature(
          title: feat.toString(),
          description: "",
        );
      }
    }).toList();

    final rawPrice = json['price'] ?? '0.00';
    final currency = json['currency'] ?? 'INR';
    final durationDays = json['duration_days'] ?? 30;

    String priceStr = "$rawPrice";
    if (currency == 'INR') {
      priceStr = "₹${double.tryParse(rawPrice.toString())?.toStringAsFixed(0) ?? rawPrice}";
    } else {
      priceStr = "$currency $rawPrice";
    }

    String periodStr = "month";
    if (durationDays >= 365) {
      periodStr = "year";
    } else if (durationDays == 30) {
      periodStr = "month";
    } else if (durationDays > 0) {
      periodStr = "$durationDays days";
    }

    final String? rawSlug = json['slug']?.toString();

    return SubscriptionPlan(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      price: priceStr,
      period: periodStr,
      description: json['description'] ?? '',
      isPopular: rawSlug?.contains('pro') ?? false,
      status: 'none',
      features: parsedFeatures,
      slug: rawSlug,
    );
  }

  SubscriptionPlan copyWith({
    String? status,
    List<PlanFeature>? features,
  }) {
    return SubscriptionPlan(
      id: id,
      name: name,
      price: price,
      period: period,
      description: description,
      isPopular: isPopular,
      status: status ?? this.status,
      features: features ?? this.features,
      slug: slug,
    );
  }
}

class ProfileTypeSubscription {
  final String id;
  final String type;
  final String? subType; // raw API subtype, e.g. 'product', 'service', 'both'
  final String label;
  final IconData icon;
  final String status; // 'active', 'pending', 'none'
  final int plansCount;
  final List<SubscriptionPlan> plans;
  final int? profileId; // Dynamic profile ID from config API

  ProfileTypeSubscription({
    required this.id,
    required this.type,
    this.subType,
    required this.label,
    required this.icon,
    required this.status,
    required this.plansCount,
    required this.plans,
    this.profileId,
  });

  ProfileTypeSubscription copyWith({
    String? status,
    List<SubscriptionPlan>? plans,
    int? profileId,
  }) {
    return ProfileTypeSubscription(
      id: id,
      type: type,
      subType: subType,
      label: label,
      icon: icon,
      status: status ?? this.status,
      plansCount: plansCount,
      plans: plans ?? this.plans,
      profileId: profileId ?? this.profileId,
    );
  }
}
