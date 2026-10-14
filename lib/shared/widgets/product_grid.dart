import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import 'product_card.dart';

/// Responsive grid that sizes columns from the available width.
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products, this.maxColumns = 4, this.spacing = 20});

  final List<Product> products;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        var columns = width >= 1100 ? 4 : (width >= 760 ? 3 : 2);
        if (columns > maxColumns) columns = maxColumns;
        final gap = width < 500 ? 12.0 : spacing;
        final itemWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap + 8,
          children: [
            for (final product in products)
              SizedBox(width: itemWidth, child: ProductCard(key: ValueKey(product.id), product: product)),
          ],
        );
      },
    );
  }
}
