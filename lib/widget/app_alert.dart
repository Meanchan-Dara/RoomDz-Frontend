import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Standard alert / snackbar utility ensuring all app alerts appear at the TOP.
class AppAlert {
  /// Show success alert at the top of the screen
  static void success(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Show error alert at the top of the screen
  static void error(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Show warning alert at the top of the screen
  static void warning(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFD97706),
      colorText: Colors.white,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Show generic info alert at the top of the screen
  static void info(String title, String message, {Duration? duration}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1D4ED8),
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
