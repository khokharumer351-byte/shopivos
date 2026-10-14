import 'package:flutter_test/flutter_test.dart';

import 'package:shopivo/core/utils/formatters.dart';
import 'package:shopivo/core/utils/validators.dart';
import 'package:shopivo/data/models/product.dart';

void main() {
  group('formatPrice', () {
    test('adds currency, grouping and two decimals', () {
      expect(formatPrice(1234.5), '\$1,234.50');
      expect(formatPrice(0), '\$0.00');
      expect(formatPrice(999), '\$999.00');
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email('a@b.co'), isNull);
      expect(Validators.email('nope'), isNotNull);
    });

    test('password needs 6+ chars', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Product', () {
    test('parses a Supabase row with a joined category', () {
      final product = Product.fromMap({
        'id': 'p1',
        'name': 'Tee',
        'price': 20,
        'compare_at_price': '25.00',
        'stock': 3,
        'images': ['a.jpg'],
        'sizes': ['S', 'M'],
        'categories': {'name': 'Tops'},
      });
      expect(product.price, 20.0);
      expect(product.onSale, isTrue);
      expect(product.discountPercent, 20);
      expect(product.categoryName, 'Tops');
      expect(product.primaryImage, 'a.jpg');
    });
  });
}
