import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';
import 'package:roomdz_frontend/features/payment/data/models/payment_model.dart';
import 'package:roomdz_frontend/features/rooms/data/models/room_detail_model.dart';
import 'package:roomdz_frontend/core/database/database_service.dart';
import 'package:roomdz_frontend/features/payment/data/services/payment_service.dart';
import 'package:roomdz_frontend/core/utils/url_util.dart';
import 'package:roomdz_frontend/core/widgets/app_alert.dart';
import 'package:roomdz_frontend/core/widgets/modern_button_loader.dart';
import 'package:roomdz_frontend/core/widgets/room_status_badge.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Modal flow for Customer to Owner Direct Payment via Bakong KHQR
class BakongPaymentDialog {
  static void show({
    required BuildContext context,
    required Data room,
    VoidCallback? onPaymentCompleted,
  }) {
    // 0. Check if room is available for booking
    final statusType = getRoomStatusType(
      room.status,
      hasLatestBooking: room.latestBooking != null,
    );
    if (statusType != RoomStatusType.available) {
      _showRoomUnavailableAlert(context, room, statusType);
      return;
    }

    // 1. Check if Landlord has configured Bakong Account
    final landlord = room.landlord;
    final bakongId = landlord?.bakongAccountId?.trim();

    if (bakongId == null || bakongId.isEmpty) {
      _showNoBakongAlert(context, room);
      return;
    }

    // 2. Open payment flow sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BakongPaymentSheet(
        room: room,
        onPaymentCompleted: onPaymentCompleted,
      ),
    );
  }

  static void _showRoomUnavailableAlert(
    BuildContext context,
    Data room,
    RoomStatusType statusType,
  ) {
    final bool isBooked = statusType == RoomStatusType.booked;
    final String title = isBooked
        ? 'បន្ទប់ត្រូវបានកក់រួចហើយ'
        : 'បន្ទប់ត្រូវបានជួលរួចហើយ';
    final String desc = isBooked
        ? 'បន្ទប់ "${room.name}" ត្រូវបានអតិថិជនផ្សេងទៀតកក់ប្រាក់រួចរាល់ហើយ ដូច្នេះមិនអាចធ្វើការកក់ជាន់គ្នាបានទេ។ សូមពិនិត្យមើលបន្ទប់ទំនេរផ្សេងទៀត។'
        : 'បន្ទប់ "${room.name}" ត្រូវបានជួលរួចរាល់ហើយ មិនអាចធ្វើការកក់ប្រាក់បានទេ។ សូមពិនិត្យមើលបន្ទប់ទំនេរផ្សេងទៀត។';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isBooked
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isBooked
                    ? Icons.lock_clock_rounded
                    : Icons.do_not_disturb_on_rounded,
                color: isBooked
                    ? const Color(0xFFD97706)
                    : const Color(0xFFDC2626),
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.battambang(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isBooked
                      ? const Color(0xFF92400E)
                      : const Color(0xFF991B1B),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          desc,
          style: GoogleFonts.battambang(
            fontSize: 13,
            color: const Color(0xFF475569),
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'យល់ព្រម',
              style: GoogleFonts.battambang(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static void _showNoBakongAlert(BuildContext context, Data room) {
    final landlord = room.landlord;
    final phone = landlord?.phone ?? '';
    final telegram = landlord?.telegram ?? '';
    final urlUtil = UrlUtil();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFD97706),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'មិនទាន់មានគណនីបាគង',
                style: GoogleFonts.battambang(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'ម្ចាស់បន្ទប់ "${room.name}" មិនទាន់បានភ្ជាប់គណនី Bakong KHQR នៅក្នុងប្រព័ន្ធនៅឡើយទេ។\n\nសូមធ្វើការទំនាក់ទំនងទៅកាន់ម្ចាស់បន្ទប់ដោយផ្ទាល់តាមរយៈទូរស័ព្ទ ឬ Telegram ដើម្បីសាកសួរព័ត៌មាន និងបង់ប្រាក់។',
          style: GoogleFonts.battambang(
            fontSize: 13,
            color: const Color(0xFF475569),
            height: 1.5,
          ),
        ),
        actions: [
          if (telegram.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                final clean = telegram.replaceAll('@', '');
                urlUtil.open('https://t.me/$clean');
              },
              icon: const Icon(
                Icons.send_rounded,
                size: 16,
                color: Color(0xFF0284C7),
              ),
              label: Text(
                'Telegram',
                style: GoogleFonts.battambang(
                  color: const Color(0xFF0284C7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (phone.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                urlUtil.open('tel:$phone');
              },
              icon: const Icon(Icons.phone, size: 16, color: AppColors.primary),
              label: Text(
                'ទូរស័ព្ទផ្ទាល់',
                style: GoogleFonts.battambang(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFF475569),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('បិទ', style: GoogleFonts.battambang()),
          ),
        ],
      ),
    );
  }
}

class _BakongPaymentSheet extends StatefulWidget {
  final Data room;
  final VoidCallback? onPaymentCompleted;

  const _BakongPaymentSheet({required this.room, this.onPaymentCompleted});

  @override
  State<_BakongPaymentSheet> createState() => _BakongPaymentSheetState();
}

enum _PaymentStep { form, qr, success }

class _BakongPaymentSheetState extends State<_BakongPaymentSheet> {
  final PaymentService _paymentService = PaymentService();
  final UrlUtil _urlUtil = UrlUtil();

  _PaymentStep _step = _PaymentStep.form;

  // Form State
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  bool _isGenerating = false;
  bool _isChecking = false;

  // Amount selection: 'deposit' or 'full'
  String _paymentOption = 'deposit';
  late double _depositAmount;
  late double _fullAmount;

  // QR & Status State
  PaymentQrData? _qrData;
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 300; // 5 minutes
  bool _isBakongLimitReached = false;
  int _bakongRequestCount = 0;
  int _bakongRequestLimit = 100;

  // Success State
  PaymentCheckStatusData? _completedPayment;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();

    // Calculate amounts
    _fullAmount = widget.room.price.toDouble();
    if (widget.room.depositPrice != null && widget.room.depositPrice! > 0) {
      _depositAmount = widget.room.depositPrice!.toDouble();
    } else {
      // Default to full price if no custom deposit
      _depositAmount = _fullAmount;
    }

    _loadCurrentUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      final user = await DatabaseService.instance.getSavedUser();
      if (user != null && mounted) {
        setState(() {
          _nameCtrl.text = user.name;
          _phoneCtrl.text = user.phone ?? '';
        });
      }
    } catch (_) {}
  }

  double get _selectedAmount {
    return _paymentOption == 'deposit' ? _depositAmount : _fullAmount;
  }

  String get _paymentType {
    return _paymentOption == 'deposit' ? 'booking_deposit' : 'rent';
  }

  String get _selectedCurrency {
    if (_paymentOption == 'deposit' && widget.room.depositCurrency == 'KHR') {
      return 'KHR';
    }
    return 'USD';
  }

  String _formatPriceWithCurrency(double amt, String curr) {
    if (curr == 'KHR') {
      return '${amt.toInt()} ៛';
    }
    return '\$${_formatAmount(amt)}';
  }

  // --- Step 1: Create QR ---
  Future<void> _handleGenerateQr() async {
    if (_nameCtrl.text.trim().isEmpty) {
      AppAlert.error('កំហុស', 'សូមបញ្ចូលឈ្មោះរបស់អ្នក');
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      AppAlert.error('កំហុស', 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final res = await _paymentService.createQr(
        roomId: widget.room.id,
        amount: _selectedAmount,
        paymentType: _paymentType,
        currency: _selectedCurrency,
        customerName: _nameCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        description: _paymentOption == 'deposit'
            ? 'ប្រាក់កក់សម្រាប់ ${widget.room.name}'
            : 'ប្រាក់ថ្លៃបន្ទប់ពេញសម្រាប់ ${widget.room.name}',
      );

      if (res.success && res.data != null) {
        _qrData = res.data;

        // Setup timer
        _secondsRemaining = 300;
        _isBakongLimitReached = false;
        _startCountdown();
        // Do not auto-poll every 3 seconds to save Bakong daily quota (100 limit).
        // Only request Bakong when user clicks "ខ្ញុំបានបង់ប្រាក់រួចរាល់".

        setState(() {
          _step = _PaymentStep.qr;
          _isGenerating = false;
        });
      } else {
        throw Exception(res.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      AppAlert.error('បរាជ័យ', e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _pollingTimer?.cancel();
        AppAlert.warning('ផុតកំណត់', 'QR កូដនេះបានផុតកំណត់ហើយ សូមបង្កើតថ្មី');
      }
    });
  }

  /// Triggered when Bakong request quota hits 100 requests
  void _onBakongLimitReached(String? message, int count, [int limit = 100]) {
    _pollingTimer?.cancel();
    if (!mounted) return;

    setState(() {
      _isBakongLimitReached = true;
      _bakongRequestCount = count;
      _bakongRequestLimit = limit;
    });

    // Alert user via GetX Snackbar
    AppAlert.error(
      'Bakong Limit Reached ($count/$limit)',
      message != null && message.isNotEmpty
          ? message
          : 'សំណើទៅកាន់ Bakong ដល់កម្រិតកំណត់ $count/$limit ដងហើយ! Bakong បានផ្អាកទទួល request ជាបណ្ដោះអាសន្ន។',
      const Duration(seconds: 5),
    );
  }

  // Manual Check Button
  Future<void> _handleManualCheck() async {
    if (_qrData == null) return;

    if (_isBakongLimitReached) {
      AppAlert.warning(
        'Bakong Limit Reached',
        'ការស្នើសុំទៅកាន់ Bakong ដល់កម្រិតកំណត់ $_bakongRequestCount/$_bakongRequestLimit ដងហើយ! សូមព្យាយាមម្តងទៀតនៅពេលក្រោយ។',
      );
      return;
    }

    setState(() => _isChecking = true);

    try {
      final res = await _paymentService.checkStatus(_qrData!.paymentId);
      if (!mounted) return;

      setState(() {
        _bakongRequestCount = res.bakongRequestCount;
        _bakongRequestLimit = res.bakongRequestLimit;
      });

      if (res.isPaid) {
        _onPaymentSuccess(res.data);
      } else if (res.limitReached) {
        _onBakongLimitReached(
          res.message,
          res.bakongRequestCount,
          res.bakongRequestLimit,
        );
      } else {
        AppAlert.info(
          'ស្ថានភាពទូទាត់',
          'មិនទាន់ទទួលបានការបង់ប្រាក់នៅឡើយទេ។ សូមពិនិត្យមើលក្នុងកម្មវិធីធនាគាររបស់អ្នក។',
        );
      }
    } on BakongLimitException catch (e) {
      if (mounted) {
        _onBakongLimitReached(e.message, e.requestCount, e.requestLimit);
      }
    } catch (e) {
      AppAlert.error('កំហុស', e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _onPaymentSuccess(PaymentCheckStatusData? completedData) {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();

    setState(() {
      _completedPayment = completedData;
      _step = _PaymentStep.success;
    });

    widget.onPaymentCompleted?.call();
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatAmount(double amt) {
    return amt % 1 == 0 ? amt.toInt().toString() : amt.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),

            // Flexible content based on step
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case _PaymentStep.form:
        return _buildFormStep();
      case _PaymentStep.qr:
        return _buildQrStep();
      case _PaymentStep.success:
        return _buildSuccessStep();
    }
  }

  // ==========================================
  // STEP 1: FORM & SELECTION
  // ==========================================
  Widget _buildFormStep() {
    final landlord = widget.room.landlord;

    return Column(
      key: const ValueKey('step_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Close
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'កក់បន្ទប់តាម Bakong KHQR',
                  style: GoogleFonts.battambang(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Room Card Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    widget.room.image != null && widget.room.image!.isNotEmpty
                    ? Image.network(
                        widget.room.image!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.room.name,
                      style: GoogleFonts.battambang(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ម្ចាស់បន្ទប់៖ ${landlord?.name ?? "Landlord"}',
                      style: GoogleFonts.battambang(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: Color(0xFF0D9488),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Bakong ID: ${landlord?.bakongAccountId ?? ""}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D9488),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Deposit Amount Choice
        Text(
          'ជ្រើសរើសចំនួនទឹកប្រាក់បង់',
          style: GoogleFonts.battambang(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),

        // Option 1: Booking Deposit (Customized by Owner)
        _buildPaymentOptionTile(
          value: 'deposit',
          title: 'ប្រាក់កក់បន្ទប់ (Booking Deposit)',
          subtitle:
              widget.room.depositPrice != null && widget.room.depositPrice! > 0
              ? 'ម្ចាស់បន្ទប់បានកំណត់តម្លៃកក់៖ ${_formatPriceWithCurrency(_depositAmount, widget.room.depositCurrency)}'
              : 'កក់បន្ទប់មុនដើម្បីកុំឱ្យអ្នកផ្សេងយក',
          amount: _formatPriceWithCurrency(
            _depositAmount,
            widget.room.depositCurrency,
          ),
          isRecommended: true,
        ),

        const SizedBox(height: 10),

        // Option 2: Full Month Rent
        _buildPaymentOptionTile(
          value: 'full',
          title: 'បង់ថ្លៃបន្ទប់ពេញ (Full 1 Month Rent)',
          subtitle: 'បង់ថ្លៃឈ្នួលពេញ ១ ខែតែម្តង',
          amount: '\$${_formatAmount(_fullAmount)}',
          isRecommended: false,
        ),

        const SizedBox(height: 18),

        // Customer Details
        Text(
          'ព័ត៌មានអ្នកកក់បន្ទប់',
          style: GoogleFonts.battambang(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),

        TextField(
          controller: _nameCtrl,
          style: GoogleFonts.battambang(fontSize: 14),
          decoration: _buildInputDeco(
            label: 'ឈ្មោះរបស់អ្នក',
            hint: 'បញ្ចូលឈ្មោះពេញ',
            icon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.battambang(fontSize: 14),
          decoration: _buildInputDeco(
            label: 'លេខទូរស័ព្ទ',
            hint: 'ឧ. 012 345 678',
            icon: Icons.phone_outlined,
          ),
        ),

        const SizedBox(height: 22),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _handleGenerateQr,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary,
              disabledForegroundColor: Colors.white,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            child: ModernButtonContent(
              isLoading: _isGenerating,
              text:
                  'បន្តទៅស្កេនបង់ប្រាក់ (${_formatPriceWithCurrency(_selectedAmount, _selectedCurrency)})',
              loadingText: 'កំពុងបង្កើត KHQR',
              icon: Icons.qr_code_rounded,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPaymentOptionTile({
    required String value,
    required String title,
    required String subtitle,
    required String amount,
    required bool isRecommended,
  }) {
    final isSelected = _paymentOption == value;

    return InkWell(
      onTap: () => setState(() => _paymentOption = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF16A34A)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF16A34A)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.battambang(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ណែនាំ',
                            style: GoogleFonts.battambang(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.battambang(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 2: BAKONG KHQR DISPLAY & POLLING
  // ==========================================
  Widget _buildQrStep() {
    if (_qrData == null) return const SizedBox();

    return Column(
      key: const ValueKey('step_qr'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
              onPressed: () {
                _pollingTimer?.cancel();
                _countdownTimer?.cancel();
                setState(() => _step = _PaymentStep.form);
              },
            ),
            Text(
              'ស្កេនបង់ប្រាក់ KHQR',
              style: GoogleFonts.battambang(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                _pollingTimer?.cancel();
                _countdownTimer?.cancel();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Countdown Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _secondsRemaining > 60
                ? const Color(0xFFEFF6FF)
                : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 15,
                color: _secondsRemaining > 60
                    ? AppColors.primary
                    : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 6),
              Text(
                'សុពលភាព QR៖ ${_formatTimer(_secondsRemaining)}',
                style: GoogleFonts.battambang(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _secondsRemaining > 60
                      ? AppColors.primary
                      : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // --- AUTHENTIC KHQR CARD ---
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Red KHQR Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFE1251B), // Official Bakong KHQR Red
                  borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'KHQR',
                            style: TextStyle(
                              color: Color(0xFFE1251B),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Bakong Individual',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Merchant & Account info
                    Text(
                      _qrData!.merchantName,
                      style: GoogleFonts.battambang(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _qrData!.bakongAccountId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Amount Display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _qrData!.currency == 'KHR'
                                ? '${_qrData!.amount.toInt()} ៛'
                                : '\$${_qrData!.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _qrData!.currency,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // QR Code Widget (renders NBC EMVCo KHQR)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: _qrData!.qrString.isNotEmpty
                          ? QrImageView(
                              data: _qrData!.qrString,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                            )
                          : const SizedBox(
                              width: 200,
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                    ),

                    const SizedBox(height: 14),

                    // Bill Number
                    Text(
                      'វិក្កយបត្រ៖ ${_qrData!.billNumber}',
                      style: GoogleFonts.battambang(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Realtime Polling indicator / Bakong Limit Reached Alert
        if (_isBakongLimitReached)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ដល់កម្រិតកំណត់ Bakong ($_bakongRequestCount/$_bakongRequestLimit ដង)',
                        style: GoogleFonts.battambang(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bakong បានផ្អាកទទួលសំណើជាបណ្ដោះអាសន្ន។ ការពិនិត្យស្វ័យប្រវត្តិត្រូវបានបញ្ឈប់។',
                        style: GoogleFonts.battambang(
                          fontSize: 11,
                          color: const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'ស្កេនរួច សូមចុច «ខ្ញុំបានបង់ប្រាក់រួចរាល់» ខាងក្រោម',
                    style: GoogleFonts.battambang(
                      fontSize: 12,
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 18),

        // Action Buttons: Manual Check
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isChecking ? null : _handleManualCheck,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: ModernButtonContent(
              isLoading: _isChecking,
              text: 'ខ្ញុំបានបង់ប្រាក់រួចរាល់',
              loadingText: 'កំពុងផ្ទៀងផ្ទាត់',
              icon: Icons.check_circle_outline,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ==========================================
  // STEP 3: PAYMENT SUCCESS & E-RECEIPT
  // ==========================================
  Widget _buildSuccessStep() {
    final landlord = widget.room.landlord;
    final phone = landlord?.phone ?? '';
    final telegram = landlord?.telegram ?? '';

    return Column(
      key: const ValueKey('step_success'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),

        // Celebration Circle
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF16A34A),
              size: 52,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'ការបង់ប្រាក់បានជោគជ័យ!',
          style: GoogleFonts.battambang(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'ប្រាក់កក់របស់អ្នកត្រូវបានផ្ទេរចូលគណនីម្ចាស់បន្ទប់ដោយផ្ទាល់រួចរាល់ហើយ។',
          style: GoogleFonts.battambang(
            fontSize: 12.5,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // E-Receipt Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildReceiptRow('បន្ទប់', widget.room.name),
              const Divider(height: 20, color: Color(0xFFE2E8F0)),
              _buildReceiptRow('ម្ចាស់បន្ទប់', landlord?.name ?? 'Landlord'),
              const Divider(height: 20, color: Color(0xFFE2E8F0)),
              _buildReceiptRow(
                'ចំនួនទឹកប្រាក់',
                (_completedPayment?.currency ?? _selectedCurrency) == 'KHR'
                    ? '${(_completedPayment?.amount ?? _selectedAmount).toInt()} ៛ (KHR)'
                    : '\$${(_completedPayment?.amount ?? _selectedAmount).toStringAsFixed(2)} USD',
                isHighlight: true,
              ),
              const Divider(height: 20, color: Color(0xFFE2E8F0)),
              _buildReceiptRow(
                'លេខវិក្កយបត្រ',
                _completedPayment?.billNumber ?? (_qrData?.billNumber ?? '-'),
              ),
              if (_completedPayment?.bakongHash != null) ...[
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                _buildReceiptRow(
                  'Bakong Hash',
                  _completedPayment!.bakongHash!,
                  isTruncated: true,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Contact Landlord Action Buttons
        Text(
          'ទាក់ទងម្ចាស់បន្ទប់ដើម្បីបញ្ជាក់ការចូលនៅ',
          style: GoogleFonts.battambang(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            if (telegram.isNotEmpty) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final clean = telegram.replaceAll('@', '');
                    _urlUtil.open('https://t.me/$clean');
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text('Telegram', style: GoogleFonts.battambang()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            if (phone.isNotEmpty)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _urlUtil.open('tel:$phone'),
                  icon: const Icon(Icons.phone, size: 16),
                  label: Text('ខលផ្ទាល់', style: GoogleFonts.battambang()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Finish button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'ត្រឡប់ទៅមើលបន្ទប់វិញ',
              style: GoogleFonts.battambang(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isTruncated = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.battambang(
            fontSize: 12.5,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.battambang(
              fontSize: isHighlight ? 15 : 12.5,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.end,
            overflow: isTruncated ? TextOverflow.ellipsis : TextOverflow.clip,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDeco({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.battambang(
        color: const Color(0xFF64748B),
        fontSize: 13,
      ),
      hintStyle: GoogleFonts.battambang(
        color: const Color(0xFF94A3B8),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade200,
      child: const Icon(Icons.hotel_rounded, color: Colors.grey, size: 28),
    );
  }
}
