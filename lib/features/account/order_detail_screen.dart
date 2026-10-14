import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/feedback.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import '../../shared/layout/store_shell.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/bits.dart';
import '../../shared/widgets/net_image.dart';
import '../../shared/widgets/page_container.dart';
import '../../shared/widgets/state_views.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _repo = OrderRepository();
  late Future<ShopOrder?> _future = _repo.fetchOrder(widget.orderId);
  bool _cancelling = false;

  Future<void> _cancel(ShopOrder order) async {
    final ok = await confirmDialog(
      context,
      title: 'Cancel this order?',
      message: 'Items go back on the shelf and this can’t be undone.',
      confirmLabel: 'Cancel order',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _cancelling = true);
    try {
      await _repo.cancelOrder(order.id);
      if (!mounted) return;
      showSnack(context, 'Order cancelled');
      setState(() => _future = _repo.fetchOrder(widget.orderId));
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    return FutureBuilder<ShopOrder?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StorePage(children: [ErrorView(message: friendlyError(snapshot.error!))]);
        }
        if (snapshot.connectionState != ConnectionState.done && !snapshot.hasData) {
          return const StorePage(showFooter: false, children: [LoadingView(padding: 160)]);
        }
        final order = snapshot.data;
        if (order == null) {
          return StorePage(children: [
            EmptyState(
              title: 'Order not found',
              message: 'We couldn’t find that order on your account.',
              actionLabel: 'My orders',
              onAction: () => context.go('/account/orders'),
            ),
          ]);
        }

        final items = InkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Items', style: AppText.display(22)),
              const SizedBox(height: 16),
              for (final item in order.items) ...[
                OrderItemRow(item: item),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );

        final side = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkCard(
              shadow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Line('Subtotal', formatPrice(order.subtotal)),
                  const SizedBox(height: 8),
                  _Line('Shipping', order.shippingFee == 0 ? 'Free' : formatPrice(order.shippingFee)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _Line('Total', formatPrice(order.total), bold: true),
                  const SizedBox(height: 8),
                  _Line('Payment', order.paymentLabel),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SHIP TO', style: AppText.label(size: 11)),
                  const SizedBox(height: 10),
                  Text(order.fullName, style: AppText.body(15, weight: FontWeight.w700)),
                  Text(order.phone, style: AppText.body(14, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Text(order.shippingAddress, style: AppText.body(14)),
                  if ((order.notes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('“${order.notes}”', style: AppText.serif(16, color: AppColors.muted)),
                  ],
                ],
              ),
            ),
            if (order.canCancel) ...[
              const SizedBox(height: 16),
              AppButton(
                label: 'Cancel order',
                variant: AppButtonVariant.outline,
                expand: true,
                loading: _cancelling,
                onPressed: () => _cancel(order),
              ),
            ],
          ],
        );

        return StorePage(
          children: [
            PageContainer(
              verticalPadding: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.go('/account/orders'),
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                      label: Text('All orders', style: AppText.body(14, weight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Text('Order ${orderRef(order.id)}', style: AppText.display(compact ? 32 : 44)),
                      StatusChip(order.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Placed ${formatDate(order.createdAt)}', style: AppText.body(14, color: AppColors.muted)),
                  const SizedBox(height: 28),
                  OrderProgress(status: order.status),
                  const SizedBox(height: 28),
                  if (compact) ...[items, const SizedBox(height: 20), side]
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: items),
                        const SizedBox(width: 24),
                        SizedBox(width: 360, child: side),
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class OrderItemRow extends StatelessWidget {
  const OrderItemRow({super.key, required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: 56, height: 70, child: NetImage(item.productImage)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName, style: AppText.body(15, weight: FontWeight.w600)),
              Text(
                [
                  if (item.size != null) 'Size ${item.size}',
                  'Qty ${item.quantity}',
                  formatPrice(item.unitPrice),
                ].join(' · '),
                style: AppText.body(13, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Text(formatPrice(item.lineTotal), style: AppText.display(16)),
      ],
    );
  }
}

/// Horizontal tracker: pending → processing → shipped → delivered.
class OrderProgress extends StatelessWidget {
  const OrderProgress({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return InkCard(
        color: AppColors.paperDark,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.danger),
            const SizedBox(width: 12),
            Expanded(child: Text('This order was cancelled.', style: AppText.body(15, weight: FontWeight.w600))),
          ],
        ),
      );
    }

    final current = OrderStatus.flow.indexOf(status);
    return Row(
      children: [
        for (var i = 0; i < OrderStatus.flow.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(height: 3, color: i <= current ? AppColors.ink : AppColors.line),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: i <= current ? AppColors.lime : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: i <= current ? AppColors.ink : AppColors.line, width: 1.5),
                ),
                child: Icon(
                  i < current ? Icons.check_rounded : _icons[i],
                  size: 18,
                  color: i <= current ? AppColors.ink : AppColors.muted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                capitalize(OrderStatus.flow[i]),
                style: AppText.body(12, weight: FontWeight.w600, color: i <= current ? AppColors.ink : AppColors.muted),
              ),
            ],
          ),
        ],
      ],
    );
  }

  static const _icons = [
    Icons.receipt_outlined,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.home_outlined,
  ];
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: bold ? AppText.display(18) : AppText.body(14, color: AppColors.muted)),
        const Spacer(),
        Text(value, style: bold ? AppText.display(22) : AppText.body(14, weight: FontWeight.w600)),
      ],
    );
  }
}
