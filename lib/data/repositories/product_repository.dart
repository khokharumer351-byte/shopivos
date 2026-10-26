import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../supabase_client.dart';

class ProductRepository {
  static const _select = '*, categories(name)';

  Future<List<Product>> fetchProducts({
    String? categoryId,
    String? search,
    ProductSort sort = ProductSort.newest,
    bool featuredOnly = false,
    bool includeInactive = false,
    String? excludeId,
    int? limit,
  }) async {
    var query = supabase.from('products').select(_select);

    if (!includeInactive) query = query.eq('is_active', true);
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }
    if (featuredOnly) query = query.eq('is_featured', true);
    if (excludeId != null) query = query.neq('id', excludeId);

    final term = _sanitize(search);
    if (term.isNotEmpty) {
      query = query.or('name.ilike.%$term%,description.ilike.%$term%');
    }

    final ordered = query.order(sort.column, ascending: sort.ascending);
    final rows = limit != null ? await ordered.limit(limit) : await ordered;
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> fetchProduct(String id) async {
    try {
      final row = await supabase
          .from('products')
          .select(_select)
          .eq('id', id)
          .maybeSingle();
      return row == null ? null : Product.fromMap(row);
    } on PostgrestException catch (e) {
      if (e.code == '22P02') return null;
      rethrow;
    }
  }

  Future<Product> create(Product product) async {
    final row = await supabase
        .from('products')
        .insert(product.toRow())
        .select(_select)
        .single();
    return Product.fromMap(row);
  }

  Future<Product> update(Product product) async {
    final row = await supabase
        .from('products')
        .update(product.toRow())
        .eq('id', product.id)
        .select(_select)
        .single();
    return Product.fromMap(row);
  }

  Future<void> delete(String id) async {
    await supabase.from('products').delete().eq('id', id);
  }

  String _sanitize(String? input) =>
      (input ?? '').replaceAll(RegExp(r'[,()%*\\]'), ' ').trim();
}
