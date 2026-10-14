/// Supabase credentials.
///
/// Either paste your values into the defaults below, or pass them at run time:
///   flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// Find them in Supabase Dashboard → Project Settings → API.
/// The anon key is safe to ship in a web app; Row Level Security protects the data.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR-PROJECT.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR-ANON-KEY',
  );

  static bool get isConfigured =>
      !supabaseUrl.contains('YOUR-PROJECT') && !supabaseAnonKey.contains('YOUR-ANON-KEY');
}
