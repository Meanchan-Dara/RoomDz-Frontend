import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Standard alert / snackbar utility ensuring all app alerts appear at the TOP
/// with consistent colors:
/// - Success: Green (#16A34A)
/// - Error: Red (#DC2626)
/// - Warning: Orange (#EA580C)
/// - Info: Blue (#2563EB)
class AppAlert {
  /// Show success alert at the top of the screen (Green)
  static void success(String title, [String? message, Duration? duration]) {
    final msg = message ?? '';
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      titleText: Text(
        title,
        style: GoogleFonts.battambang(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      messageText: msg.isNotEmpty
          ? Text(
              msg,
              style: GoogleFonts.battambang(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13,
              ),
            )
          : const SizedBox.shrink(),
      icon: const Icon(
        Icons.check_circle_rounded,
        color: Colors.white,
        size: 24,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: const Color(0xFF16A34A).withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Show error alert at the top of the screen (Red)
  static void error(String title, [String? message, Duration? duration]) {
    final msg = message ?? '';
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      titleText: Text(
        title,
        style: GoogleFonts.battambang(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      messageText: msg.isNotEmpty
          ? Text(
              msg,
              style: GoogleFonts.battambang(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13,
              ),
            )
          : const SizedBox.shrink(),
      icon: const Icon(Icons.error_rounded, color: Colors.white, size: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 4),
      boxShadows: [
        BoxShadow(
          color: const Color(0xFFDC2626).withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Show warning alert at the top of the screen (Orange)
  static void warning(String title, [String? message, Duration? duration]) {
    final msg = message ?? '';
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFEA580C),
      colorText: Colors.white,
      titleText: Text(
        title,
        style: GoogleFonts.battambang(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      messageText: msg.isNotEmpty
          ? Text(
              msg,
              style: GoogleFonts.battambang(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13,
              ),
            )
          : const SizedBox.shrink(),
      icon: const Icon(Icons.warning_rounded, color: Colors.white, size: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: const Color(0xFFEA580C).withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Show generic info alert at the top of the screen (Blue)
  static void info(String title, [String? message, Duration? duration]) {
    final msg = message ?? '';
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF2563EB),
      colorText: Colors.white,
      titleText: Text(
        title,
        style: GoogleFonts.battambang(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      messageText: msg.isNotEmpty
          ? Text(
              msg,
              style: GoogleFonts.battambang(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13,
              ),
            )
          : const SizedBox.shrink(),
      icon: const Icon(Icons.info_rounded, color: Colors.white, size: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
