import 'package:get/get.dart';
import 'package:roomdz_frontend/model/roomModel.dart';
import 'package:roomdz_frontend/rooms/room_detail_model.dart';

class FavoriteController extends GetxController {
  final RxList<int> favoriteRoomIds = <int>[].obs;
  bool isFavorite(int roomId) {
    return favoriteRoomIds.contains(roomId);
  }

  void toggleFavorite(int roomId) {
    if (isFavorite(roomId)) {
      favoriteRoomIds.remove(roomId);
    } else {
      favoriteRoomIds.add(roomId);
    }
  }

  void removeFavorite(int roomId) {
    favoriteRoomIds.remove(roomId);
  }

  void clearFavorites() {
    favoriteRoomIds.clear();
  }
}
