import 'package:flutter/material.dart';
import '../helper/profile_permission_manager.dart';

class AppColors {
  AppColors._();

  static bool get _isGoldEligible {
    try {
      return ProfilePermissionManager.isGoldEligible;
    } catch (e) {
      return false;
    }
  }

  static bool get isGoldEligible => _isGoldEligible;

  // ================= CLIENT BRAND COLORS =================
  static const Color mainBackground = Color(0xFF050505);
  static const Color secondaryBackground = Color(0xFF111111);
  static const Color cardSurface = Color(0xFF181818);
  static const Color elevatedSurface = Color(0xFF222222);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB8B8B8);
  static const Color border = Color(0xFF3A3A3A);
  
  static Color get premiumGold => _isGoldEligible ? const Color(0xFFC0A062) : const Color(0xFFF5F5F5); 
  static Color get goldHighlight => _isGoldEligible ? const Color(0xFFD4B776) : const Color(0xFFFFFFFF);
  static Color get goldGlow => _isGoldEligible ? const Color(0xFFA68748) : const Color(0xFFE0E0E0);
  static Color get successSoftGold => premiumGold;

  // ================= BACKWARD COMPATIBILITY & ALIASES =================
  static const Color primary = mainBackground;
  static const Color primaryDark = Color(0xFF000000);
  static const Color primaryLight = secondaryBackground;

  static Color get secondary => premiumGold;
  static Color get secondaryDark => premiumGold;
  static Color get secondaryLight => goldHighlight;

  static Color get accent => premiumGold;
  static Color get accentGold => premiumGold;

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ================= SEMANTIC COLORS =================
  static Color get success => successSoftGold;
  static Color get warning => goldHighlight;
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static Color get bullishGreen => successSoftGold;
  static const Color bearishRed = Color(0xFFDC2626);
  static const Color neutralGray = secondaryText;

  // ================= LIGHT THEME (Mapped to Dark for this design) =================
  static const Color lightBackground = mainBackground;
  static const Color lightSurface = secondaryBackground;

  static const Color lightTextPrimary = primaryText;
  static const Color lightTextSecondary = secondaryText;
  static const Color lightTextDisabled = border;

  static const Color lightBorder = border;
  static const Color lightDivider = border;

  static const Color lightShadowLight = Color(0x0A000000);
  static const Color lightShadowMedium = Color(0x14000000);
  static const Color lightShadowStrong = Color(0x1F000000);

  static List<Color> get lightGradientPrimary => [
    premiumGold,
    goldHighlight,
  ];

  static const List<Color> lightBackgroundGradient = [
    mainBackground,
    secondaryBackground,
    mainBackground,
  ];

  // ================= DARK THEME =================
  static const Color darkBackground = mainBackground;
  static const Color darkSurface = cardSurface;

  static const Color darkTextPrimary = primaryText;
  static const Color darkTextSecondary = secondaryText;
  static const Color darkTextDisabled = border;

  static const Color darkBorder = border;
  static const Color darkDivider = border;

  static const Color darkShadowLight = Color(0x14000000);
  static const Color darkShadowMedium = Color(0x1F000000);
  static const Color darkShadowStrong = Color(0x29000000);

  static List<Color> get darkGradientPrimary => [
    premiumGold,
    goldHighlight,
  ];

  static const List<Color> darkBackgroundGradient = [
    mainBackground,
    secondaryBackground,
    cardSurface,
  ];

  // ================= UTILITIES =================
  static Color textColorForBackground(Color background) {
    return background.computeLuminance() > 0.5
        ? mainBackground
        : primaryText;
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
