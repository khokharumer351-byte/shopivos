import '../models/product_category.dart';
import '../supabase_client.dart';

class CategoryRepository {
  Future<List<ProductCategory>> fetchAll() async {
    final rows = await supabase.from('categories').select().order('name');
    return rows.map(ProductCategory.fromMap).toList();
  }

  Future<void> create({required String name, String? imageUrl}) async {
    await supabase.from('categories').insert({
      'name': name.trim(),
      'image_url': _blankToNull(imageUrl),
    });
  }

  Future<void> update(
    String id, {
    required String name,
    String? imageUrl,
  }) async {
    await supabase
        .from('categories')
        .update({'name': name.trim(), 'image_url': _blankToNull(imageUrl)})
        .eq('id', id);
  }

  Future<void> delete(String id) async {
    await supabase.from('categories').delete().eq('id', id);
  }

  String? _blankToNull(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value.trim();
}
