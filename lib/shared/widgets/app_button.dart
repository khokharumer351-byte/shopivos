import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

enum AppButtonVariant { primary, accent, outline, ghost, danger }

enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (widget.variant) {
      AppButtonVariant.primary => (AppColors.ink, Colors.white),
      AppButtonVariant.accent => (AppColors.lime, AppColors.ink),
      AppButtonVariant.outline => (AppColors.surface, AppColors.ink),
      AppButtonVariant.ghost => (Colors.transparent, AppColors.ink),
      AppButtonVariant.danger => (AppColors.danger, Colors.white),
    };
    final hasShadow = widget.variant != AppButtonVariant.ghost;
    final (height, fontSize, hPad) = switch (widget.size) {
      AppButtonSize.small => (38.0, 12.0, 16.0),
      AppButtonSize.medium => (48.0, 14.0, 22.0),
      AppButtonSize.large => (58.0, 16.0, 30.0),
    };

    final lifted = _enabled && _hovered && !_pressed;
    final shift = _pressed ? 3.0 : (lifted ? -2.0 : 0.0);
    final shadowOffset = _pressed ? 0.0 : (lifted ? 5.0 : 3.0);

    final content = widget.loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: fontSize + 4, color: foreground),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label.toUpperCase(),
                maxLines: 1,
                style: AppText.label(size: fontSize, color: foreground),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  widget.trailingIcon,
                  size: fontSize + 4,
                  color: foreground,
                ),
              ],
            ],
          );

    final button = MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTap: _enabled ? widget.onPressed : null,
        child: Semantics(
          button: true,
          enabled: _enabled,
          label: widget.label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            height: height,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            transform: Matrix4.translationValues(shift, shift, 0),
            decoration: BoxDecoration(
              color: _enabled ? background : background.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(999),
              border: widget.variant == AppButtonVariant.ghost
                  ? null
                  : Border.all(color: AppColors.ink, width: 1.5),
              boxShadow: hasShadow && _enabled && shadowOffset > 0
                  ? [
                      BoxShadow(
                        color: AppColors.ink,
                        offset: Offset(shadowOffset, shadowOffset),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.background = AppColors.surface,
    this.foreground = AppColors.ink,
    this.size = 44,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color background;
  final Color foreground;
  final double size;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    Widget child = Material(
      color: background,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.ink, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.45, color: foreground),
        ),
      ),
    );

    if (badge != null && badge! > 0) {
      child = Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ink, width: 1.5),
              ),
              child: Text(
                badge! > 99 ? '99+' : '$badge',
                style: AppText.label(size: 10),
              ),
            ),
          ),
        ],
      );
    }

    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}
