import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/model/view_quest_model.dart';
import 'package:roomdz_frontend/service/viewing_request_service.dart';

class OwnerNotificationScreen extends StatefulWidget {
  const OwnerNotificationScreen({super.key});

  @override
  State<OwnerNotificationScreen> createState() =>
      _OwnerNotificationScreenState();
}

class _OwnerNotificationScreenState extends State<OwnerNotificationScreen> {
  final ViewingRequestService _service = ViewingRequestService();

  List<ViewingRequestModel> _notifications = [];
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
      final requests = await _service.getViewingRequests();
      if (!mounted) return;
      setState(() {
        _notifications = requests;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'ការជូនដំណឹង',
          style: GoogleFonts.battambang(
            color: AppColors.neutral,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: AppColors.primary,
        child: _buildBody(),
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
                    ),
                    child: Text(
                      'ព្យាយាមម្តងទៀត',
                      style: GoogleFonts.battambang(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
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
                  'មិនមានការជូនដំណឹងថ្មីទេ',
                  style: GoogleFonts.battambang(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'រាល់ដំណឹងសំខាន់ៗ នឹងបង្ហាញនៅទីនេះ',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _notifications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final req = _notifications[index];
        final customerName = req.name ?? req.requester?.name ?? 'អតិថិជន';
        final roomName = req.room?.name ?? 'បន្ទប់';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'សំណើមើលបន្ទប់ថ្មី',
                      style: GoogleFonts.battambang(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$customerName បានផ្ញើសំណើសុំមើលបន្ទប់ "$roomName"',
                      style: GoogleFonts.battambang(
                        fontSize: 13,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    if (req.createdAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        req.createdAt!.substring(0, 10),
                        style: GoogleFonts.battambang(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
