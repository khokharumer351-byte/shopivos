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
    final name = auth.profile?.displayName ?? auth.user?.email ?? '';

    final content = switch (section) {
      AccountSection.profile => const ProfileForm(),
      AccountSection.orders => const OrdersList(),
      AccountSection.security => const SecurityForm(),
    };

    final nav = _AccountNav(current: section, compact: compact);

    return StorePage(
      children: [
        PageContainer(
          verticalPadding: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('✦ YOUR SPACE', style: AppText.label(color: AppColors.muted)),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Hey, ', style: AppText.display(compact ? 40 : 60)),
                  TextSpan(
                    text: '${name.split(' ').first}.',
                    style: AppText.serif(compact ? 44 : 64, color: AppColors.violet),
                  ),
                ]),
              ),
              const SizedBox(height: 32),
              if (compact) ...[nav, const SizedBox(height: 24), content]
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 260, child: nav),
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
      // No sidebar (or website drawer in the app), so sign-out lives here too.
      final signOut = _NavItem(
        label: 'Sign out',
        icon: Icons.logout_rounded,
        selected: false,
        onTap: () async {
          await context.read<AuthProvider>().signOut();
          if (context.mounted) context.go('/');
        },
      );
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final item in [...items, signOut])
              Padding(padding: const EdgeInsets.only(right: 8), child: item),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items) Padding(padding: const EdgeInsets.only(bottom: 6), child: item),
          const SizedBox(height: 12),
          AppButton(
            label: 'Sign out',
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.small,
            expand: true,
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) context.go('/');
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
    final bg = selected ? AppColors.ink : (highlight ? AppColors.lime : Colors.transparent);
    final fg = selected ? Colors.white : AppColors.ink;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 12),
              Text(label, style: AppText.body(15, weight: FontWeight.w600, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
