import 'package:flutter/material.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart'; // Adjust path if needed

class BuildStatsGrid extends StatelessWidget {
  final int totalRooms;
  final int availableRooms;
  final int rentedRooms;
  final int pendingVisits;

  const BuildStatsGrid({
    super.key,
    this.totalRooms = 8,
    this.availableRooms = 5,
    this.rentedRooms = 3,
    this.pendingVisits = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      padding: const EdgeInsets.all(16),
      children: [
        // ១. បន្ទប់សរុប (Total Rooms Card)
        _buildStatCard(
          title: 'បន្ទប់សរុប',
          value: '$totalRooms',
          subtitle: 'បន្ទប់',
          icon: Icons.home_outlined,
          iconBgColor: AppColors.primary.withValues(alpha: 0.12),
          iconColor: AppColors.primary,
          valueColor: AppColors.neutral,
          subtitleColor: AppColors.neutral.withValues(alpha: 0.6),
        ),

        // ២. បន្ទប់ទំនេរ (Available Card)
        _buildStatCard(
          title: 'បន្ទប់ទំនេរ',
          value: '$availableRooms',
          subtitle: 'អាចជួលបាន',
          icon: Icons.check_circle_outline_rounded,
          iconBgColor: AppColors.secondary.withValues(alpha: 0.15),
          iconColor: AppColors.secondary,
          valueColor: AppColors.secondary,
          subtitleColor: AppColors.secondary,
        ),

        // ៣. បានជួលរួច (Rented Card)
        _buildStatCard(
          title: 'បានជួលរួច',
          value: '$rentedRooms',
          subtitle: 'មានអ្នកជួល',
          icon: Icons.key_outlined,
          iconBgColor: AppColors.primary.withValues(alpha: 0.12),
          iconColor: AppColors.primary,
          valueColor: AppColors.neutral,
          subtitleColor: AppColors.neutral.withValues(alpha: 0.6),
        ),

        // ៤. សំណើណាត់ជួប (Pending Visits Card)
        _buildStatCard(
          title: 'សំណើណាត់ជួប',
          value: '$pendingVisits',
          subtitle: 'សំណើថ្មី',
          icon: Icons.access_time_rounded,
          iconBgColor: AppColors.primary.withValues(alpha: 0.12),
          iconColor: AppColors.primary,
          valueColor: AppColors.primary,
          subtitleColor: AppColors.primary,
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
    required Color iconBgColor,
    required Color iconColor,
    required Color valueColor,
    required Color subtitleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface, iconBgColor.withValues(alpha: 0.25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Title and Circular Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral.withValues(alpha: 0.7),
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
                  child: Icon(icon, color: iconColor, size: 18),
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
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
