import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../shared/layout/store_shell.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/bits.dart';
import '../../shared/widgets/page_container.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return StorePage(
      children: [
        PageContainer(
          maxWidth: 640,
          verticalPadding: 80,
          child: Column(
            children: [
              Sticker(text: 'ORDER\nPLACED ✦', size: 150, angle: degrees(-8)),
              const SizedBox(height: 40),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(text: 'It’s ', style: AppText.display(52)),
                    TextSpan(
                      text: 'official.',
                      style: AppText.serif(56, color: AppColors.violet),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your order ${orderRef(orderId)} is in. We’ll pack it with love and keep you posted.',
                textAlign: TextAlign.center,
                style: AppText.body(17, color: AppColors.muted),
              ),
              const SizedBox(height: 36),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 14,
                children: [
                  AppButton(
                    label: 'Track order',
                    icon: Icons.local_shipping_outlined,
                    onPressed: () => context.go('/account/orders/$orderId'),
                  ),
                  AppButton(
                    label: 'Keep shopping',
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.go('/shop'),
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
