import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum RoomStatusType { available, booked, rented }

/// Helper function to parse room status into RoomStatusType enum
RoomStatusType getRoomStatusType(
  String? status, {
  bool hasLatestBooking = false,
}) {
  final s = (status ?? '').trim().toUpperCase();

  // 1. Rented / Occupied always takes top priority
  if (s == 'OCCUPIED' ||
      s == 'RENTED' ||
      s.contains('OCCUPIED') ||
      s.contains('RENTED') ||
      s.contains('ជួល')) {
    return RoomStatusType.rented;
  }

  // 2. Booked / Reserved
  if (s == 'BOOKED' ||
      s == 'RESERVED' ||
      s.contains('BOOKED') ||
      s.contains('RESERVED') ||
      s.contains('កក់')) {
    return RoomStatusType.booked;
  }

  // 3. Explicitly Available (cleared/available status overrides old past bookings)
  if (s.contains('AVAILABLE') || s.contains('ទំនេរ')) {
    return RoomStatusType.available;
  }

  // 4. Fallback if room has an active latest booking
  if (hasLatestBooking) {
    return RoomStatusType.booked;
  }

  return RoomStatusType.available;
}

/// A badge widget showing "ទំនេរ", "ត្រូវបានកក់", or "ត្រូវបានជួល"
/// Designed to be overlaid on room images or placed alongside room info
class RoomStatusBadge extends StatelessWidget {
  final String? status;
  final bool hasLatestBooking;
  final bool isCompact;

  const RoomStatusBadge({
    super.key,
    required this.status,
    this.hasLatestBooking = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusType = getRoomStatusType(
      status,
      hasLatestBooking: hasLatestBooking,
    );

    final Color bgColor;
    final String label;
    final IconData icon;

    switch (statusType) {
      case RoomStatusType.available:
        bgColor = const Color(0xFF10B981); // Emerald Green
        label = 'ទំនេរ';
        icon = Icons.check_circle_outline_rounded;
        break;
      case RoomStatusType.booked:
        bgColor = const Color(0xFFF59E0B); // Amber / Warm Orange
        label = 'ត្រូវបានកក់';
        icon = Icons.lock_clock_rounded;
        break;
      case RoomStatusType.rented:
        bgColor = const Color(0xFF64748B); // Slate Grey
        label = 'ត្រូវបានជួល';
        icon = Icons.do_not_disturb_on_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 9,
        vertical: isCompact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: isCompact ? 11 : 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.battambang(
              color: Colors.white,
              fontSize: isCompact ? 10 : 11.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
