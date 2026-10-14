import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/feedback.dart';
import '../../data/models/product.dart';
import '../../data/models/product_category.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../shared/layout/store_shell.dart';
import '../../shared/widgets/page_container.dart';
import '../../shared/widgets/product_grid.dart';
import '../../shared/widgets/state_views.dart';
import 'widgets/shop_filters.dart';

/// Product listing. All filters live in the URL so results are shareable:
/// `/shop?category=<id>&q=<search>&sort=<key>&featured=1`
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, this.categoryId, this.search, this.sortKey, this.featuredOnly = false});

  final String? categoryId;
  final String? search;
  final String? sortKey;
  final bool featuredOnly;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _productRepo = ProductRepository();
  final _categoryRepo = CategoryRepository();
  late final _searchController = TextEditingController(text: widget.search ?? '');

  List<ProductCategory> _categories = const [];
  late Future<List<Product>> _future = _loadProducts();

  ProductSort get _sort => ProductSort.fromKey(widget.sortKey);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepo.fetchAll();
      if (mounted) setState(() => _categories = categories);
    } catch (_) {
      // Filters are optional; the product list shows its own error state.
    }
  }

  @override
  void didUpdateWidget(covariant ShopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId ||
        oldWidget.search != widget.search ||
        oldWidget.sortKey != widget.sortKey ||
        oldWidget.featuredOnly != widget.featuredOnly) {
      _searchController.text = widget.search ?? '';
      _future = _loadProducts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Product>> _loadProducts() => _productRepo.fetchProducts(
        categoryId: widget.categoryId,
        search: widget.search,
        sort: _sort,
        featuredOnly: widget.featuredOnly,
      );

  void _update({String? categoryId, String? search, ProductSort? sort, bool? featured, bool clearCategory = false}) {
    final params = <String, String>{};
    final category = clearCategory ? null : (categoryId ?? widget.categoryId);
    final term = search ?? widget.search;
    final sortKey = (sort ?? _sort).key;
    final isFeatured = featured ?? widget.featuredOnly;

    if (category != null && category.isNotEmpty) params['category'] = category;
    if (term != null && term.trim().isNotEmpty) params['q'] = term.trim();
    if (sortKey != ProductSort.newest.key) params['sort'] = sortKey;
    if (isFeatured) params['featured'] = '1';

    context.go(Uri(path: '/shop', queryParameters: params.isEmpty ? null : params).toString());
  }

  String get _title {
    if (widget.featuredOnly) return 'Featured';
    if (widget.search != null && widget.search!.isNotEmpty) return 'Results';
    if (widget.categoryId != null) {
      for (final c in _categories) {
        if (c.id == widget.categoryId) return c.name;
      }
    }
    return 'Shop all';
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    final filters = ShopFilters(
      categories: _categories,
      selectedCategoryId: widget.categoryId,
      sort: _sort,
      featuredOnly: widget.featuredOnly,
      compact: compact,
      onCategory: (id) => id == null ? _update(clearCategory: true) : _update(categoryId: id),
      onSort: (sort) => _update(sort: sort),
      onFeatured: (value) => _update(featured: value),
    );

    final results = FutureBuilder<List<Product>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            message: friendlyError(snapshot.error!),
            onRetry: () => setState(() => _future = _loadProducts()),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
        final products = snapshot.data ?? const <Product>[];
        if (products.isEmpty) {
          return EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Nothing here (yet)',
            message: 'Try a different search or clear your filters.',
            actionLabel: 'Clear filters',
            onAction: () => context.go('/shop'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${products.length} ${products.length == 1 ? 'piece' : 'pieces'}',
              style: AppText.label(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            ProductGrid(products: products, maxColumns: compact ? 4 : 3),
          ],
        );
      },
    );

    return StorePage(
      children: [
        PageContainer(
          verticalPadding: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 24,
                runSpacing: 20,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('✦ THE COLLECTION', style: AppText.label(color: AppColors.muted)),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: _title, style: AppText.display(compact ? 40 : 60)),
                            TextSpan(text: '.', style: AppText.serif(compact ? 44 : 64, color: AppColors.violet)),
                          ],
                        ),
                      ),
                      if (widget.search != null && widget.search!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('for “${widget.search}”', style: AppText.serif(22, color: AppColors.muted)),
                        ),
                    ],
                  ),
                  SizedBox(
                    width: compact ? double.infinity : 340,
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) => _update(search: value),
                      decoration: InputDecoration(
                        hintText: 'Search products…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: (widget.search ?? '').isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () => _update(search: ''),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (compact) ...[
                filters,
                const SizedBox(height: 24),
                results,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 250, child: filters),
                    const SizedBox(width: 36),
                    Expanded(child: results),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
