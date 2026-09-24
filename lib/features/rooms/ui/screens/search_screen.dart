import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';
import 'package:roomdz_frontend/features/rooms/ui/controllers/category_filter_controller.dart';
import 'package:roomdz_frontend/features/rooms/data/models/room_model.dart';
import 'package:roomdz_frontend/features/rooms/ui/screens/detail_screen.dart';
import 'package:roomdz_frontend/features/rooms/ui/controllers/category_static_list.dart';
import 'package:roomdz_frontend/core/widgets/room_status_badge.dart';
import 'package:roomdz_frontend/core/widgets/skeleton/home_screen_skeleton.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late CategoryFilter categoryFilter;

  final TextEditingController searchController = TextEditingController();

  int selectedCategory = 0;

  @override
  void initState() {
    super.initState();

    categoryFilter = Get.find<CategoryFilter>();

    searchController.addListener(() {
      _searchRooms(searchController.text);
    });
  }

  void _searchRooms(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      categoryFilter.clearAllFilters();
      return;
    }

    final rooms = categoryFilter.allRooms.where((room) {
      final name = room.name.toLowerCase();
      final address = room.address.toLowerCase();
      final type = room.type.toLowerCase();
      final category = room.category.name.toLowerCase();

      return name.contains(search) ||
          address.contains(search) ||
          type.contains(search) ||
          category.contains(search);
    }).toList();

    categoryFilter.filteredRooms.assignAll(rooms);
  }

  void _selectCategory(int index) {
    setState(() {
      selectedCategory = index;
    });

    if (index == 0) {
      _searchRooms(searchController.text);
      return;
    }

    final category = categories[index];

    var rooms = categoryFilter.allRooms.where((room) {
      return room.categoryId == category.id;
    }).toList();

    final search = searchController.text.trim().toLowerCase();

    if (search.isNotEmpty) {
      rooms = rooms.where((room) {
        return room.name.toLowerCase().contains(search) ||
            room.address.toLowerCase().contains(search) ||
            room.type.toLowerCase().contains(search) ||
            room.category.name.toLowerCase().contains(search);
      }).toList();
    }

    categoryFilter.filteredRooms.assignAll(rooms);
  }

  void _clearSearch() {
    searchController.clear();

    setState(() {
      selectedCategory = 0;
    });

    categoryFilter.clearAllFilters();
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ស្វែងរកបន្ទប់',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBox(),

          _buildCategories(),

          const SizedBox(height: 8),

          Expanded(child: _buildRooms()),
        ],
      ),
    );
  }

  // search box
  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'ស្វែងរកបន្ទប់, ទីតាំង...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close),
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  // category list
  Widget _buildCategories() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          final isSelected = selectedCategory == index;

          return GestureDetector(
            onTap: () {
              _selectCategory(index);
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

  // room results
  Widget _buildRooms() {
    return Obx(() {
      if (categoryFilter.isLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: 4,
          itemBuilder: (context, index) => const HomeScreenSkeleton(),
        );
      }

      final rooms = categoryFilter.filteredRooms;

      if (rooms.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 4,
          bottom: 100,
        ),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return SearchRoomCard(room: rooms[index]);
        },
      );
    });
  }

  // empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 70, color: Colors.grey.shade400),

            const SizedBox(height: 16),

            const Text(
              'រកមិនឃើញបន្ទប់ជួល',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'សូមសាកល្បងឈ្មោះបន្ទប់ ឬទីតាំងផ្សេងទៀត',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: _clearSearch,
              child: const Text('សម្អាតការស្វែងរក'),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchRoomCard extends StatelessWidget {
  final Datum room;

  const SearchRoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(() => Detailscreen(id: room.id));
        },
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: room.image != null && room.image!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: room.image!,
                          width: 120,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) {
                            return Container(
                              width: 120,
                              height: 140,
                              color: Colors.grey.shade200,
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Container(
                              width: 120,
                              height: 140,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 120,
                          height: 140,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.apartment_outlined,
                            size: 40,
                            color: Colors.grey,
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
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
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

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
                          '\$${room.price}/ខែ',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9ECFF),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        room.category.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
