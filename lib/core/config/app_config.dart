abstract final class AppConfig {
  static const appName = 'Shopivo';
  static const currencySymbol = '\$';

  /// Keep these two in sync with `place_order` in supabase/schema.sql.
  static const freeShippingThreshold = 50.0;
  static const shippingFee = 5.0;

  static const productImagesBucket = 'product-images';
  static const lowStockThreshold = 5;

  /// Deep link the mobile app opens from sign-up / password-reset emails.
  /// Must be listed in Supabase → Authentication → URL Configuration → Redirect URLs,
  /// and match the scheme in AndroidManifest.xml and ios/Runner/Info.plist.
  static const appAuthCallback = 'io.shopivo.app://login-callback';
}
