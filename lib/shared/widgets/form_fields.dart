import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';

/// Uppercase label stacked above any input.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: AppText.label(size: 11)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.hint = '••••••••',
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        hintText: widget.hint,
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
        ),
      ),
    );
  }
}

/// Lays out form fields in two columns on wide screens, one on narrow.
class FieldRow extends StatelessWidget {
  const FieldRow({super.key, required this.children, this.gap = 16});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: gap),
                children[i],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}
