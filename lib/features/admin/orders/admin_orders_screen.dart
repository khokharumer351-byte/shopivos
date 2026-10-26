import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../shared/widgets/bits.dart';
import '../../../shared/widgets/state_views.dart';
import '../../account/order_detail_screen.dart';
import '../widgets/admin_page.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _repo = OrderRepository();
  String? _status;
  late Future<List<ShopOrder>> _future = _load();

  Future<List<ShopOrder>> _load() => _repo.fetchAllOrders(status: _status);

  void _reload() => setState(() => _future = _load());

  Future<void> _changeStatus(ShopOrder order, String status) async {
    if (status == order.status) return;
    if (status == OrderStatus.cancelled) {
      final ok = await confirmDialog(
        context,
        title: 'Cancel order ${orderRef(order.id)}?',
        message: 'Stock for these items will be returned to inventory.',
        confirmLabel: 'Cancel order',
        destructive: true,
      );
      if (!ok) return;
    }
    try {
      await _repo.updateStatus(order.id, status);
      if (!mounted) return;
      showSnack(context, 'Order ${orderRef(order.id)} → ${capitalize(status)}');
      _reload();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Orders',
      subtitle: 'Track, fulfil and update every order.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusFilter(
                label: 'All',
                selected: _status == null,
                onTap: () {
                  _status = null;
                  _reload();
                },
              ),
              for (final s in OrderStatus.all)
                _StatusFilter(
                  label: capitalize(s),
                  selected: _status == s,
                  onTap: () {
                    _status = s;
                    _reload();
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<ShopOrder>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorView(
                  message: friendlyError(snapshot.error!),
                  onRetry: _reload,
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return const LoadingView();
              }
              final orders = snapshot.data ?? const <ShopOrder>[];
              if (orders.isEmpty) {
                return const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders here',
                  message:
                      'Orders will show up as soon as customers check out.',
                );
              }
              return Column(
                children: [
                  for (final order in orders)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AdminOrderRow(
                        order: order,
                        onOpen: () => showAdminOrderDialog(context, order),
                        onStatus: (s) => _changeStatus(order, s),
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

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({
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
      shape: const StadiumBorder(
        side: BorderSide(color: AppColors.ink, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: AppText.body(
              13,
              weight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminOrderRow extends StatelessWidget {
  const _AdminOrderRow({
    required this.order,
    required this.onOpen,
    required this.onStatus,
  });

  final ShopOrder order;
  final VoidCallback onOpen;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderRef(order.id), style: AppText.display(17)),
                    const SizedBox(height: 4),
                    Text(
                      '${order.fullName}${order.customerEmail != null ? ' · ${order.customerEmail}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(13),
                    ),
                    Text(
                      '${formatDate(order.createdAt)} · ${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                      style: AppText.body(12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              if (!compact)
                SizedBox(
                  width: 120,
                  child: Text(
                    formatPrice(order.total),
                    style: AppText.display(17),
                  ),
                ),
              PopupMenuButton<String>(
                tooltip: 'Change status',
                onSelected: onStatus,
                itemBuilder: (context) => [
                  for (final s in OrderStatus.all)
                    PopupMenuItem<String>(
                      value: s,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: StatusChip.colorFor(s),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(capitalize(s)),
                          if (s == order.status) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.check_rounded, size: 18),
                          ],
                        ],
                      ),
                    ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusChip(order.status),
                    const Icon(Icons.expand_more_rounded),
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

Future<void> showAdminOrderDialog(BuildContext context, ShopOrder order) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.ink, width: 1.5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order ${orderRef(order.id)}',
                      style: AppText.display(26),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  StatusChip(order.status),
                  const SizedBox(width: 10),
                  Text(
                    formatDate(order.createdAt),
                    style: AppText.body(13, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('CUSTOMER', style: AppText.label(size: 11)),
              const SizedBox(height: 8),
              Text(
                order.fullName,
                style: AppText.body(15, weight: FontWeight.w700),
              ),
              if (order.customerEmail != null)
                Text(order.customerEmail!, style: AppText.body(14)),
              Text(order.phone, style: AppText.body(14)),
              Text(
                order.shippingAddress,
                style: AppText.body(14, color: AppColors.muted),
              ),
              if ((order.notes ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Note: ${order.notes}',
                  style: AppText.serif(15, color: AppColors.muted),
                ),
              ],
              const SizedBox(height: 24),
              Text('ITEMS', style: AppText.label(size: 11)),
              const SizedBox(height: 12),
              for (final item in order.items) ...[
                OrderItemRow(item: item),
                const SizedBox(height: 10),
              ],
              const Divider(height: 28),
              _Row('Subtotal', formatPrice(order.subtotal)),
              _Row(
                'Shipping',
                order.shippingFee == 0
                    ? 'Free'
                    : formatPrice(order.shippingFee),
              ),
              _Row('Payment', order.paymentLabel),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('Total', style: AppText.display(18)),
                  const Spacer(),
                  Text(formatPrice(order.total), style: AppText.display(22)),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label, style: AppText.body(14, color: AppColors.muted)),
          const Spacer(),
          Text(value, style: AppText.body(14, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
