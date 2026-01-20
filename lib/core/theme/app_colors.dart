/*
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Brand Colors (Crypto App Identity)
  static const Color primary = Color(0xFF7069E3); // Crypto Blue
  static const Color splash = Color(0xFF001F3E); // Crypto Blue
  static const Color secondary = Color(0xFFFFFFFF); // Teal/Green (Growth)
  static const Color accent = Color(0xFF1ED760); // Neon Green Accent
  static const Color success = Color(0xFF21C55D); // Profit Green
  static const Color warning = Color(0xFFFFB020); // Alert/Volatility Orange
  static const Color error = Color(0xFFE53935); // Loss/Red
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);



  /// Light Mode Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFDCEFFF);
  static const Color lightSecondaryContainer = Color(0xFFE5FFFA);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextDisabled = Color(0xFF9CA3AF);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightBorder = Color(0xFFD1D5DB);
  static const Color lightIcon = Color(0xFF6B7280);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightAppBar = Color(0xFFF1F5F9);
  static const Color lightChipBackground = Color(0xFFE0F2FE);
  static const Color lightShadow = Color(0x1A000000);
  static List<Color> lightBackgroundColors = [
    Colors.white,
    Colors.blue.shade100,
    Colors.teal.shade100,
  ];

  /// Dark Mode Colors
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkPrimaryContainer = Color(0xFF003566);
  static const Color darkSecondaryContainer = Color(0xFF004D40);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextDisabled = Color(0xFF6B7280);
  static const Color darkDivider = Color(0xFF2D333B);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkIcon = Color(0xFFD1D5DB);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkAppBar = Color(0xFF161B22);
  static const Color darkChipBackground = Color(0xFF1F2937);
  static const Color darkShadow = Color(0x1AFFFFFF);
  static List<Color> darkBackgroundColors = [
    Color(0xFF1a1a2e),
    Color(0xFF16213e),
    Color(0xFF0f3460),
    Color(0xFF533483),
  ];

  /// Trade Indicators
  static const Color profitGreen = Color(0xFF21C55D);
  static const Color lossRed = Color(0xFFE53935);
  static const Color neutralGrey = Color(0xFF9CA3AF);

  /// Special Tags
  static const Color hotCoin = Color(0xFFFF5722); // Trending coin
  static const Color newListing = Color(0xFF0A84FF); // Newly listed
  static const Color flashSale = Color(0xFFFFC107); // Limited-time promo

  /// Rating colors
  static const Color ratingActive = Color(0xFFFFD600);
  static const Color ratingInactive = Color(0xFF9CA3AF);

  /// Button states
  static const Color buttonDisabled = Color(0xFF6B7280);
  static const Color buttonPressed = Color(0xFF0056D2);
}
*/

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============== BRAND IDENTITY COLORS ==============
  // Professional Crypto Blue - Modern, trustworthy, tech-forward
  static const Color primary = Color(0xFF05A1BC); // Indigo 500 - Premium feel
  static const Color primaryDark = Color(0xFF0891B2,); // Indigo 600 - Hover state
  static const Color primaryLight = Color(0xFF3BDFF8,); // Purple tint for gradients

  // Sophisticated Secondary Palette
  static const Color secondary = Color(0xFF06B6D4); // Cyan 500 - Innovation
  static const Color secondaryDark = Color(0xFF0891B2); // Cyan 600
  static const Color secondaryLight = Color(0xFF22D3EE); // Cyan 400

  static const Color darkText = Color(0xFF5E5E5E); // Gray 200

  static final List<Color> backgroundGradient = [
    Color(0xFF7AB6F0),
    Color(0xFFB3E5F5),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];

  // Color(0xFF0E0E0E),
  // Color(0xFF424242),
  // Color(0xFFCCCBCB),
  // Color(0xFFFFFFFF),
  // Premium Accent Colors

  static const Color accent = Color(0xFF10B981); // Emerald 500 - Growth/Success
  static const Color accentGold = Color(
    0xFFF59E0B,
  ); // Amber 500 - Premium features

  // Core System Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ============== SEMANTIC COLORS ==============
  // Enhanced Trading Indicators
  static const Color bullishGreen = Color(
    0xFF059669,
  ); // Emerald 600 - Stronger green
  static const Color bearishRed = Color(
    0xFFDC2626,
  ); // Red 600 - Professional red
  static const Color neutralGray = Color(0xFFBDBFC2); // Gray 500
  static const Color gray = Color(0xFF909AA3); // Gray 500

  // Market Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // ============== LIGHT THEME COLORS ==============
  // Background Hierarchy
  static const Color lightBackground = Color(0xFFFAFAFA); // Neutral 50
  static const Color lightBackgroundSecondary = Color(
    0xFFF5F5F5,
  ); // Neutral 100
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF); // Cards

  // Container Colors
  static const Color lightPrimaryContainer = Color(0xFFEEF2FF); // Indigo 50
  static const Color lightSecondaryContainer = Color(0xFFECFEFF); // Cyan 50
  static const Color lightSuccessContainer = Color(0xFFECFDF5); // Emerald 50
  static const Color lightWarningContainer = Color(0xFFFFFBEB); // Amber 50
  static const Color lightErrorContainer = Color(0xFFFEF2F2); // Red 50

  // Text Hierarchy
  static const Color lightTextPrimary = Color(0xFF111827); // Gray 900
  static const Color lightTextSecondary = Color(0xFF4B5563); // Gray 600
  static const Color lightTextTertiary = Color(0xFF6B7280); // Gray 500
  static const Color lightTextDisabled = Color(0xFF9CA3AF); // Gray 400
  static const Color lightTextOnColor = Color(
    0xFFFFFFFF,
  ); // White on colored backgrounds

  // Borders & Dividers
  static const Color lightBorder = Color(0xFF6E6E6E); // Gray 200
  static const Color lightBorderStrong = Color(0xFFD1D5DB); // Gray 300
  static const Color lightDivider = Color(0xFF6E6E6E); // Gray 100

  // Interactive Elements
  static const Color lightHover = Color(0xFFF9FAFB); // Gray 50
  static const Color lightPressed = Color(0xFFF3F4F6); // Gray 100
  static const Color lightFocusRing = Color(
    0x4D6366F1,
  ); // Primary with 30% opacity

  // Shadows & Elevation
  static const Color lightShadowLight = Color(0x0A000000); // 4% black
  static const Color lightShadowMedium = Color(0x14000000); // 8% black
  static const Color lightShadowStrong = Color(0x1F000000); // 12% black

  // Light Theme Gradients
  static List<Color> lightGradientPrimary = [
    Color(0xFF6366F1), // Indigo 500
    Color(0xFF8B5CF6), // Purple 500
  ];

  static List<Color> lightGradientSuccess = [
    Color(0xFF10B981), // Emerald 500
    Color(0xFF06B6D4), // Cyan 500
  ];

  static List<Color> lightBackgroundGradient = [
    Color(0xFFdbeafe),
    Color(0xFFbfdbfe),
    Color(0xFF93c5fd),
    Color(0xFFa5b4fc),
  ];

  // ============== DARK THEME COLORS ==============
  // Background Hierarchy - Premium dark design
  static const Color darkBackground = Color(0xFF0A0A0B); // Almost black
  static const Color darkBackgroundSecondary = Color(
    0xFF111114,
  ); // Slightly lighter
  static const Color darkSurface = Color(0xFF1A1A1E); // Card background
  static const Color darkSurfaceElevated = Color(0xFF242428); // Elevated cards

  // Container Colors
  static const Color darkPrimaryContainer = Color(0xFF312E81); // Indigo 800
  static const Color darkSecondaryContainer = Color(0xFF164E63); // Cyan 800
  static const Color darkSuccessContainer = Color(0xFF064E3B); // Emerald 800
  static const Color darkWarningContainer = Color(0xFF92400E); // Amber 800
  static const Color darkErrorContainer = Color(0xFF991B1B); // Red 800

  // Text Hierarchy
  static const Color darkTextPrimary = Color(0xFFFAFAFA); // Neutral 50
  static const Color darkTextSecondary = Color(0xFFD1D5DB); // Gray 300
  static const Color darkTextTertiary = Color(0xFF9CA3AF); // Gray 400
  static const Color darkTextDisabled = Color(0xFF6B7280); // Gray 500
  static const Color darkTextOnColor = Color(
    0xFFFFFFFF,
  ); // White on colored backgrounds

  // Borders & Dividers
  static const Color darkBorder = Color(0xFFD9D9D9); // Gray 700
  static const Color darkBorderStrong = Color(0xFF4B5563); // Gray 600
  static const Color darkDivider = Color(0xFFD9D9D9); // Subtle divider

  // Interactive Elements
  static const Color darkHover = Color(0xFF374151); // Gray 700
  static const Color darkPressed = Color(0xFF4B5563); // Gray 600
  static const Color darkFocusRing = Color(
    0x4D8B5CF6,
  ); // Purple with 30% opacity

  // Shadows & Elevation
  static const Color darkShadowLight = Color(0x14FFFFFF); // 8% white
  static const Color darkShadowMedium = Color(0x1FFFFFFF); // 12% white
  static const Color darkShadowStrong = Color(0x29FFFFFF); // 16% white

  // Dark Theme Gradients - More vibrant for OLED displays
  static List<Color> darkGradientPrimary = [
    Color(0xFF7C3AED), // Purple 600
    Color(0xFF6366F1), // Indigo 500
  ];

  static List<Color> darkGradientSuccess = [
    Color(0xFF059669), // Emerald 600
    Color(0xFF0891B2), // Cyan 600
  ];

  static List<Color> darkBackgroundGradient = [
    Color(0xFF1a1a2e),
    Color(0xFF16213e),
    Color(0xFF0f3460),
    Color(0xFF533483),
  ];

  // ============== SPECIAL FEATURE COLORS ==============
  // Premium Features
  static const Color premiumGold = Color(0xFFD97706); // Amber 600
  static const Color premiumGoldLight = Color(0xFFFBBF24); // Amber 400
  static const Color premiumPlatinum = Color(0xFF8B8B8B); // Gray metallic

  // Market Indicators - Enhanced visibility
  static const Color trendingHot = Color(0xFFEF4444); // Red 500 - Hot/trending
  static const Color newListing = Color(0xFF3B82F6); // Blue 500 - New
  static const Color flashSale = Color(0xFFF59E0B); // Amber 500 - Limited time
  static const Color verified = Color(0xFF10B981); // Emerald 500 - Verified

  // Rating System
  static const Color ratingActive = Color(0xFFF59E0B); // Amber 500
  static const Color ratingInactive = Color(0xFFD1D5DB); // Gray 300 (light)
  static const Color ratingInactiveDark = Color(0xFF6B7280); // Gray 500 (dark)

  // Trading Charts - Optimized for readability
  static const Color chartBullish = Color(0xFF10B981); // Emerald 500
  static const Color chartBearish = Color(0xFFEF4444); // Red 500
  static const Color chartNeutral = Color(0xFF6B7280); // Gray 500
  static const Color chartGrid = Color(0xFFE5E7EB); // Gray 200 (light)
  static const Color chartGridDark = Color(0xFF374151); // Gray 700 (dark)

  // Status Indicators
  static const Color statusOnline = Color(0xFF10B981); // Emerald 500
  static const Color statusOffline = Color(0xFF6B7280); // Gray 500
  static const Color statusMaintenance = Color(0xFFF59E0B); // Amber 500

  // Button States - Enhanced interaction feedback
  static const Color buttonPrimaryDefault = Color(0xFF6366F1); // Indigo 500
  static const Color buttonPrimaryHover = Color(0xFF4F46E5); // Indigo 600
  static const Color buttonPrimaryPressed = Color(0xFF4338CA); // Indigo 700
  static const Color buttonPrimaryDisabled = Color(0xFF9CA3AF); // Gray 400

  static const Color buttonSecondaryDefault = Color(0xFFFFFFFF); // White
  static const Color buttonSecondaryHover = Color(0xFFF9FAFB); // Gray 50
  static const Color buttonSecondaryPressed = Color(0xFFF3F4F6); // Gray 100

  // ============== ACCESSIBILITY HELPERS ==============
  // High contrast alternatives for better accessibility
  static const Color highContrastPrimary = Color(0xFF3730A3); // Indigo 800
  static const Color highContrastSuccess = Color(0xFF047857); // Emerald 700
  static const Color highContrastError = Color(0xFFB91C1C); // Red 700

  // ============== UTILITY METHODS ==============
  /// Returns appropriate text color based on background
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? lightTextPrimary : darkTextPrimary;
  }

  /// Returns appropriate border color based on theme
  static Color getBorderColor(bool isDark) {
    return isDark ? darkBorder : lightBorder;
  }

  /// Returns gradient colors based on theme
  static List<Color> getPrimaryGradient(bool isDark) {
    return isDark ? darkGradientPrimary : lightGradientPrimary;
  }

  /// Returns appropriate shadow color based on theme
  static Color getShadowColor(bool isDark, {String intensity = 'medium'}) {
    if (isDark) {
      switch (intensity) {
        case 'light':
          return darkShadowLight;
        case 'strong':
          return darkShadowStrong;
        default:
          return darkShadowMedium;
      }
    } else {
      switch (intensity) {
        case 'light':
          return lightShadowLight;
        case 'strong':
          return lightShadowStrong;
        default:
          return lightShadowMedium;
      }
    }
  }
}
