import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';

enum NotificationType { request, payment, alert, system }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all'; // 'all', 'unread', 'request', 'payment'

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'សំណើណាត់ជួបត្រូវបានបញ្ជាក់!',
      message:
          'ម្ចាស់បន្ទប់បានយល់ព្រមលើសំណើណាត់ជួបមើលបន្ទប់ "Studio Deluxe #302" នៅថ្ងៃស្អែកវេលាម៉ោង 2:00 រសៀល។',
      time: '10 នាទីមុន',
      type: NotificationType.request,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'បន្ទប់ថ្មីត្រូវនឹងចំណូលចិត្តរបស់អ្នក',
      message:
          'មានបន្ទប់ជួលថ្មីមួយតម្លៃ \$120/ខែ នៅក្នុងខណ្ឌទួលគោក ទើបតែត្រូវបានបង្ហោះ។',
      time: '2 ម៉ោងមុន',
      type: NotificationType.alert,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'ការទូទាត់ប្រាក់កក់ទទួលបានជោគជ័យ',
      message:
          'ការទូទាត់ប្រាក់កក់ចំនួន \$150.00 តាមរយៈ Bakong KHQR ត្រូវបានផ្ទៀងផ្ទាត់ដោយជោគជ័យ។',
      time: 'ម្សិលមិញ',
      type: NotificationType.payment,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'រំលឹកការណាត់ជួបនៅថ្ងៃស្អែក',
      message:
          'សូមកុំភ្លេចការណាត់ជួបមើលបន្ទប់ "Modern Studio Room" របស់អ្នកនៅថ្ងៃស្អែកវេលាម៉ោង 10:30 ព្រឹក។',
      time: '2 ថ្ងៃមុន',
      type: NotificationType.request,
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'ការធ្វើបច្ចុប្បន្នភាពប្រព័ន្ធ RoomDz v1.0.2',
      message:
          'យើងបានបន្ថែមមុខងារថ្មីៗ និងបង្កើនល្បឿននៃការស្វែងរកបន្ទប់ជួលឱ្យកាន់តែប្រសើរឡើង។',
      time: '5 ថ្ងៃមុន',
      type: NotificationType.system,
      isRead: true,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'request':
        return _notifications
            .where((n) => n.type == NotificationType.request)
            .toList();
      case 'payment':
        return _notifications
            .where((n) => n.type == NotificationType.payment)
            .toList();
      default:
        return _notifications;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    Get.snackbar(
      'ជោគជ័យ',
      'បានសម្គាល់ការជូនដំណឹងទាំងអស់ថាបានអាន',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
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
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(
                Icons.done_all_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                'អានទាំងអស់',
                style: GoogleFonts.battambang(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
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
              child: Row(
                children: [
                  _buildFilterChip('all', 'ទាំងអស់ (${_notifications.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('unread', 'មិនទាន់អាន ($_unreadCount)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('request', 'សំណើណាត់ជួប'),
                  const SizedBox(width: 8),
                  _buildFilterChip('payment', 'ការទូទាត់'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 600));
                      setState(() {});
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: _filteredNotifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _filteredNotifications[index];
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
                              setState(() {
                                item.isRead = true;
                              });
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  color: const Color(
                                                    0xFF0F172A,
                                                  ),
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                item.time,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ),
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
