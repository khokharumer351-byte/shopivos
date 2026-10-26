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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().sendPasswordReset(_email.text);
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return AuthLayout(
        title: 'Link',
        accent: 'sent.',
        subtitle:
            'If an account exists for ${_email.text.trim()}, a reset link is on its way.',
        child: InkCard(
          color: AppColors.lime,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('📨  Check your inbox', style: AppText.display(22)),
              const SizedBox(height: 8),
              Text(
                'Open the email on this device and tap the link — you’ll land on a page to choose a new password.',
                style: AppText.body(14),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Back to sign in',
                expand: true,
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Resend link',
                variant: AppButtonVariant.ghost,
                expand: true,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      );
    }

    return AuthLayout(
      title: 'Forgot',
      accent: 'it?',
      subtitle:
          'It happens to the best of us. Enter your email and we’ll send you a reset link.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledField(
              label: 'Email',
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(hintText: 'you@example.com'),
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'Send reset link',
              size: AppButtonSize.large,
              expand: true,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Back to sign in',
                  style: AppText.body(14, weight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
