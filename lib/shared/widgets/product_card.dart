import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/feedback.dart';
import '../../data/models/product.dart';
import '../../state/cart_provider.dart';
import '../../state/wishlist_provider.dart';
import 'bits.dart';
import 'net_image.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;

  Product get _product => widget.product;

  void _open() => context.go('/product/${_product.id}');

  Future<void> _toggleWishlist() async {
    try {
      final ok = await context.read<WishlistProvider>().toggle(_product.id);
      if (!ok && mounted) {
        showSnack(
          context,
          'Sign in to save your favorites ♡',
          action: SnackBarAction(label: 'Sign in', onPressed: () => context.go('/login')),
        );
      }
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  void _quickAdd() {
    if (_product.sizes.isNotEmpty) {
      _open();
      return;
    }
    context.read<CartProvider>().add(_product);
    showSnack(
      context,
      '${_product.name} added to your bag',
      action: SnackBarAction(label: 'View bag', onPressed: () => context.go('/cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.select<WishlistProvider, bool>((w) => w.contains(_product.id));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.ink, width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.ink, offset: _hovered ? const Offset(6, 6) : const Offset(0, 0)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _hovered ? 1.05 : 1,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        child: NetImage(_product.primaryImage),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (!_product.inStock)
                              const Pill('Sold out', color: AppColors.ink, textColor: Colors.white)
                            else if (_product.onSale)
                              Pill('-${_product.discountPercent}%', color: AppColors.pink),
                            if (_product.isFeatured && _product.inStock) const Pill('Hot', icon: Icons.bolt_rounded),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: _CircleAction(
                          icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: saved ? AppColors.pink : AppColors.surface,
                          tooltip: saved ? 'Remove from wishlist' : 'Save to wishlist',
                          onTap: _toggleWishlist,
                        ),
                      ),
                      if (_product.inStock)
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: AnimatedOpacity(
                            opacity: _hovered ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: IgnorePointer(
                              ignoring: !_hovered,
                              child: _QuickAddBar(
                                label: _product.sizes.isEmpty ? 'Quick add +' : 'Choose size →',
                                onTap: _quickAdd,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (_product.categoryName ?? 'Shopivo').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.label(size: 10.5, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(15, weight: FontWeight.w600, height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: PriceTag(price: _product.price, compareAt: _product.compareAtPrice, size: 16),
                        ),
                        if (_product.ratingCount > 0) ...[
                          const Icon(Icons.star_rounded, size: 15),
                          Text(_product.ratingAvg.toStringAsFixed(1), style: AppText.body(12, weight: FontWeight.w600)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.color, required this.onTap, required this.tooltip});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(side: BorderSide(color: AppColors.ink, width: 1.5)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 18, color: AppColors.ink)),
        ),
      ),
    );
  }
}

class _QuickAddBar extends StatelessWidget {
  const _QuickAddBar({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lime,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.ink, width: 1.5)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Center(child: Text(label.toUpperCase(), style: AppText.label(size: 12))),
        ),
      ),
    );
  }
}
