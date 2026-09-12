import 'package:roomdz_frontend/model/roomModel.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlUtil {
  Future<void> open(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Clound not launch $url');
    }
  }

  // Future<void> navigateToRoom(RoomModel room) async {
  //   final url = Uri.parse(
  //     "https://www.google.com/maps/dir/"
  //     "?api=1"
  //     "&destination=${room.latitude},${room.longitude}",
  //   );
  //
  //   await launchUrl(url, mode: LaunchMode.externalApplication);
  // }
}
