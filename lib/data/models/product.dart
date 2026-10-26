import 'json_utils.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.compareAtPrice,
    this.stock = 0,
    this.categoryId,
    this.categoryName,
    this.images = const [],
    this.sizes = const [],
    this.isFeatured = false,
    this.isActive = true,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final double? compareAtPrice;
  final int stock;
  final String? categoryId;
  final String? categoryName;
  final List<String> images;
  final List<String> sizes;
  final bool isFeatured;
  final bool isActive;
  final double ratingAvg;
  final int ratingCount;
  final DateTime? createdAt;

  String? get primaryImage => images.isNotEmpty ? images.first : null;
  bool get inStock => stock > 0;
  bool get onSale => compareAtPrice != null && compareAtPrice! > price;
  int get discountPercent => onSale
      ? (((compareAtPrice! - price) / compareAtPrice!) * 100).round()
      : 0;

  factory Product.fromMap(Map<String, dynamic> map) {
    final category = map['categories'];
    return Product(
      id: map['id'] as String,
      name: (map['name'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      price: toDouble(map['price']),
      compareAtPrice: map['compare_at_price'] == null
          ? null
          : toDouble(map['compare_at_price']),
      stock: toInt(map['stock']),
      categoryId: map['category_id'] as String?,
      categoryName: category is Map
          ? category['name'] as String?
          : map['category_name'] as String?,
      images: toStringList(map['images']),
      sizes: toStringList(map['sizes']),
      isFeatured: map['is_featured'] == true,
      isActive: map['is_active'] != false,
      ratingAvg: toDouble(map['rating_avg']),
      ratingCount: toInt(map['rating_count']),
      createdAt: toDate(map['created_at']),
    );
  }

  Map<String, dynamic> toRow() => {
    'name': name,
    'description': description,
    'price': price,
    'compare_at_price': compareAtPrice,
    'stock': stock,
    'category_id': categoryId,
    'images': images,
    'sizes': sizes,
    'is_featured': isFeatured,
    'is_active': isActive,
  };

  Map<String, dynamic> toCacheMap() => {
    ...toRow(),
    'id': id,
    'category_name': categoryName,
    'rating_avg': ratingAvg,
    'rating_count': ratingCount,
  };
}

enum ProductSort {
  newest('newest', 'Newest', 'created_at', false),
  priceLow('price_asc', 'Price: low to high', 'price', true),
  priceHigh('price_desc', 'Price: high to low', 'price', false),
  alphabetical('name', 'Name A–Z', 'name', true);

  const ProductSort(this.key, this.label, this.column, this.ascending);

  final String key;
  final String label;
  final String column;
  final bool ascending;

  static ProductSort fromKey(String? key) => ProductSort.values.firstWhere(
    (s) => s.key == key,
    orElse: () => ProductSort.newest,
  );
}
