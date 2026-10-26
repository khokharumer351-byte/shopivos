class ProductCategory {
  const ProductCategory({required this.id, required this.name, this.imageUrl});

  final String id;
  final String name;
  final String? imageUrl;

  factory ProductCategory.fromMap(Map<String, dynamic> map) => ProductCategory(
    id: map['id'] as String,
    name: (map['name'] ?? '') as String,
    imageUrl: map['image_url'] as String?,
  );
}
