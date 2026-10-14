import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/feedback.dart';
import '../../core/utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/page_container.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    return Container(
      margin: const EdgeInsets.only(top: 80),
      color: AppColors.ink,
      child: PageContainer(
        verticalPadding: 56,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 64,
              runSpacing: 40,
              children: [
                SizedBox(
                  width: compact ? double.infinity : 380,
                  child: const _Newsletter(),
                ),
                _LinkColumn(title: 'Shop', links: {
                  'All products': '/shop',
                  'New in': '/shop?sort=newest',
                  'Featured': '/shop?featured=1',
                }),
                _LinkColumn(title: 'Account', links: {
                  'Sign in': '/login',
                  'My orders': '/account/orders',
                  'Wishlist': '/wishlist',
                  'Bag': '/cart',
                }),
                const _InfoColumn(),
              ],
            ),
            const SizedBox(height: 56),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'shopivo', style: AppText.display(compact ? 72 : 150, color: Colors.white)),
                    TextSpan(text: '.', style: AppText.display(compact ? 72 : 150, color: AppColors.lime)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 20),
            Text(
              '© ${DateTime.now().year} Shopivo. Made with love for the culture.',
              style: AppText.body(13, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkColumn extends StatelessWidget {
  const _LinkColumn({required this.title, required this.links});

  final String title;
  final Map<String, String> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title.toUpperCase(), style: AppText.label(color: AppColors.lime)),
        const SizedBox(height: 16),
        for (final entry in links.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => context.go(entry.value),
              child: Text(entry.key, style: AppText.body(15, color: Colors.white)),
            ),
          ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn();

  @override
  Widget build(BuildContext context) {
    final style = AppText.body(15, color: Colors.white.withValues(alpha: 0.8));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('HELP', style: AppText.label(color: AppColors.lime)),
        const SizedBox(height: 16),
        Text('hello@shopivo.store', style: style),
        const SizedBox(height: 10),
        Text('Shipping & returns', style: style),
        const SizedBox(height: 10),
        Text('Size guide', style: style),
      ],
    );
  }
}

class _Newsletter extends StatefulWidget {
  const _Newsletter();

  @override
  State<_Newsletter> createState() => _NewsletterState();
}

class _NewsletterState extends State<_Newsletter> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _subscribe() {
    final error = Validators.email(_controller.text);
    if (error != null) {
      showSnack(context, error, error: true);
      return;
    }
    _controller.clear();
    showSnack(context, "You're on the list ✦ See you in your inbox.");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Join the ', style: AppText.display(30, color: Colors.white)),
              TextSpan(text: 'inner circle', style: AppText.serif(32, color: AppColors.lime)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Early access to drops, members-only prices, zero spam.',
          style: AppText.body(14, color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _subscribe(),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'your@email.com'),
              ),
            ),
            const SizedBox(width: 10),
            AppButton(label: 'Join', variant: AppButtonVariant.accent, onPressed: _subscribe),
          ],
        ),
      ],
    );
  }
}
