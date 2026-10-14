import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/bits.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Sticker(text: '404', size: 160, color: AppColors.pink, angle: degrees(-10)),
              const SizedBox(height: 36),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(children: [
                  TextSpan(text: 'This page ', style: AppText.display(44)),
                  TextSpan(text: 'ghosted', style: AppText.serif(48, color: AppColors.violet)),
                  TextSpan(text: ' you.', style: AppText.display(44)),
                ]),
              ),
              const SizedBox(height: 12),
              Text('It’s not you, it’s the URL.', style: AppText.body(16, color: AppColors.muted)),
              const SizedBox(height: 28),
              AppButton(label: 'Take me home', onPressed: () => context.go('/')),
            ],
          ),
        ),
      ),
    );
  }
}
