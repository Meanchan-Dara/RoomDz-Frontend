import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';
import 'package:roomdz_frontend/features/rooms/data/models/room_model.dart';
import 'package:roomdz_frontend/features/rooms/data/services/owner_room_service.dart';
import 'package:roomdz_frontend/features/rooms/ui/screens/post_room_screen.dart';
import 'package:roomdz_frontend/features/rooms/ui/screens/detail_screen.dart';
import 'package:roomdz_frontend/features/rooms/ui/controllers/category_static_list.dart';
import 'package:roomdz_frontend/core/widgets/app_alert.dart';
import 'package:roomdz_frontend/core/widgets/room_status_badge.dart';
import 'package:roomdz_frontend/core/widgets/skeleton/home_screen_skeleton.dart';
import 'package:url_launcher/url_launcher.dart';

class MyRoomsScreen extends StatefulWidget {
  const MyRoomsScreen({super.key});

  @override
  State<MyRoomsScreen> createState() => _MyRoomsScreenState();
}

class _MyRoomsScreenState extends State<MyRoomsScreen> {
  final OwnerRoomService _roomService = OwnerRoomService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Datum> _allRooms = [];
  List<Datum> _filteredRooms = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    _fetchRooms();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rooms = await _roomService.getOwnerRooms();
      if (!mounted) return;
      setState(() {
        _allRooms = rooms;
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchCtrl.text.trim().toLowerCase();
    var rooms = List<Datum>.from(_allRooms);

    // Filter by Category
    if (_selectedCategory > 0 && _selectedCategory < categories.length) {
      final cat = categories[_selectedCategory];
      rooms = rooms.where((r) {
        final catId = r.categoryId;
        final catName = r.category.name.toLowerCase();
        final selectedText = cat.text.toLowerCase();

        return catId == cat.id ||
            catName.contains(selectedText) ||
            selectedText.contains(catName);
      }).toList();
    }

    // Filter by Search text
    if (query.isNotEmpty) {
      rooms = rooms.where((r) {
        final name = r.name.toLowerCase();
        final address = r.address.toLowerCase();
        final type = r.type.toLowerCase();
        final catName = r.category.name.toLowerCase();

        return name.contains(query) ||
            address.contains(query) ||
            type.contains(query) ||
            catName.contains(query);
      }).toList();
    }

    setState(() {
      _filteredRooms = rooms;
    });
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategory = index;
    });
    _applyFilter();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _selectedCategory = 0;
    });
    _applyFilter();
  }

  Future<void> _openPostRoom() async {
    final created = await Get.to(() => const PostRoomScreen());
    if (created == true) {
      _fetchRooms();
    }
  }

  Future<void> _confirmDeleteRoom(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'លុបបន្ទប់?',
          style: GoogleFonts.battambang(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'តើអ្នកពិតជាចង់លុបបន្ទប់ "$name" នេះមែនទេ? សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។',
          style: GoogleFonts.battambang(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'បោះបង់',
              style: GoogleFonts.battambang(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'លុបចេញ',
              style: GoogleFonts.battambang(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _roomService.deleteRoom(id);
        AppAlert.success('ជោគជ័យ', 'បានលុបបន្ទប់រួចរាល់');
        _fetchRooms();
      } catch (e) {
        AppAlert.error('បរាជ័យ', e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _handleRentOut(int id) async {
    try {
      await _roomService.rentOutRoom(id);
      AppAlert.success('ជោគជ័យ', 'បានកាត់បន្ថយបន្ទប់ទំនេររួចរាល់');
      _fetchRooms();
    } catch (e) {
      AppAlert.error('បរាជ័យ', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _handleReleaseUnit(int id) async {
    try {
      await _roomService.releaseUnit(id);
      AppAlert.success('ជោគជ័យ', 'បានបន្ថែមចំនួនបន្ទប់ទំនេរវិញរួចរាល់');
      _fetchRooms();
    } catch (e) {
      AppAlert.error('បរាជ័យ', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'បន្ទប់របស់ខ្ញុំ',
              style: GoogleFonts.battambang(
                color: AppColors.neutral,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_allRooms.length}',
                style: GoogleFonts.battambang(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchRooms,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: FilledButton.icon(
              onPressed: _openPostRoom,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              icon: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                'បង្ហោះ',
                style: GoogleFonts.battambang(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          _buildSearchBox(),
          const SizedBox(height: 10),
          _buildCategories(),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchRooms,
              color: AppColors.primary,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  // Modern Search Box
  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          style: GoogleFonts.battambang(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'ស្វែងរកបន្ទប់, ទីតាំង...',
            hintStyle: GoogleFonts.battambang(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  // Modern Categories Filter Pills
  Widget _buildCategories() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == index;

          return GestureDetector(
            onTap: () => _selectCategory(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Text(
                category.text,
                style: GoogleFonts.battambang(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 4,
        itemBuilder: (context, index) => const HomeScreenSkeleton(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
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
                    onPressed: _fetchRooms,
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

    if (_filteredRooms.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 70, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _allRooms.isEmpty
                        ? 'មិនទាន់មានបន្ទប់នៅឡើយទេ'
                        : 'រកមិនឃើញបន្ទប់ទេ',
                    style: GoogleFonts.battambang(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _allRooms.isEmpty
                        ? 'បន្ទប់ដែលលោកអ្នកបង្ហោះ នឹងបង្ហាញនៅទីនេះ'
                        : 'សាកល្បងស្វែងរកឈ្មោះ ឬជ្រើសរើសប្រភេទផ្សេង',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.battambang(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_allRooms.isNotEmpty)
                    OutlinedButton(
                      onPressed: _clearSearch,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'សម្អាតការស្វែងរក',
                        style: GoogleFonts.battambang(color: AppColors.primary),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _openPostRoom,
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: Text(
                        'បង្ហោះបន្ទប់ដំបូងរបស់អ្នក',
                        style: GoogleFonts.battambang(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Owner room list
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 100),
      itemCount: _filteredRooms.length,
      itemBuilder: (context, index) {
        final room = _filteredRooms[index];
        return _buildOwnerSearchRoomCard(room);
      },
    );
  }

  // Modern compact Airbnb-style Owner Room Card
  Widget _buildOwnerSearchRoomCard(Datum room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(() => Detailscreen(id: room.id));
          },
          child: SizedBox(
            height: 108,
            child: Row(
              children: [
                // Thumbnail on the left with fixed compact size (108 x 108)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: 108,
                        height: 108,
                        child: room.image != null && room.image!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: room.image!,
                                width: 108,
                                height: 108,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFF1F5F9),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFFF1F5F9),
                                  child: const Icon(
                                    Icons.apartment_rounded,
                                    size: 30,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(
                                  Icons.apartment_rounded,
                                  size: 30,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                      ),
                    ),
                    // Floating Status Badge on top of image
                    Positioned(
                      top: 5,
                      left: 5,
                      child: RoomStatusBadge(
                        status: room.status,
                        hasLatestBooking: room.latestBooking != null,
                        isCompact: true,
                      ),
                    ),
                  ],
                ),

                // Content Details on the right
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Row 1: Title & 3-dots Menu
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                room.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.battambang(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: _buildPopupMenu(room),
                            ),
                          ],
                        ),

                        const SizedBox(height: 2),

                        // Row 2: Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                room.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.battambang(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Row 3: Category & Rating
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                room.category.name,
                                style: GoogleFonts.battambang(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFFEF3C7),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 11,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    room.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Row 4: Price & Booking Status
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '\$${room.price.toStringAsFixed(0)}',
                                    style: GoogleFonts.battambang(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' /ខែ',
                                    style: GoogleFonts.battambang(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (room.latestBooking != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: const Color(0xFFBBF7D0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 10,
                                      color: Color(0xFF16A34A),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      room.latestBooking!.customerName !=
                                                  null &&
                                              room
                                                  .latestBooking!
                                                  .customerName!
                                                  .isNotEmpty
                                          ? room.latestBooking!.customerName!
                                          : 'បានកក់',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.battambang(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                    if (room.latestBooking!.customerPhone !=
                                            null &&
                                        room
                                            .latestBooking!
                                            .customerPhone!
                                            .isNotEmpty) ...[
                                      const SizedBox(width: 3),
                                      InkWell(
                                        onTap: () async {
                                          final uri = Uri.parse(
                                            'tel:${room.latestBooking!.customerPhone}',
                                          );
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri);
                                          }
                                        },
                                        child: const Icon(
                                          Icons.phone_rounded,
                                          size: 10,
                                          color: Color(0xFF16A34A),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(Datum room) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: Color(0xFF64748B),
      ),
      onSelected: (val) {
        if (val == 'details') {
          Get.to(() => Detailscreen(id: room.id));
        } else if (val == 'rent_out') {
          _handleRentOut(room.id);
        } else if (val == 'release') {
          _handleReleaseUnit(room.id);
        } else if (val == 'delete') {
          _confirmDeleteRoom(room.id, room.name);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'មើលព័ត៌មានលម្អិត',
                style: GoogleFonts.battambang(fontSize: 13),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'rent_out',
          child: Row(
            children: [
              const Icon(
                Icons.person_remove_outlined,
                size: 18,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'ជួលបន្ទប់ចេញ (-1)',
                style: GoogleFonts.battambang(fontSize: 13),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'release',
          child: Row(
            children: [
              const Icon(
                Icons.person_add_outlined,
                size: 18,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                'ដោះលែងបន្ទប់ (+1)',
                style: GoogleFonts.battambang(fontSize: 13),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'លុបបន្ទប់',
                style: GoogleFonts.battambang(fontSize: 13, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
