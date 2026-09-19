import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/model/view_quest_model.dart';
import 'package:roomdz_frontend/service/payment/payment_service.dart';
import 'package:roomdz_frontend/service/viewing_request_service.dart';
import 'package:roomdz_frontend/util/url_util.dart';

enum _NotificationTab { all, bookings, viewings }

class OwnerNotificationScreen extends StatefulWidget {
  const OwnerNotificationScreen({super.key});

  @override
  State<OwnerNotificationScreen> createState() =>
      _OwnerNotificationScreenState();
}

class _OwnerNotificationScreenState extends State<OwnerNotificationScreen> {
  final ViewingRequestService _viewingService = ViewingRequestService();
  final PaymentService _paymentService = PaymentService();
  final UrlUtil _urlUtil = UrlUtil();

  _NotificationTab _selectedTab = _NotificationTab.all;

  List<ViewingRequestModel> _viewingRequests = [];
  List<Map<String, dynamic>> _paymentBookings = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _viewingService.getViewingRequests().catchError(
          (_) => <ViewingRequestModel>[],
        ),
        _paymentService
            .getPayments(myRoomsOnly: true)
            .catchError((_) => <dynamic>[]),
      ]);

      if (!mounted) return;

      final requests = results[0] as List<ViewingRequestModel>;
      final rawPayments = results[1];

      final payments = rawPayments
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      setState(() {
        _viewingRequests = requests;
        _paymentBookings = payments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  int get _bookingCount => _paymentBookings.length;
  int get _viewingCount => _viewingRequests.length;
  int get _totalCount => _bookingCount + _viewingCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'ការជូនដំណឹងម្ចាស់បន្ទប់',
          style: GoogleFonts.battambang(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchNotifications,
            tooltip: 'ផ្ទុកឡើងវិញ',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),

          // Body Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchNotifications,
              color: AppColors.primary,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _buildTabPill(
            tab: _NotificationTab.all,
            title: 'ទាំងអស់',
            count: _totalCount,
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            tab: _NotificationTab.bookings,
            title: 'ការកក់ & បង់ប្រាក់',
            count: _bookingCount,
            badgeColor: const Color(0xFF16A34A),
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            tab: _NotificationTab.viewings,
            title: 'សំណើសុំមើល',
            count: _viewingCount,
            badgeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required _NotificationTab tab,
    required String title,
    required int count,
    Color? badgeColor,
  }) {
    final isSelected = _selectedTab == tab;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = tab),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEFF6FF)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.battambang(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFF475569),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (badgeColor ?? AppColors.primary)
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 54, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.battambang(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'ព្យាយាមម្តងទៀត',
                      style: GoogleFonts.battambang(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Build unified items list
    final List<Widget> items = [];

    if (_selectedTab == _NotificationTab.all ||
        _selectedTab == _NotificationTab.bookings) {
      for (final payment in _paymentBookings) {
        items.add(_buildPaymentNotificationCard(payment));
      }
    }

    if (_selectedTab == _NotificationTab.all ||
        _selectedTab == _NotificationTab.viewings) {
      for (final viewing in _viewingRequests) {
        items.add(_buildViewingNotificationCard(viewing));
      }
    }

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 14),
                Text(
                  'មិនមានការជូនដំណឹងនៅឡើយទេ',
                  style: GoogleFonts.battambang(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'រាល់ការកក់បន្ទប់ និងការបង់ប្រាក់ នឹងបង្ហាញនៅទីនេះ',
                  style: GoogleFonts.battambang(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => items[index],
    );
  }

  // ==========================================
  // CARD 1: BOOKING & PAYMENT NOTIFICATION
  // ==========================================
  Widget _buildPaymentNotificationCard(Map<String, dynamic> payment) {
    final customerName = payment['customer_name']?.toString() ?? 'អតិថិជន';
    final customerPhone = payment['customer_phone']?.toString() ?? '';
    final amount = payment['amount'] is num
        ? (payment['amount'] as num).toDouble()
        : (double.tryParse(payment['amount']?.toString() ?? '0') ?? 0.0);
    final status = payment['status']?.toString() ?? 'completed';
    final billNumber = payment['bill_number']?.toString() ?? '';
    final paidAt =
        payment['paid_at']?.toString() ??
        payment['created_at']?.toString() ??
        '';

    final roomMap = payment['room'] is Map
        ? Map<String, dynamic>.from(payment['room'])
        : null;
    final roomName = roomMap?['name']?.toString() ?? 'បន្ទប់ជួល';

    final userMap = payment['user'] is Map
        ? Map<String, dynamic>.from(payment['user'])
        : null;
    final telegram = userMap?['telegram']?.toString() ?? '';

    final isCompleted = status.toLowerCase() == 'completed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFE2E8F0),
          width: isCompleted ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? const Color(0xFF16A34A).withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Badge + Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.hourglass_top_rounded,
                    color: isCompleted
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD97706),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isCompleted
                                ? 'បានបង់ប្រាក់កក់ KHQR'
                                : 'កំពុងរង់ចាំបង់ប្រាក់',
                            style: GoogleFonts.battambang(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'បន្ទប់៖ $roomName',
                      style: GoogleFonts.battambang(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Customer Info Row
          Row(
            children: [
              const Icon(Icons.person_pin, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                'អ្នកកក់៖ ',
                style: GoogleFonts.battambang(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              Expanded(
                child: Text(
                  customerName,
                  style: GoogleFonts.battambang(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (customerPhone.isNotEmpty) ...[
                const Icon(
                  Icons.phone_android,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  customerPhone,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          // Bill Number & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'វិក្កយបត្រ៖ $billNumber',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              if (paidAt.isNotEmpty)
                Text(
                  paidAt.length >= 16
                      ? paidAt.substring(0, 16).replaceAll('T', ' ')
                      : paidAt,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Direct Action Buttons for Landlord
          Row(
            children: [
              if (customerPhone.isNotEmpty)
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () => _urlUtil.open('tel:$customerPhone'),
                      icon: const Icon(Icons.phone, size: 15),
                      label: Text(
                        'ខលផ្ទាល់',
                        style: GoogleFonts.battambang(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
              if (telegram.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final clean = telegram.replaceAll('@', '');
                        _urlUtil.open('https://t.me/$clean');
                      },
                      icon: const Icon(Icons.send_rounded, size: 14),
                      label: Text(
                        'Telegram',
                        style: GoogleFonts.battambang(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 2: VIEWING REQUEST NOTIFICATION
  // ==========================================
  Widget _buildViewingNotificationCard(ViewingRequestModel req) {
    final customerName = req.name ?? req.requester?.name ?? 'អតិថិជន';
    final customerPhone = req.phone ?? req.requester?.phone ?? '';
    final roomName = req.room?.name ?? 'បន្ទប់';
    final preferredDate = req.preferredDate ?? '';
    final preferredTime = req.preferredTime ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.calendar_month,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'សំណើសុំមើលបន្ទប់',
                            style: GoogleFonts.battambang(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          req.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: req.status == 'confirmed'
                                ? const Color(0xFF16A34A)
                                : (req.status == 'rejected'
                                      ? Colors.red
                                      : Colors.orange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'បន្ទប់៖ $roomName',
                      style: GoogleFonts.battambang(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            '$customerName បានស្នើសុំមើលបន្ទប់នៅថ្ងៃ $preferredDate ម៉ោង $preferredTime',
            style: GoogleFonts.battambang(
              fontSize: 12.5,
              color: const Color(0xFF475569),
            ),
          ),

          if (customerPhone.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton.icon(
                onPressed: () => _urlUtil.open('tel:$customerPhone'),
                icon: const Icon(Icons.phone, size: 15),
                label: Text(
                  'ខលទៅកាន់ $customerName ($customerPhone)',
                  style: GoogleFonts.battambang(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
