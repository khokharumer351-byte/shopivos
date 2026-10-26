import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class Marquee extends StatefulWidget {
  const Marquee({
    super.key,
    required this.items,
    this.background = AppColors.ink,
    this.foreground = AppColors.lime,
    this.height = 48,
    this.fontSize = 18,
    this.duration = const Duration(seconds: 20),
  });

  final List<String> items;
  final Color background;
  final Color foreground;
  final double height;
  final double fontSize;
  final Duration duration;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppText.display(
      widget.fontSize,
      color: widget.foreground,
    ).copyWith(letterSpacing: 0.5);
    final segment = '${widget.items.join('   ✦   ')}   ✦   ';

    return Container(
      height: widget.height,
      color: widget.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final painter = TextPainter(
            text: TextSpan(text: segment, style: style),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          final segmentWidth = painter.width;
          painter.dispose();
          if (segmentWidth <= 0) return const SizedBox.shrink();

          final copies = (constraints.maxWidth / segmentWidth).ceil() + 1;
          return ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.translate(
                offset: Offset(-_controller.value * segmentWidth, 0),
                child: child,
              ),
              child: OverflowBox(
                minWidth: 0,
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    copies,
                    (_) => Text(
                      segment,
                      style: style,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
