import 'package:get/get.dart';
import 'package:roomdz_frontend/features/rooms/data/models/room_model.dart';
import 'package:roomdz_frontend/features/rooms/data/services/room_service.dart';

class CategoryFilter extends GetxController {
  final RoomServer roomServer;

  CategoryFilter({required this.roomServer});

  // all rooms
  final RxList<Datum> allRooms = <Datum>[].obs;

  // rooms after filter
  final RxList<Datum> filteredRooms = <Datum>[].obs;

  // selected category id
  final RxInt selectedCategoryId = 0.obs;

  // selected location
  final RxString selectedLocation = ''.obs;

  // search location
  final RxString searchLocation = ''.obs;

  // loading
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getRooms();
  }

  // get all rooms
  Future<void> getRooms() async {
    try {
      isLoading.value = true;

      final roomModel = await roomServer.getRooms();

      allRooms.assignAll(roomModel.data);
      filteredRooms.assignAll(roomModel.data);
    } catch (e) {
      print('error getting rooms: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // filter rooms by category
  void filterByCategory(int categoryId) {
    selectedCategoryId.value = categoryId;

    _applyFilters();
  }

  // search rooms by location
  void searchByLocation(String location) {
    searchLocation.value = location;

    _applyFilters();
  }

  // select location
  void selectLocation(String location) {
    selectedLocation.value = location;
    searchLocation.value = location;

    _applyFilters();
  }

  // clear location
  void clearLocation() {
    selectedLocation.value = '';
    searchLocation.value = '';

    _applyFilters();
  }

  // get location suggestions
  List<String> getLocationSuggestions(String query) {
    if (query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase().trim();

    final locations = <String>{};

    for (final room in allRooms) {
      final address = room.address.trim();

      if (address.toLowerCase().contains(lowerQuery)) {
        locations.add(address);
      }
    }

    return locations.toList();
  }

  // get all available locations
  List<String> get allLocations {
    final locations = <String>{};

    for (final room in allRooms) {
      if (room.address.trim().isNotEmpty) {
        locations.add(room.address.trim());
      }
    }

    return locations.toList();
  }

  // apply category and location filters
  void _applyFilters() {
    var result = List<Datum>.from(allRooms);

    // category filter
    if (selectedCategoryId.value != 0) {
      result = result
          .where((room) => room.categoryId == selectedCategoryId.value)
          .toList();
    }

    // location filter
    if (searchLocation.value.trim().isNotEmpty) {
      final location = searchLocation.value.toLowerCase().trim();

      result = result
          .where(
            (room) =>
                room.address.toLowerCase().contains(location) ||
                room.name.toLowerCase().contains(location),
          )
          .toList();
    }

    filteredRooms.assignAll(result);
  }

  // clear category filter
  void clearFilter() {
    selectedCategoryId.value = 0;

    _applyFilters();
  }

  // clear all filters
  void clearAllFilters() {
    selectedCategoryId.value = 0;
    selectedLocation.value = '';
    searchLocation.value = '';

    filteredRooms.assignAll(allRooms);
  }
}
