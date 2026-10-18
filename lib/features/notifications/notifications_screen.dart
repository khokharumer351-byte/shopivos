import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/feedback.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_notification.dart';
import '../../shared/layout/store_shell.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/page_container.dart';
import '../../shared/widgets/state_views.dart';
import '../../state/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _open(BuildContext context, AppNotification notification) async {
    final provider = context.read<NotificationProvider>();
    final router = GoRouter.of(context);
    await provider.markRead(notification);
    final link = notification.link;
    if (link != null && link.startsWith('/')) router.go(link);
  }

  Future<void> _clearAll(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Clear all notifications?',
      message: 'This removes every notification from your inbox.',
      confirmLabel: 'Clear all',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await context.read<NotificationProvider>().clearAll();
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.items;
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    final Widget body;
    if (provider.loading && items.isEmpty) {
      body = const LoadingView();
    } else if (provider.error != null && items.isEmpty) {
      body = ErrorView(message: provider.error!, onRetry: provider.refresh);
    } else if (items.isEmpty) {
      body = EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'All quiet here',
        message: 'Order updates, new drops and offers will show up here.',
        actionLabel: 'Go shopping',
        onAction: () => context.go('/shop'),
      );
    } else {
      body = Column(
        children: [
          for (final n in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                ),
                onDismissed: (_) async {
                  try {
                    await provider.remove(n);
                  } catch (e) {
                    if (context.mounted) showSnack(context, friendlyError(e), error: true);
                  }
                },
                child: _NotificationTile(notification: n, onTap: () => _open(context, n)),
              ),
            ),
        ],
      );
    }

    return StorePage(
      children: [
        PageContainer(
          maxWidth: 820,
          verticalPadding: compact ? 24 : 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('✦ INBOX', style: AppText.label(color: AppColors.muted)),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Notifi', style: AppText.display(compact ? 40 : 56)),
                  TextSpan(text: 'cations', style: AppText.serif(compact ? 42 : 58, color: AppColors.violet)),
                ]),
              ),
              const SizedBox(height: 20),
              if (items.isNotEmpty) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AppButton(
                      label: 'Mark all read',
                      icon: Icons.done_all_rounded,
                      size: AppButtonSize.small,
                      variant: AppButtonVariant.accent,
                      onPressed: provider.unreadCount == 0 ? null : provider.markAllRead,
                    ),
                    AppButton(
                      label: 'Clear all',
                      icon: Icons.delete_sweep_outlined,
                      size: AppButtonSize.small,
                      variant: AppButtonVariant.outline,
                      onPressed: () => _clearAll(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              body,
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  (IconData, Color) get _style => switch (notification.kind) {
        'order' => (Icons.local_shipping_outlined, AppColors.sky),
        'admin' => (Icons.dashboard_customize_outlined, AppColors.peach),
        'promo' => (Icons.local_fire_department_outlined, AppColors.pink),
        _ => (Icons.auto_awesome_outlined, AppColors.lime),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style;
    final unread = !notification.isRead;

    return Material(
      color: unread ? AppColors.surface : AppColors.paperDark,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.ink, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: Icon(icon, size: 22, color: AppColors.ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppText.body(15, weight: unread ? FontWeight.w700 : FontWeight.w600),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(color: AppColors.violet, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(notification.body, style: AppText.body(14, color: AppColors.muted)),
                    ],
                    const SizedBox(height: 8),
                    Text(_timeAgo(notification.createdAt), style: AppText.label(size: 10, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _timeAgo(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'JUST NOW';
  if (diff.inMinutes < 60) return '${diff.inMinutes}M AGO';
  if (diff.inHours < 24) return '${diff.inHours}H AGO';
  if (diff.inDays < 7) return '${diff.inDays}D AGO';
  return formatDate(date).toUpperCase();
}
