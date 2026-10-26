import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/feedback.dart';
import '../../core/utils/validators.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import '../../shared/layout/store_shell.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/bits.dart';
import '../../shared/widgets/form_fields.dart';
import '../../shared/widgets/page_container.dart';
import '../../shared/widgets/state_views.dart';
import '../../state/auth_provider.dart';
import '../../state/cart_provider.dart';
import '../cart/cart_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orders = OrderRepository();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();
  final _country = TextEditingController();
  final _notes = TextEditingController();

  bool _saveAddress = true;
  bool _placing = false;
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefill();
  }

  void _prefill() {
    if (_prefilled) return;
    final profile = context.read<AuthProvider>().profile;
    if (profile == null) return;
    _prefilled = true;
    _name.text = profile.fullName ?? '';
    _phone.text = profile.phone ?? '';
    _address.text = profile.address ?? '';
    _city.text = profile.city ?? '';
    _postal.text = profile.postalCode ?? '';
    _country.text = profile.country ?? '';
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _address,
      _city,
      _postal,
      _country,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();

    setState(() => _placing = true);
    try {
      final orderId = await _orders.placeOrder(
        items: cart.items,
        shipping: ShippingDetails(
          fullName: _name.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          city: _city.text.trim(),
          postalCode: _postal.text.trim(),
          country: _country.text.trim(),
          notes: _notes.text.trim(),
        ),
      );

      final profile = auth.profile;
      if (_saveAddress && profile != null) {
        try {
          await auth.updateProfile(
            profile.copyWith(
              fullName: _name.text.trim(),
              phone: _phone.text.trim(),
              address: _address.text.trim(),
              city: _city.text.trim(),
              postalCode: _postal.text.trim(),
              country: _country.text.trim(),
            ),
          );
        } catch (_) {}
      }

      cart.clear();
      if (mounted) context.go('/order-success/$orderId');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    if (!_prefilled && profile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _prefill();
      });
    }

    final cart = context.watch<CartProvider>();
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    if (cart.isEmpty && !_placing) {
      return StorePage(
        children: [
          EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Nothing to check out',
            message: 'Your bag is empty. Add something first.',
            actionLabel: 'Go shopping',
            onAction: () => context.go('/shop'),
          ),
        ],
      );
    }

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepTitle(number: '01', title: 'Shipping details'),
          const SizedBox(height: 20),
          InkCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldRow(
                  children: [
                    LabeledField(
                      label: 'Full name',
                      child: TextFormField(
                        controller: _name,
                        validator: (v) => Validators.notEmpty(v, 'Name'),
                        decoration: const InputDecoration(
                          hintText: 'Alex Morgan',
                        ),
                      ),
                    ),
                    LabeledField(
                      label: 'Phone',
                      child: TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => Validators.notEmpty(v, 'Phone'),
                        decoration: const InputDecoration(
                          hintText: '+1 555 0100',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Address',
                  child: TextFormField(
                    controller: _address,
                    validator: (v) => Validators.notEmpty(v, 'Address'),
                    decoration: const InputDecoration(
                      hintText: 'Street, building, apartment',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FieldRow(
                  children: [
                    LabeledField(
                      label: 'City',
                      child: TextFormField(
                        controller: _city,
                        validator: (v) => Validators.notEmpty(v, 'City'),
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
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Order notes (optional)',
                  child: TextFormField(
                    controller: _notes,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Gate code, delivery time, anything else…',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _saveAddress,
                  onChanged: (v) => setState(() => _saveAddress = v ?? false),
                  title: Text(
                    'Save these details to my profile',
                    style: AppText.body(14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _StepTitle(number: '02', title: 'Payment'),
          const SizedBox(height: 20),
          const _PaymentOption(
            icon: Icons.payments_outlined,
            title: 'Cash on delivery',
            subtitle: 'Pay when your order arrives.',
            selected: true,
          ),
          const SizedBox(height: 12),
          const _PaymentOption(
            icon: Icons.credit_card_rounded,
            title: 'Card / wallet',
            subtitle: 'Coming soon',
            selected: false,
            disabled: true,
          ),
        ],
      ),
    );

    final summary = OrderSummaryCard(
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in cart.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CartLine(item: item, editable: false),
            ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Place order',
            variant: AppButtonVariant.accent,
            size: AppButtonSize.large,
            expand: true,
            loading: _placing,
            icon: Icons.lock_outline_rounded,
            onPressed: _placeOrder,
          ),
          const SizedBox(height: 10),
          Text(
            'Final prices and stock are confirmed when you place the order.',
            textAlign: TextAlign.center,
            style: AppText.body(12, color: AppColors.muted),
          ),
        ],
      ),
    );

    return StorePage(
      children: [
        PageContainer(
          verticalPadding: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Check',
                      style: AppText.display(compact ? 40 : 60),
                    ),
                    TextSpan(
                      text: 'out.',
                      style: AppText.serif(
                        compact ? 44 : 64,
                        color: AppColors.violet,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (compact) ...[
                form,
                const SizedBox(height: 32),
                summary,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: form),
                    const SizedBox(width: 32),
                    SizedBox(width: 400, child: summary),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Pill(number, color: AppColors.violet, textColor: Colors.white),
        const SizedBox(width: 12),
        Text(title, style: AppText.display(24)),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.disabled = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppColors.lime : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.ink, width: selected ? 2 : 1.5),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.body(15, weight: FontWeight.w700)),
                  Text(
                    subtitle,
                    style: AppText.body(13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
