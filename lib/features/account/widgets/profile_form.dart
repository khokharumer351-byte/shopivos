import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/profile.dart';
import '../../../data/supabase_client.dart';
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
  bool _uploadingAvatar = false;
  XFile? _pickedAvatar;

  Future<void> _pickAvatar(Profile profile) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() => _pickedAvatar = file);
      setState(() => _uploadingAvatar = true);
      final bytes = await file.readAsBytes();
      final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
      final path =
          '${profile.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
      try {
        await supabase.storage.from('avatars').uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
        final url = supabase.storage.from('avatars').getPublicUrl(path);
        try {
          await supabase
              .from('profiles')
              .update({'avatar_url': url}).eq('id', profile.id);
          if (!mounted) return;
          await context.read<AuthProvider>().refreshProfile();
          if (!mounted) return;
          showSnack(context, 'Profile photo updated');
        } catch (_) {
          if (mounted) {
            showSnack(
              context,
              'Photo selected. Upload saved, but avatar_url is not enabled in profile yet.',
              error: true,
            );
          }
        }
      } catch (_) {
        if (mounted) {
          showSnack(
            context,
            'Photo selected (preview only). Cloud upload/storage is not configured yet.',
          );
        }
      }
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
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
    var profile = auth.profile;
    if (profile == null && auth.profileLoading) {
      return const LoadingView();
    }
    if (profile == null) {
      final user = auth.user;
      if (user == null) {
        return ErrorView(
          message: 'Please sign in to view your profile.',
          onRetry: () => context.read<AuthProvider>().refreshProfile(),
        );
      }
      profile = Profile(
        id: user.id,
        email: user.email,
        fullName: user.userMetadata?['full_name'] as String?,
      );
    }

    final profileKey = '${profile.id}:${auth.profile != null}';
    if (_loadedFor != profileKey) {
      _loadedFor = profileKey;
      _name.text = profile.fullName ?? '';
      _phone.text = profile.phone ?? '';
      _address.text = profile.address ?? '';
      _city.text = profile.city ?? '';
      _postal.text = profile.postalCode ?? '';
      _country.text = profile.country ?? '';
    }

    return InkCard(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('My Profile', style: AppText.display(24)),
            const SizedBox(height: 6),
            Text(
              'Your account information and details',
              style: AppText.body(14, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: _uploadingAvatar ? null : () => _pickAvatar(profile!),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.violet,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.ink, width: 1.5),
                          image: _pickedAvatar != null && !kIsWeb
                              ? DecorationImage(
                                  image: FileImage(File(_pickedAvatar!.path)),
                                  fit: BoxFit.cover,
                                )
                              : (profile.avatarUrl != null &&
                                      profile.avatarUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(profile.avatarUrl!),
                                      fit: BoxFit.cover,
                                      onError: (_, _) {},
                                    )
                                  : null),
                        ),
                        alignment: Alignment.center,
                        child: (_pickedAvatar == null &&
                                (profile.avatarUrl == null ||
                                    profile.avatarUrl!.isEmpty))
                            ? Text(
                                profile.initials,
                                style:
                                    AppText.display(24, color: Colors.white),
                              )
                            : null,
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.lime,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.ink, width: 1.5),
                          ),
                          child: _uploadingAvatar
                              ? const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.ink,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 14,
                                  color: AppColors.ink,
                                ),
                        ),
                      ),
                    ],
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
                onPressed: () => _save(profile!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
