import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medigram/core/constants/app_colors.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Başarılı',
      message,
      backgroundColor: AppColors.success,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.check_circle,
        color: AppColors.textPrimary,
      ),
    );
  }

  static void showError(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Hata',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(
        Icons.error,
        color: AppColors.textPrimary,
      ),
    );
  }

  static void showInfo(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Bilgi',
      message,
      backgroundColor: AppColors.info,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.info,
        color: AppColors.textPrimary,
      ),
    );
  }

  static void showWarning(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Uyarı',
      message,
      backgroundColor: AppColors.warning,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.warning,
        color: AppColors.textPrimary,
      ),
    );
  }

  static void showCustom({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor ?? AppColors.surface,
      colorText: textColor ?? AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
      icon: icon,
    );
  }
}
