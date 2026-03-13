class MarketplaceProductResponse {
  final int currentPage;
  final List<MarketplaceProduct> products;
  final int total;
  final int perPage;
  final int lastPage;

  MarketplaceProductResponse({
    required this.currentPage,
    required this.products,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory MarketplaceProductResponse.fromJson(Map<String, dynamic> json) {
    return MarketplaceProductResponse(
      currentPage: json['current_page'] ?? 1,
      products: (json['data'] as List<dynamic>?)
          ?.map((item) => MarketplaceProduct.fromJson(item))
          .toList() ?? [],
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 12,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class MarketplaceProduct {
  final String id;
  final String uuid;
  final String title;
  final String description;
  final String price;
  final String? discountPrice;
  final int stock;
  final String coverImage;
  final String status;
  final String createdAt;
  final List<ProductImage> images;
  final Seller seller;

  MarketplaceProduct({
    required this.id,
    required this.uuid,
    required this.title,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.coverImage,
    required this.status,
    required this.createdAt,
    required this.images,
    required this.seller,
  });

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    return MarketplaceProduct(
      id: json['id'].toString(),
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString(),
      stock: json['stock'] ?? 0,
      coverImage: json['cover_image'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => ProductImage.fromJson(img))
          .toList() ?? [],
      seller: Seller.fromJson(json['seller'] ?? {}),
    );
  }
}

class ProductImage {
  final String id;
  final String imagePath;

  ProductImage({
    required this.id,
    required this.imagePath,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'].toString(),
      imagePath: json['image_path'] ?? '',
    );
  }
}

class Seller {
  final String id;
  final String name;
  final String username;
  final String? profilePhotoPath;
  final String? bio;
  final int followersCount;
  final bool isVerified;

  Seller({
    required this.id,
    required this.name,
    required this.username,
    this.profilePhotoPath,
    this.bio,
    required this.followersCount,
    required this.isVerified,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      profilePhotoPath: json['profile_photo_path'],
      bio: json['bio'],
      followersCount: json['followers_count'] ?? 0,
      isVerified: json['is_verified'] ?? false,
    );
  }
}
