import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/feedback.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/page_container.dart';
import '../widgets/admin_page.dart';

class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = NotificationRepository();
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _link = '/shop?sort=newest';
  bool _sending = false;

  static const _links = {
    '/shop?sort=newest': 'New in',
    '/shop?featured=1': 'Featured',
    '/shop': 'Shop all',
    '/': 'Home',
  };

  static const _presets = [
    (
      'New drop is live ✦',
      'Fresh pieces just landed. Go get yours before they sell out.',
      '/shop?sort=newest',
    ),
    (
      'Weekend sale 🔥',
      'Up to 30% off selected styles — this weekend only.',
      '/shop',
    ),
    (
      'Back in stock',
      'Your faves are back. Restocked and ready to ship.',
      '/shop?featured=1',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    _body.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await confirmDialog(
      context,
      title: 'Send to every customer?',
      message:
          'Everyone gets "${_title.text.trim()}" in their inbox and as a phone notification.',
      confirmLabel: 'Send',
    );
    if (!ok) return;

    setState(() => _sending = true);
    try {
      final count = await _repo.broadcast(
        title: _title.text.trim(),
        body: _body.text.trim(),
        link: _link,
      );
      if (!mounted) return;
      showSnack(context, 'Sent to $count customer${count == 1 ? '' : 's'} ✦');
      _title.clear();
      _body.clear();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('QUICK START', style: AppText.label(size: 11)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (title, body, link) in _presets)
                ActionChip(
                  label: Text(title),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.ink, width: 1.5),
                  shape: const StadiumBorder(),
                  onPressed: () => setState(() {
                    _title.text = title;
                    _body.text = body;
                    _link = link;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 24),
          LabeledField(
            label: 'Title',
            child: TextFormField(
              controller: _title,
              maxLength: 80,
              decoration: const InputDecoration(
                hintText: 'New drop is live ✦',
                counterText: '',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Add a title' : null,
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Message',
            child: TextFormField(
              controller: _body,
              maxLines: 3,
              maxLength: 240,
              decoration: const InputDecoration(
                hintText: 'What do you want to tell your customers?',
              ),
            ),
          ),
          const SizedBox(height: 10),
          LabeledField(
            label: 'Opens',
            child: DropdownButtonFormField<String>(
              key: ValueKey(_link),
              initialValue: _link,
              isExpanded: true,
              items: [
                for (final entry in _links.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (v) => setState(() => _link = v ?? '/'),
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Send notification',
            icon: Icons.send_rounded,
            loading: _sending,
            expand: true,
            onPressed: _send,
          ),
        ],
      ),
    );

    final preview = _Preview(
      title: _title.text.trim().isEmpty ? 'Your title' : _title.text.trim(),
      body: _body.text.trim().isEmpty
          ? 'Your message shows up here.'
          : _body.text.trim(),
    );

    return AdminPage(
      title: 'Notify',
      subtitle:
          'Send a message to every customer — web inbox + phone notification.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkCard(child: form),
                const SizedBox(height: 24),
                preview,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: InkCard(child: form)),
              const SizedBox(width: 28),
              Expanded(flex: 2, child: preview),
            ],
          );
        },
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PREVIEW', style: AppText.label(size: 11)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.ink, width: 1.5),
            boxShadow: const [
              BoxShadow(color: AppColors.ink, offset: Offset(4, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  's.',
                  style: AppText.display(18, color: AppColors.lime),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'SHOPIVO',
                          style: AppText.label(
                            size: 10,
                            color: AppColors.muted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'now',
                          style: AppText.body(11, color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: AppText.body(14, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(body, style: AppText.body(13, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
