import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../shared/widgets/bits.dart';
import '../../../shared/widgets/net_image.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../state/auth_provider.dart';

class OrdersList extends StatefulWidget {
  const OrdersList({super.key});

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  final _repo = OrderRepository();
  Future<List<ShopOrder>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<AuthProvider>().user?.id;
    if (_future == null && userId != null) _future = _repo.fetchMyOrders(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ShopOrder>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorView(message: friendlyError(snapshot.error!));
        if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
        final orders = snapshot.data ?? const <ShopOrder>[];
        if (orders.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            message: 'When you place an order it will show up here.',
            actionLabel: 'Start shopping',
            onAction: () => context.go('/shop'),
          );
        }
        return Column(
          children: [
            for (final order in orders)
              Padding(padding: const EdgeInsets.only(bottom: 14), child: OrderTile(order: order)),
          ],
        );
      },
    );
  }
}

class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order, this.onTap});

  final ShopOrder order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final thumbs = order.items.where((i) => i.productImage != null).take(3).toList();

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => context.go('/account/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              SizedBox(
                width: 56.0 + (thumbs.length > 1 ? (thumbs.length - 1) * 22.0 : 0),
                height: 64,
                child: Stack(
                  children: [
                    if (thumbs.isEmpty)
                      Container(
                        width: 56,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.paperDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.ink, width: 1.5),
                        ),
                        child: const Icon(Icons.inventory_2_outlined),
                      ),
                    for (var i = 0; i < thumbs.length; i++)
                      Positioned(
                        left: i * 22.0,
                        child: Container(
                          width: 56,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.ink, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: NetImage(thumbs[i].productImage),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderRef(order.id), style: AppText.display(18)),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDate(order.createdAt)} · ${order.itemCount} item${order.itemCount == 1 ? '' : 's'}'
                      '${order.customerEmail != null && onTap != null ? ' · ${order.customerEmail}' : ''}',
                      style: AppText.body(13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatPrice(order.total), style: AppText.display(18)),
                  const SizedBox(height: 6),
                  StatusChip(order.status),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
