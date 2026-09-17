import 'package:url_launcher/url_launcher.dart';

class UrlUtil {
  Future<void> open(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> openGoogleMaps({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open Google Maps');
    }
  }
}
