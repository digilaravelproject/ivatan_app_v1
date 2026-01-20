import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import 'AppDimens.dart';

class AppDecorations {
  static BoxDecoration cardDecoration(
    BuildContext context, {
    Color? customColor,
    double? elevation,
    BorderRadius? borderRadius,
  }) {
    final isDark = context.isDarkMode;
    final surfaceColor = context.theme.colorScheme.surface;

    return BoxDecoration(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      color: customColor ?? surfaceColor,
      boxShadow: [
        BoxShadow(
          color: context.theme.shadowColor.withValues(
            alpha: isDark ? 0.25 : 0.15,
          ),
          blurRadius: elevation ?? 6,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: context.theme.shadowColor.withValues(
            alpha: isDark ? 0.15 : 0.08,
          ),
          blurRadius: (elevation ?? 6) * 1.5,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration primaryBgDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: context.theme.primaryColor,
      border: Border.all(color: context.theme.dividerColor, width: 2),
    );
  }

  static BoxDecoration bottomSheetDecoration(
    BuildContext context, {
    Color? customColor,
    double? elevation,
    BorderRadius? borderRadius,
  }) {
    final isDark = context.isDarkMode;
    return BoxDecoration(
      borderRadius:
          borderRadius ?? BorderRadius.vertical(top: Radius.circular(24)),
      color:
          customColor ??
          (isDark ? AppColors.darkSurface : AppColors.lightSurface),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 0.5,
      ),
    );
  }

  static BoxDecoration neonBorder(
    Color color, {
    BoxShape? shape,
    double glowIntensity = 0.6,
    double borderWidth = 2,
  }) {
    return BoxDecoration(
      shape: shape ?? BoxShape.rectangle,
      borderRadius: shape == BoxShape.circle
          ? null
          : BorderRadius.circular(AppDimens.radiusLarge),
      border: Border.all(color: color, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: glowIntensity),
          blurRadius: AppDimens.blurLarge,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
