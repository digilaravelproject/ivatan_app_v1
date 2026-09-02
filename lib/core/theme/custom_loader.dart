import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomLoader {
  static bool _isShowing = false;

  static const String _logoPath = "assets/images/imageApplogo.jpg";

  static void show() {
    if (_isShowing) return;

    _isShowing = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.white,
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔥 Fixed Logo (No need to pass from outside)
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(_logoPath, fit: BoxFit.contain),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Loading...",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (_isShowing) {
      _isShowing = false;
      Get.back();
    }
  }
}
