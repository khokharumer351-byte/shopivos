import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/notifications/local_notifications.dart';
import 'core/router/app_router.dart';
import 'core/router/back_navigation.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/platform.dart';
import 'features/misc/setup_required_screen.dart';
import 'state/auth_provider.dart';
import 'state/cart_provider.dart';
import 'state/notification_provider.dart';
import 'state/wishlist_provider.dart';

class ShopivoApp extends StatefulWidget {
  const ShopivoApp({super.key});

  @override
  State<ShopivoApp> createState() => _ShopivoAppState();
}

class _ShopivoAppState extends State<ShopivoApp> {
  late final AuthProvider _auth = AuthProvider();
  late final GoRouter _router = createRouter(_auth);
  late final NotificationProvider _notifications = NotificationProvider();
  AppBackHandler? _backHandler;
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    if (isMobileApp) {
      _backHandler = AppBackHandler(_router);

      LocalNotifications.onOpenLink = _openLink;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final link = await LocalNotifications.takeLaunchLink();
        if (link != null) _openLink(link);
      });
    }

    _lifecycle = AppLifecycleListener(onResume: _notifications.refresh);
  }

  void _openLink(String link) {
    if (link.startsWith('/')) _router.go(link);
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    _backHandler?.dispose();
    LocalNotifications.onOpenLink = null;
    _router.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider()..load(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(),
          update: (_, auth, wishlist) =>
              (wishlist ?? WishlistProvider())..bindUser(auth.user?.id),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => _notifications,
          update: (_, auth, notifications) =>
              (notifications ?? _notifications)..bindUser(auth.user?.id),
        ),
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}

class SetupRequiredApp extends StatelessWidget {
  const SetupRequiredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SetupRequiredScreen(),
    );
  }
}
