import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/notifications/local_notifications.dart';
import 'core/utils/platform.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean URLs (/shop instead of /#/shop) — also needed for the
  // password-reset link to land on /reset-password. No-op in the app.
  usePathUrlStrategy();

  if (isMobileApp) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  if (!Env.isConfigured) {
    runApp(const SetupRequiredApp());
    return;
  }

  // On the app this also handles the io.shopivo.app://login-callback deep link
  // from sign-up and password-reset emails.
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  await LocalNotifications.init();
  runApp(const ShopivoApp());
}
