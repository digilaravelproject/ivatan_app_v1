class CartResponse {
  final Cart? cart;
  final double totalPrice;
  final int totalItems;
  final bool success;

  CartResponse({
    this.cart,
    required this.totalPrice,
    required this.totalItems,
    required this.success,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      cart: json['cart'] != null ? Cart.fromJson(json['cart']) : null,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      totalItems: int.tryParse(json['total_items']?.toString() ?? '0') ?? 0,
      success: json['success'] ?? true,
    );
  }
}

class Cart {
  final int id;
  final String uuid;
  final int userId;
  final List<CartItemModel> items;

  Cart({
    required this.id,
    required this.uuid,
    required this.userId,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      userId: json['user_id'] ?? 0,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItemModel.fromJson(item))
          .toList() ?? [],
    );
  }
}

class CartItemModel {
  final int id;
  final String uuid;
  final int cartId;
  final int sellerId;
  final String itemType;
  final int itemId;
  final int quantity;
  final String price;
  final String name;
  final String coverImage;
  final String slug;
  final ProductData? product;

  CartItemModel({
    required this.id,
    required this.uuid,
    required this.cartId,
    required this.sellerId,
    required this.itemType,
    required this.itemId,
    required this.quantity,
    required this.price,
    required this.name,
    required this.coverImage,
    required this.slug,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      cartId: json['cart_id'] ?? 0,
      sellerId: json['seller_id'] ?? 0,
      itemType: json['item_type'] ?? '',
      itemId: json['item_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: json['price']?.toString() ?? '0',
      name: json['name'] ?? '',
      coverImage: json['cover_image'] ?? '',
      slug: json['slug'] ?? '',
      product: json['product'] != null ? ProductData.fromJson(json['product']) : null,
    );
  }

  CartItemModel copyWith({
    int? quantity,
  }) {
    return CartItemModel(
      id: id,
      uuid: uuid,
      cartId: cartId,
      sellerId: sellerId,
      itemType: itemType,
      itemId: itemId,
      quantity: quantity ?? this.quantity,
      price: price,
      name: name,
      coverImage: coverImage,
      slug: slug,
      product: product,
    );
  }
}

class ProductData {
  final int id;
  final String title;
  final String price;
  final String? discountPrice;
  final String coverImage;

  ProductData({
    required this.id,
    required this.title,
    required this.price,
    this.discountPrice,
    required this.coverImage,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString(),
      coverImage: json['cover_image'] ?? '',
    );
  }
}
