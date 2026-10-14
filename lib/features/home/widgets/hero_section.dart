import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/bits.dart';
import '../../../shared/widgets/net_image.dart';
import '../../../shared/widgets/page_container.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, this.imageUrl, this.secondaryImageUrl});

  final String? imageUrl;
  final String? secondaryImageUrl;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < Breakpoints.tablet;

    final copy = _HeroCopy(compact: compact, mobile: width < Breakpoints.mobile);
    final art = _HeroArt(imageUrl: imageUrl, secondaryImageUrl: secondaryImageUrl);

    return PageContainer(
      verticalPadding: compact ? 40 : 72,
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                copy,
                const SizedBox(height: 48),
                Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: art)),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: copy),
                const SizedBox(width: 56),
                Expanded(flex: 5, child: art),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.compact, required this.mobile});

  final bool compact;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final size = mobile ? 46.0 : (compact ? 62.0 : 82.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Pill('SS26 collection — live now', icon: Icons.auto_awesome),
        const SizedBox(height: 28),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Wear the ', style: AppText.display(size)),
              TextSpan(text: 'vibe,', style: AppText.serif(size * 1.08, color: AppColors.violet)),
              TextSpan(text: '\nnot the ', style: AppText.display(size)),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: size * 0.15),
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(size * 0.2),
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  child: Text('trend.', style: AppText.display(size)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Timeless cuts with a loud attitude. Curated pieces that age like vinyl, '
            'priced for people who still check their bank app twice.',
            style: AppText.body(mobile ? 15 : 17, color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            AppButton(
              label: 'Shop the drop',
              size: AppButtonSize.large,
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: () => context.go('/shop'),
            ),
            AppButton(
              label: 'New arrivals',
              size: AppButtonSize.large,
              variant: AppButtonVariant.outline,
              onPressed: () => context.go('/shop?sort=newest'),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 32,
          runSpacing: 16,
          children: const [
            _Stat(value: '12k+', label: 'happy humans'),
            _Stat(value: '4.9★', label: 'average rating'),
            _Stat(value: '48h', label: 'dispatch'),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppText.display(30)),
        const SizedBox(height: 2),
        Text(label, style: AppText.body(13, color: AppColors.muted)),
      ],
    );
  }
}

class _HeroArt extends StatelessWidget {
  const _HeroArt({this.imageUrl, this.secondaryImageUrl});

  final String? imageUrl;
  final String? secondaryImageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.92,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Back card
              Positioned(
                left: s * 0.12,
                top: 0,
                right: 0,
                bottom: s * 0.08,
                child: Transform.rotate(
                  angle: degrees(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.violet,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.ink, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CustomPaint(
                        painter: StripesPainter(color: Colors.white.withValues(alpha: 0.25), gap: 18),
                      ),
                    ),
                  ),
                ),
              ),
              // Main photo card
              Positioned(
                left: 0,
                top: s * 0.06,
                right: s * 0.14,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.ink, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(8, 8))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: NetImage(imageUrl, placeholder: const _ArtPlaceholder()),
                  ),
                ),
              ),
              // Small polaroid
              if (secondaryImageUrl != null)
                Positioned(
                  right: -s * 0.02,
                  bottom: s * 0.14,
                  width: s * 0.32,
                  height: s * 0.4,
                  child: Transform.rotate(
                    angle: degrees(-6),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(6, 6, 6, 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.ink, width: 2),
                        boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(5, 5))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: NetImage(secondaryImageUrl),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: s * 0.04,
                top: -s * 0.06,
                child: Sticker(text: 'NEW\nDROP ✦', size: s * 0.26, angle: degrees(12)),
              ),
              Positioned(
                left: -s * 0.04,
                bottom: s * 0.1,
                child: Transform.rotate(
                  angle: degrees(-8),
                  child: const Pill('100% that fit', color: AppColors.sky, icon: Icons.favorite_rounded),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArtPlaceholder extends StatelessWidget {
  const _ArtPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.pink, AppColors.peach],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text('est.\n2026', textAlign: TextAlign.center, style: AppText.serif(64)),
    );
  }
}
