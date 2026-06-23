import 'package:flutter/widgets.dart';

/// Foundational color tokens (dark-first).
abstract class AppColors {
  static const base = Color(0xFF0C0C14);
  static const surface = Color(0xFF16161F);
  static const surfaceAlt = Color(0xFF1F1F2C);
  static const hairline = Color(0xFF2A2A38);

  static const textPrimary = Color(0xFFF4F4F8);
  static const textSecondary = Color(0xFF9B9BAE);
  static const textMuted = Color(0xFF6C6C7E);

  static const success = Color(0xFF18E0B5);
  static const warning = Color(0xFFFFC14D);
  static const error = Color(0xFFFF4D6D);
  static const info = Color(0xFF5CC8FF);
}

/// 4-based spacing scale.
abstract class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Corner radii.
abstract class AppRadii {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const pill = 999.0;
}
