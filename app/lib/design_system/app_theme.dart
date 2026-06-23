import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Dark-first Material 3 theme with display type in Space Grotesk and body in Inter.
abstract class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.base,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.surface,
        primary: const Color(0xFF6E56F7),
        secondary: const Color(0xFFFF3D77),
        error: AppColors.error,
      ),
      textTheme: textTheme.copyWith(
        headlineMedium: GoogleFonts.spaceGrotesk(
          textStyle: textTheme.headlineMedium,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          textStyle: textTheme.titleLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.base,
        elevation: 0,
        centerTitle: false,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceAlt,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        side: const BorderSide(color: AppColors.hairline),
        shape: const StadiumBorder(),
      ),
    );
  }
}
