import 'package:flutter/foundation.dart';

/// True when running as the installed Android / iOS app (not in a browser).
/// The app swaps the website header/footer for a native tab bar and enables
/// system notifications; every screen and the Supabase backend stay shared.
bool get isMobileApp =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
