import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import 'app_button.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.padding = 80});

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.sentiment_neutral_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: scheme.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.outline),
                ),
                child: Icon(icon, size: 40, color: scheme.onSecondary),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppText.display(28, color: scheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppText.body(15, color: scheme.onSurface.withValues(alpha: 0.65)),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  trailingIcon: Icons.arrow_forward,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_tethering_error_rounded,
      title: 'Oops, a glitch.',
      message: message,
      actionLabel: onRetry == null ? null : 'Try again',
      onAction: onRetry,
    );
  }
}
