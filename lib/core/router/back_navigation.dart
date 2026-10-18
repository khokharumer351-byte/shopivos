import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Android back button for the mobile app.
///
/// The store navigates with `context.go(...)` (URL style, like the website),
/// which replaces the page instead of stacking it, so the system back button
/// would close the app from anywhere. This keeps a small history of visited
/// locations and walks back through it; dialogs and sheets still close first.
class AppBackHandler {
  AppBackHandler(this._router) {
    instance = this;
    _current = _location;
    _router.routerDelegate.addListener(_onRouteChanged);
    _dispatcher = _router.backButtonDispatcher.createChildBackButtonDispatcher()
      ..addCallback(_onBack)
      ..takePriority();
  }

  final GoRouter _router;
  late final ChildBackButtonDispatcher _dispatcher;
  final List<String> _history = [];
  String _current = '/';
  bool _goingBack = false;

  static const _maxHistory = 40;

  /// Set while the mobile app is running (null on the web).
  static AppBackHandler? instance;

  /// Pages you shouldn't land on again by pressing back.
  static bool _skip(String location) {
    final path = Uri.parse(location).path;
    return path == '/login' ||
        path == '/signup' ||
        path == '/forgot-password' ||
        path == '/reset-password' ||
        path == '/checkout' ||
        path.startsWith('/order-success') ||
        path.endsWith('/new') ||
        path.endsWith('/edit');
  }

  String get _location => _router.routerDelegate.currentConfiguration.uri.toString();

  void _onRouteChanged() {
    final next = _location;
    if (next == _current) return;
    if (!_goingBack && _current.isNotEmpty && !_skip(_current)) {
      _history.add(_current);
      if (_history.length > _maxHistory) _history.removeAt(0);
    }
    _goingBack = false;
    _current = next;
  }

  Future<bool> _onBack() async {
    // Let dialogs, bottom sheets and pushed pages close normally.
    if (_router.canPop()) return false;
    return goBack();
  }

  /// Goes to the previous page (or up to home). Returns `false` when there is
  /// nowhere left to go, i.e. on the home screen.
  bool goBack() {
    while (_history.isNotEmpty && _history.last == _current) {
      _history.removeLast();
    }
    if (_history.isNotEmpty) {
      _goingBack = true;
      _router.go(_history.removeLast());
      return true;
    }
    final path = Uri.parse(_current).path;
    if (path != '/') {
      _goingBack = true;
      _router.go(path.startsWith('/admin') && path != '/admin' ? '/admin' : '/');
      return true;
    }
    // On the home tab with nothing behind it: let Android close the app.
    return false;
  }

  void dispose() {
    if (identical(instance, this)) instance = null;
    _router.routerDelegate.removeListener(_onRouteChanged);
    _dispatcher.removeCallback(_onBack);
    _router.backButtonDispatcher.forget(_dispatcher);
  }
}
