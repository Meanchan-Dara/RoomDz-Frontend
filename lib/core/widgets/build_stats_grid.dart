import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildStatsGrid extends StatelessWidget {
  final int totalRooms;
  final int availableRooms;
  final int rentedRooms;
  final int pendingVisits;

  const BuildStatsGrid({
    super.key,
    this.totalRooms = 0,
    this.availableRooms = 0,
    this.rentedRooms = 0,
    this.pendingVisits = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.42,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // ១. បន្ទប់សរុប (Total Rooms Card - Blue)
        _buildStatCard(
          title: 'បន្ទប់សរុប',
          value: '$totalRooms',
          subtitle: 'បន្ទប់',
          icon: Icons.meeting_room_rounded,
          accentColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFEFF6FF),
          cardBgColor: Colors.white,
          borderColor: const Color(0xFFDBEAFE),
          valueColor: const Color(0xFF0F172A),
          subtitleColor: const Color(0xFF64748B),
        ),

        // ២. បន្ទប់ទំនេរ (Available Card - Emerald Green)
        _buildStatCard(
          title: 'បន្ទប់ទំនេរ',
          value: '$availableRooms',
          subtitle: 'អាចជួលបាន',
          icon: Icons.check_circle_rounded,
          accentColor: const Color(0xFF059669),
          iconBgColor: const Color(0xFFECFDF5),
          cardBgColor: Colors.white,
          borderColor: const Color(0xFFA7F3D0),
          valueColor: const Color(0xFF059669),
          subtitleColor: const Color(0xFF047857),
        ),

        // ៣. បានជួលរួច (Rented Card - Warm Orange)
        _buildStatCard(
          title: 'បានជួលរួច',
          value: '$rentedRooms',
          subtitle: 'មានអ្នកជួល',
          icon: Icons.vpn_key_rounded,
          accentColor: const Color(0xFFEA580C),
          iconBgColor: const Color(0xFFFFF7ED),
          cardBgColor: Colors.white,
          borderColor: const Color(0xFFFED7AA),
          valueColor: const Color(0xFFC2410C),
          subtitleColor: const Color(0xFF9A3412),
        ),

        // ៤. សំណើណាត់ជួប (Pending Visits Card - Indigo/Purple)
        _buildStatCard(
          title: 'សំណើណាត់ជួប',
          value: '$pendingVisits',
          subtitle: 'សំណើថ្មី',
          icon: Icons.calendar_month_rounded,
          accentColor: const Color(0xFF7C3AED),
          iconBgColor: const Color(0xFFF5F3FF),
          cardBgColor: Colors.white,
          borderColor: const Color(0xFFDDD6FE),
          valueColor: const Color(0xFF6D28D9),
          subtitleColor: const Color(0xFF5B21B6),
        ),
      ],
    );
  }

  /// Reusable Single Stat Card Helper Method
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color iconBgColor,
    required Color cardBgColor,
    required Color borderColor,
    required Color valueColor,
    required Color subtitleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Title and Circular Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.battambang(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 19),
                ),
              ],
            ),

            // Bottom Row: Value Number & Subtitle Text
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.battambang(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.battambang(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
