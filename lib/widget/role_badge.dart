import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable RoleBadge widget to display the user's role (owner, customer, admin)
/// next to their name with customized color palette, icon, and Khmer label.
class RoleBadge extends StatelessWidget {
  final String? role;
  final bool isCompact;
  final double? fontSize;

  const RoleBadge({
    super.key,
    required this.role,
    this.isCompact = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final cleanRole = (role ?? '').trim().toLowerCase();

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String label;

    switch (cleanRole) {
      case 'owner':
      case 'landlord':
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFBFDBFE);
        textColor = const Color(0xFF1D4ED8);
        icon = Icons.verified_rounded;
        label = isCompact ? 'ម្ចាស់' : 'ម្ចាស់បន្ទប់';
        break;
      case 'customer':
      case 'user':
      case 'tenant':
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFBBF7D0);
        textColor = const Color(0xFF15803D);
        icon = Icons.person_rounded;
        label = isCompact ? 'អ្នកជួល' : 'អ្នកជួល';
        break;
      case 'admin':
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFECACA);
        textColor = const Color(0xFFDC2626);
        icon = Icons.admin_panel_settings_rounded;
        label = isCompact ? 'Admin' : 'អ្នកគ្រប់គ្រង';
        break;
      default:
        bgColor = const Color(0xFFF8FAFC);
        borderColor = const Color(0xFFE2E8F0);
        textColor = const Color(0xFF475569);
        icon = Icons.badge_outlined;
        label = cleanRole.isEmpty ? 'USER' : cleanRole.toUpperCase();
    }

    final effectiveFontSize = fontSize ?? (isCompact ? 11.0 : 12.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 10,
        vertical: isCompact ? 2.5 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: effectiveFontSize + 2, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.battambang(
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
