import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../shared/widgets/bits.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../state/auth_provider.dart';
import '../widgets/admin_page.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final _repo = ProfileRepository();
  final _search = TextEditingController();
  late Future<List<Profile>> _future = _repo.fetchAll();

  void _reload() => setState(() => _future = _repo.fetchAll());

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _toggleRole(Profile profile) async {
    final makeAdmin = !profile.isAdmin;
    final ok = await confirmDialog(
      context,
      title: makeAdmin
          ? 'Make ${profile.displayName} an admin?'
          : 'Remove admin access?',
      message: makeAdmin
          ? 'Admins can manage products, orders and other customers.'
          : '${profile.displayName} will lose access to the admin panel.',
      confirmLabel: makeAdmin ? 'Make admin' : 'Remove access',
      destructive: !makeAdmin,
    );
    if (!ok) return;
    try {
      await _repo.setRole(profile.id, makeAdmin ? 'admin' : 'customer');
      if (!mounted) return;
      showSnack(context, 'Role updated');
      _reload();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.watch<AuthProvider>().user?.id;

    return AdminPage(
      title: 'Customers',
      subtitle:
          'Everyone who has signed up, and who can access the admin panel.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              hintText: 'Filter by name or email…',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Profile>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorView(
                  message: friendlyError(snapshot.error!),
                  onRetry: _reload,
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return const LoadingView();
              }
              final term = _search.text.trim().toLowerCase();
              final people = (snapshot.data ?? const <Profile>[])
                  .where(
                    (p) =>
                        term.isEmpty ||
                        p.displayName.toLowerCase().contains(term) ||
                        (p.email ?? '').toLowerCase().contains(term),
                  )
                  .toList();
              if (people.isEmpty) {
                return const EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'No customers found',
                  message: 'Try a different search.',
                );
              }
              return Column(
                children: [
                  for (final p in people)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CustomerRow(
                        profile: p,
                        isMe: p.id == myId,
                        onToggleRole: () => _toggleRole(p),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({
    required this.profile,
    required this.isMe,
    required this.onToggleRole,
  });

  final Profile profile;
  final bool isMe;
  final VoidCallback onToggleRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: profile.isAdmin ? AppColors.lime : AppColors.sky,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: Text(profile.initials, style: AppText.label(size: 13)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      profile.displayName,
                      style: AppText.body(15, weight: FontWeight.w700),
                    ),
                    if (profile.isAdmin)
                      const Pill('Admin', color: AppColors.lime),
                    if (isMe) const Pill('You', color: AppColors.paperDark),
                  ],
                ),
                Text(
                  [
                    profile.email ?? '',
                    if ((profile.phone ?? '').isNotEmpty) profile.phone!,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(13, color: AppColors.muted),
                ),
                Text(
                  'Joined ${formatDate(profile.createdAt)}',
                  style: AppText.body(12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (!isMe)
            TextButton(
              onPressed: onToggleRole,
              child: Text(
                profile.isAdmin ? 'Remove admin' : 'Make admin',
                style: AppText.body(
                  13,
                  weight: FontWeight.w700,
                  color: profile.isAdmin ? AppColors.danger : AppColors.violet,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
