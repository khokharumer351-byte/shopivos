import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/notification_provider.dart';
import 'app_button.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final unread = context.select<NotificationProvider, int>(
      (n) => n.unreadCount,
    );
    return AppIconButton(
      icon: unread > 0
          ? Icons.notifications_active_outlined
          : Icons.notifications_none_rounded,
      tooltip: 'Notifications',
      size: size,
      badge: unread,
      onPressed: () => context.go('/notifications'),
    );
  }
}
