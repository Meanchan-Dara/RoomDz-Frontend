import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';
import 'package:roomdz_frontend/core/utils/app_rules.dart';
import 'package:roomdz_frontend/features/rooms/ui/controllers/favorite_controller.dart';
import 'package:roomdz_frontend/features/rooms/data/models/room_detail_model.dart';
import 'package:roomdz_frontend/core/database/database_service.dart';
import 'package:roomdz_frontend/features/rooms/data/services/room_service.dart';
import 'package:roomdz_frontend/features/rooms/data/models/view_request_model.dart';
import 'package:roomdz_frontend/features/rooms/data/services/viewing_request_service.dart';
import 'package:roomdz_frontend/core/utils/url_util.dart';
import 'package:roomdz_frontend/core/widgets/app_alert.dart';
import 'package:roomdz_frontend/core/widgets/role_badge.dart';
import 'package:roomdz_frontend/core/widgets/room_status_badge.dart';
import 'package:roomdz_frontend/core/widgets/skeleton/detail_screen_skeleton.dart';
import 'package:roomdz_frontend/core/widgets/modern_button_loader.dart';
import 'package:roomdz_frontend/features/payment/ui/widgets/bakong_payment_dialog.dart';

class Detailscreen extends StatefulWidget {
  final int id;

  const Detailscreen({super.key, required this.id});

  @override
  State<Detailscreen> createState() => _DetailscreenState();
}

class _DetailscreenState extends State<Detailscreen> {
  final ViewingRequestService _viewingRequestService = ViewingRequestService();
  final RoomServer _roomServer = RoomServer();
  final UrlUtil _urlUtil = UrlUtil();
  late Future<RoomDetialModel> _roomDetailFuture;
  final FavoriteController favoriteController = Get.find<FavoriteController>();

  ViewingRequestModel? _userActiveRequest;

  @override
  void initState() {
    super.initState();
    // Cache the future in initState to avoid re-triggering network requests on rebuilds
    _roomDetailFuture = _roomServer.getRoomsDetail(widget.id);
    _checkUserViewingRequest();
  }

  Future<void> _checkUserViewingRequest() async {
    try {
      final myRequests = await _viewingRequestService.getMyViewingRequests();
      ViewingRequestModel? active;
      for (final r in myRequests) {
        if (r.room?.id == widget.id &&
            (r.status.toLowerCase() == 'pending' ||
                r.status.toLowerCase() == 'confirmed')) {
          active = r;
          break;
        }
      }
      if (mounted) {
        setState(() {
          _userActiveRequest = active;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RoomDetialModel>(
      future: _roomDetailFuture,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const DetailScreenSkeleton();
        }

        // Error state
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('មានបញ្ហា៖ ${snapshot.error}')),
          );
        }

        // Empty state
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('រកមិនឃើញទិន្នន័យបន្ទប់')),
          );
        }

        // API Data
        final room = snapshot.data!.data;

        // Location coordinates
        final LatLng roomLocation =
            (room.location.latitude != 0.0 && room.location.longitude != 0.0)
            ? LatLng(room.location.latitude, room.location.longitude)
            : const LatLng(11.5564, 104.9282);

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              // App Bar with Hero Image
              SliverAppBar(
                leadingWidth: 60,
                actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white60,
                      ),
                      child: const Icon(Icons.arrow_back_outlined),
                    ),
                  ),
                ),
                actions: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white60,
                    ),
                    child: const Icon(Icons.share),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white54,
                    ),
                    child: Obx(() {
                      final isFavorite = favoriteController.isFavorite(room.id);

                      return IconButton(
                        onPressed: () {
                          favoriteController.toggleFavorite(room.id);
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                        ),
                      );
                    }),
                  ),
                ],
                expandedHeight: 320,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      (room.image != null && room.image!.isNotEmpty)
                          ? Image.network(
                              room.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 70,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 16,
                        child: RoomStatusBadge(
                          status: room.status,
                          hasLatestBooking: room.latestBooking != null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Room Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text(
                            room.rating.toString(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      // Address & Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_outlined),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              room.address,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "\$${room.price}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 24,
                            ),
                          ),
                          const Text(
                            ' / មួយខែ',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      const Divider(thickness: 0.8),
                      const SizedBox(height: 8),

                      // About Section
                      const Text(
                        "អំពីបន្ទប់",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        room.about.isNotEmpty
                            ? room.about
                            : "គ្មានការពិពណ៌នាអំពីបន្ទប់នេះទេ",
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Room Information Details
                      _buildBgContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "ព័ត៌មានបន្ទប់",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Type
                            _buildInfoRow(
                              icon: Icons.meeting_room_outlined,
                              label: "ប្រភេទ",
                              value: room.roomInformation.type,
                            ),
                            const SizedBox(height: 14),
                            Divider(
                              thickness: 0.7,
                              color: Colors.grey.shade200,
                            ),
                            const SizedBox(height: 14),

                            // Size
                            _buildInfoRow(
                              icon: Icons.straighten_outlined,
                              label: "ទំហំ",
                              value: room.roomInformation.size,
                            ),
                            const SizedBox(height: 14),
                            Divider(
                              thickness: 0.7,
                              color: Colors.grey.shade200,
                            ),
                            const SizedBox(height: 14),

                            // Floor
                            _buildInfoRow(
                              icon: Icons.layers_outlined,
                              label: "ជាន់",
                              value: room.roomInformation.floor,
                            ),
                            const SizedBox(height: 14),
                            Divider(
                              thickness: 0.7,
                              color: Colors.grey.shade200,
                            ),
                            const SizedBox(height: 14),

                            // Deposit
                            _buildInfoRow(
                              icon: Icons.key_outlined,
                              label: "ប្រាក់កក់",
                              value: () {
                                if (room.depositPrice != null &&
                                    room.depositPrice! > 0) {
                                  final amountStr =
                                      room.depositCurrency == 'KHR'
                                      ? "${room.depositPrice!.toInt()} ៛"
                                      : "\$${room.depositPrice}";
                                  final cleanDeposit = room
                                      .roomInformation
                                      .deposit
                                      .replaceAll(
                                        RegExp(r'\s*\(\$.*?\)\s*'),
                                        '',
                                      )
                                      .trim();
                                  return cleanDeposit.isNotEmpty &&
                                          cleanDeposit != amountStr
                                      ? "$amountStr ($cleanDeposit)"
                                      : amountStr;
                                }
                                return room.roomInformation.deposit.isNotEmpty
                                    ? room.roomInformation.deposit
                                    : "មិនតម្រូវ";
                              }(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // House Rules
                      _buildBgContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ច្បាប់សម្រាប់អ្នកជួល",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Rules.rules.map((rule) => "• $rule").join("\n"),
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.7,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Location Map Section
                      _buildBgContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ទីតាំង',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),

                                TextButton.icon(
                                  onPressed: () {
                                    _urlUtil.openGoogleMaps(
                                      latitude: room.location.latitude,
                                      longitude: room.location.longitude,
                                    );
                                  },
                                  icon: const Icon(Icons.directions, size: 18),
                                  label: const Text('Google Maps'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: FlutterMap(
                                options: MapOptions(
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none,
                                  ),
                                  initialCenter: roomLocation,
                                  initialZoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.example.roomdz_frontend',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: roomLocation,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 40,
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

                      const SizedBox(height: 16),

                      // Landlord Contact Information Section
                      _buildBgContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "បានចុះបញ្ជីដោយម្ចាស់ផ្ទះ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  backgroundImage:
                                      (room.landlord?.avatar != null &&
                                          room.landlord!.avatar!.isNotEmpty)
                                      ? NetworkImage(room.landlord!.avatar!)
                                      : null,
                                  child:
                                      (room.landlord?.avatar == null ||
                                          room.landlord!.avatar!.isEmpty)
                                      ? Text(
                                          (room.landlord?.name != null &&
                                                  room.landlord!.name
                                                      .trim()
                                                      .isNotEmpty)
                                              ? room.landlord!.name
                                                    .trim()
                                                    .characters
                                                    .first
                                                    .toUpperCase()
                                              : 'SV',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0284C7),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          Text(
                                            room.landlord?.name ??
                                                'Sophea Vorn',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const RoleBadge(
                                            role: 'owner',
                                            isCompact: true,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Color(0xFF0D9488),
                                          ),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'ឆ្លើយតបក្នុងរង្វង់ ១៥ នាទី',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF64748B),
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
                            const SizedBox(height: 20),

                            // Telegram Option
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFBAE6FD),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0EA5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Telegram',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0284C7),
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          room.landlord?.telegram ??
                                              '@Sophea Vorn',
                                          style: const TextStyle(
                                            color: Color(0xFF475569),
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      final rawTg = room.landlord?.telegram
                                          ?.replaceAll('@', '')
                                          .trim();
                                      final url =
                                          (rawTg != null && rawTg.isNotEmpty)
                                          ? "https://t.me/$rawTg"
                                          : "https://t.me/s/numeducation";
                                      _urlUtil.open(url);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0EA5E9),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text(
                                      'ផ្ញើសារ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Phone Call Option
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2563EB),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ទូរស័ព្ទផ្ទាល់',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          room.landlord?.phone ??
                                              "+855 976394738",
                                          style: const TextStyle(
                                            color: Color(0xFF475569),
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      String number =
                                          room.landlord?.phone ??
                                          "+855976394738";
                                      _urlUtil.open("tel:$number");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text(
                                      'ហៅទូរស័ព្ទ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- ADDED BOTTOM SHEET / BOTTOM NAVIGATION BAR WITH 2 SIDE-BY-SIDE BUTTONS ---
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Builder(
                builder: (context) {
                  final statusType = getRoomStatusType(
                    room.status,
                    hasLatestBooking: room.latestBooking != null,
                  );
                  final isAvailable = statusType == RoomStatusType.available;
                  final isBooked = statusType == RoomStatusType.booked;
                  final isRented = statusType == RoomStatusType.rented;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Warning notification banner if room is not available
                      if (!isAvailable)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isBooked
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isBooked
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isBooked
                                    ? Icons.lock_clock_rounded
                                    : Icons.do_not_disturb_on_rounded,
                                size: 16,
                                color: isBooked
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isBooked
                                      ? 'បន្ទប់នេះមានអ្នកកក់ប្រាក់រួចហើយ (មិនអាចកក់ជាន់គ្នាបានទេ)'
                                      : 'បន្ទប់នេះត្រូវបានជួលរួចរាល់ហើយ (មិនអាចកក់បានទេ)',
                                  style: GoogleFonts.battambang(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isBooked
                                        ? const Color(0xFF92400E)
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Row(
                        children: [
                          // Leading: Price & Deposit Info
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    "\$${room.price}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Text(
                                    '/ខែ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (room.depositPrice != null &&
                                  room.depositPrice! > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    room.depositCurrency == 'KHR'
                                        ? 'កក់ ${room.depositPrice!.toInt()}៛'
                                        : 'កក់ \$${room.depositPrice}',
                                    style: GoogleFonts.battambang(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF15803D),
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  'តម្លៃសរុប',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          // Actions: Two side-by-side buttons
                          Expanded(
                            child: Row(
                              children: [
                                // Button 1: Request Viewing
                                Builder(
                                  builder: (context) {
                                    final hasActiveRequest =
                                        _userActiveRequest != null;
                                    final isConfirmed =
                                        _userActiveRequest?.status
                                            .toLowerCase() ==
                                        'confirmed';
                                    final isPending =
                                        _userActiveRequest?.status
                                            .toLowerCase() ==
                                        'pending';
                                    final isViewDisabled =
                                        isRented || hasActiveRequest;

                                    final Color viewBtnColor = isRented
                                        ? const Color(0xFF64748B) // Slate
                                        : AppColors.primary;

                                    final IconData viewIcon = isRented
                                        ? Icons.do_not_disturb_on_rounded
                                        : isConfirmed
                                        ? Icons.check_circle_rounded
                                        : isPending
                                        ? Icons.hourglass_top_rounded
                                        : Icons.calendar_month_outlined;

                                    final String viewText = isRented
                                        ? 'ត្រូវបានជួល'
                                        : isConfirmed
                                        ? 'យល់ព្រម'
                                        : isPending
                                        ? 'កំពុងរង់ចាំ'
                                        : 'ស្នើសុំមើល';

                                    return Expanded(
                                      child: SizedBox(
                                        height: 44,
                                        child: ElevatedButton(
                                          onPressed: isViewDisabled
                                              ? null
                                              : () {
                                                  _showSendRequestDialog(
                                                    context,
                                                    room.name,
                                                  );
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: viewBtnColor,
                                            disabledBackgroundColor:
                                                viewBtnColor,
                                            disabledForegroundColor:
                                                Colors.white,
                                            foregroundColor: Colors.white,
                                            elevation: isViewDisabled ? 0 : 1,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                viewIcon,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  viewText,
                                                  style: GoogleFonts.battambang(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(width: 8),

                                // Button 2: Direct Bakong KHQR Payment
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: !isAvailable
                                          ? null
                                          : () {
                                              BakongPaymentDialog.show(
                                                context: context,
                                                room: room,
                                                onPaymentCompleted: () {
                                                  setState(() {
                                                    _roomDetailFuture =
                                                        _roomServer
                                                            .getRoomsDetail(
                                                              widget.id,
                                                            );
                                                  });
                                                },
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isBooked
                                            ? const Color(0xFFF59E0B) // Amber
                                            : isRented
                                            ? const Color(0xFF64748B) // Slate
                                            : const Color(
                                                0xFFE1251B,
                                              ), // Official Bakong Red
                                        disabledBackgroundColor: isBooked
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFF64748B),
                                        disabledForegroundColor: Colors.white,
                                        foregroundColor: Colors.white,
                                        elevation: !isAvailable ? 0 : 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isBooked
                                                ? Icons.lock_clock_rounded
                                                : isRented
                                                ? Icons
                                                      .do_not_disturb_on_rounded
                                                : Icons.qr_code_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              isBooked
                                                  ? 'ត្រូវបានកក់'
                                                  : isRented
                                                  ? 'ត្រូវបានជួល'
                                                  : 'កក់ KHQR',
                                              style: GoogleFonts.battambang(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Helper action to confirm or send request
  Future<void> _showSendRequestDialog(
    BuildContext context,
    String roomName,
  ) async {
    // Check if user already has an active (pending or confirmed) request for this room
    try {
      final myRequests = await _viewingRequestService.getMyViewingRequests();
      ViewingRequestModel? activeReq;
      for (final r in myRequests) {
        if (r.room?.id == widget.id &&
            (r.status.toLowerCase() == 'pending' ||
                r.status.toLowerCase() == 'confirmed')) {
          activeReq = r;
          break;
        }
      }

      if (activeReq != null) {
        if (!context.mounted) return;
        final isConfirmed = activeReq.status.toLowerCase() == 'confirmed';
        final statusKhmer = isConfirmed
            ? 'ត្រូវបានម្ចាស់បន្ទប់យល់ព្រមរួចរាល់'
            : 'កំពុងរង់ចាំការឆ្លើយតបពីម្ចាស់បន្ទប់';
        AppAlert.warning(
          'មិនអាចស្នើសុំបានទេ',
          'អ្នកបានផ្ញើសំណើណាត់ជួបមើលបន្ទប់នេះរួចហើយ ($statusKhmer)។ អ្នកអាចស្នើសុំម្តងទៀតបាន លុះត្រាតែម្ចាស់បន្ទប់បានធ្វើការបដិសេធសំណើមុនសិន។',
        );
        return;
      }
    } catch (_) {}

    final savedUser = await DatabaseService.instance.getSavedUser();
    final nameController = TextEditingController(text: savedUser?.name ?? '');
    final phoneController = TextEditingController(text: savedUser?.phone ?? '');
    final emailController = TextEditingController(text: savedUser?.email ?? '');
    final notesController = TextEditingController();

    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    bool isSubmitting = false;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top drag handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header: Icon badge, Title & Close Button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ផ្ញើសំណើមើលបន្ទប់',
                                style: GoogleFonts.battambang(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                roomName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.battambang(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          color: const Color(0xFF64748B),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 16),

                    // 1. Name input
                    _buildInputField(
                      controller: nameController,
                      label: 'ឈ្មោះរបស់អ្នក',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                    ),

                    const SizedBox(height: 12),

                    // 2. Phone input
                    _buildInputField(
                      controller: phoneController,
                      label: 'លេខទូរស័ព្ទ',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 12),

                    // 3. Email input (optional)
                    _buildInputField(
                      controller: emailController,
                      label: 'អ៊ីមែល (មិនបង្ខំ)',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 12),

                    // 4. Date & Time picker (2 columns row)
                    Row(
                      children: [
                        // Date picker
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setSheetState(() => selectedDate = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedDate != null
                                      ? AppColors.primary
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18,
                                    color: selectedDate != null
                                        ? AppColors.primary
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedDate == null
                                          ? 'ជ្រើសរើសថ្ងៃ'
                                          : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.battambang(
                                        fontSize: 13,
                                        fontWeight: selectedDate != null
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: selectedDate != null
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Time picker
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                setSheetState(() => selectedTime = time);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedTime != null
                                      ? AppColors.primary
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                    color: selectedTime != null
                                        ? AppColors.primary
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedTime == null
                                          ? 'ជ្រើសរើសម៉ោង'
                                          : selectedTime!.format(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.battambang(
                                        fontSize: 13,
                                        fontWeight: selectedTime != null
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: selectedTime != null
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 5. Notes input
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      style: GoogleFonts.battambang(
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        labelText: 'ចំណាំបន្ថែម (ប្រសិនបើមាន)',
                        labelStyle: GoogleFonts.battambang(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Icon(
                            Icons.notes_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 6. Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary,
                          disabledForegroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nameController.text.trim().isEmpty) {
                                  AppAlert.error(
                                    'កំហុស',
                                    'សូមបញ្ចូលឈ្មោះរបស់អ្នក',
                                  );
                                  return;
                                }

                                if (phoneController.text.trim().isEmpty) {
                                  AppAlert.error(
                                    'កំហុស',
                                    'សូមបញ្ចូលលេខទូរស័ព្ទ',
                                  );
                                  return;
                                }

                                setSheetState(() => isSubmitting = true);

                                String? preferredDate;
                                if (selectedDate != null) {
                                  preferredDate =
                                      '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                                }

                                String? preferredTime;
                                if (selectedTime != null) {
                                  preferredTime =
                                      '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                                }

                                try {
                                  await _viewingRequestService.requestViewing(
                                    roomId: widget.id,
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    email: emailController.text.trim(),
                                    preferredDate: preferredDate,
                                    preferredTime: preferredTime,
                                    notes: notesController.text.trim(),
                                  );

                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }

                                  AppAlert.success(
                                    'ជោគជ័យ',
                                    'សំណើរបស់អ្នកត្រូវបានផ្ញើទៅម្ចាស់ផ្ទះរួចរាល់',
                                  );
                                  _checkUserViewingRequest();
                                } catch (e) {
                                  setSheetState(() => isSubmitting = false);
                                  AppAlert.error(
                                    'បរាជ័យ',
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  );
                                }
                              },
                        child: ModernButtonContent(
                          isLoading: isSubmitting,
                          text: 'ផ្ញើសំណើ',
                          loadingText: 'កំពុងផ្ញើសំណើ',
                          icon: Icons.send_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.battambang(
        fontSize: 14,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.battambang(
          fontSize: 13,
          color: const Color(0xFF64748B),
        ),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
      ),
    );
  }

  /// Background card container wrapper helper
  Widget _buildBgContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }

  /// Helper method for building repetitive room information rows
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey.shade700),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.battambang(
            fontSize: 14.5,
            color: Colors.blueGrey.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.battambang(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
