class OrderModel {
  final int? id;
  final int? parentId;
  final String? uuid;
  final int? buyerId;
  final int? sellerId;
  final String? totalAmount;
  final String? status;
  final String? paymentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItem>? items;
  final PaymentDetail? payment;
  final ShippingDetail? shipping;
  final BuyerDetail? buyer;
  final AddressDetail? address;

  OrderModel({
    this.id,
    this.parentId,
    this.uuid,
    this.buyerId,
    this.sellerId,
    this.totalAmount,
    this.status,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.items,
    this.payment,
    this.shipping,
    this.buyer,
    this.address,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      parentId: json['parent_id'],
      uuid: json['uuid'],
      buyerId: json['buyer_id'],
      sellerId: json['seller_id'],
      totalAmount: json['total_amount']?.toString(),
      status: json['status'],
      paymentStatus: json['payment_status'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      items: _parseItems(json),
      payment: json['payment'] != null ? PaymentDetail.fromJson(json['payment']) : null,
      shipping: json['shipping'] != null ? ShippingDetail.fromJson(json['shipping']) : null,
      buyer: json['buyer'] != null ? BuyerDetail.fromJson(json['buyer']) : null,
      address: json['address'] != null ? AddressDetail.fromJson(json['address']) : null,
    );
  }

  static List<OrderItem>? _parseItems(Map<String, dynamic> json) {
    List<OrderItem> allItems = [];

    // 1. Check direct items
    final List<String> possibleKeys = [
      'items', 
      'order_items', 
      'order_line_items', 
      'line_items', 
      'order_products',
      'products', 
      'details', 
      'order_details',
      'items_only',
      'orderItems',
      'orderLineItems',
      'orderProducts'
    ];

    for (var key in possibleKeys) {
      final value = json[key];
      if (value != null) {
        if (value is List) {
          allItems.addAll(value.map((i) => OrderItem.fromJson(i)).toList());
        } else if (value is Map && value['data'] != null && value['data'] is List) {
          allItems.addAll((value['data'] as List).map((i) => OrderItem.fromJson(i)).toList());
        }
      }
    }

    // 2. Check children (Sub-orders) and their items
    if (json['children'] != null && json['children'] is List) {
      for (var child in json['children']) {
        if (child is Map<String, dynamic>) {
          final childItems = _parseItems(child);
          if (childItems != null) {
            allItems.addAll(childItems);
          }
        }
      }
    }

    // 3. Last resort: Find ANY field that is a non-empty List (excluding children)
    if (allItems.isEmpty) {
      for (var entry in json.entries) {
        if (entry.key != 'children' && entry.value is List && entry.value.isNotEmpty) {
           final firstItem = entry.value.first;
           if (firstItem is Map) {
             allItems.addAll((entry.value as List).map((i) => OrderItem.fromJson(i)).toList());
           }
        }
      }
    }

    return allItems.isEmpty ? null : allItems;
  }
}

class OrderItem {
  final int? id;
  final String? uuid;
  final int? orderId;
  final int? sellerId;
  final String? itemType;
  final int? itemId;
  final int? quantity;
  final String? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  String? title;
  String? image;

  OrderItem({
    this.id,
    this.uuid,
    this.orderId,
    this.sellerId,
    this.itemType,
    this.itemId,
    this.quantity,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.title,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Check if there is a nested product object
    final productJson = json['product'] ?? json['item'] ?? {};
    
    return OrderItem(
      id: json['id'],
      uuid: json['uuid'],
      orderId: json['order_id'],
      sellerId: json['seller_id'],
      itemType: json['item_type'],
      // Try top level, then within product object
      itemId: json['item_id'] ?? json['product_id'] ?? json['id'] ?? productJson['id'],
      quantity: json['quantity'] ?? json['qty'] ?? 1,
      price: (json['price'] ?? json['unit_price'] ?? json['amount'] ?? productJson['price'] ?? '0').toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      // Priority: Top level title > product title > name
      title: json['title'] ?? productJson['title'] ?? json['name'] ?? productJson['name'],
      // Priority: Top level image > product image > cover image
      image: json['image'] ?? productJson['image'] ?? json['cover_image'] ?? productJson['cover_image'] ?? productJson['thumbnail_url'],
    );
  }
}

class PaymentDetail {
  final int? id;
  final String? uuid;
  final String? gateway;
  final String? amount;
  final String? status;
  final String? transactionId;
  final String? meta;

  PaymentDetail({this.id, this.uuid, this.gateway, this.amount, this.status, this.transactionId, this.meta});

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      id: json['id'],
      uuid: json['uuid'],
      gateway: json['gateway'],
      amount: json['amount']?.toString(),
      status: json['status'],
      transactionId: json['transaction_id'],
      meta: json['meta']?.toString(), // Safely convert Map or String to String
    );
  }
}

class ShippingDetail {
  final int? id;
  final String? provider;
  final String? trackingNumber;
  final String? status;

  ShippingDetail({this.id, this.provider, this.trackingNumber, this.status});

  factory ShippingDetail.fromJson(Map<String, dynamic> json) {
    return ShippingDetail(
      id: json['id'],
      provider: json['provider'],
      trackingNumber: json['tracking_number'],
      status: json['status'],
    );
  }
}

class BuyerDetail {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? profilePhotoPath;

  BuyerDetail({this.id, this.name, this.email, this.phone, this.profilePhotoPath});

  factory BuyerDetail.fromJson(Map<String, dynamic> json) {
    return BuyerDetail(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profilePhotoPath: json['profile_photo_path'],
    );
  }
}

class AddressDetail {
  final int? id;
  final String? type;
  final String? name;
  final String? phone;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  AddressDetail({
    this.id,
    this.type,
    this.name,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory AddressDetail.fromJson(Map<String, dynamic> json) {
    return AddressDetail(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      phone: json['phone'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code']?.toString(), // Safely handle numeric postal codes
    );
  }
}
