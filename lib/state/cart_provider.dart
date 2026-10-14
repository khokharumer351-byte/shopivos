import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../data/models/cart_item.dart';
import '../data/models/product.dart';

/// Shopping bag, persisted in local storage so it survives refreshes.
/// Prices here are for display only — the server recalculates on checkout.
class CartProvider extends ChangeNotifier {
  static const _storageKey = 'shopivo_cart_v1';

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get count => _items.fold<int>(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold<double>(0, (sum, item) => sum + item.lineTotal);
  double get shippingFee =>
      isEmpty || subtotal >= AppConfig.freeShippingThreshold ? 0 : AppConfig.shippingFee;
  double get total => subtotal + shippingFee;
  double get amountToFreeShipping =>
      (AppConfig.freeShippingThreshold - subtotal).clamp(0, AppConfig.freeShippingThreshold).toDouble();

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw) as List<dynamic>;
      _items
        ..clear()
        ..addAll(decoded.map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map))));
      notifyListeners();
    } catch (e) {
      debugPrint('Could not restore cart: $e');
    }
  }

  void add(Product product, {int quantity = 1, String? size}) {
    final index = _items.indexWhere((item) => item.matches(product.id, size));
    if (index >= 0) {
      final current = _items[index];
      _items[index] = current.copyWith(quantity: _clamp(product, current.quantity + quantity));
    } else {
      _items.add(CartItem(product: product, quantity: _clamp(product, quantity), size: size));
    }
    _changed();
  }

  void setQuantity(CartItem item, int quantity) {
    final index = _items.indexWhere((e) => e.matches(item.product.id, item.size));
    if (index < 0) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: _clamp(item.product, quantity));
    }
    _changed();
  }

  void remove(CartItem item) {
    _items.removeWhere((e) => e.matches(item.product.id, item.size));
    _changed();
  }

  void clear() {
    _items.clear();
    _changed();
  }

  int _clamp(Product product, int quantity) {
    if (product.stock <= 0) return quantity < 1 ? 1 : quantity;
    return quantity.clamp(1, product.stock);
  }

  void _changed() {
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Could not save cart: $e');
    }
  }
}
