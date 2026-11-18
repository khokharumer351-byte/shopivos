import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/bits.dart';

abstract final class AdminColors {
  static const ink = Color(0xFF2C353D);
  static const paper = Color(0xFFF7F8FA);
  static const paperDark = Color(0xFFEDF1F5);
  static const surface = Color(0xFFFFFFFF);
  static const muted = Color(0xFF6B7785);
  static const line = Color(0xFFE2E8EF);

  static const lime = Color(0xFFE8F0F6);
  static const violet = Color(0xFF5F7F9E);
  static const pink = Color(0xFFF4E6EC);
  static const peach = Color(0xFFF8EBDD);
  static const sky = Color(0xFFE7F0F7);

  static const success = Color(0xFF3F7C66);
  static const danger = Color(0xFFB85C5C);
  static const warning = Color(0xFFA87332);

  static const playful = [lime, sky, peach, pink, paperDark];
}

abstract final class AdminText {
  static TextStyle display(
    double size, {
    Color color = AdminColors.ink,
    FontWeight weight = FontWeight.w600,
  }) => GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: 1.1,
    letterSpacing: -size * 0.02,
  );

  static TextStyle body(
    double size, {
    Color color = AdminColors.ink,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: 1.5,
  );

  static TextStyle label({
    Color color = AdminColors.muted,
    double size = 12,
  }) => GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.8,
  );

  static TextStyle serif(
    double size, {
    Color color = AdminColors.ink,
  }) => GoogleFonts.playfairDisplay(
    fontSize: size,
    color: color,
    height: 1.1,
  );
}

abstract final class AdminTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AdminColors.violet,
      brightness: Brightness.light,
    ).copyWith(
      primary: AdminColors.violet,
      onPrimary: Colors.white,
      secondary: AdminColors.lime,
      onSecondary: AdminColors.ink,
      surface: AdminColors.surface,
      onSurface: AdminColors.ink,
      outline: AdminColors.line,
      error: AdminColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AdminColors.paper,
      textTheme: AppTheme.light.textTheme.apply(
        bodyColor: AdminColors.ink,
        displayColor: AdminColors.ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppText.body(14, color: AdminColors.muted),
        border: _border(AdminColors.line),
        enabledBorder: _border(AdminColors.line),
        focusedBorder: _border(AdminColors.violet, width: 1.5),
        errorBorder: _border(AdminColors.danger),
        focusedErrorBorder: _border(AdminColors.danger, width: 1.5),
        disabledBorder: _border(AdminColors.line),
      ),
      dividerTheme: const DividerThemeData(
        color: AdminColors.line,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.ink,
        contentTextStyle: AppText.body(14, color: Colors.white),
        actionTextColor: AdminColors.lime,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AdminColors.violet,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AdminColors.violet,
        selectionColor: AdminColors.lime,
        selectionHandleColor: AdminColors.violet,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AdminColors.ink,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppText.body(12, color: Colors.white),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AdminColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AdminColors.line),
        ),
        textStyle: AppText.body(14),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
}

class AdminStatusChip extends StatelessWidget {
  const AdminStatusChip(this.status, {super.key});

  final String status;

  static Color colorFor(String status) => switch (status) {
    'pending' => AdminColors.peach,
    'processing' => AdminColors.sky,
    'shipped' => AdminColors.lime,
    'delivered' => AdminColors.success,
    'cancelled' => AdminColors.paperDark,
    _ => AdminColors.paperDark,
  };

  @override
  Widget build(BuildContext context) {
    return Pill(
      capitalize(status),
      color: colorFor(status),
      textColor: AdminColors.ink,
    );
  }
}
