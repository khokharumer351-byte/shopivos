import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/cart_item.dart';
import '../../shared/layout/store_shell.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/bits.dart';
import '../../shared/widgets/net_image.dart';
import '../../shared/widgets/page_container.dart';
import '../../shared/widgets/state_views.dart';
import '../../state/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    if (cart.isEmpty) {
      return StorePage(
        children: [
          EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Your bag is empty',
            message:
                'Main character energy needs a wardrobe. Go find something you love.',
            actionLabel: 'Start shopping',
            onAction: () => context.go('/shop'),
          ),
        ],
      );
    }

    final items = Column(
      children: [
        for (final item in cart.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CartLine(item: item),
          ),
      ],
    );

    return StorePage(
      children: [
        PageContainer(
          verticalPadding: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Your ',
                      style: AppText.display(compact ? 40 : 60),
                    ),
                    TextSpan(
                      text: 'bag',
                      style: AppText.serif(
                        compact ? 44 : 64,
                        color: AppColors.violet,
                      ),
                    ),
                    TextSpan(
                      text: ' (${cart.count})',
                      style: AppText.display(
                        compact ? 24 : 32,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (compact) ...[
                items,
                const SizedBox(height: 16),
                const OrderSummaryCard(showCheckout: true),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: items),
                    const SizedBox(width: 32),
                    const SizedBox(
                      width: 380,
                      child: OrderSummaryCard(showCheckout: true),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CartLine extends StatelessWidget {
  const CartLine({super.key, required this.item, this.editable = true});

  final CartItem item;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final product = item.product;

    return InkCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.go('/product/${product.id}'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: editable ? 96 : 64,
                height: editable ? 120 : 80,
                child: NetImage(product.primaryImage),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(
                          editable ? 16 : 14,
                          weight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (editable)
                      IconButton(
                        tooltip: 'Remove',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => cart.remove(item),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (item.size != null)
                      Text(
                        'Size ${item.size}',
                        style: AppText.body(13, color: AppColors.muted),
                      ),
                    if (!editable)
                      Text(
                        'Qty ${item.quantity}',
                        style: AppText.body(13, color: AppColors.muted),
                      ),
                    Text(
                      formatPrice(product.price),
                      style: AppText.body(13, color: AppColors.muted),
                    ),
                  ],
                ),
                SizedBox(height: editable ? 16 : 6),
                Row(
                  children: [
                    if (editable)
                      QuantityStepper(
                        compact: true,
                        value: item.quantity,
                        max: product.stock > 0 ? product.stock : null,
                        onChanged: (value) => cart.setQuantity(item, value),
                      ),
                    const Spacer(),
                    Text(
                      formatPrice(item.lineTotal),
                      style: AppText.display(editable ? 18 : 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key, this.showCheckout = false, this.footer});

  final bool showCheckout;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final progress = (cart.subtotal / AppConfig.freeShippingThreshold).clamp(
      0.0,
      1.0,
    );

    return InkCard(
      shadow: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Summary', style: AppText.display(26)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cart.shippingFee == 0 ? AppColors.lime : AppColors.paper,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cart.shippingFee == 0
                      ? 'You unlocked free shipping 🎉'
                      : 'Add ${formatPrice(cart.amountToFreeShipping)} more for free shipping',
                  style: AppText.body(13, weight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.surface,
                    color: AppColors.violet,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SummaryRow(label: 'Subtotal', value: formatPrice(cart.subtotal)),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Shipping',
            value: cart.shippingFee == 0
                ? 'Free'
                : formatPrice(cart.shippingFee),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Total', style: AppText.display(20)),
              const Spacer(),
              Text(formatPrice(cart.total), style: AppText.display(26)),
            ],
          ),
          if (showCheckout) ...[
            const SizedBox(height: 24),
            AppButton(
              label: 'Checkout',
              variant: AppButtonVariant.accent,
              size: AppButtonSize.large,
              expand: true,
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: () => context.go('/checkout'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Keep shopping',
              variant: AppButtonVariant.ghost,
              expand: true,
              onPressed: () => context.go('/shop'),
            ),
          ],
          if (footer != null) ...[const SizedBox(height: 24), footer!],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppText.body(15, color: AppColors.muted)),
        const Spacer(),
        Text(value, style: AppText.body(15, weight: FontWeight.w600)),
      ],
    );
  }
}
