import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/back_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../state/auth_provider.dart';
import '../../state/cart_provider.dart';
import '../../state/wishlist_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/notification_bell.dart';

class _Tab {
  const _Tab(this.label, this.icon, this.activeIcon, this.path);

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
}

const _tabs = [
  _Tab('Home', Icons.home_outlined, Icons.home_rounded, '/'),
  _Tab('Shop', Icons.grid_view_outlined, Icons.grid_view_rounded, '/shop'),
  _Tab(
    'Saved',
    Icons.favorite_border_rounded,
    Icons.favorite_rounded,
    '/wishlist',
  ),
  _Tab('Bag', Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, '/cart'),
  _Tab('You', Icons.person_outline_rounded, Icons.person_rounded, '/account'),
];

const _tabRoots = {'/', '/shop', '/wishlist', '/cart', '/account'};

int _tabIndexFor(String path) {
  if (path == '/') return 0;
  if (path.startsWith('/shop') || path.startsWith('/product')) return 1;
  if (path.startsWith('/wishlist')) return 2;
  if (path.startsWith('/cart') ||
      path.startsWith('/checkout') ||
      path.startsWith('/order-success')) {
    return 3;
  }
  if (path.startsWith('/account') || path.startsWith('/notifications')) {
    return 4;
  }
  return -1;
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = Uri.parse(location).path;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: Column(
          children: [
            _TopBar(showBack: !_tabRoots.contains(path)),
            Expanded(child: child),
          ],
        ),
        bottomNavigationBar: _TabBar(currentIndex: _tabIndexFor(path)),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showBack});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.select<AuthProvider, bool>((a) => a.isLoggedIn);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(bottom: BorderSide(color: AppColors.ink, width: 1.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 62,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (showBack) ...[
                  AppIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    size: 40,
                    onPressed: () {
                      final handled =
                          AppBackHandler.instance?.goBack() ?? false;
                      if (!handled) context.go('/');
                    },
                  ),
                  const SizedBox(width: 12),
                ],
                const AppLogo(size: 24),
                const Spacer(),
                AppIconButton(
                  icon: Icons.search_rounded,
                  tooltip: 'Search',
                  size: 40,
                  onPressed: () => context.go('/shop'),
                ),
                if (loggedIn) ...[
                  const SizedBox(width: 8),
                  const NotificationBell(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<CartProvider, int>((c) => c.count);
    final wishCount = context.select<WishlistProvider, int>((w) => w.count);
    final loggedIn = context.select<AuthProvider, bool>((a) => a.isLoggedIn);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.ink, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _TabItem(
                    tab: _tabs[i],
                    label: i == 4 && !loggedIn ? 'Sign in' : _tabs[i].label,
                    active: i == currentIndex,
                    badge: switch (i) {
                      2 => wishCount,
                      3 => cartCount,
                      _ => 0,
                    },
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.go(_tabs[i].path);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.label,
    required this.active,
    required this.badge,
    required this.onTap,
  });

  final _Tab tab;
  final String label;
  final bool active;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 54,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppColors.lime : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? AppColors.ink : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: active
            ? const [BoxShadow(color: AppColors.ink, offset: Offset(2, 2))]
            : null,
      ),
      child: Icon(
        active ? tab.activeIcon : tab.icon,
        size: 22,
        color: AppColors.ink,
      ),
    );

    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                icon,
                if (badge > 0)
                  Positioned(
                    right: 2,
                    top: -6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.violet,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.ink, width: 1.5),
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: AppText.label(size: 9, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(
                11,
                weight: active ? FontWeight.w700 : FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
