import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 26,
    this.light = false,
    this.linkHome = true,
  });

  final double size;
  final bool light;
  final bool linkHome;

  @override
  Widget build(BuildContext context) {
    final logo = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'shopivo',
          style: AppText.display(
            size,
            color: light ? Colors.white : AppColors.ink,
          ),
        ),
        Container(
          width: size * 0.32,
          height: size * 0.32,
          margin: EdgeInsets.only(left: 2, bottom: size * 0.12),
          decoration: BoxDecoration(
            color: AppColors.lime,
            shape: BoxShape.circle,
            border: Border.all(
              color: light ? Colors.white : AppColors.ink,
              width: 1.5,
            ),
          ),
        ),
      ],
    );

    if (!linkHome) return logo;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: () => context.go('/'), child: logo),
    );
  }
}
