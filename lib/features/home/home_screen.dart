import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/feedback.dart';
import '../../data/models/product.dart';
import '../../data/models/product_category.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../shared/layout/store_shell.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/bits.dart';
import '../../shared/widgets/marquee.dart';
import '../../shared/widgets/page_container.dart';
import '../../shared/widgets/product_grid.dart';
import '../../shared/widgets/state_views.dart';
import 'widgets/category_strip.dart';
import 'widgets/hero_section.dart';
import 'widgets/perks_row.dart';
import 'widgets/promo_banner.dart';

class _HomeData {
  const _HomeData(this.categories, this.featured, this.newest);

  final List<ProductCategory> categories;
  final List<Product> featured;
  final List<Product> newest;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _products = ProductRepository();
  final _categories = CategoryRepository();
  late Future<_HomeData> _future = _load();

  Future<_HomeData> _load() async {
    final results = await Future.wait([
      _categories.fetchAll(),
      _products.fetchProducts(featuredOnly: true, limit: 8),
      _products.fetchProducts(sort: ProductSort.newest, limit: 8),
    ]);
    return _HomeData(
      results[0] as List<ProductCategory>,
      results[1] as List<Product>,
      results[2] as List<Product>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final featured = data?.featured ?? const <Product>[];

        return StorePage(
          children: [
            HeroSection(
              imageUrl: featured.isNotEmpty ? featured.first.primaryImage : null,
              secondaryImageUrl: featured.length > 1 ? featured[1].primaryImage : null,
            ),
            const Marquee(
              items: ['NEW SEASON', 'LIMITED DROPS', 'FREE SHIPPING RS 14,000+', 'CLASSICS REMIXED', '30-DAY RETURNS'],
            ),
            if (snapshot.hasError)
              ErrorView(
                message: friendlyError(snapshot.error!),
                onRetry: () => setState(() => _future = _load()),
              )
            else if (data == null)
              const LoadingView()
            else ...[
              if (data.categories.isNotEmpty) ...[
                const SizedBox(height: 72),
                PageContainer(
                  child: SectionTitle(kicker: 'Shop by vibe', title: 'Find your', accent: 'lane.'),
                ),
                const SizedBox(height: 28),
                CategoryStrip(categories: data.categories),
              ],
              const SizedBox(height: 80),
              PageContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionTitle(
                      kicker: 'Trending now',
                      title: 'The hot',
                      accent: 'list.',
                      trailing: AppButton(
                        label: 'View all',
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.small,
                        trailingIcon: Icons.arrow_forward_rounded,
                        onPressed: () => context.go('/shop?featured=1'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (featured.isEmpty && data.newest.isEmpty)
                      const EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No products yet',
                        message: 'Sign in as an admin and add your first product from the admin panel.',
                      )
                    else
                      ProductGrid(products: featured.isNotEmpty ? featured : data.newest.take(4).toList()),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              const PromoBanner(),
              if (data.newest.isNotEmpty) ...[
                const SizedBox(height: 80),
                PageContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionTitle(
                        kicker: 'Just landed',
                        title: 'Fresh',
                        accent: 'arrivals.',
                        trailing: AppButton(
                          label: 'Shop new',
                          variant: AppButtonVariant.outline,
                          size: AppButtonSize.small,
                          trailingIcon: Icons.arrow_forward_rounded,
                          onPressed: () => context.go('/shop?sort=newest'),
                        ),
                      ),
                      const SizedBox(height: 28),
                      ProductGrid(products: data.newest),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 80),
            const PerksRow(),
            const SizedBox(height: 24),
            const Marquee(
              items: ['SHOPIVO', 'WEAR THE VIBE', 'NOT THE TREND'],
              background: AppColors.lime,
              foreground: AppColors.ink,
              height: 64,
              fontSize: 28,
              duration: Duration(seconds: 14),
            ),
          ],
        );
      },
    );
  }
}
