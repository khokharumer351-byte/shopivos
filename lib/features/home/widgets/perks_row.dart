import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/page_container.dart';

class PerksRow extends StatelessWidget {
  const PerksRow({super.key});

  @override
  Widget build(BuildContext context) {
    final perks = [
      (
        Icons.local_shipping_outlined,
        'Free shipping',
        'On orders over ${formatPrice(AppConfig.freeShippingThreshold)}',
      ),
      (
        Icons.autorenew_rounded,
        '30-day returns',
        'Changed your mind? No drama.',
      ),
      (Icons.lock_outline_rounded, 'Secure checkout', 'Your data stays yours.'),
      (
        Icons.support_agent_rounded,
        'Real humans',
        'Support that actually replies.',
      ),
    ];

    return PageContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000
              ? 4
              : (constraints.maxWidth >= 560 ? 2 : 1);
          const gap = 16.0;
          final itemWidth =
              (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final (icon, title, subtitle) in perks)
                SizedBox(
                  width: itemWidth,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.lime,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.ink,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(icon, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: AppText.display(17)),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: AppText.body(13, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
