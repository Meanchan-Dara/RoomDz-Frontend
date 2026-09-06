import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({super.key});

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  BitmapDescriptor? customMarker;

  @override
  void initState() {
    super.initState();
    loadCustomMarker();
  }

  Future<void> loadCustomMarker() async {
    customMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(80, 80)),
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
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(11.5683, 104.9211),

          zoom: 18,
        ),
        markers: markers,
      ),
    );
  }
}
