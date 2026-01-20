import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackBarType { success, warning, error, info }

class CustomSnackBar {
  static void show({
    required String message,
    SnackBarType type = SnackBarType.success,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    if (Get.context == null) {
      return;
    }
    final context = Get.context!;
    final snackBar = SnackBar(
      content: _SnackBarContent(message: message, type: type, onTap: onTap),
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSuccess({
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    show(
      message: message,
      type: SnackBarType.success,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showWarning({
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    show(
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showError({
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    show(
      message: message,
      type: SnackBarType.error,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showInfo({
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    show(
      message: message,
      type: SnackBarType.info,
      duration: duration,
      onTap: onTap,
    );
  }
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final SnackBarType type;
  final VoidCallback? onTap;

  const _SnackBarContent({
    required this.message,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(_getIcon(), color: _getIconColor(), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              onTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getCloseButtonColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.close, color: _getTextColor(), size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFFF0FDF4);
      case SnackBarType.warning:
        return const Color(0xFFFFFBEB);
      case SnackBarType.error:
        return const Color(0xFFFEF2F2);
      case SnackBarType.info:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFFBBF7D0);
      case SnackBarType.warning:
        return const Color(0xFFFDE68A);
      case SnackBarType.error:
        return const Color(0xFFFECACA);
      case SnackBarType.info:
        return const Color(0xFFBFDBFE);
    }
  }

  Color _getShadowColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF22C55E).withValues(alpha: 0.15);
      case SnackBarType.warning:
        return const Color(0xFFF59E0B).withValues(alpha: 0.15);
      case SnackBarType.error:
        return const Color(0xFFEF4444).withValues(alpha: 0.15);
      case SnackBarType.info:
        return const Color(0xFF3B82F6).withValues(alpha: 0.15);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF166534);
      case SnackBarType.warning:
        return const Color(0xFF92400E);
      case SnackBarType.error:
        return const Color(0xFF991B1B);
      case SnackBarType.info:
        return const Color(0xFF1E40AF);
    }
  }

  Color _getIconColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF22C55E);
      case SnackBarType.warning:
        return const Color(0xFFF59E0B);
      case SnackBarType.error:
        return const Color(0xFFEF4444);
      case SnackBarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  Color _getIconBackgroundColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFFDCFCE7);
      case SnackBarType.warning:
        return const Color(0xFFFEF3C7);
      case SnackBarType.error:
        return const Color(0xFFFEE2E2);
      case SnackBarType.info:
        return const Color(0xFFDBEAFE);
    }
  }

  Color _getCloseButtonColor() {
    return _getTextColor().withValues(alpha: 0.1);
  }

  IconData _getIcon() {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.info:
        return Icons.info;
    }
  }
}

// Example usage in a StatefulWidget
class SnackbarDemo extends StatelessWidget {
  const SnackbarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Snackbar Demo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Custom Snackbar Examples',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              _buildButton(
                context,
                'Show Success',
                Colors.green,
                () => CustomSnackBar.showSuccess(
                  message: 'Operation completed successfully!',
                ),
              ),
              const SizedBox(height: 16),
              _buildButton(
                context,
                'Show Warning',
                Colors.orange,
                () => CustomSnackBar.showWarning(
                  message: 'Please check your input data.',
                ),
              ),
              const SizedBox(height: 16),
              _buildButton(
                context,
                'Show Error',
                Colors.red,
                () => CustomSnackBar.showError(
                  message: 'Something went wrong. Please try again.',
                ),
              ),
              const SizedBox(height: 16),
              _buildButton(
                context,
                'Show Info',
                Colors.blue,
                () => CustomSnackBar.showInfo(
                  message: 'Here\'s some helpful information for you.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
