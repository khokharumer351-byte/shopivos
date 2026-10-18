import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../state/auth_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';

class MobileNavDrawer extends StatelessWidget {
  const MobileNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    void go(String path) {
      Scaffold.of(context).closeDrawer();
      context.go(path);
    }

    return Drawer(
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const AppLogo(linkHome: false),
            const SizedBox(height: 32),
            _DrawerLink('Home', () => go('/')),
            _DrawerLink('Shop all', () => go('/shop')),
            _DrawerLink('New in', () => go('/shop?sort=newest')),
            _DrawerLink('Featured', () => go('/shop?featured=1')),
            _DrawerLink('Wishlist', () => go('/wishlist')),
            _DrawerLink('Bag', () => go('/cart')),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            if (auth.isLoggedIn) ...[
              _DrawerLink('My account', () => go('/account')),
              _DrawerLink('My orders', () => go('/account/orders')),
              _DrawerLink('Notifications', () => go('/notifications')),
              if (auth.isAdmin) _DrawerLink('Admin panel', () => go('/admin')),
              const SizedBox(height: 16),
              AppButton(
                label: 'Sign out',
                variant: AppButtonVariant.outline,
                expand: true,
                onPressed: () async {
                  Scaffold.of(context).closeDrawer();
                  await context.read<AuthProvider>().signOut();
                },
              ),
            ] else ...[
              AppButton(label: 'Sign in', expand: true, onPressed: () => go('/login')),
              const SizedBox(height: 12),
              AppButton(
                label: 'Create account',
                variant: AppButtonVariant.accent,
                expand: true,
                onPressed: () => go('/signup'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppText.display(26))),
            const Icon(Icons.arrow_outward_rounded),
          ],
        ),
      ),
    );
  }
}
