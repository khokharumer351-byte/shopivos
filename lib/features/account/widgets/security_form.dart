import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../state/auth_provider.dart';

class SecurityForm extends StatefulWidget {
  const SecurityForm({super.key});

  @override
  State<SecurityForm> createState() => _SecurityFormState();
}

class _SecurityFormState extends State<SecurityForm> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updatePassword(_password.text);
      _password.clear();
      _confirm.clear();
      if (mounted) showSnack(context, 'Password updated 🔒');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkCard(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Change password', style: AppText.display(24)),
            const SizedBox(height: 6),
            Text(
              'Pick something long and unique. Your future self says thanks.',
              style: AppText.body(14, color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            LabeledField(
              label: 'New password',
              child: PasswordField(
                controller: _password,
                validator: Validators.password,
                autofillHints: const [AutofillHints.newPassword],
              ),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Confirm new password',
              child: PasswordField(
                controller: _confirm,
                validator: (v) =>
                    v != _password.text ? 'Passwords don’t match' : null,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: 'Update password',
                loading: _saving,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
