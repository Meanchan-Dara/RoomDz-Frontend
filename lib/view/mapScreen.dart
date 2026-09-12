import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roomdz_frontend/view/detailScreen.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({super.key});

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

// Room? selectedRoom;
class _MapscreenState extends State<Mapscreen> {
  BitmapDescriptor? customMarker;

  @override
  void initState() {
    super.initState();
    loadCustomMarker();
  }

  Future<void> loadCustomMarker() async {
    customMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(65, 65)),
      "assets/images/pin.png",
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId("room_1"),
        position: const LatLng(11.5683, 104.9211),

        // Custom marker
        icon: customMarker!,

        infoWindow: const InfoWindow(title: "Room A", snippet: "\$150 / month"),
      ),

      Marker(
        anchor: const Offset(0.5, 1.0),

        markerId: const MarkerId("room_2"),
        position: const LatLng(11.5720, 104.9250),
        icon: customMarker!,
        infoWindow: const InfoWindow(title: "Room B", snippet: "\$200 / month"),
      ),

      Marker(
        anchor: const Offset(0.5, 1.0),

        markerId: const MarkerId("room_3"),
        position: const LatLng(11.5650, 104.9180),
        icon: customMarker!,
        infoWindow: const InfoWindow(title: "Room C", snippet: "\$120 / month"),
      ),
    };

    return Scaffold(
      body: GestureDetector(
        onDoubleTap: () {
          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'fafggg',
                    // room.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '12',
                    // room.price,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text("View Room"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(11.5683, 104.9211),
            zoom: 15,
          ),
          markers: markers,
        ),
      ),
    );
  }
}
