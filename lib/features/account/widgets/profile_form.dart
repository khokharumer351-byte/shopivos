import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/profile.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../state/auth_provider.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();
  final _country = TextEditingController();

  String? _loadedFor;
  bool _saving = false;

  void _fill(Profile profile) {
    _loadedFor = profile.id;
    _name.text = profile.fullName ?? '';
    _phone.text = profile.phone ?? '';
    _address.text = profile.address ?? '';
    _city.text = profile.city ?? '';
    _postal.text = profile.postalCode ?? '';
    _country.text = profile.country ?? '';
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _city, _postal, _country]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(Profile profile) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updateProfile(
        profile.copyWith(
          fullName: _name.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          city: _city.text.trim(),
          postalCode: _postal.text.trim(),
          country: _country.text.trim(),
        ),
      );
      if (mounted) showSnack(context, 'Profile saved ✦');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    if (profile == null) {
      return auth.profileLoading
          ? const LoadingView()
          : const ErrorView(
              message:
                  'We could not load your profile. Refresh the page to try again.',
            );
    }

    if (_loadedFor != profile.id) _fill(profile);

    return InkCard(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.violet,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Text(
                    profile.initials,
                    style: AppText.display(22, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.displayName, style: AppText.display(22)),
                      Text(
                        profile.email ?? '',
                        style: AppText.body(14, color: AppColors.muted),
                      ),
                      Text(
                        'Member since ${formatDate(profile.createdAt)}',
                        style: AppText.body(12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            FieldRow(
              children: [
                LabeledField(
                  label: 'Full name',
                  child: TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(hintText: 'Your name'),
                  ),
                ),
                LabeledField(
                  label: 'Phone',
                  child: TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '+1 555 0100'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Default address',
              child: TextFormField(
                controller: _address,
                decoration: const InputDecoration(hintText: 'Street, building'),
              ),
            ),
            const SizedBox(height: 16),
            FieldRow(
              children: [
                LabeledField(
                  label: 'City',
                  child: TextFormField(
                    controller: _city,
                    decoration: const InputDecoration(hintText: 'City'),
                  ),
                ),
                LabeledField(
                  label: 'Postal code',
                  child: TextFormField(
                    controller: _postal,
                    decoration: const InputDecoration(hintText: '00000'),
                  ),
                ),
                LabeledField(
                  label: 'Country',
                  child: TextFormField(
                    controller: _country,
                    decoration: const InputDecoration(hintText: 'Country'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: 'Save changes',
                loading: _saving,
                onPressed: () => _save(profile),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
