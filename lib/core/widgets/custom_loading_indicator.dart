import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;
  final Animation<Color?>? valueColor;
  final double? value;
  final Color? backgroundColor;
  final String? semanticsLabel;
  final String? semanticsValue;
  final double? strokeAlign;

  const CustomLoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
    this.valueColor,
    this.value,
    this.backgroundColor,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeAlign,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Default normal loader size is 28.0
        double determinedSize = size ?? 28.0;

        // Only scale down if both dimensions are bounded and small (e.g., inside buttons or custom small spaces)
        if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
          final minConstraint = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;
          if (minConstraint > 0 && minConstraint < 40) {
            determinedSize = minConstraint;
          }
        }

        // Keep size within standard reasonable bounds
        if (determinedSize < 12) determinedSize = 12;
        if (determinedSize > 100) determinedSize = 100;

        return LoadingAnimationWidget.hexagonDots(
          color: color ?? AppColors.black, // Default color is black
          size: determinedSize,
        );
      },
    );
  }
}
