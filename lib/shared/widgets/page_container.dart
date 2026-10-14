import 'package:flutter/material.dart';

abstract final class Breakpoints {
  static const mobile = 640.0;
  static const tablet = 960.0;
  static const desktop = 1200.0;

  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < mobile;
  static bool isCompact(BuildContext context) => MediaQuery.sizeOf(context).width < tablet;
}

/// Centers content with a max width and responsive side padding.
class PageContainer extends StatelessWidget {
  const PageContainer({super.key, required this.child, this.maxWidth = 1280, this.verticalPadding = 0});

  final Widget child;
  final double maxWidth;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < Breakpoints.mobile ? 16.0 : (width < Breakpoints.tablet ? 24.0 : 40.0);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: verticalPadding),
          child: child,
        ),
      ),
    );
  }
}

/// White card with an ink border — the base surface used across the app.
class InkCard extends StatelessWidget {
  const InkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = Colors.white,
    this.radius = 20,
    this.shadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFF0E0E10), width: 1.5),
        boxShadow: shadow ? const [BoxShadow(color: Color(0xFF0E0E10), offset: Offset(5, 5))] : null,
      ),
      child: child,
    );
  }
}
