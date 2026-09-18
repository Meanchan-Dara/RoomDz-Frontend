import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/model/view_quest_model.dart';
import 'package:roomdz_frontend/service/rooms/owner_room_service.dart';
import 'package:roomdz_frontend/service/viewing_request_service.dart';
import 'package:roomdz_frontend/view/own_room/post_room_screen.dart';
import 'package:roomdz_frontend/widget/build_stats_grid.dart';
import 'package:roomdz_frontend/widget/role_badge.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final ViewingRequestService _viewingRequestService = ViewingRequestService();
  final OwnerRoomService _roomService = OwnerRoomService();

  List<ViewingRequestModel> viewingRequests = [];

  bool isLoading = false;
  int? processingRequestId;

  int _totalRooms = 0;
  int _availableRooms = 0;
  int _rentedRooms = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await Future.wait([_loadViewingRequests(), _loadStats()]);
  }

  Future<void> _loadStats() async {
    try {
      final data = await _roomService.getDashboardStats();
      if (data != null && data['stats'] is Map && mounted) {
        final stats = data['stats'] as Map;
        setState(() {
          _totalRooms = (stats['total_rooms'] as num?)?.toInt() ?? 0;
          _availableRooms = (stats['available_rooms'] as num?)?.toInt() ?? 0;
          _rentedRooms = (stats['occupied_rooms'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (_) {}
  }

  // get viewing requests from laravel
  Future<void> _loadViewingRequests() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final requests = await _viewingRequestService.getViewingRequests();

      if (!mounted) return;

      setState(() {
        viewingRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // owner confirms request
  Future<void> _acceptRequest(ViewingRequestModel request) async {
    if (processingRequestId != null) return;

    setState(() {
      processingRequestId = request.id;
    });

    try {
      await _viewingRequestService.confirmViewingRequest(request.id);

      if (!mounted) return;

      Get.snackbar(
        'ជោគជ័យ',
        'បានយល់ព្រមសំណើណាត់ជួប',
        snackPosition: SnackPosition.TOP,
      );

      await _loadViewingRequests();
    } catch (e) {
      if (!mounted) return;

      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) {
        setState(() {
          processingRequestId = null;
        });
      }
    }
  }

  // owner rejects request
  Future<void> _declineRequest(ViewingRequestModel request) async {
    if (processingRequestId != null) return;

    setState(() {
      processingRequestId = request.id;
    });

    try {
      await _viewingRequestService.rejectViewingRequest(request.id);

      if (!mounted) return;

      Get.snackbar(
        'ជោគជ័យ',
        'បានបដិសេធសំណើណាត់ជួប',
        snackPosition: SnackPosition.TOP,
      );

      await _loadViewingRequests();
    } catch (e) {
      if (!mounted) return;

      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) {
        setState(() {
          processingRequestId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingVisits = viewingRequests
        .where((request) => request.status.toLowerCase() == 'pending')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.0,

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'RoomDz',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 4),

                    Text(
                      'OWNER MODE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        actions: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.neutral.withValues(alpha: 0.7),
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.neutral.withValues(alpha: 0.8),
                  size: 26,
                ),
              ),

              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 16),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadDashboardData,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BuildStatsGrid(
                totalRooms: _totalRooms,
                availableRooms: _availableRooms,
                rentedRooms: _rentedRooms,
                pendingVisits: pendingVisits,
              ),

              // Quick action: Post Room Banner
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final created = await Get.to(() => const PostRoomScreen());
                    if (created == true) {
                      _loadDashboardData();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_home_work_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'បង្ហោះបន្ទប់ជួលថ្មី',
                                style: GoogleFonts.battambang(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ដាក់បន្ទប់ជួលរបស់អ្នកឱ្យអតិថិជនមើលឃើញភ្លាមៗ',
                                style: GoogleFonts.battambang(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ViewingRequestsSection(
                  requests: viewingRequests,
                  processingRequestId: processingRequestId,
                  onSeeAllTap: () {},
                  onAccept: _acceptRequest,
                  onDecline: _declineRequest,
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewingRequestsSection extends StatelessWidget {
  final List<ViewingRequestModel>? requests;

  final VoidCallback? onSeeAllTap;

  final Function(ViewingRequestModel)? onAccept;

  final Function(ViewingRequestModel)? onDecline;

  final int? processingRequestId;

  const ViewingRequestsSection({
    super.key,
    this.requests,
    this.onSeeAllTap,
    this.onAccept,
    this.onDecline,
    this.processingRequestId,
  });

  @override
  Widget build(BuildContext context) {
    final list = requests ?? [];

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 45,
                color: AppColors.neutral.withValues(alpha: 0.3),
              ),

              const SizedBox(height: 10),

              Text(
                'មិនមានសំណើណាត់ជួប',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.neutral.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Text(
                'សំណើណាត់ជួប',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),

                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Text(
                  '${list.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: onSeeAllTap,

                child: Text(
                  'មើលទាំងអស់ (${list.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,

            itemBuilder: (context, index) {
              final request = list[index];

              return _buildRequestCard(context, request);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, ViewingRequestModel request) {
    final room = request.room;
    final requester = request.requester;

    final requesterName = request.name ?? requester?.name ?? 'Unknown user';

    final roomName = room?.name ?? 'Unknown room';

    final address = room?.address ?? 'No address';

    final avatar = requester?.avatar;

    final isProcessing = processingRequestId == request.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.tertiary,

                backgroundImage: avatar != null && avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,

                child: avatar == null || avatar.isEmpty
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            requesterName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const RoleBadge(role: 'customer', isCompact: true),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '$roomName • $address',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral.withValues(alpha: 0.6),
                      ),

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _buildStatus(request.status),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    _formatPreferredDateTime(request),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (request.phone != null && request.phone!.isNotEmpty) ...[
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 17,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 8),

                Text(
                  request.phone!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral,
                  ),
                ),
              ],
            ),
          ],

          if (request.email != null && request.email!.isNotEmpty) ...[
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 17,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    request.email!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (request.notes != null && request.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(10),
              ),

              child: Text(
                request.notes!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],

          if (request.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,

                    child: ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => onDecline?.call(request),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                        foregroundColor: AppColors.neutral,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.05,
                        ),
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      icon: isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.close_rounded, size: 18),

                      label: const Text(
                        'បដិសេធ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 42,

                    child: ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => onAccept?.call(request),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      icon: isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded, size: 18),

                      label: Text(
                        isProcessing ? 'កំពុងដំណើរការ...' : 'ទទួលយក',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
  }

  Widget _buildStatus(String status) {
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        text = 'រង់ចាំ';
        break;

      case 'confirmed':
        text = 'បានយល់ព្រម';
        break;

      case 'rejected':
        text = 'បានបដិសេធ';
        break;

      default:
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  String _formatPreferredDateTime(ViewingRequestModel request) {
    final date = request.preferredDate;
    final time = request.preferredTime;

    if (date != null && date.isNotEmpty) {
      if (time != null && time.isNotEmpty) {
        return '$date • $time';
      }

      return date;
    }

    if (request.createdAt != null && request.createdAt!.isNotEmpty) {
      return _formatCreatedAt(request.createdAt!);
    }

    return 'មិនបានកំណត់ថ្ងៃ';
  }

  String _formatCreatedAt(String value) {
    try {
      final date = DateTime.parse(value);

      return '${date.day}/${date.month}/${date.year} • '
          '${date.hour}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return value;
    }
  }
}
