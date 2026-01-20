import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ================= BRAND COLORS =================
  // Black primary – premium & minimal
  static const Color primary = Color(0xFF000000);
  static const Color primaryDark = Color(0xFF0A0A0A);
  static const Color primaryLight = Color(0xFF1F2937);

  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color secondaryLight = Color(0xFF22D3EE);

  static const Color accent = Color(0xFF10B981); // Emerald
  static const Color accentGold = Color(0xFFF59E0B); // Gold

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ================= SEMANTIC COLORS =================
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color bullishGreen = Color(0xFF059669);
  static const Color bearishRed = Color(0xFFDC2626);
  static const Color neutralGray = Color(0xFF9CA3AF);

  // ================= LIGHT THEME =================
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextDisabled = Color(0xFF9CA3AF);

  static const Color lightBorder = Color(0xFFD1D5DB);
  static const Color lightDivider = Color(0xFFE5E7EB);

  static const Color lightShadowLight = Color(0x0A000000);
  static const Color lightShadowMedium = Color(0x14000000);
  static const Color lightShadowStrong = Color(0x1F000000);

  static const List<Color> lightGradientPrimary = [
    Color(0xFF000000),
    Color(0xFF1F2937),
  ];

  static const List<Color> lightBackgroundGradient = [
    Color(0xFFF9FAFB),
    lightTextSecondary,
    lightTextSecondary,
  ];

  // ================= DARK THEME =================
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF111827);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextDisabled = Color(0xFF6B7280);

  static const Color darkBorder = Color(0xFF374151);
  static const Color darkDivider = Color(0xFF1F2937);

  static const Color darkShadowLight = Color(0x14FFFFFF);
  static const Color darkShadowMedium = Color(0x1FFFFFFF);
  static const Color darkShadowStrong = Color(0x29FFFFFF);

  static const List<Color> darkGradientPrimary = [
    Color(0xFF000000),
    Color(0xFF1F2937),
  ];

  static const List<Color> darkBackgroundGradient = [
    Color(0xFF000000),
    Color(0xFF0F172A),
    Color(0xFF1E293B),
  ];

  // ================= UTILITIES =================
  static Color textColorForBackground(Color background) {
    return background.computeLuminance() > 0.5
        ? lightTextPrimary
        : darkTextPrimary;
  }

  static Color shadowColor(bool isDark, {bool strong = false}) {
    if (isDark) {
      return strong ? darkShadowStrong : darkShadowMedium;
    }
    return strong ? lightShadowStrong : lightShadowMedium;
  }

  static List<Color> primaryGradient(bool isDark) {
    return isDark ? darkGradientPrimary : lightGradientPrimary;
  }
}
