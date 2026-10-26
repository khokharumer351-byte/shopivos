import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/feedback.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../shared/layout/store_shell.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/bits.dart';
import '../../shared/widgets/page_container.dart';
import '../../shared/widgets/product_grid.dart';
import '../../shared/widgets/state_views.dart';
import '../../state/cart_provider.dart';
import '../../state/wishlist_provider.dart';
import 'widgets/product_gallery.dart';
import 'widgets/reviews_section.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _repo = ProductRepository();
  late Future<Product?> _future = _repo.fetchProduct(widget.productId);
  Future<List<Product>>? _related;

  String? _size;
  int _quantity = 1;

  @override
  void didUpdateWidget(covariant ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _future = _repo.fetchProduct(widget.productId);
      _related = null;
      _size = null;
      _quantity = 1;
    }
  }

  void _reload() =>
      setState(() => _future = _repo.fetchProduct(widget.productId));

  void _addToCart(Product product) {
    if (product.sizes.isNotEmpty && _size == null) {
      showSnack(context, 'Pick a size first ✌️', error: true);
      return;
    }
    context.read<CartProvider>().add(product, quantity: _quantity, size: _size);
    showSnack(
      context,
      'Added to your bag',
      action: SnackBarAction(
        label: 'View bag',
        onPressed: () => context.go('/cart'),
      ),
    );
  }

  Future<void> _toggleWishlist(Product product) async {
    try {
      final ok = await context.read<WishlistProvider>().toggle(product.id);
      if (!ok && mounted) {
        showSnack(
          context,
          'Sign in to save your favorites ♡',
          action: SnackBarAction(
            label: 'Sign in',
            onPressed: () => context.go('/login'),
          ),
        );
      }
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();

    return FutureBuilder<Product?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StorePage(
            children: [
              ErrorView(
                message: friendlyError(snapshot.error!),
                onRetry: _reload,
              ),
            ],
          );
        }
        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          return const StorePage(
            showFooter: false,
            children: [LoadingView(padding: 160)],
          );
        }
        final product = snapshot.data;
        if (product == null) {
          return StorePage(
            children: [
              EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Product not found',
                message: 'It might have sold out or been moved.',
                actionLabel: 'Back to shop',
                onAction: () => context.go('/shop'),
              ),
            ],
          );
        }

        _related ??= _repo.fetchProducts(
          categoryId: product.categoryId,
          excludeId: product.id,
          limit: 4,
        );
        final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
        final gallery = ProductGallery(images: product.images);
        final info = _buildInfo(
          product,
          compact,
          saved: wishlist.contains(product.id),
        );

        return StorePage(
          children: [
            PageContainer(
              verticalPadding: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Breadcrumbs(product: product),
                  const SizedBox(height: 24),
                  if (compact) ...[
                    gallery,
                    const SizedBox(height: 32),
                    info,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: gallery),
                        const SizedBox(width: 56),
                        Expanded(child: info),
                      ],
                    ),
                  const SizedBox(height: 80),
                  ReviewsSection(product: product, onChanged: _reload),
                  const SizedBox(height: 80),
                  FutureBuilder<List<Product>>(
                    future: _related,
                    builder: (context, relatedSnap) {
                      final related = relatedSnap.data ?? const <Product>[];
                      if (related.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionTitle(
                            kicker: 'Complete the look',
                            title: 'You might',
                            accent: 'also like.',
                          ),
                          const SizedBox(height: 28),
                          ProductGrid(products: related),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfo(Product product, bool compact, {required bool saved}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.categoryName != null)
              Pill(product.categoryName!, color: AppColors.sky),
            if (product.isFeatured)
              const Pill('Hot right now', icon: Icons.bolt_rounded),
            if (product.onSale)
              Pill('Save ${product.discountPercent}%', color: AppColors.pink),
          ],
        ),
        const SizedBox(height: 20),
        Text(product.name, style: AppText.display(compact ? 38 : 52)),
        const SizedBox(height: 12),
        Row(
          children: [
            StarRating(rating: product.ratingAvg, size: 18),
            const SizedBox(width: 8),
            Text(
              product.ratingCount == 0
                  ? 'No reviews yet'
                  : '${product.ratingAvg.toStringAsFixed(1)} · ${product.ratingCount} review${product.ratingCount == 1 ? '' : 's'}',
              style: AppText.body(13, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 24),
        PriceTag(
          price: product.price,
          compareAt: product.compareAtPrice,
          size: 34,
        ),
        const SizedBox(height: 12),
        _StockLine(stock: product.stock),
        if (product.sizes.isNotEmpty) ...[
          const SizedBox(height: 28),
          Row(
            children: [
              Text('SIZE', style: AppText.label()),
              const Spacer(),
              if (_size != null)
                Text(
                  'Selected: $_size',
                  style: AppText.body(13, color: AppColors.muted),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final size in product.sizes)
                _SizeChip(
                  label: size,
                  selected: _size == size,
                  onTap: () => setState(() => _size = size),
                ),
            ],
          ),
        ],
        const SizedBox(height: 28),
        if (product.inStock)
          Row(
            children: [
              QuantityStepper(
                value: _quantity,
                max: product.stock,
                onChanged: (value) => setState(() => _quantity = value),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Add to bag',
                  icon: Icons.shopping_bag_outlined,
                  variant: AppButtonVariant.accent,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: () => _addToCart(product),
                ),
              ),
              const SizedBox(width: 12),
              AppIconButton(
                icon: saved
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                background: saved ? AppColors.pink : AppColors.surface,
                size: 56,
                tooltip: saved ? 'Remove from wishlist' : 'Save to wishlist',
                onPressed: () => _toggleWishlist(product),
              ),
            ],
          )
        else
          Row(
            children: [
              const Expanded(
                child: AppButton(
                  label: 'Sold out',
                  onPressed: null,
                  size: AppButtonSize.large,
                  expand: true,
                ),
              ),
              const SizedBox(width: 12),
              AppIconButton(
                icon: saved
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                background: saved ? AppColors.pink : AppColors.surface,
                size: 56,
                onPressed: () => _toggleWishlist(product),
              ),
            ],
          ),
        const SizedBox(height: 28),
        InkCard(
          color: AppColors.paperDark,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _Perk(
                icon: Icons.local_shipping_outlined,
                text:
                    'Free shipping on orders over ${formatPrice(AppConfig.freeShippingThreshold)}',
              ),
              const SizedBox(height: 12),
              const _Perk(
                icon: Icons.autorenew_rounded,
                text: '30-day returns, no questions asked',
              ),
              const SizedBox(height: 12),
              const _Perk(
                icon: Icons.payments_outlined,
                text: 'Cash on delivery available',
              ),
            ],
          ),
        ),
        if (product.description.trim().isNotEmpty) ...[
          const SizedBox(height: 32),
          Text('THE DETAILS', style: AppText.label()),
          const SizedBox(height: 12),
          Text(product.description, style: AppText.body(16, height: 1.7)),
        ],
      ],
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final style = AppText.body(13, color: AppColors.muted);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        InkWell(
          onTap: () => context.go('/'),
          child: Text('Home', style: style),
        ),
        Text('/', style: style),
        InkWell(
          onTap: () => context.go('/shop'),
          child: Text('Shop', style: style),
        ),
        if (product.categoryId != null && product.categoryName != null) ...[
          Text('/', style: style),
          InkWell(
            onTap: () => context.go('/shop?category=${product.categoryId}'),
            child: Text(product.categoryName!, style: style),
          ),
        ],
        Text('/', style: style),
        Text(product.name, style: AppText.body(13, weight: FontWeight.w600)),
      ],
    );
  }
}

class _StockLine extends StatelessWidget {
  const _StockLine({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final (color, text) = stock <= 0
        ? (AppColors.danger, 'Sold out — check back soon')
        : stock <= AppConfig.lowStockThreshold
        ? (AppColors.warning, 'Only $stock left — move fast')
        : (AppColors.success, 'In stock, ready to ship');
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: AppText.body(14, weight: FontWeight.w600)),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 56),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppText.display(
              15,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppText.body(14))),
      ],
    );
  }
}
