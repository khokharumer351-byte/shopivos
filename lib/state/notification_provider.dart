import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/notifications/local_notifications.dart';
import '../data/models/app_notification.dart';
import '../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationRepository? repository})
    : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;
  String? _userId;
  RealtimeChannel? _channel;
  List<AppNotification> _items = [];
  bool _loading = false;
  String? _error;

  List<AppNotification> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  void bindUser(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _items = [];
    _error = null;
    _stopListening();

    Future.microtask(() async {
      await refresh();
      if (userId != null && userId == _userId) {
        _channel = _repository.subscribe(userId, _onIncoming);
        await LocalNotifications.requestPermission();
      }
    });
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) {
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      final items = await _repository.fetch(userId);
      if (userId == _userId) {
        _items = items;
        _error = null;
      }
    } catch (e) {
      debugPrint('Could not load notifications: $e');
      if (userId == _userId) _error = 'Could not load notifications.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _onIncoming(AppNotification notification) {
    if (_items.any((n) => n.id == notification.id)) return;
    _items = [notification, ..._items];
    notifyListeners();
    LocalNotifications.show(notification);
  }

  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    _replace(notification.markedRead());
    try {
      await _repository.markRead(notification.id);
    } catch (e) {
      debugPrint('Could not mark notification read: $e');
    }
  }

  Future<void> markAllRead() async {
    final userId = _userId;
    if (userId == null || unreadCount == 0) return;
    _items = [for (final n in _items) n.markedRead()];
    notifyListeners();
    try {
      await _repository.markAllRead(userId);
    } catch (e) {
      debugPrint('Could not mark notifications read: $e');
    }
  }

  Future<void> remove(AppNotification notification) async {
    final previous = _items;
    _items = _items.where((n) => n.id != notification.id).toList();
    notifyListeners();
    try {
      await _repository.delete(notification.id);
    } catch (e) {
      _items = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearAll() async {
    final userId = _userId;
    if (userId == null) return;
    final previous = _items;
    _items = [];
    notifyListeners();
    try {
      await _repository.clearAll(userId);
    } catch (e) {
      _items = previous;
      notifyListeners();
      rethrow;
    }
  }

  void _replace(AppNotification updated) {
    _items = [for (final n in _items) n.id == updated.id ? updated : n];
    notifyListeners();
  }

  void _stopListening() {
    final channel = _channel;
    _channel = null;
    if (channel != null) unawaited(_repository.unsubscribe(channel));
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}
