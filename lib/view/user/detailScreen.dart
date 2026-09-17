import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/const/colors/data/rule.dart';
import 'package:roomdz_frontend/controller/favorite_controller.dart';
import 'package:roomdz_frontend/rooms/room_detail_model.dart';
import 'package:roomdz_frontend/service/rooms/room_service.dart';
import 'package:roomdz_frontend/service/viewing_request_service.dart';
import 'package:roomdz_frontend/util/url_util.dart';
import 'package:roomdz_frontend/widget/skeleton/detail_screen_skeleton.dart';

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

  @override
  void initState() {
    super.initState();
    // Cache the future in initState to avoid re-triggering network requests on rebuilds
    _roomDetailFuture = _roomServer.getRoomsDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RoomDetialModel>(
      future: _roomDetailFuture,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: DetailScreenSkeleton());
        }

        // Error state
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        // Empty state
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('No room data')));
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
                  background: (room.image != null && room.image!.isNotEmpty)
                      ? Image.network(
                          room.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.image_not_supported, size: 60),
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
                              value: room.roomInformation.deposit,
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
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Landlord',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
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
                                              'Responds within 15 mins',
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
                                      'Chat Now',
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
                                          'Phone Call',
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
                                      'Call Now',
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

          // --- ADDED BOTTOM SHEET / BOTTOM NAVIGATION BAR ---
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Leading: Price Info
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'តម្លៃសរុប',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "\$${room.price}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 22,
                            ),
                          ),
                          const Text(
                            ' / មួយខែ',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Action: Send Request Button
                  ElevatedButton.icon(
                    onPressed: () {
                      _showSendRequestDialog(context, room.name);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text(
                      'ផ្ញើសំណើ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Helper action to confirm or send request
  void _showSendRequestDialog(BuildContext context, String roomName) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final notesController = TextEditingController();

    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    Get.defaultDialog(
      title: 'ផ្ញើសំណើមើលបន្ទប់',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ឈ្មោះ',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'លេខទូរស័ព្ទ',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                // date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined),
                        const SizedBox(width: 10),
                        Text(
                          selectedDate == null
                              ? 'ជ្រើសរើសថ្ងៃ'
                              : '${selectedDate!.year}-'
                                    '${selectedDate!.month.toString().padLeft(2, '0')}-'
                                    '${selectedDate!.day.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // time
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_outlined),
                        const SizedBox(width: 10),
                        Text(
                          selectedTime == null
                              ? 'ជ្រើសរើសម៉ោង'
                              : selectedTime!.format(context),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ចំណាំ',
                    prefixIcon: Icon(Icons.notes_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        Get.snackbar('Error', 'សូមបញ្ចូលឈ្មោះ');
                        return;
                      }

                      if (phoneController.text.trim().isEmpty) {
                        Get.snackbar('Error', 'សូមបញ្ចូលលេខទូរស័ព្ទ');
                        return;
                      }

                      String? preferredDate;

                      if (selectedDate != null) {
                        preferredDate =
                            '${selectedDate!.year}-'
                            '${selectedDate!.month.toString().padLeft(2, '0')}-'
                            '${selectedDate!.day.toString().padLeft(2, '0')}';
                      }

                      String? preferredTime;

                      if (selectedTime != null) {
                        preferredTime =
                            '${selectedTime!.hour.toString().padLeft(2, '0')}:'
                            '${selectedTime!.minute.toString().padLeft(2, '0')}';
                      }

                      try {
                        Get.back();

                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );

                        await _viewingRequestService.requestViewing(
                          roomId: widget.id,
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim(),
                          preferredDate: preferredDate,
                          preferredTime: preferredTime,
                          notes: notesController.text.trim(),
                        );

                        if (Get.isDialogOpen == true) {
                          Get.back();
                        }

                        Get.snackbar(
                          'ជោគជ័យ',
                          'សំណើរបស់អ្នកត្រូវបានផ្ញើទៅម្ចាស់ផ្ទះរួចរាល់',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } catch (e) {
                        if (Get.isDialogOpen == true) {
                          Get.back();
                        }

                        Get.snackbar(
                          'Error',
                          e.toString().replaceFirst('Exception: ', ''),
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: const Text('ផ្ញើសំណើ'),
                  ),
                ),
              ],
            ),
          );
        },
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
      children: [
        Icon(icon, size: 22, color: Colors.blueGrey.shade700),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade700),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
