import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  /// Change this one variable to update font everywhere
  static const String _fontFamily = 'Urbanist';

  /// Light Text Theme
  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      color: AppColors.lightTextPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 28,
      color: AppColors.lightTextPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 24,
      color: AppColors.lightTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      color: AppColors.lightTextPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 20,
      color: AppColors.lightTextPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 18,
      color: AppColors.lightTextPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: AppColors.lightTextSecondary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      color: AppColors.lightTextSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: AppColors.lightTextDisabled,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: AppColors.lightTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.premiumGold,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.premiumGold,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.blueGrey.shade900,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey.shade800,
    ),
  );

  /// Dark Text Theme
  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      color: AppColors.darkTextPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 28,
      color: AppColors.darkTextPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 24,
      color: AppColors.darkTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: AppColors.darkTextPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 18,
      color: AppColors.darkTextPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 18,
      color: AppColors.darkTextPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: AppColors.darkTextSecondary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      color: AppColors.darkTextSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: AppColors.darkTextSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: AppColors.darkTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.premiumGold,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.premiumGold,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.teal.shade200,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.teal.shade100,
    ),
  );
}
