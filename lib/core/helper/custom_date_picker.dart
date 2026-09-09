import 'package:flutter/material.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'profile_permission_manager.dart';

class CustomDatePicker {
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final isGold = ProfilePermissionManager.isGoldEligible;
    final accentColor = isGold ? const Color(0xFFC0A062) : AppColors.white;

    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? lastDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            colorScheme: ColorScheme.dark(
              primary: accentColor, // Selected date circle and header action
              onPrimary: AppColors.black, // Text inside selected circle
              surface: const Color(0xFF1E1E1E), // Dialog surface
              onSurface: AppColors.white, // Dates, day names, month labels
              secondary: accentColor,
              onSecondary: AppColors.black,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isGold
                      ? const Color(0xFFC0A062).withValues(alpha: 0.5)
                      : const Color(0xFF38383A),
                  width: 1.2,
                ),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: const Color(0xFF1E1E1E),
              headerBackgroundColor: const Color(0xFF181818),
              headerForegroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.black;
                }
                if (states.contains(WidgetState.disabled)) {
                  return AppColors.secondaryText.withValues(alpha: 0.3);
                }
                return AppColors.white;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return accentColor;
                }
                return null;
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.black;
                }
                return accentColor;
              }),
              todayBorder: BorderSide(color: accentColor, width: 1),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.black;
                }
                return AppColors.white;
              }),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return accentColor;
                }
                return null;
              }),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
