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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _awaitingConfirmation = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final signedIn = await context.read<AuthProvider>().signUp(
        email: _email.text,
        password: _password.text,
        fullName: _name.text,
      );

      if (!signedIn && mounted) setState(() => _awaitingConfirmation = true);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_awaitingConfirmation) {
      return AuthLayout(
        title: 'Check your',
        accent: 'inbox.',
        subtitle:
            'We sent a confirmation link to ${_email.text.trim()}. Tap it to activate your account.',
        child: InkCard(
          color: AppColors.lime,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('📬  Almost there!', style: AppText.display(22)),
              const SizedBox(height: 8),
              Text(
                'Didn’t get it? Check spam or try signing up again in a minute.',
                style: AppText.body(14),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Go to sign in',
                expand: true,
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      );
    }

    return AuthLayout(
      title: 'Join the',
      accent: 'club.',
      subtitle:
          'Create an account for member prices, a wishlist and order tracking.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LabeledField(
                label: 'Full name',
                child: TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: (v) => Validators.notEmpty(v, 'Name'),
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'Email',
                child: TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                  ),
                ),
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'Password',
                child: PasswordField(
                  controller: _password,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: Validators.password,
                ),
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'Confirm password',
                child: PasswordField(
                  controller: _confirm,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      v != _password.text ? 'Passwords don’t match' : null,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Create account',
                variant: AppButtonVariant.accent,
                size: AppButtonSize.large,
                expand: true,
                loading: _loading,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: _submit,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a member?',
                    style: AppText.body(14, color: AppColors.muted),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Sign in',
                      style: AppText.body(14, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
