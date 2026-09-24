import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:roomdz_frontend/features/payment/data/services/payment_service.dart';
import 'package:roomdz_frontend/features/rooms/data/models/room_model.dart';
import 'package:roomdz_frontend/features/rooms/data/models/view_request_model.dart';
import 'package:roomdz_frontend/features/rooms/data/services/room_service.dart';
import 'package:roomdz_frontend/features/rooms/data/services/viewing_request_service.dart';

enum NotificationType { request, payment, alert, system }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final DateTime? timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.timestamp,
    this.isRead = false,
  });
}

class NotificationController extends GetxController {
  final ViewingRequestService _viewingService = ViewingRequestService();
  final PaymentService _paymentService = PaymentService();
  final RoomServer _roomService = RoomServer();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _readKey = 'customer_notifications_read';
  static const String _deletedKey = 'customer_notifications_deleted';

  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Set<String> _readIds = {};
  Set<String> _deletedIds = {};

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Load stored read and deleted sets
      final storedRead = await _loadStoredSet(_readKey);
      final storedDeleted = await _loadStoredSet(_deletedKey);
      _readIds = storedRead;
      _deletedIds = storedDeleted;

      // 2. Fetch real data from backend concurrently
      final results = await Future.wait([
        _viewingService.getMyViewingRequests().catchError(
          (_) => <ViewingRequestModel>[],
        ),
        _paymentService.getPayments().catchError((_) => <dynamic>[]),
        _roomService.getRooms().catchError((_) => RoomModel(data: [])),
      ]);

      final myRequests = results[0] as List<ViewingRequestModel>;
      final rawPayments = results[1] as List<dynamic>;
      final roomModel = results[2] as RoomModel;
      final recentRooms = roomModel.data;

      final List<NotificationItem> items = [];

      // A. Build Viewing Request notifications
      for (final req in myRequests) {
        final id = 'vr_${req.id}';
        if (_deletedIds.contains(id)) continue;

        String title;
        String message;
        final roomName = req.room?.name ?? 'បន្ទប់ជួល';
        final status = req.status.toLowerCase();

        if (status == 'confirmed') {
          title = 'សំណើណាត់ជួបត្រូវបានបញ្ជាក់! 🎉';
          final dateStr =
              (req.preferredDate != null && req.preferredDate!.isNotEmpty)
              ? ' នៅថ្ងៃ ${req.preferredDate}'
              : '';
          final timeStr =
              (req.preferredTime != null && req.preferredTime!.isNotEmpty)
              ? ' វេលាម៉ោង ${req.preferredTime}'
              : '';
          message =
              'ម្ចាស់បន្ទប់បានយល់ព្រមលើសំណើណាត់ជួបមើល "$roomName"$dateStr$timeStr។';
        } else if (status == 'rejected') {
          title = 'សំណើណាត់ជួបត្រូវបានបដិសេធ';
          message =
              'ម្ចាស់បន្ទប់មិនអាចទទួលការណាត់ជួបមើល "$roomName" បានទេនៅពេលនេះ។';
        } else if (status == 'cancelled') {
          title = 'សំណើណាត់ជួបត្រូវបានបោះបង់';
          message = 'អ្នកបានបោះបង់សំណើណាត់ជួបមើលបន្ទប់ "$roomName" រួចហើយ។';
        } else {
          title = 'សំណើណាត់ជួបកំពុងរង់ចាំការបញ្ជាក់';
          message =
              'សំណើណាត់ជួបមើល "$roomName" ត្រូវបានផ្ញើជូនម្ចាស់បន្ទប់ សូមរង់ចាំការឆ្លើយតប។';
        }

        DateTime? dt;
        if (req.updatedAt != null && req.updatedAt!.isNotEmpty) {
          dt = DateTime.tryParse(req.updatedAt!);
        } else if (req.createdAt != null && req.createdAt!.isNotEmpty) {
          dt = DateTime.tryParse(req.createdAt!);
        }

        items.add(
          NotificationItem(
            id: id,
            title: title,
            message: message,
            time: _formatTimeAgo(dt),
            type: NotificationType.request,
            timestamp: dt,
            isRead: _readIds.contains(id),
          ),
        );
      }

      // B. Build Payment notifications
      for (final p in rawPayments) {
        if (p is! Map) continue;
        final map = Map<String, dynamic>.from(p);
        final id = 'pay_${map['id'] ?? map['bill_number']}';
        if (_deletedIds.contains(id)) continue;

        final status = (map['status'] ?? '').toString().toLowerCase();
        final amount = map['amount']?.toString() ?? '0';
        final roomName = map['room']?['name'] ?? 'បន្ទប់ជួល';
        final billNumber = (map['bill_number'] ?? '').toString();

        String title;
        String message;

        if (status == 'completed') {
          title = 'ការទូទាត់ប្រាក់កក់ទទួលបានជោគជ័យ! ✅';
          message =
              'ការទូទាត់ប្រាក់កក់ចំនួន \$$amount តាមរយៈ Bakong KHQR សម្រាប់បន្ទប់ "$roomName" ត្រូវបានផ្ទៀងផ្ទាត់ដោយជោគជ័យ។'
              '${billNumber.isNotEmpty ? ' (វិក្កយបត្រ: $billNumber)' : ''}';
        } else if (status == 'expired') {
          title = 'QR កូដទូទាត់បានផុតកំណត់';
          message =
              'QR កូដទូទាត់ប្រាក់កក់ \$$amount សម្រាប់បន្ទប់ "$roomName" បានផុតកំណត់។';
        } else {
          title = 'ការទូទាត់កំពុងរង់ចាំការផ្ទៀងផ្ទាត់';
          message =
              'ប្រតិបត្តិការទូទាត់ \$$amount សម្រាប់បន្ទប់ "$roomName" កំពុងរង់ចាំការផ្ទៀងផ្ទាត់ពីបាគង។';
        }

        DateTime? dt;
        final paidAtStr = map['paid_at']?.toString();
        final createdAtStr = map['created_at']?.toString();
        if (paidAtStr != null && paidAtStr.isNotEmpty) {
          dt = DateTime.tryParse(paidAtStr);
        } else if (createdAtStr != null && createdAtStr.isNotEmpty) {
          dt = DateTime.tryParse(createdAtStr);
        }

        items.add(
          NotificationItem(
            id: id,
            title: title,
            message: message,
            time: _formatTimeAgo(dt),
            type: NotificationType.payment,
            timestamp: dt,
            isRead: _readIds.contains(id),
          ),
        );
      }

      // C. Build Room Alerts (top 3 newly added rooms)
      if (recentRooms.isNotEmpty) {
        final recentList = recentRooms.take(3);
        for (final r in recentList) {
          final roomId = r.id;
          final id = 'room_new_$roomId';
          if (_deletedIds.contains(id)) continue;

          final roomName = r.name.isNotEmpty ? r.name : 'បន្ទប់ជួលថ្មី';
          final price = r.price.toString();
          final address = r.address.isNotEmpty ? ' នៅក្នុង${r.address}' : '';

          items.add(
            NotificationItem(
              id: id,
              title: 'បន្ទប់ថ្មីទើបតែត្រូវបានបង្ហោះ! 🏠',
              message:
                  'មានបន្ទប់ជួលថ្មីមួយ "$roomName" តម្លៃ \$$price/ខែ$address ទើបតែត្រូវបានបង្ហោះដាក់ជួល។',
              time: 'ថ្មីៗ',
              type: NotificationType.alert,
              timestamp: DateTime.now(),
              isRead: _readIds.contains(id),
            ),
          );
        }
      }

      // Sort items: newest timestamps first
      items.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return b.timestamp!.compareTo(a.timestamp!);
      });

      notifications.assignAll(items);
      unreadCount.value = items.where((n) => !n.isRead).length;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      isLoading.value = false;
    }
  }

  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead = true;
      _readIds.add(n.id);
    }
    unreadCount.value = 0;
    notifications.refresh();
    _saveStoredSet(_readKey, _readIds);
  }

  void markItemAsRead(NotificationItem item) {
    if (!item.isRead) {
      item.isRead = true;
      _readIds.add(item.id);
      unreadCount.value = notifications.where((n) => !n.isRead).length;
      notifications.refresh();
      _saveStoredSet(_readKey, _readIds);
    }
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    _deletedIds.add(id);
    unreadCount.value = notifications.where((n) => !n.isRead).length;
    notifications.refresh();
    _saveStoredSet(_deletedKey, _deletedIds);
  }

  Future<Set<String>> _loadStoredSet(String key) async {
    try {
      final raw = await _storage.read(key: key);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toSet();
        }
      }
    } catch (_) {}
    return <String>{};
  }

  Future<void> _saveStoredSet(String key, Set<String> set) async {
    try {
      await _storage.write(key: key, value: jsonEncode(set.toList()));
    } catch (_) {}
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'ទើបតែឥឡូវនេះ';
    if (diff.inMinutes < 60) return '${diff.inMinutes} នាទីមុន';
    if (diff.inHours < 24) return '${diff.inHours} ម៉ោងមុន';
    if (diff.inDays == 1) return 'ម្សិលមិញ';
    if (diff.inDays < 7) return '${diff.inDays} ថ្ងៃមុន';
    return '${date.day}/${date.month}/${date.year}';
  }
}
