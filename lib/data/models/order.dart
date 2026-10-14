import 'json_utils.dart';

abstract final class OrderStatus {
  static const pending = 'pending';
  static const processing = 'processing';
  static const shipped = 'shipped';
  static const delivered = 'delivered';
  static const cancelled = 'cancelled';

  static const all = [pending, processing, shipped, delivered, cancelled];

  /// The happy path, used for the progress tracker.
  static const flow = [pending, processing, shipped, delivered];
}

class OrderItem {
  const OrderItem({
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.productId,
    this.productImage,
    this.size,
  });

  final String? productId;
  final String productName;
  final String? productImage;
  final double unitPrice;
  final int quantity;
  final String? size;

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['product_id'] as String?,
        productName: (map['product_name'] ?? '') as String,
        productImage: map['product_image'] as String?,
        unitPrice: toDouble(map['unit_price']),
        quantity: toInt(map['quantity']),
        size: map['size'] as String?,
      );
}

class ShopOrder {
  const ShopOrder({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.userId,
    this.postalCode,
    this.country,
    this.notes,
    this.paymentMethod = 'cod',
    this.createdAt,
    this.items = const [],
    this.customerEmail,
  });

  final String id;
  final String? userId;
  final String status;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String? postalCode;
  final String? country;
  final String? notes;
  final String paymentMethod;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final String? customerEmail;

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);
  bool get canCancel => status == OrderStatus.pending;

  String get paymentLabel => paymentMethod == 'cod' ? 'Cash on delivery' : paymentMethod;

  String get shippingAddress => [address, city, postalCode, country]
      .whereType<String>()
      .where((part) => part.trim().isNotEmpty)
      .join(', ');

  factory ShopOrder.fromMap(Map<String, dynamic> map) {
    final rawItems = map['order_items'];
    final profile = map['profiles'];
    return ShopOrder(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      status: (map['status'] ?? OrderStatus.pending) as String,
      subtotal: toDouble(map['subtotal']),
      shippingFee: toDouble(map['shipping_fee']),
      total: toDouble(map['total']),
      fullName: (map['full_name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      address: (map['address'] ?? '') as String,
      city: (map['city'] ?? '') as String,
      postalCode: map['postal_code'] as String?,
      country: map['country'] as String?,
      notes: map['notes'] as String?,
      paymentMethod: (map['payment_method'] ?? 'cod') as String,
      createdAt: toDate(map['created_at']),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
      customerEmail: profile is Map ? profile['email'] as String? : null,
    );
  }
}

class ShippingDetails {
  const ShippingDetails({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.postalCode = '',
    this.country = '',
    this.notes = '',
    this.paymentMethod = 'cod',
  });

  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String postalCode;
  final String country;
  final String notes;
  final String paymentMethod;

  Map<String, dynamic> toMap() => {
        'full_name': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'postal_code': postalCode,
        'country': country,
        'notes': notes,
        'payment_method': paymentMethod,
      };
}
