import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*enum ButtonType { elevated, outlined }

class MyButton extends StatelessWidget {
  final String title;
  final bool isLoading;
  final VoidCallback? onPressed;
  final ButtonType type;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final Color? color;
  final IconData? icon;
  final Gradient? gradient; // 🌈 NEW: Gradient support

  const MyButton({
    super.key,
    required this.title,
    this.isLoading = false,
    this.onPressed,
    this.elevation = 0,
    this.type = ButtonType.elevated,
    this.padding,
    this.color,
    this.icon,
    this.gradient, // ✅ added
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? context.theme.primaryColor;

    final buttonContent = isLoading
        ? SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(
        color: type == ButtonType.outlined
            ? context.theme.primaryColor
            : context.theme.colorScheme.onPrimary,
        strokeWidth: 2,
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: type == ButtonType.outlined
                ? context.theme.primaryColor
                : context.theme.colorScheme.onPrimary,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall?.copyWith(
              color: type == ButtonType.outlined
                  ? context.theme.primaryColor
                  : context.theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );

    Widget buttonWidget;

    if (type == ButtonType.elevated) {
      // 🌈 Gradient button
      buttonWidget = Container(
        decoration: BoxDecoration(
          gradient: gradient ??
              LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: elevation,
            backgroundColor: Colors.transparent, // 🪄 transparent to show gradient
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          onPressed: isLoading ? null : onPressed,
          child: buttonContent,
        ),
      );
    } else {
      // 🧾 Outlined button
      buttonWidget = OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: context.theme.primaryColor),
        ),
        onPressed: isLoading ? null : onPressed,
        child: buttonContent,
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: buttonWidget,
      ),
    );
  }
}*/




import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

enum ButtonType { elevated, outlined }

class MyButton extends StatelessWidget {
  final String title;
  final bool isLoading;
  final VoidCallback? onPressed;
  final ButtonType type;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final Color? color;
  final IconData? icon;
  final Gradient? gradient;
  final double? height; // ✅ dynamic height
  final double? borderRadius; // ✅ dynamic radius

  const MyButton({
    super.key,
    required this.title,
    this.isLoading = false,
    this.onPressed,
    this.elevation = 0,
    this.type = ButtonType.elevated,
    this.padding,
    this.color,
    this.icon,
    this.gradient,
    this.height, // ✅ added
    this.borderRadius, // ✅ added
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? context.theme.primaryColor;
    final double radius = borderRadius ?? 16; // ✅ fallback radius
    final double btnHeight = height ?? 48; // ✅ fallback height

    final buttonContent = isLoading
        ? SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(
        color: type == ButtonType.outlined
            ? context.theme.primaryColor
            : context.theme.colorScheme.onPrimary,
        strokeWidth: 2,
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: type == ButtonType.outlined
                ? context.theme.primaryColor
                : context.theme.colorScheme.onPrimary,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: type == ButtonType.outlined
                  ? context.theme.primaryColor
                  : context.theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );

    Widget buttonWidget;

    if (type == ButtonType.elevated) {
      // 🌈 Gradient button
      buttonWidget = Container(
        height: btnHeight,
        decoration: BoxDecoration(
          gradient: gradient ??
              LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryLight.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: elevation,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: EdgeInsets.zero, // 🔹 handled by height now
          ),
          onPressed: isLoading ? null : onPressed,
          child: Center(child: buttonContent),
        ),
      );
    } else {
      // 🧾 Outlined button
      buttonWidget = OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, btnHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          side: BorderSide(color: context.theme.primaryColor),
        ),
        onPressed: isLoading ? null : onPressed,
        child: buttonContent,
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: buttonWidget,
      ),
    );
  }
}


