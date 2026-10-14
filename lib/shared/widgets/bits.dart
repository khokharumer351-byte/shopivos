import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/order.dart';

/// Small rounded label, e.g. "SALE -20%".
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = AppColors.lime, this.textColor = AppColors.ink, this.icon});

  final String text;
  final Color color;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: textColor), const SizedBox(width: 4)],
          Text(text.toUpperCase(), style: AppText.label(size: 10.5, color: textColor)),
        ],
      ),
    );
  }
}

/// Round rotated sticker, the Gen-Z garnish on hero sections.
class Sticker extends StatelessWidget {
  const Sticker({super.key, required this.text, this.size = 110, this.color = AppColors.lime, this.angle = 0.2});

  final String text;
  final double size;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 2),
          boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(4, 4))],
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.12),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppText.display(size * 0.16).copyWith(height: 1.05),
          ),
        ),
      ),
    );
  }
}

class PriceTag extends StatelessWidget {
  const PriceTag({super.key, required this.price, this.compareAt, this.size = 16});

  final double price;
  final double? compareAt;
  final double size;

  @override
  Widget build(BuildContext context) {
    final onSale = compareAt != null && compareAt! > price;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(formatPrice(price), style: AppText.display(size, color: onSale ? AppColors.violet : AppColors.ink)),
        if (onSale)
          Text(
            formatPrice(compareAt!),
            style: AppText.body(size * 0.8, color: AppColors.muted).copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 16, this.color = AppColors.ink});

  final double rating;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = rating - index;
        final icon = value >= 1
            ? Icons.star_rounded
            : (value >= 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded);
        return Icon(icon, size: size, color: color);
      }),
    );
  }
}

class StarPicker extends StatelessWidget {
  const StarPicker({super.key, required this.value, required this.onChanged, this.size = 30});

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final selected = index < value;
        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: () => onChanged(index + 1),
          icon: Icon(
            selected ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: selected ? AppColors.ink : AppColors.muted,
          ),
        );
      }),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.value, required this.onChanged, this.max, this.compact = false});

  final int value;
  final ValueChanged<int> onChanged;
  final int? max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 36.0 : 48.0;
    final canIncrease = max == null || value < max!;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: compact ? 16 : 18,
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: compact ? 22 : 32,
            child: Text('$value', textAlign: TextAlign.center, style: AppText.display(compact ? 14 : 16)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: compact ? 16 : 18,
            onPressed: canIncrease ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final String status;

  static Color colorFor(String status) => switch (status) {
        OrderStatus.pending => AppColors.peach,
        OrderStatus.processing => AppColors.sky,
        OrderStatus.shipped => AppColors.violet,
        OrderStatus.delivered => AppColors.lime,
        OrderStatus.cancelled => AppColors.paperDark,
        _ => AppColors.paperDark,
      };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Pill(
      capitalize(status),
      color: color,
      textColor: status == OrderStatus.shipped ? Colors.white : AppColors.ink,
    );
  }
}

/// Section heading: small kicker label + big title with an optional serif word.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.kicker, required this.title, this.accent, this.trailing});

  final String kicker;
  final String title;
  final String? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 640;
    final size = compact ? 30.0 : 44.0;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('✦ ${kicker.toUpperCase()}', style: AppText.label(color: AppColors.muted)),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: title, style: AppText.display(size)),
              if (accent != null) TextSpan(text: ' $accent', style: AppText.serif(size + 4, color: AppColors.violet)),
            ],
          ),
        ),
      ],
    );

    if (trailing == null) return heading;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [Expanded(child: heading), const SizedBox(width: 16), trailing!],
    );
  }
}

/// Wavy-free, simple diagonal stripes used as a decorative fill.
class StripesPainter extends CustomPainter {
  const StripesPainter({this.color = AppColors.ink, this.gap = 14, this.strokeWidth = 1.5});

  final Color color;
  final double gap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    final diagonal = size.width + size.height;
    for (double x = -size.height; x < diagonal; x += gap) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant StripesPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.gap != gap;
}

double degrees(double deg) => deg * math.pi / 180;
