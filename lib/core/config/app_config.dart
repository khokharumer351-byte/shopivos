abstract final class AppConfig {
  static const appName = 'Shopivo';
  static const currencySymbol = '\$';

  /// Keep these two in sync with `place_order` in supabase/schema.sql.
  static const freeShippingThreshold = 50.0;
  static const shippingFee = 5.0;

  static const productImagesBucket = 'product-images';
  static const lowStockThreshold = 5;
}
