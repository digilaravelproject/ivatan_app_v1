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
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : null,
      payment: json['payment'] != null ? PaymentDetail.fromJson(json['payment']) : null,
      shipping: json['shipping'] != null ? ShippingDetail.fromJson(json['shipping']) : null,
      buyer: json['buyer'] != null ? BuyerDetail.fromJson(json['buyer']) : null,
      address: json['address'] != null ? AddressDetail.fromJson(json['address']) : null,
    );
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
    return OrderItem(
      id: json['id'],
      uuid: json['uuid'],
      orderId: json['order_id'],
      sellerId: json['seller_id'],
      itemType: json['item_type'],
      itemId: json['item_id'],
      quantity: json['quantity'],
      price: json['price']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
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
