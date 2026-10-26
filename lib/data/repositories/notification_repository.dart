import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_notification.dart';
import '../supabase_client.dart';

class NotificationRepository {
  Future<List<AppNotification>> fetch(String userId, {int limit = 60}) async {
    final rows = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(AppNotification.fromMap).toList();
  }

  Future<void> markRead(String id) async {
    await supabase
        .from('notifications')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }

  Future<void> markAllRead(String userId) async {
    await supabase
        .from('notifications')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('user_id', userId)
        .isFilter('read_at', null);
  }

  Future<void> delete(String id) async {
    await supabase.from('notifications').delete().eq('id', id);
  }

  Future<void> clearAll(String userId) async {
    await supabase.from('notifications').delete().eq('user_id', userId);
  }

  Future<int> broadcast({
    required String title,
    required String body,
    String? link,
  }) async {
    final result = await supabase.rpc(
      'broadcast_notification',
      params: {'p_title': title, 'p_body': body, 'p_link': link},
    );
    return (result as num?)?.toInt() ?? 0;
  }

  RealtimeChannel subscribe(
    String userId,
    void Function(AppNotification notification) onInsert,
  ) {
    return supabase
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) =>
              onInsert(AppNotification.fromMap(payload.newRecord)),
        )
        .subscribe();
  }

  Future<void> unsubscribe(RealtimeChannel channel) =>
      supabase.removeChannel(channel);
}
