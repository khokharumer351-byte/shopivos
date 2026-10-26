import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppText {
  static TextStyle display(
    double size, {
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w700,
  }) => GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: 1.05,
    letterSpacing: -size * 0.03,
  );

  static TextStyle serif(
    double size, {
    Color color = AppColors.ink,
    FontStyle style = FontStyle.italic,
    FontWeight weight = FontWeight.w500,
  }) => GoogleFonts.playfairDisplay(
    fontSize: size,
    fontStyle: style,
    fontWeight: weight,
    color: color,
    height: 1.05,
  );

  static TextStyle body(
    double size, {
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static TextStyle label({Color color = AppColors.ink, double size = 12}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.1,
      );
}
