import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../data/models/order.dart';
import '../../../data/models/product.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/net_image.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../shared/widgets/state_views.dart';
import '../../account/widgets/orders_list.dart';
import '../orders/admin_orders_screen.dart';
import '../widgets/admin_page.dart';

class _DashboardData {
  const _DashboardData(this.products, this.orders, this.customers);

  final List<Product> products;
  final List<ShopOrder> orders;
  final List<Profile> customers;
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<_DashboardData> _future = _load();

  Future<_DashboardData> _load() async {
    final results = await Future.wait([
      ProductRepository().fetchProducts(includeInactive: true),
      OrderRepository().fetchAllOrders(),
      ProfileRepository().fetchAll(),
    ]);
    return _DashboardData(
      results[0] as List<Product>,
      results[1] as List<ShopOrder>,
      results[2] as List<Profile>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Dashboard',
      subtitle: 'Your store at a glance.',
      actions: [
        AppButton(
          label: 'New product',
          icon: Icons.add_rounded,
          variant: AppButtonVariant.accent,
          size: AppButtonSize.small,
          onPressed: () => context.go('/admin/products/new'),
        ),
      ],
      child: FutureBuilder<_DashboardData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(
              message: friendlyError(snapshot.error!),
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final data = snapshot.data;
          if (data == null) return const LoadingView();

          final activeOrders = data.orders.where(
            (o) => o.status != OrderStatus.cancelled,
          );
          final revenue = activeOrders.fold<double>(
            0,
            (sum, o) => sum + o.total,
          );
          final pending = data.orders
              .where((o) => o.status == OrderStatus.pending)
              .length;
          final lowStock =
              data.products
                  .where((p) => p.stock <= AppConfig.lowStockThreshold)
                  .toList()
                ..sort((a, b) => a.stock.compareTo(b.stock));
          final recent = data.orders.take(6).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResponsiveGrid(
                children: [
                  StatCard(
                    label: 'Revenue',
                    value: formatPrice(revenue),
                    icon: Icons.trending_up_rounded,
                    color: AppColors.lime,
                  ),
                  StatCard(
                    label: 'Orders',
                    value: '${data.orders.length}',
                    icon: Icons.receipt_long_outlined,
                  ),
                  StatCard(
                    label: 'Pending',
                    value: '$pending',
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.peach,
                  ),
                  StatCard(
                    label: 'Products',
                    value: '${data.products.length}',
                    icon: Icons.checkroom_outlined,
                    color: AppColors.sky,
                  ),
                  StatCard(
                    label: 'Customers',
                    value: '${data.customers.length}',
                    icon: Icons.people_outline_rounded,
                    color: AppColors.violet,
                  ),
                ],
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  final ordersPanel = _Panel(
                    title: 'Recent orders',
                    action: TextButton(
                      onPressed: () => context.go('/admin/orders'),
                      child: const Text('See all'),
                    ),
                    child: recent.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No orders yet.',
                              style: AppText.body(14, color: AppColors.muted),
                            ),
                          )
                        : Column(
                            children: [
                              for (final order in recent)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: OrderTile(
                                    order: order,
                                    onTap: () =>
                                        showAdminOrderDialog(context, order),
                                  ),
                                ),
                            ],
                          ),
                  );
                  final stockPanel = _Panel(
                    title: 'Low stock',
                    action: TextButton(
                      onPressed: () => context.go('/admin/products'),
                      child: const Text('Manage'),
                    ),
                    child: lowStock.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'All stocked up ✦',
                              style: AppText.body(14, color: AppColors.muted),
                            ),
                          )
                        : Column(
                            children: [
                              for (final p in lowStock.take(8))
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  onTap: () => context.go(
                                    '/admin/products/${p.id}/edit',
                                  ),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 40,
                                      height: 48,
                                      child: NetImage(p.primaryImage),
                                    ),
                                  ),
                                  title: Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                    p.stock == 0
                                        ? 'Sold out'
                                        : '${p.stock} left',
                                    style: AppText.body(
                                      13,
                                      weight: FontWeight.w700,
                                      color: p.stock == 0
                                          ? AppColors.danger
                                          : AppColors.warning,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  );
                  if (!wide) {
                    return Column(
                      children: [
                        ordersPanel,
                        const SizedBox(height: 20),
                        stockPanel,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: ordersPanel),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: stockPanel),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return InkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppText.display(22))),
              ?action,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
