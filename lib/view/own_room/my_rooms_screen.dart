import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/model/roomModel.dart';
import 'package:roomdz_frontend/service/rooms/owner_room_service.dart';
import 'package:roomdz_frontend/view/own_room/post_room_screen.dart';
import 'package:roomdz_frontend/view/user/detailScreen.dart';
import 'package:roomdz_frontend/viewmodel/viewCategory.dart';
import 'package:roomdz_frontend/widget/app_alert.dart';
import 'package:roomdz_frontend/widget/room_status_badge.dart';
import 'package:roomdz_frontend/widget/skeleton/home_screen_skeleton.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPostRoom,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'បង្ហោះបន្ទប់',
          style: GoogleFonts.battambang(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'បន្ទប់របស់ខ្ញុំ (${_allRooms.length})',
          style: GoogleFonts.battambang(
            color: AppColors.neutral,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openPostRoom,
            tooltip: 'បង្ហោះបន្ទប់ថ្មី',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          IconButton(
            onPressed: _fetchRooms,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.neutral),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Box (Exact Customer Search Layout)
          _buildSearchBox(),

          const SizedBox(height: 12),

          // Categories Filter Chips (Exact Customer Search Layout)
          _buildCategories(),

          const SizedBox(height: 10),

          // Room Results / Body
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

  // Customer-style Search Box
  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchCtrl,
        style: GoogleFonts.battambang(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'ស្វែងរកបន្ទប់, ទីតាំង...',
          hintStyle: GoogleFonts.battambang(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close, size: 20),
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // Customer-style Categories Bar
  Widget _buildCategories() {
    return SizedBox(
      height: 42,
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
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                category.text,
                style: GoogleFonts.battambang(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
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

    // Owner room list using Customer SearchRoomCard Layout
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 85),
      itemCount: _filteredRooms.length,
      itemBuilder: (context, index) {
        final room = _filteredRooms[index];
        return _buildOwnerSearchRoomCard(room);
      },
    );
  }

  // Exact Customer SearchRoomCard format customized for Owner
  Widget _buildOwnerSearchRoomCard(Datum room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(() => Detailscreen(id: room.id));
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail (Exact 120 width layout matching SearchRoomCard)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: 120,
                      child: room.image != null && room.image!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: room.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) {
                                return Container(color: Colors.grey.shade200);
                              },
                              errorWidget: (context, url, error) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.apartment_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: RoomStatusBadge(
                      status: room.status,
                      hasLatestBooking: room.latestBooking != null,
                      isCompact: true,
                    ),
                  ),
                ],
              ),

              // Content details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Owner Popup Menu
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              room.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.battambang(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
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
                                      style: GoogleFonts.battambang(
                                        fontSize: 13,
                                      ),
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
                                      style: GoogleFonts.battambang(
                                        fontSize: 13,
                                      ),
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
                                      style: GoogleFonts.battambang(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'លុបបន្ទប់',
                                      style: GoogleFonts.battambang(
                                        fontSize: 13,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Location & Address
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              room.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.battambang(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Rating & Price (Exact format)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            room.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            '\$${room.price.toStringAsFixed(0)}/month',
                            style: GoogleFonts.battambang(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Category tag & Status badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9ECFF),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              room.category.name,
                              style: GoogleFonts.battambang(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          RoomStatusBadge(
                            status: room.status,
                            hasLatestBooking: room.latestBooking != null,
                            isCompact: true,
                          ),
                        ],
                      ),

                      // Booking Deposit Banner if room has a paid booking
                      if (room.latestBooking != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Color(0xFF059669),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'បានកក់ប្រាក់ \$${room.latestBooking!.amount.toStringAsFixed(0)}',
                                      style: GoogleFonts.battambang(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF065F46),
                                      ),
                                    ),
                                    if (room.latestBooking!.customerName !=
                                            null &&
                                        room
                                            .latestBooking!
                                            .customerName!
                                            .isNotEmpty)
                                      Text(
                                        'កក់ដោយ: ${room.latestBooking!.customerName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.battambang(
                                          fontSize: 11,
                                          color: const Color(0xFF047857),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (room.latestBooking!.customerPhone != null &&
                                  room.latestBooking!.customerPhone!.isNotEmpty)
                                InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(
                                      'tel:${room.latestBooking!.customerPhone}',
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF059669,
                                      ).withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.phone_rounded,
                                      size: 16,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
