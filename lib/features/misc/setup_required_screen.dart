import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/page_container.dart';

class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final code = AppText.body(14).copyWith(fontFamily: 'monospace');
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: InkCard(
              shadow: true,
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(linkHome: false),
                  const SizedBox(height: 24),
                  Text('Connect Supabase to start', style: AppText.display(28)),
                  const SizedBox(height: 12),
                  Text(
                    'Add your project URL and anon key in lib/core/config/env.dart, '
                    'or run with --dart-define:',
                    style: AppText.body(15, color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.paperDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      'flutter run -d chrome --web-port 5000 \\\n'
                      '  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \\\n'
                      '  --dart-define=SUPABASE_ANON_KEY=eyJ...',
                      style: code,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'See README.md for the full setup guide.',
                    style: AppText.body(14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
