import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppBackHandler {
  AppBackHandler(this._router) {
    instance = this;
    _current = _location;
    _router.routerDelegate.addListener(_onRouteChanged);
    _dispatcher = _router.backButtonDispatcher.createChildBackButtonDispatcher()
      ..addCallback(_onBack);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _dispatcher.takePriority(),
    );
  }

  final GoRouter _router;
  late final ChildBackButtonDispatcher _dispatcher;
  final List<String> _history = [];
  String _current = '/';
  bool _goingBack = false;

  static const _maxHistory = 40;

  static AppBackHandler? instance;

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

  String get _location =>
      _router.routerDelegate.currentConfiguration.uri.toString();

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
    if (_router.canPop()) return false;
    return goBack();
  }

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
      _router.go(
        path.startsWith('/admin') && path != '/admin' ? '/admin' : '/',
      );
      return true;
    }

    return false;
  }

  void dispose() {
    if (identical(instance, this)) instance = null;
    _router.routerDelegate.removeListener(_onRouteChanged);
    _dispatcher.removeCallback(_onBack);
    _router.backButtonDispatcher.forget(_dispatcher);
  }
}
