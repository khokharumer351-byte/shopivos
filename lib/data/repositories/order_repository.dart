import '../models/cart_item.dart';
import '../models/order.dart';
import '../supabase_client.dart';

class OrderRepository {
  static const _select = '*, order_items(*), profiles(email)';

  /// Places the order through the `place_order` RPC, which re-checks prices
  /// and stock on the server. Returns the new order id.
  Future<String> placeOrder({
    required List<CartItem> items,
    required ShippingDetails shipping,
  }) async {
    final result = await supabase.rpc('place_order', params: {
      'p_items': items
          .map((item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'size': item.size,
              })
          .toList(),
      'p_shipping': shipping.toMap(),
    });
    return result as String;
  }

  Future<List<ShopOrder>> fetchMyOrders(String userId) async {
    final rows = await supabase
        .from('orders')
        .select(_select)
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map(ShopOrder.fromMap).toList();
  }

  Future<ShopOrder?> fetchOrder(String id) async {
    final row = await supabase.from('orders').select(_select).eq('id', id).maybeSingle();
    return row == null ? null : ShopOrder.fromMap(row);
  }

  /// Admin only (enforced by RLS).
  Future<List<ShopOrder>> fetchAllOrders({String? status, int? limit}) async {
    var query = supabase.from('orders').select(_select);
    if (status != null) query = query.eq('status', status);
    final ordered = query.order('created_at', ascending: false);
    final rows = limit != null ? await ordered.limit(limit) : await ordered;
    return rows.map(ShopOrder.fromMap).toList();
  }

  /// Admin only (enforced by RLS).
  Future<void> updateStatus(String orderId, String status) async {
    await supabase.from('orders').update({'status': status}).eq('id', orderId);
  }

  Future<void> cancelOrder(String orderId) async {
    await supabase.rpc('cancel_order', params: {'p_order_id': orderId});
  }
}
