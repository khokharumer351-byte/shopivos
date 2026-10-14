import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/bits.dart';
import '../../../shared/widgets/net_image.dart';
import '../../../shared/widgets/state_views.dart';
import '../widgets/admin_page.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _repo = ProductRepository();
  final _search = TextEditingController();
  late Future<List<Product>> _future = _load();

  Future<List<Product>> _load() => _repo.fetchProducts(includeInactive: true, search: _search.text);

  void _reload() => setState(() => _future = _load());

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(Product product) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete “${product.name}”?',
      message: 'This removes the product from the store. Past orders keep their copy of it.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    try {
      await _repo.delete(product.id);
      if (!mounted) return;
      showSnack(context, 'Product deleted');
      _reload();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Products',
      subtitle: 'Create, edit and manage your catalogue.',
      actions: [
        AppButton(
          label: 'New product',
          icon: Icons.add_rounded,
          variant: AppButtonVariant.accent,
          size: AppButtonSize.small,
          onPressed: () => context.go('/admin/products/new'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            onSubmitted: (_) => _reload(),
            decoration: InputDecoration(
              hintText: 'Search products and press Enter…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _search.clear();
                  _reload();
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Product>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) return ErrorView(message: friendlyError(snapshot.error!), onRetry: _reload);
              if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
              final products = snapshot.data ?? const <Product>[];
              if (products.isEmpty) {
                return EmptyState(
                  icon: Icons.checkroom_outlined,
                  title: 'No products',
                  message: 'Add your first product to start selling.',
                  actionLabel: 'New product',
                  onAction: () => context.go('/admin/products/new'),
                );
              }
              return Column(
                children: [
                  for (final product in products)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProductRow(
                        product: product,
                        onEdit: () => context.go('/admin/products/${product.id}/edit'),
                        onDelete: () => _delete(product),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onEdit, required this.onDelete});

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final stockColor = product.stock == 0
        ? AppColors.danger
        : (product.stock <= AppConfig.lowStockThreshold ? AppColors.warning : AppColors.success);

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(width: 56, height: 68, child: NetImage(product.primaryImage)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(15, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(product.categoryName ?? 'Uncategorized', style: AppText.body(13, color: AppColors.muted)),
                        if (!product.isActive) const Pill('Hidden', color: AppColors.paperDark),
                        if (product.isFeatured) const Pill('Featured', icon: Icons.bolt_rounded),
                        if (product.onSale) Pill('-${product.discountPercent}%', color: AppColors.pink),
                      ],
                    ),
                    if (compact) ...[
                      const SizedBox(height: 4),
                      Text('${formatPrice(product.price)} · ${product.stock} in stock',
                          style: AppText.body(13, weight: FontWeight.w600, color: stockColor)),
                    ],
                  ],
                ),
              ),
              if (!compact) ...[
                SizedBox(
                  width: 110,
                  child: Text(formatPrice(product.price), style: AppText.display(16)),
                ),
                SizedBox(
                  width: 110,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: stockColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text('${product.stock} in stock', style: AppText.body(13, weight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              IconButton(tooltip: 'Edit', onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
