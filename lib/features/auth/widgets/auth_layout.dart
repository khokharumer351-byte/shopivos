import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/bits.dart';
import '../../../shared/widgets/marquee.dart';
import '../../../shared/widgets/page_container.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.accent,
  });

  final String title;
  final String? accent;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

    final form = SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                if (!wide) const AppLogo(size: 22),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: AppColors.ink,
                  ),
                  label: Text(
                    'Back to store',
                    style: AppText.body(14, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: title, style: AppText.display(44)),
                            if (accent != null)
                              TextSpan(
                                text: ' $accent',
                                style: AppText.serif(
                                  48,
                                  color: AppColors.violet,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: AppText.body(15, color: AppColors.muted),
                      ),
                      const SizedBox(height: 32),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: wide
          ? Row(
              children: [
                const Expanded(child: _ArtPanel()),
                Expanded(child: form),
              ],
            )
          : form,
    );
  }
}

class _ArtPanel extends StatelessWidget {
  const _ArtPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: StripesPainter(
                      color: Colors.white.withValues(alpha: 0.05),
                      gap: 22,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLogo(light: true),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Your next\nfavorite ',
                              style: AppText.display(64, color: Colors.white),
                            ),
                            TextSpan(
                              text: 'fit',
                              style: AppText.serif(70, color: AppColors.lime),
                            ),
                            TextSpan(
                              text: '\nis one click\naway.',
                              style: AppText.display(64, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Classic pieces. Loud energy. Zero gatekeeping.',
                        style: AppText.body(
                          16,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Positioned(
                  right: 48,
                  top: 120,
                  child: Sticker(
                    text: 'MEMBERS\nGET 10%\nOFF',
                    size: 140,
                    angle: degrees(14),
                  ),
                ),
                Positioned(
                  right: 120,
                  bottom: 80,
                  child: Sticker(
                    text: '♡',
                    size: 80,
                    color: AppColors.pink,
                    angle: degrees(-10),
                  ),
                ),
              ],
            ),
          ),
          const Marquee(
            items: [
              'NEW DROPS WEEKLY',
              'FREE SHIPPING RS 14,000+',
              '30-DAY RETURNS',
              'MEMBER PRICES',
            ],
            background: AppColors.lime,
            foreground: AppColors.ink,
          ),
        ],
      ),
    );
  }
}
