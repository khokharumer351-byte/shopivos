import 'package:flutter/foundation.dart';

import '../data/repositories/wishlist_repository.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider({WishlistRepository? repository})
    : _repository = repository ?? WishlistRepository();

  final WishlistRepository _repository;
  String? _userId;
  Set<String> _ids = {};

  bool get isSignedIn => _userId != null;
  int get count => _ids.length;
  bool contains(String productId) => _ids.contains(productId);

  void bindUser(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _ids = {};

    Future.microtask(_load);
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId != null) {
      try {
        final ids = await _repository.fetchIds(userId);
        if (userId == _userId) _ids = ids;
      } catch (e) {
        debugPrint('Could not load wishlist: $e');
      }
    }
    notifyListeners();
  }

  Future<bool> toggle(String productId) async {
    final userId = _userId;
    if (userId == null) return false;

    final wasSaved = _ids.contains(productId);
    if (wasSaved) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    notifyListeners();

    try {
      if (wasSaved) {
        await _repository.remove(userId, productId);
      } else {
        await _repository.add(userId, productId);
      }
    } catch (e) {
      if (wasSaved) {
        _ids.add(productId);
      } else {
        _ids.remove(productId);
      }
      notifyListeners();
      rethrow;
    }
    return true;
  }
}
