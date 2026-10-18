import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/models/app_notification.dart';
import '../utils/platform.dart';

final _plugin = FlutterLocalNotificationsPlugin();
bool _ready = false;
bool _launchHandled = false;

const _channel = AndroidNotificationChannel(
  'shopivo_updates',
  'Shopivo updates',
  description: 'Order updates, new drops and store alerts',
  importance: Importance.high,
);

Future<void> init(void Function(String link) onOpenLink) async {
  // dart:io also exists on desktop; only phones get system notifications.
  if (!isMobileApp || _ready) return;
  try {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final link = response.payload;
        if (link != null && link.isNotEmpty) onOpenLink(link);
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    _ready = true;
  } catch (e) {
    debugPrint('Local notifications unavailable: $e');
  }
}

Future<void> requestPermission() async {
  if (!_ready) return;
  try {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  } catch (e) {
    debugPrint('Notification permission request failed: $e');
  }
}

Future<void> show(AppNotification notification) async {
  if (!_ready) return;
  try {
    await _plugin.show(
      // Stable 31-bit id per notification row.
      notification.id.hashCode & 0x7fffffff,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF7B5CFF),
          styleInformation: BigTextStyleInformation(notification.body),
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentBanner: true, presentSound: true),
      ),
      payload: notification.link,
    );
  } catch (e) {
    debugPrint('Could not show notification: $e');
  }
}

Future<String?> takeLaunchLink() async {
  if (!_ready || _launchHandled) return null;
  _launchHandled = true;
  try {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      final link = details!.notificationResponse?.payload;
      if (link != null && link.isNotEmpty) return link;
    }
  } catch (e) {
    debugPrint('Could not read launch notification: $e');
  }
  return null;
}
