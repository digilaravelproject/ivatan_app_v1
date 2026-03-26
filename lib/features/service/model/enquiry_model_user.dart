import 'service_model.dart';
import '../../dashboard/model/user_profile.dart';

class EnquiryUserModel {
  final int id;
  final String uuid;
  final UserData? user;
  final int sellerId;
  final int? serviceId;
  final int? productId;
  final SellerInfo? seller;
  final ServiceModel? service;
  final dynamic product; // Can be modeled later if needed
  final String subject;
  final String message;
  final String status;
  final String? replyMessage;
  final String createdAt;

  EnquiryUserModel({
    required this.id,
    required this.uuid,
    this.user,
    required this.sellerId,
    this.serviceId,
    this.productId,
    this.seller,
    this.service,
    this.product,
    required this.subject,
    required this.message,
    required this.status,
    this.replyMessage,
    required this.createdAt,
  });

  factory EnquiryUserModel.fromJson(Map<String, dynamic> json) {
    return EnquiryUserModel(
      id: json['id'],
      uuid: json['uuid'] ?? "",
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
      sellerId: json['seller_id'] ?? 0,
      serviceId: json['service_id'],
      productId: json['product_id'],
      seller: json['seller'] != null ? SellerInfo.fromJson(json['seller']) : null,
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
      product: json['product'],
      subject: json['subject'] ?? "",
      message: json['message'] ?? "",
      status: json['status'] ?? "pending",
      replyMessage: json['reply_message'],
      createdAt: json['created_at'] ?? "",
    );
  }
}

class SellerInfo {
  final int id;
  final String name;
  final String email;

  SellerInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['id'],
      name: json['name'] ?? "",
      email: json['email'] ?? "",
    );
  }
}
