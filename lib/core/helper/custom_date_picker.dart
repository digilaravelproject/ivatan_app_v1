import 'package:flutter/material.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';

class CustomDatePicker {
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    // Use Material DatePicker instead of Cupertino to avoid Impeller rendering issues
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? firstDate ?? DateTime(1950),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Header background color
              onPrimary: AppColors.white, // Header text color
              onSurface: AppColors.white, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
