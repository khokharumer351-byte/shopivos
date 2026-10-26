import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/feedback.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/form_fields.dart';
import '../../shared/widgets/page_container.dart';
import '../../state/auth_provider.dart';
import 'widgets/auth_layout.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().updatePassword(_password.text);
      if (!mounted) return;
      showSnack(context, 'Password updated. You’re all set ✦');
      context.go('/');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return AuthLayout(
        title: 'Verifying',
        accent: 'link…',
        subtitle:
            'Hang tight while we confirm your reset link. If nothing happens, the link may have expired.',
        child: InkCard(
          color: AppColors.paperDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
              Text(
                'Link expired or already used?',
                style: AppText.body(14, weight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Request a new link',
                variant: AppButtonVariant.outline,
                expand: true,
                onPressed: () => context.go('/forgot-password'),
              ),
            ],
          ),
        ),
      );
    }

    return AuthLayout(
      title: 'New',
      accent: 'password.',
      subtitle:
          'Choose a new password for ${auth.user?.email ?? 'your account'}.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledField(
              label: 'New password',
              child: PasswordField(
                controller: _password,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.password,
              ),
            ),
            const SizedBox(height: 18),
            LabeledField(
              label: 'Confirm new password',
              child: PasswordField(
                controller: _confirm,
                validator: (v) =>
                    v != _password.text ? 'Passwords don’t match' : null,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'Save password',
              variant: AppButtonVariant.accent,
              size: AppButtonSize.large,
              expand: true,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
