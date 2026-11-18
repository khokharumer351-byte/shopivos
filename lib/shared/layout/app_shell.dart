import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _navVisible = true;

  void _handleScroll(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return;
    if (notification.direction == ScrollDirection.reverse && _navVisible) {
      setState(() => _navVisible = false);
    } else if (notification.direction == ScrollDirection.forward &&
        !_navVisible) {
      setState(() => _navVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = Uri.parse(widget.location).path;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navSpace = 74.0 + bottomInset;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                _TopBar(showBack: !_tabRoots.contains(path)),
                Expanded(
                  child: NotificationListener<UserScrollNotification>(
                    onNotification: (n) {
                      _handleScroll(n);
                      return false;
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: navSpace),
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                offset: _navVisible ? Offset.zero : const Offset(0, 1.15),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _navVisible ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_navVisible,
                    child: _TabBar(currentIndex: _tabIndexFor(path)),
                  ),
                ),
              ),
            ),
          ],
        ),
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

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.ink, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
                BoxShadow(color: AppColors.ink, offset: Offset(0, 2)),
              ],
            ),
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
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: active ? 46 : 40,
            height: 40,
            decoration: BoxDecoration(
              color: active ? AppColors.lime : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active ? AppColors.ink : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: active
                  ? const [BoxShadow(color: AppColors.ink, offset: Offset(1.5, 1.5))]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  scale: active ? 1.0 : 0.94,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    active ? tab.activeIcon : tab.icon,
                    size: 22,
                    color: active ? AppColors.ink : AppColors.muted,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 15),
                      height: 15,
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.violet,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.ink, width: 1.2),
                      ),
                      child: Text(
                        badge > 99 ? '9+' : '$badge',
                        style: AppText.label(size: 8, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
