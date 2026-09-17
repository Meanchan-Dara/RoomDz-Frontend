import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/model/view_quest_model.dart';
import 'package:roomdz_frontend/service/viewing_request_service.dart';
import 'package:roomdz_frontend/widget/role_badge.dart';

class ViewingRequestScreen extends StatefulWidget {
  const ViewingRequestScreen({super.key});

  @override
  State<ViewingRequestScreen> createState() => _ViewingRequestScreenState();
}

class _ViewingRequestScreenState extends State<ViewingRequestScreen> {
  final ViewingRequestService _service = ViewingRequestService();

  List<ViewingRequestModel> _allRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _actionId;
  String _selectedFilter = 'all'; // all, pending, confirmed, rejected

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await _service.getViewingRequests();
      if (!mounted) return;
      setState(() {
        _allRequests = requests;
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

  Future<void> _handleConfirm(int id) async {
    setState(() => _actionId = id);
    try {
      await _service.confirmViewingRequest(id);
      Get.snackbar('ជោគជ័យ', 'បានយល់ព្រមសំណើររួចរាល់');
      await _fetchRequests();
    } catch (e) {
      Get.snackbar('បរាជ័យ', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _actionId = null);
    }
  }

  Future<void> _handleReject(int id) async {
    setState(() => _actionId = id);
    try {
      await _service.rejectViewingRequest(id);
      Get.snackbar('ជោគជ័យ', 'បានបដិសេធសំណើររួចរាល់');
      await _fetchRequests();
    } catch (e) {
      Get.snackbar('បរាជ័យ', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _actionId = null);
    }
  }

  List<ViewingRequestModel> get _filteredRequests {
    if (_selectedFilter == 'all') return _allRequests;
    return _allRequests
        .where((r) => r.status.toLowerCase() == _selectedFilter)
        .toList();
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
          'សំណើមើលបន្ទប់',
          style: GoogleFonts.battambang(
            color: AppColors.neutral,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('ទាំងអស់', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('រង់ចាំ', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('បានយល់ព្រម', 'confirmed'),
                const SizedBox(width: 8),
                _buildFilterChip('បានបដិសេធ', 'rejected'),
              ],
            ),
          ),

          // Content body
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchRequests,
              color: AppColors.primary,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.battambang(
          color: isSelected ? Colors.white : AppColors.neutral,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
      ),
      onSelected: (_) => setState(() => _selectedFilter = value),
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
                    style: GoogleFonts.battambang(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchRequests,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

    final requests = _filteredRequests;
    if (requests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 14),
                Text(
                  'មិនមានសំណើមើលបន្ទប់ទេ',
                  style: GoogleFonts.battambang(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'រាល់សំណើមើលបន្ទប់ពីអតិថិជន នឹងបង្ហាញនៅទីនេះ',
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
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = requests[index];
        final isProcessing = _actionId == req.id;
        final statusLower = req.status.toLowerCase();

        Color statusBg;
        Color statusColor;
        String statusText;

        if (statusLower == 'confirmed') {
          statusBg = const Color(0xFFDCFCE7);
          statusColor = const Color(0xFF16A34A);
          statusText = 'បានយល់ព្រម';
        } else if (statusLower == 'rejected') {
          statusBg = const Color(0xFFFEE2E2);
          statusColor = const Color(0xFFDC2626);
          statusText = 'បានបដិសេធ';
        } else {
          statusBg = const Color(0xFFFEF3C7);
          statusColor = const Color(0xFFD97706);
          statusText = 'រង់ចាំ';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Room Name & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      req.room?.name ?? 'បន្ទប់ #${req.id}',
                      style: GoogleFonts.battambang(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.battambang(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Requester Info
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    req.name ?? req.requester?.name ?? 'អតិថិជន',
                    style: GoogleFonts.battambang(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const RoleBadge(role: 'customer', isCompact: true),
                  const Spacer(),
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    req.phone ?? req.requester?.phone ?? '-',
                    style: GoogleFonts.battambang(
                      fontSize: 13,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),

              // Date & Time
              if (req.preferredDate != null || req.preferredTime != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${req.preferredDate ?? ''}  ${req.preferredTime ?? ''}'
                          .trim(),
                      style: GoogleFonts.battambang(
                        fontSize: 13,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],

              // Notes
              if (req.notes != null && req.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    req.notes!,
                    style: GoogleFonts.battambang(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],

              // Actions (if pending)
              if (statusLower == 'pending') ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isProcessing
                            ? null
                            : () => _handleReject(req.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'បដិសេធ',
                          style: GoogleFonts.battambang(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () => _handleConfirm(req.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'យល់ព្រម',
                                style: GoogleFonts.battambang(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
