import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../state/auth_provider.dart';
import '../../state/cart_provider.dart';
import '../../state/wishlist_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/page_container.dart';

class SiteHeader extends StatelessWidget {
  const SiteHeader({super.key, required this.location});

  /// Current URL, used to highlight the active nav link.
  final String location;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < Breakpoints.tablet;
    final cartCount = context.select<CartProvider, int>((c) => c.count);
    final wishCount = context.select<WishlistProvider, int>((w) => w.count);
    final auth = context.watch<AuthProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          color: AppColors.ink,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'FREE SHIPPING OVER ${formatPrice(AppConfig.freeShippingThreshold)}  ✦  30-DAY EASY RETURNS  ✦  NEW DROPS EVERY FRIDAY',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.label(size: 11, color: AppColors.lime),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.paper,
            border: Border(bottom: BorderSide(color: AppColors.ink, width: 1.5)),
          ),
          child: PageContainer(
            child: SizedBox(
              height: 74,
              child: Row(
                children: [
                  if (compact) ...[
                    AppIconButton(
                      icon: Icons.menu_rounded,
                      tooltip: 'Menu',
                      size: 40,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const AppLogo(),
                  if (!compact) ...[
                    const SizedBox(width: 40),
                    _NavLink(label: 'Home', path: '/', active: location == '/'),
                    _NavLink(label: 'Shop all', path: '/shop', active: location == '/shop'),
                    _NavLink(label: 'New in', path: '/shop?sort=newest', active: location == '/shop?sort=newest'),
                    _NavLink(label: 'Featured', path: '/shop?featured=1', active: location == '/shop?featured=1'),
                  ],
                  const Spacer(),
                  if (!compact) ...[const _HeaderSearch(), const SizedBox(width: 12)],
                  if (compact) ...[
                    AppIconButton(
                      icon: Icons.search_rounded,
                      tooltip: 'Search',
                      size: 40,
                      onPressed: () => context.go('/shop'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (width >= Breakpoints.mobile) ...[
                    AppIconButton(
                      icon: Icons.favorite_border_rounded,
                      tooltip: 'Wishlist',
                      size: 40,
                      badge: wishCount,
                      onPressed: () => context.go('/wishlist'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  AppIconButton(
                    icon: Icons.shopping_bag_outlined,
                    tooltip: 'Bag',
                    size: 40,
                    badge: cartCount,
                    background: AppColors.lime,
                    onPressed: () => context.go('/cart'),
                  ),
                  const SizedBox(width: 8),
                  if (auth.isLoggedIn)
                    const _AccountMenu()
                  else if (!compact)
                    AppButton(
                      label: 'Sign in',
                      size: AppButtonSize.small,
                      onPressed: () => context.go('/login'),
                    )
                  else
                    AppIconButton(
                      icon: Icons.person_outline_rounded,
                      tooltip: 'Sign in',
                      size: 40,
                      onPressed: () => context.go('/login'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.path, required this.active});

  final String label;
  final String path;
  final bool active;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.ink : (_hovered ? AppColors.lime : Colors.transparent),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.label,
            style: AppText.body(14, weight: FontWeight.w600, color: active ? Colors.white : AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _HeaderSearch extends StatefulWidget {
  const _HeaderSearch();

  @override
  State<_HeaderSearch> createState() => _HeaderSearchState();
}

class _HeaderSearchState extends State<_HeaderSearch> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final term = value.trim();
    context.go(term.isEmpty ? '/shop' : '/shop?q=${Uri.encodeQueryComponent(term)}');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width > 1200 ? 260 : 190,
      height: 42,
      child: TextField(
        controller: _controller,
        onSubmitted: _submit,
        textInputAction: TextInputAction.search,
        style: AppText.body(14),
        decoration: InputDecoration(
          hintText: 'Search the drop…',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.violet, width: 2),
          ),
        ),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final initials = auth.profile?.initials ?? (auth.user?.email?.substring(0, 1).toUpperCase() ?? '?');

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 52),
      onSelected: (value) async {
        if (value == 'signout') {
          await context.read<AuthProvider>().signOut();
          if (context.mounted) context.go('/');
        } else {
          context.go(value);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            auth.profile?.displayName ?? auth.user?.email ?? '',
            style: AppText.body(13, weight: FontWeight.w600, color: AppColors.muted),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: '/account', child: _MenuRow(Icons.person_outline_rounded, 'My profile')),
        const PopupMenuItem(value: '/account/orders', child: _MenuRow(Icons.receipt_long_outlined, 'My orders')),
        const PopupMenuItem(value: '/wishlist', child: _MenuRow(Icons.favorite_border_rounded, 'Wishlist')),
        if (auth.isAdmin)
          const PopupMenuItem(value: '/admin', child: _MenuRow(Icons.dashboard_customize_outlined, 'Admin panel')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'signout', child: _MenuRow(Icons.logout_rounded, 'Sign out')),
      ],
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.violet,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        child: Text(initials, style: AppText.label(size: 13, color: Colors.white)),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}
