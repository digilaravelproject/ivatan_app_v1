import '../../dashboard/model/user_profile.dart';

class ServiceModel {
  final int id;
  final String uuid;
  final int sellerId;
  final String title;
  final String slug;
  final String description;
  final String price;
  final String? discountPrice;
  final String status;
  final String? adminNote;
  final String createdAt;
  final String updatedAt;
  final String? coverImage;
  final List<ServiceImage> images;
  final UserData? seller;

  ServiceModel({
    required this.id,
    required this.uuid,
    required this.sellerId,
    required this.title,
    required this.slug,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.status,
    this.adminNote,
    required this.createdAt,
    required this.updatedAt,
    this.coverImage,
    required this.images,
    this.seller,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      uuid: json['uuid'] ?? "",
      sellerId: json['seller_id'] ?? 0,
      title: json['title'] ?? "",
      slug: json['slug'] ?? "",
      description: json['description'] ?? "",
      price: json['price']?.toString() ?? "0",
      discountPrice: json['discount_price']?.toString(),
      status: json['status'] ?? "pending",
      adminNote: json['admin_note'],
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
      coverImage: json['cover_image'],
      images: json['images'] != null
          ? (json['images'] as List).map((i) => ServiceImage.fromJson(i)).toList()
          : [],
      seller: json['seller'] != null ? UserData.fromJson(json['seller']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'seller_id': sellerId,
      'title': title,
      'slug': slug,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'status': status,
      'admin_note': adminNote,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'cover_image': coverImage,
      'images': images.map((i) => i.toJson()).toList(),
      'seller': seller?.id,
    };
  }
}

class ServiceImage {
  final int id;
  final int serviceId;
  final String imagePath;
  final String createdAt;
  final String updatedAt;

  ServiceImage({
    required this.id,
    required this.serviceId,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      id: json['id'],
      serviceId: json['service_id'],
      imagePath: json['image_path'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'image_path': imagePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
