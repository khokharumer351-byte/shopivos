import 'json_utils.dart';

class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment = '',
    this.authorName,
    this.createdAt,
  });

  final String id;
  final String productId;
  final String userId;
  final int rating;
  final String comment;
  final String? authorName;
  final DateTime? createdAt;

  factory Review.fromMap(Map<String, dynamic> map) => Review(
    id: map['id'] as String,
    productId: map['product_id'] as String,
    userId: map['user_id'] as String,
    rating: toInt(map['rating']),
    comment: (map['comment'] ?? '') as String,
    authorName: map['author_name'] as String?,
    createdAt: toDate(map['created_at']),
  );
}
