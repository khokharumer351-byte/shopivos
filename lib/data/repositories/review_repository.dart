import '../models/review.dart';
import '../supabase_client.dart';

class ReviewRepository {
  Future<List<Review>> fetchForProduct(String productId) async {
    final rows = await supabase
        .from('reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);
    return rows.map(Review.fromMap).toList();
  }

  /// One review per user per product — submitting again updates it.
  Future<void> submit({
    required String productId,
    required String userId,
    required int rating,
    required String comment,
    required String authorName,
  }) async {
    await supabase.from('reviews').upsert(
      {
        'product_id': productId,
        'user_id': userId,
        'rating': rating,
        'comment': comment.trim(),
        'author_name': authorName,
      },
      onConflict: 'product_id,user_id',
    );
  }

  Future<void> delete(String reviewId) async {
    await supabase.from('reviews').delete().eq('id', reviewId);
  }
}
