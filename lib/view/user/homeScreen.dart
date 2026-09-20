import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/controller/category_fillter.dart';
import 'package:roomdz_frontend/controller/location_controller.dart';
import 'package:roomdz_frontend/controller/profile_controller.dart';
import 'package:roomdz_frontend/model/roomModel.dart';
import 'package:roomdz_frontend/service/rooms/room_service.dart';
import 'package:roomdz_frontend/view/user/detailScreen.dart';
import 'package:roomdz_frontend/view/user/profile_Screen.dart';
import 'package:roomdz_frontend/viewmodel/viewCategory.dart';
import 'package:roomdz_frontend/widget/skeleton/home_screen_skeleton.dart';
import 'package:roomdz_frontend/controller/favorite_controller.dart';
import 'package:roomdz_frontend/widget/home_banner_slider.dart';
import 'package:roomdz_frontend/widget/room_status_badge.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final ProfileController _profileCtrl = Get.put(ProfileController());

  final RoomServer roomService = RoomServer();

  int selectedCategories = 0;

  late CategoryFilter categoryFilter;
  late LocationController locationController;

  @override
  void initState() {
    super.initState();

    categoryFilter = Get.put(CategoryFilter(roomServer: roomService));

    locationController = Get.put(
      LocationController(categoryFilter: categoryFilter),
    );
  }

  // refresh room list
  Future<void> _refreshRooms() async {
    locationController.resetLocation();

    selectedCategories = 0;

    await categoryFilter.getRooms();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, size: 28),
          ),
        ],
        leading: GestureDetector(
          onTap: () => Get.to(() => const ProfileScreen()),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              final path = _profileCtrl.localAvatarPath.value;
              final remote = _profileCtrl.currentUser.value?.avatar;

              ImageProvider image;
              if (path != null && path.isNotEmpty && File(path).existsSync()) {
                image = FileImage(File(path));
              } else if (remote != null && remote.isNotEmpty) {
                image = CachedNetworkImageProvider(remote);
              } else {
                image = const NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                );
              }

              return CircleAvatar(radius: 25, backgroundImage: image);
            }),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Room-Dz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.primary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRooms,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentLocation(),

                const SizedBox(height: 16),

                _buildCategory(),

                const SizedBox(height: 16),

                const HomeBannerSlider(),

                const SizedBox(height: 16),

                _buildBody(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // current location section
  Widget _buildCurrentLocation() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on, color: AppColors.primary),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ទីតាំងបច្ចុប្បន្ន',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    locationController.currentLocation.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            locationController.isGettingCurrentLocation.value
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.my_location,
                      color: AppColors.primary.withValues(alpha: 0.4),
                      size: 22,
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      locationController.showLocationBottomSheet(context);
                    },
                    icon: Icon(Icons.my_location, color: AppColors.primary),
                    tooltip: 'ជ្រើសរើសទីតាំង',
                  ),
          ],
        ),
      ),
    );
  }

  // rooms body
  Widget _buildBody() {
    return Obx(() {
      if (categoryFilter.isLoading.value) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return const HomeScreenSkeleton();
          },
        );
      }

      final rooms = categoryFilter.filteredRooms;

      if (rooms.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Text(
              'មិនមានបន្ទប់ជួលទេ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      return ListView.builder(
        itemCount: rooms.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final Datum room = rooms[index];

          return RoomCard(room: room);
        },
      );
    });
  }

  // category filter
  Widget _buildCategory() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          final bool isSelected = selectedCategories == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategories = index;
              });

              categoryFilter.filterByCategory(category.id);
            },
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
              ),
              child: Text(
                category.text,
                textAlign: TextAlign.center,
                style: TextStyle(
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
}

class RoomCard extends StatelessWidget {
  final Datum room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final FavoriteController favoriteController =
        Get.find<FavoriteController>();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: room.image != null && room.image!.isNotEmpty
                    ? CachedNetworkImage(
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl: room.image!,
                        placeholder: (context, url) {
                          return Container(
                            height: 180,
                            color: Colors.grey.shade200,
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.apartment_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        //title
                        room.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      //price
                      '\$${room.price}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      ' /ខែ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        room.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(icon: Icons.home_outlined, label: room.type),

                      const SizedBox(width: 8),

                      _buildChip(
                        icon: Icons.category_outlined,
                        label: room.category.name,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.to(() => Detailscreen(id: room.id));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(double.infinity, 42),
                    ),
                    child: const Text(
                      'មើលព័ត៌មានលម្អិត',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),

          Positioned(
            top: 12,
            left: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        room.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                RoomStatusBadge(
                  status: room.status,
                  hasLatestBooking: room.latestBooking != null,
                ),
              ],
            ),
          ),
          //favorate icon
          Positioned(
            top: 12,
            right: 12,
            child: Obx(() {
              final isFavorite = favoriteController.isFavorite(room.id);

              return Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                  onTap: () {
                    favoriteController.toggleFavorite(room.id);
                  },
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),

          const SizedBox(width: 6),

          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
