import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.ink,
      onPrimary: Colors.white,
      secondary: AppColors.lime,
      onSecondary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppText.body(14, color: AppColors.muted),
        border: _border(AppColors.ink),
        enabledBorder: _border(AppColors.ink),
        focusedBorder: _border(AppColors.violet, width: 2),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger, width: 2),
        disabledBorder: _border(AppColors.line),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppText.body(14, color: Colors.white),
        actionTextColor: AppColors.lime,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.ink),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.ink,
        selectionColor: AppColors.lime,
        selectionHandleColor: AppColors.ink,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(8)),
        textStyle: AppText.body(12, color: Colors.white),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        textStyle: AppText.body(14),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1.5}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
}
