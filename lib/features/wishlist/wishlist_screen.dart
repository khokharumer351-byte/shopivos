import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/feedback.dart';
import '../../data/models/product.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../shared/layout/store_shell.dart';
import '../../shared/widgets/page_container.dart';
import '../../shared/widgets/product_grid.dart';
import '../../shared/widgets/state_views.dart';
import '../../state/auth_provider.dart';
import '../../state/wishlist_provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _repo = WishlistRepository();
  Future<List<Product>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<AuthProvider>().user?.id;
    if (_future == null && userId != null) _future = _repo.fetchProducts(userId);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when hearts are toggled so removed items disappear instantly.
    final wishlist = context.watch<WishlistProvider>();
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    return StorePage(
      children: [
        PageContainer(
          verticalPadding: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Saved ', style: AppText.display(compact ? 40 : 60)),
                  TextSpan(text: 'for later.', style: AppText.serif(compact ? 44 : 64, color: AppColors.violet)),
                ]),
              ),
              const SizedBox(height: 32),
              FutureBuilder<List<Product>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ErrorView(message: friendlyError(snapshot.error!));
                  }
                  if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
                  final products = (snapshot.data ?? const <Product>[])
                      .where((p) => wishlist.contains(p.id))
                      .toList();
                  if (products.isEmpty) {
                    return EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'No favorites yet',
                      message: 'Tap the heart on anything you love and it will live here.',
                      actionLabel: 'Browse the shop',
                      onAction: () => context.go('/shop'),
                    );
                  }
                  return ProductGrid(products: products);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
