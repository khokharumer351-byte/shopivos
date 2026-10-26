import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/bits.dart';
import '../../../shared/widgets/page_container.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    final classic = _Panel(
      color: AppColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Pill('Editor’s pick', color: AppColors.lime),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'The ',
                  style: AppText.display(
                    compact ? 38 : 52,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'classics,',
                  style: AppText.serif(
                    compact ? 42 : 58,
                    color: AppColors.lime,
                  ),
                ),
                TextSpan(
                  text: '\nremixed.',
                  style: AppText.display(
                    compact ? 38 : 52,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Old-school silhouettes, new-school energy. Built to outlive the algorithm.',
            style: AppText.body(
              15,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Explore',
            variant: AppButtonVariant.accent,
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: () => context.go('/shop'),
          ),
        ],
      ),
    );

    final members = _Panel(
      color: AppColors.pink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('10% OFF', style: AppText.display(compact ? 64 : 88)),
          Text('your first order', style: AppText.serif(compact ? 26 : 32)),
          const SizedBox(height: 16),
          Text(
            'Create an account to unlock member pricing, a wishlist and order tracking.',
            style: AppText.body(15),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Join the club',
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: () => context.go('/signup'),
          ),
        ],
      ),
    );

    return PageContainer(
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [classic, const SizedBox(height: 20), members],
            )
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: classic),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: members),
                ],
              ),
            ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.ink, offset: Offset(6, 6)),
        ],
      ),
      child: child,
    );
  }
}
