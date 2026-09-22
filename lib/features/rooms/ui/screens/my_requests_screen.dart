import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';
import 'package:roomdz_frontend/features/rooms/data/models/view_request_model.dart';
import 'package:roomdz_frontend/features/rooms/data/services/viewing_request_service.dart';
import 'package:roomdz_frontend/core/widgets/app_alert.dart';

class MyRequestsScreen extends StatefulWidget {
  final String? initialFilter;
  const MyRequestsScreen({super.key, this.initialFilter});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final ViewingRequestService _service = ViewingRequestService();
  List<ViewingRequestModel> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;
  late String _selectedFilter;
  int? _cancellingId;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'all';
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _service.getMyViewingRequests();
      if (mounted) {
        setState(() {
          _requests = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCancel(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'បោះបង់សំណើ',
          style: GoogleFonts.battambang(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'តើអ្នកពិតជាចង់បោះបង់សំណើមើលបន្ទប់នេះមែនទេ?',
          style: GoogleFonts.battambang(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'ទេ',
              style: GoogleFonts.battambang(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'បោះបង់',
              style: GoogleFonts.battambang(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _cancellingId = id);
    try {
      await _service.cancelViewingRequest(id);
      AppAlert.success('ជោគជ័យ', 'បានបោះបង់សំណើរួចរាល់');
      await _fetchRequests();
    } catch (e) {
      AppAlert.error('បរាជ័យ', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  List<ViewingRequestModel> get _filteredRequests {
    if (_selectedFilter == 'all') return _requests;
    return _requests
        .where((r) => r.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'សំណើរបស់ខ្ញុំ',
          style: GoogleFonts.battambang(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: const Color(0xFF1E293B),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('ទាំងអស់', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('កំពុងរង់ចាំ', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('បានយល់ព្រម', 'confirmed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('បានបោះបង់', 'cancelled'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchRequests,
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
                  'រាល់សំណើមើលបន្ទប់របស់អ្នកនឹងបង្ហាញនៅទីនេះ',
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
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildRequestCard(requests[index]);
      },
    );
  }

  Widget _buildRequestCard(ViewingRequestModel request) {
    final room = request.room;
    final isCancelling = _cancellingId == request.id;
    final isPending = request.status.toLowerCase() == 'pending';

    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (request.status.toLowerCase()) {
      case 'confirmed':
        statusColor = const Color(0xFF15803D);
        statusBgColor = const Color(0xFFDCFCE7);
        statusText = 'បានយល់ព្រម';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFB91C1C);
        statusBgColor = const Color(0xFFFEE2E2);
        statusText = 'បានបោះបង់';
        break;
      case 'rejected':
        statusColor = const Color(0xFFB91C1C);
        statusBgColor = const Color(0xFFFEE2E2);
        statusText = 'បានបដិសេធ';
        break;
      case 'pending':
      default:
        statusColor = const Color(0xFFB45309);
        statusBgColor = const Color(0xFFFEF3C7);
        statusText = 'កំពុងរង់ចាំ';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status badge & ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.battambang(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                Text(
                  '#${request.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Room info row
            if (room != null)
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: room.image != null && room.image!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: room.image!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              width: 64,
                              height: 64,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.home, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.home, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name ?? 'បន្ទប់គ្មានឈ្មោះ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.battambang(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${room.price.toStringAsFixed(0)} /ខែ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                        if (room.address != null &&
                            room.address!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  room.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.battambang(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Appointment date and time
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: Color(0xFF1D4ED8),
                ),
                const SizedBox(width: 6),
                Text(
                  'កាលបរិច្ឆេទ: ${request.preferredDate ?? 'មិនកំណត់'} ${request.preferredTime ?? ''}',
                  style: GoogleFonts.battambang(
                    fontSize: 13,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),

            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ចំណាំ: ${request.notes}',
                      style: GoogleFonts.battambang(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Cancel action button if pending
            if (isPending) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: isCancelling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        onPressed: () => _handleCancel(request.id),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: Text(
                          'បោះបង់សំណើ',
                          style: GoogleFonts.battambang(fontSize: 12),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
