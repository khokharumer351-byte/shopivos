import '../../data/models/app_notification.dart';
import 'local_notifications_stub.dart'
    if (dart.library.io) 'local_notifications_io.dart'
    as impl;

abstract final class LocalNotifications {
  static void Function(String link)? onOpenLink;

  static Future<void> init() => impl.init((link) => onOpenLink?.call(link));

  static Future<void> requestPermission() => impl.requestPermission();

  static Future<void> show(AppNotification notification) =>
      impl.show(notification);

  static Future<String?> takeLaunchLink() => impl.takeLaunchLink();
}
