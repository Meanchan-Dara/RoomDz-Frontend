import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapUtil {
  /// Opens Google Maps at the specified [latitude] and [longitude].
  static Future<void> openGoogleMaps({
    required double latitude,
    required double longitude,
  }) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      Get.snackbar(
        'Error',
        'Could not open Google Maps',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}