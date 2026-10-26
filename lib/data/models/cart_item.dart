import 'product.dart';

class CartItem {
  const CartItem({required this.product, required this.quantity, this.size});

  final Product product;
  final int quantity;
  final String? size;

  double get lineTotal => product.price * quantity;

  bool matches(String productId, String? otherSize) =>
      product.id == productId && size == otherSize;

  CartItem copyWith({int? quantity}) => CartItem(
    product: product,
    quantity: quantity ?? this.quantity,
    size: size,
  );

  Map<String, dynamic> toJson() => {
    'product': product.toCacheMap(),
    'quantity': quantity,
    'size': size,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromMap(Map<String, dynamic>.from(json['product'] as Map)),
    quantity: (json['quantity'] as num).toInt(),
    size: json['size'] as String?,
  );
}
