import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:roomdz_frontend/controller/category_fillter.dart';

class LocationController extends GetxController {
  final CategoryFilter categoryFilter;

  LocationController({required this.categoryFilter});

  final TextEditingController locationTextController = TextEditingController();

  final RxBool isLocationSearching = false.obs;

  final RxBool isGettingCurrentLocation = false.obs;

  final RxString currentLocation = 'Choose your location'.obs;

  final RxList<String> locationSuggestions = <String>[].obs;

  // available locations in phnom penh
  final List<String> availableLocations = [
    'Toul Kork',
    'Chamkarmon',
    'Sen Sok',
    'Daun Penh',
    'Prampir Meakkakra',
    'Dangkao',
    'Meanchey',
    'Russey Keo',
    'Por Senchey',
    'Chroy Changvar',
    'Prek Pnov',
    'Chbar Ampov',
    'Boeng Keng Kang',
    'Kamboul',
    'BKK 1',
    'BKK 2',
    'BKK 3',
    'Toul Tom Poung',
    'Russian Market',
    'Olympic',
    'Riverside',
    'Wat Phnom',
    'Aeon Sen Sok',
  ];

  // search location suggestions
  void searchLocation(String query) {
    if (query.trim().isEmpty) {
      locationSuggestions.clear();
      isLocationSearching.value = false;
      return;
    }

    final suggestions = categoryFilter.getLocationSuggestions(query);

    locationSuggestions.assignAll(suggestions);

    isLocationSearching.value = true;
  }

  // select location from suggestion
  void selectLocation(String location) {
    locationTextController.text = location;

    currentLocation.value = location;

    locationSuggestions.clear();

    isLocationSearching.value = false;

    categoryFilter.selectLocation(location);
  }

  // clear location search
  void clearLocation() {
    locationTextController.clear();

    locationSuggestions.clear();

    isLocationSearching.value = false;

    currentLocation.value = 'Choose your location';

    categoryFilter.clearLocation();
  }

  // get current device location
  Future<void> getCurrentLocation() async {
    try {
      isGettingCurrentLocation.value = true;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        Get.snackbar(
          'Location disabled',
          'Please turn on location service on your device.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission denied',
          'Location permission was denied.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission denied',
          'Please enable location permission from settings.',
          snackPosition: SnackPosition.BOTTOM,
        );

        await Geolocator.openAppSettings();

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        Get.snackbar(
          'Location not found',
          'Could not find your location.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      final place = placemarks.first;

      final locationParts = <String>[];

      if (place.subLocality != null && place.subLocality!.trim().isNotEmpty) {
        locationParts.add(place.subLocality!.trim());
      }

      if (place.locality != null && place.locality!.trim().isNotEmpty) {
        locationParts.add(place.locality!.trim());
      }

      if (place.administrativeArea != null &&
          place.administrativeArea!.trim().isNotEmpty &&
          !locationParts.contains(place.administrativeArea!.trim())) {
        locationParts.add(place.administrativeArea!.trim());
      }

      final locationName = locationParts.join(', ');

      if (locationName.isEmpty) {
        Get.snackbar(
          'Location not found',
          'Could not convert GPS location to an address.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      locationTextController.text = locationName;

      currentLocation.value = locationName;

      categoryFilter.searchByLocation(locationName);

      locationSuggestions.clear();

      isLocationSearching.value = false;
    } catch (e) {
      print('error getting current location: $e');

      Get.snackbar(
        'Location error',
        'Unable to get your current location.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGettingCurrentLocation.value = false;
    }
  }

  // show location selection bottom sheet
  void showLocationBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose your location',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose an area to find rooms',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),

              const SizedBox(height: 16),

              // use current location
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
                title: const Text(
                  'Use my current location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Use GPS to find your location'),
                onTap: () {
                  Get.back();
                  getCurrentLocation();
                },
              ),

              const Divider(),

              // manual locations
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableLocations.length,
                  itemBuilder: (context, index) {
                    final location = availableLocations[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.red,
                        ),
                      ),
                      title: Text(
                        location,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                      onTap: () {
                        Get.back();
                        selectLocation(location);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // reset location
  void resetLocation() {
    locationTextController.clear();

    locationSuggestions.clear();

    isLocationSearching.value = false;

    currentLocation.value = 'Choose your location';

    categoryFilter.clearLocation();
  }

  @override
  void onClose() {
    locationTextController.dispose();

    super.onClose();
  }
}
