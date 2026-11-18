import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../shared/layout/store_shell.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/page_container.dart';
import '../../state/auth_provider.dart';
import 'widgets/orders_list.dart';
import 'widgets/profile_form.dart';
import 'widgets/security_form.dart';

enum AccountSection {
  profile('Profile', Icons.person_outline_rounded, '/account'),
  orders('Orders', Icons.receipt_long_outlined, '/account/orders'),
  security('Security', Icons.lock_outline_rounded, '/account/security');

  const AccountSection(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.section});

  final AccountSection section;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    if (!auth.isLoggedIn) {
      return StorePage(
        showFooter: false,
        children: [
          PageContainer(
            verticalPadding: compact ? 48 : 80,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign in to view your account',
                      style: AppText.display(compact ? 28 : 36),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Track orders, manage your profile and more.',
                      style: AppText.body(15, color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Sign in',
                      size: AppButtonSize.large,
                      onPressed: () => context.go('/login'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: Text(
                        'Create account',
                        style: AppText.body(15, weight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    final name = auth.profile?.displayName ?? auth.user?.email ?? '';
    final email = auth.user?.email ?? '';

    final content = switch (section) {
      AccountSection.profile => const ProfileForm(),
      AccountSection.orders => const OrdersList(),
      AccountSection.security => const SecurityForm(),
    };

    final nav = _AccountNav(current: section, compact: compact);

    return StorePage(
      children: [
        PageContainer(
          verticalPadding: compact ? 24 : 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 20 : 28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: compact ? 28 : 34,
                      backgroundColor: AppColors.ink,
                      child: Text(
                        _initials(name),
                        style: AppText.display(
                          compact ? 18 : 22,
                          color: Colors.white,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'Your account' : name,
                            style: AppText.display(compact ? 22 : 28),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: AppText.body(14, color: AppColors.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (compact) ...[
                nav,
                const SizedBox(height: 24),
                content,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 280, child: nav),
                    const SizedBox(width: 36),
                    Expanded(child: content),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return 'S';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _AccountNav extends StatelessWidget {
  const _AccountNav({required this.current, required this.compact});

  final AccountSection current;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final items = [
      for (final section in AccountSection.values)
        _NavItem(
          label: section.label,
          icon: section.icon,
          selected: section == current,
          onTap: () => context.go(section.path),
        ),
      _NavItem(
        label: 'Notifications',
        icon: Icons.notifications_none_rounded,
        selected: false,
        onTap: () => context.go('/notifications'),
      ),
      if (auth.isAdmin)
        _NavItem(
          label: 'Admin panel',
          icon: Icons.dashboard_customize_outlined,
          selected: false,
          highlight: true,
          onTap: () => context.go('/admin'),
        ),
    ];

    if (compact) {
      final signOut = _NavItem(
        label: 'Log out',
        icon: Icons.logout_rounded,
        selected: false,
        onTap: () async {
          await context.read<AuthProvider>().signOut();
          if (context.mounted) context.go('/login');
        },
      );
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in [...items, signOut])
              Padding(padding: const EdgeInsets.only(right: 8), child: item),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items)
            Padding(padding: const EdgeInsets.only(bottom: 6), child: item),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          AppButton(
            label: 'Log out',
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.small,
            expand: true,
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.ink
        : (highlight ? AppColors.lime : Colors.transparent);
    final fg = selected ? Colors.white : AppColors.ink;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppText.body(14, weight: FontWeight.w600, color: fg),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 16, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}
