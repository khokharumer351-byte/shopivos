import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean URLs (/shop instead of /#/shop) — also needed for the
  // password-reset link to land on /reset-password.
  usePathUrlStrategy();

  if (!Env.isConfigured) {
    runApp(const SetupRequiredApp());
    return;
  }

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  runApp(const ShopivoApp());
}
