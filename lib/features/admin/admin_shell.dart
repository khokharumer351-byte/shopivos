import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'widgets/admin_theme.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/notification_bell.dart';
import '../../shared/widgets/page_container.dart';
import '../../shared/widgets/state_views.dart';
import '../../state/auth_provider.dart';

class _AdminNavEntry {
  const _AdminNavEntry(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}

const _entries = [
  _AdminNavEntry('Dashboard', Icons.space_dashboard_outlined, '/admin'),
  _AdminNavEntry('Products', Icons.checkroom_outlined, '/admin/products'),
  _AdminNavEntry('Categories', Icons.category_outlined, '/admin/categories'),
  _AdminNavEntry('Orders', Icons.receipt_long_outlined, '/admin/orders'),
  _AdminNavEntry('Customers', Icons.people_outline_rounded, '/admin/customers'),
  _AdminNavEntry('Notify', Icons.campaign_outlined, '/admin/notify'),
];

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(data: AdminTheme.light, child: _build(context));
  }

  Widget _build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.profile == null && auth.profileLoading) {
      return const Scaffold(body: LoadingView());
    }
    if (!auth.isAdmin) {
      return Scaffold(
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Admins only',
          message:
              'Your account doesn’t have access to the admin panel. '
              'Ask an existing admin to promote you, or see README → "Make yourself admin".',
          actionLabel: 'Back to store',
          onAction: () => context.go('/'),
        ),
      );
    }

    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    final sidebar = _Sidebar(location: location);

    return Scaffold(
      backgroundColor: AdminColors.paper,
      drawer: compact ? Drawer(width: 270, child: sidebar) : null,
      appBar: compact
          ? AppBar(
              backgroundColor: AdminColors.surface,
              foregroundColor: AdminColors.ink,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Admin',
                style: AdminText.display(20, color: AdminColors.ink),
              ),
              actions: const [NotificationBell(size: 36), SizedBox(width: 12)],
            )
          : null,
      body: compact
          ? child
          : Row(
              children: [
                SizedBox(width: 260, child: sidebar),
                Expanded(child: child),
              ],
            ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.location});

  final String location;

  bool _isActive(String path) =>
      path == '/admin' ? location == '/admin' : location.startsWith(path);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    void go(String path) {
      final scaffold = Scaffold.maybeOf(context);
      if (scaffold != null && scaffold.isDrawerOpen) scaffold.closeDrawer();
      context.go(path);
    }

    return Container(
      color: AdminColors.surface,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AdminColors.line)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const AppLogo(light: false, size: 24),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.lime,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'ADMIN',
                      style: AdminText.label(size: 9, color: AdminColors.violet),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              for (final entry in _entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _SidebarItem(
                    label: entry.label,
                    icon: entry.icon,
                    active: _isActive(entry.path),
                    onTap: () => go(entry.path),
                  ),
                ),
              const Spacer(),
              _SidebarItem(
                label: 'View store',
                icon: Icons.storefront_outlined,
                active: false,
                onTap: () => go('/'),
              ),
              const SizedBox(height: 6),
              _SidebarItem(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                active: false,
                onTap: () async {
                  await context.read<AuthProvider>().signOut();
                },
              ),
              const SizedBox(height: 16),
              Text(
                auth.profile?.email ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AdminText.body(12, color: AdminColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AdminColors.violet : AdminColors.muted;
    return Material(
      color: active ? AdminColors.lime : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: AdminColors.paperDark,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 12),
              Text(
                label,
                style: AdminText.body(15, weight: FontWeight.w600, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
