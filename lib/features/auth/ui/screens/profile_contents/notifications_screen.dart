import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';
import 'package:roomdz_frontend/core/widgets/app_alert.dart';
import 'package:roomdz_frontend/features/auth/ui/controllers/notification_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _notifCtrl = Get.put(NotificationController());
  String _selectedFilter = 'all'; // 'all', 'unread', 'request', 'payment'

  List<NotificationItem> get _filteredNotifications {
    final list = _notifCtrl.notifications;
    switch (_selectedFilter) {
      case 'unread':
        return list.where((n) => !n.isRead).toList();
      case 'request':
        return list.where((n) => n.type == NotificationType.request).toList();
      case 'payment':
        return list.where((n) => n.type == NotificationType.payment).toList();
      default:
        return list;
    }
  }

  void _markAllAsRead() {
    _notifCtrl.markAllAsRead();
    AppAlert.success('ជោគជ័យ', 'បានសម្គាល់ការជូនដំណឹងទាំងអស់ថាបានអាន');
  }

  void _markItemAsRead(NotificationItem item) {
    _notifCtrl.markItemAsRead(item);
  }

  void _deleteNotification(String id) {
    _notifCtrl.deleteNotification(id);
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.request:
        return Icons.calendar_today_rounded;
      case NotificationType.payment:
        return Icons.account_balance_wallet_rounded;
      case NotificationType.alert:
        return Icons.home_work_rounded;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.request:
        return const Color(0xFF2563EB);
      case NotificationType.payment:
        return const Color(0xFF10B981);
      case NotificationType.alert:
        return const Color(0xFFF59E0B);
      case NotificationType.system:
        return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.neutral,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'ការជូនដំណឹង',
          style: GoogleFonts.battambang(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.neutral,
          ),
        ),
        actions: [
          // Text button without checkmark icon
          Obx(() {
            if (_notifCtrl.unreadCount.value > 0) {
              return TextButton(
                onPressed: _markAllAsRead,
                child: Text(
                  'អានទាំងអស់',
                  style: GoogleFonts.battambang(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: [
                    _buildFilterChip(
                      'all',
                      'ទាំងអស់ (${_notifCtrl.notifications.length})',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'unread',
                      'មិនទាន់អាន (${_notifCtrl.unreadCount.value})',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('request', 'សំណើណាត់ជួប'),
                    const SizedBox(width: 8),
                    _buildFilterChip('payment', 'ការទូទាត់'),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Notifications List or Loading / Empty state
          Expanded(
            child: Obx(() {
              if (_notifCtrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (_notifCtrl.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _notifCtrl.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.battambang(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _notifCtrl.fetchNotifications,
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          'ព្យាយាមម្តងទៀត',
                          style: GoogleFonts.battambang(),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final filtered = _filteredNotifications;
              if (filtered.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: _notifCtrl.fetchNotifications,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final color = _getTypeColor(item.type);
                    final icon = _getTypeIcon(item.type);

                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      onDismissed: (_) => _deleteNotification(item.id),
                      child: InkWell(
                        onTap: () {
                          _markItemAsRead(item);
                          _showDetailDialog(item);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.isRead
                                ? Colors.white
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: item.isRead
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFFBFDBFE),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const SizedBox(width: 12),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: GoogleFonts.battambang(
                                              fontWeight: item.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.bold,
                                              fontSize: 14,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        if (!item.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.only(
                                              left: 6,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.battambang(
                                        fontSize: 13,
                                        color: const Color(0xFF64748B),
                                        height: 1.4,
                                      ),
                                    ),
                                    if (item.time.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        item.time,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.battambang(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'មិនមានការជូនដំណឹងទេ',
              style: GoogleFonts.battambang(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'រាល់ការជូនដំណឹងថ្មីៗអំពីបន្ទប់ និងការណាត់ជួបនឹងបង្ហាញនៅទីនេះ',
              textAlign: TextAlign.center,
              style: GoogleFonts.battambang(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(NotificationItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getTypeColor(item.type).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(item.type),
                color: _getTypeColor(item.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: GoogleFonts.battambang(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.message,
              style: GoogleFonts.battambang(
                fontSize: 14,
                color: const Color(0xFF334155),
                height: 1.5,
              ),
            ),
            if (item.time.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'បិទ',
              style: GoogleFonts.battambang(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
