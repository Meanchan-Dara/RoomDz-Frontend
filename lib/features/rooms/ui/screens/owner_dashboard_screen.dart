import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';
import 'package:roomdz_frontend/features/auth/ui/controllers/profile_controller.dart';
import 'package:roomdz_frontend/features/auth/ui/screens/profile_screen.dart';
import 'package:roomdz_frontend/features/rooms/data/models/view_request_model.dart';
import 'package:roomdz_frontend/features/rooms/data/services/owner_room_service.dart';
import 'package:roomdz_frontend/features/rooms/data/services/viewing_request_service.dart';
import 'package:roomdz_frontend/features/rooms/ui/screens/post_room_screen.dart';
import 'package:roomdz_frontend/core/widgets/app_alert.dart';
import 'package:roomdz_frontend/core/widgets/build_stats_grid.dart';
import 'package:roomdz_frontend/core/widgets/modern_button_loader.dart';
import 'package:roomdz_frontend/core/widgets/role_badge.dart';
import 'package:roomdz_frontend/features/rooms/ui/screens/viewing_request_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final ViewingRequestService _viewingRequestService = ViewingRequestService();
  final OwnerRoomService _roomService = OwnerRoomService();
  final ProfileController _profileCtrl = Get.find<ProfileController>();

  List<ViewingRequestModel> viewingRequests = [];

  bool isLoading = false;
  int? processingRequestId;
  String? processingAction;

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

      AppAlert.error('បរាជ័យ', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // owner confirms request
  Future<void> _acceptRequest(ViewingRequestModel request) async {
    if (processingRequestId != null) return;

    setState(() {
      processingRequestId = request.id;
      processingAction = 'accept';
    });

    try {
      await _viewingRequestService.confirmViewingRequest(request.id);

      if (!mounted) return;

      AppAlert.success('ជោគជ័យ', 'បានយល់ព្រមសំណើណាត់ជួប');

      await _loadViewingRequests();
    } catch (e) {
      if (!mounted) return;

      AppAlert.error('បរាជ័យ', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          processingRequestId = null;
          processingAction = null;
        });
      }
    }
  }

  // owner rejects request
  Future<void> _declineRequest(ViewingRequestModel request) async {
    if (processingRequestId != null) return;

    setState(() {
      processingRequestId = request.id;
      processingAction = 'decline';
    });

    try {
      await _viewingRequestService.rejectViewingRequest(request.id);

      if (!mounted) return;

      AppAlert.success('ជោគជ័យ', 'បានបដិសេធសំណើណាត់ជួប');

      await _loadViewingRequests();
    } catch (e) {
      if (!mounted) return;

      AppAlert.error('បរាជ័យ', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          processingRequestId = null;
          processingAction = null;
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
          Center(
            child: GestureDetector(
              onTap: () => Get.to(() => const ProfileScreen()),
              child: Obx(() {
                final user = _profileCtrl.currentUser.value;
                final path = _profileCtrl.localAvatarPath.value;
                final remote = user?.avatar;

                ImageProvider image;
                if (path != null &&
                    path.isNotEmpty &&
                    File(path).existsSync()) {
                  image = FileImage(File(path));
                } else if (remote != null && remote.isNotEmpty) {
                  image = CachedNetworkImageProvider(remote);
                } else {
                  image = const NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                  );
                }

                final String displayName =
                    (user?.name != null && user!.name.trim().isNotEmpty)
                    ? user.name.trim()
                    : 'ម្ចាស់បន្ទប់';
                final String displayEmail =
                    (user?.email != null && user!.email.trim().isNotEmpty)
                    ? user.email.trim()
                    : '';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade200, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile image on the left
                      Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: image,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Name and Email on the right
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 85),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              displayEmail.isNotEmpty
                                  ? displayEmail
                                  : 'ម្ចាស់បន្ទប់',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 4),

                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(width: 14),
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
                  processingAction: processingAction,
                  onSeeAllTap: () => Get.to(() => const ViewingRequestScreen()),
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
  final String? processingAction;

  const ViewingRequestsSection({
    super.key,
    this.requests,
    this.onSeeAllTap,
    this.onAccept,
    this.onDecline,
    this.processingRequestId,
    this.processingAction,
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

    final isAccepting =
        processingRequestId == request.id && processingAction == 'accept';
    final isDeclining =
        processingRequestId == request.id && processingAction == 'decline';
    final isAnyProcessing = processingRequestId == request.id;

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

                    child: ElevatedButton(
                      onPressed: isAnyProcessing
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
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),

                      child: ModernButtonContent(
                        isLoading: isDeclining,
                        text: 'បដិសេធ',
                        loadingText: 'កំពុងបដិសេធ',
                        icon: Icons.close_rounded,
                        textColor: AppColors.neutral,
                        iconSize: 18,
                        dotSize: 4.0,
                        dotSpacing: 3.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 42,

                    child: ElevatedButton(
                      onPressed: isAnyProcessing
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
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),

                      child: ModernButtonContent(
                        isLoading: isAccepting,
                        text: 'យល់ព្រម',
                        loadingText: 'កំពុងយល់ព្រម',
                        icon: Icons.check_rounded,
                        textColor: Colors.white,
                        iconSize: 18,
                        dotSize: 4.0,
                        dotSpacing: 3.0,
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
