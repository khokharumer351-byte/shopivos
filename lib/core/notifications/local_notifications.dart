import '../../data/models/app_notification.dart';
import 'local_notifications_stub.dart' if (dart.library.io) 'local_notifications_io.dart' as impl;

/// System (status-bar / lock-screen) notifications for the mobile app.
///
/// On the web this is a no-op: the plugin is only imported on Android/iOS,
/// and the website shows notifications through the bell in the header.
abstract final class LocalNotifications {
  /// Called with the in-app route (e.g. `/account/orders/<id>`) when the user
  /// taps a notification.
  static void Function(String link)? onOpenLink;

  static Future<void> init() => impl.init((link) => onOpenLink?.call(link));

  /// Asks for permission (Android 13+ / iOS). Safe to call more than once.
  static Future<void> requestPermission() => impl.requestPermission();

  static Future<void> show(AppNotification notification) => impl.show(notification);

  /// If the app was launched by tapping a notification, returns its link once.
  static Future<String?> takeLaunchLink() => impl.takeLaunchLink();
}
