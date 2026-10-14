import '../models/product.dart';
import '../supabase_client.dart';

class WishlistRepository {
  Future<Set<String>> fetchIds(String userId) async {
    final rows = await supabase.from('wishlist').select('product_id').eq('user_id', userId);
    return rows.map((row) => row['product_id'] as String).toSet();
  }

  Future<List<Product>> fetchProducts(String userId) async {
    final rows = await supabase
        .from('wishlist')
        .select('created_at, products(*, categories(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows
        .map((row) => row['products'])
        .whereType<Map>()
        .map((map) => Product.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> add(String userId, String productId) async {
    await supabase.from('wishlist').insert({'user_id': userId, 'product_id': productId});
  }

  Future<void> remove(String userId, String productId) async {
    await supabase.from('wishlist').delete().eq('user_id', userId).eq('product_id', productId);
  }
}
