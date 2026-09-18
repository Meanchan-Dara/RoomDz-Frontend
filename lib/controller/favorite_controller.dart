import 'package:get/get.dart';
import 'package:roomdz_frontend/service/api_client.dart';

class FavoriteController extends GetxController {
  final RxList<int> favoriteRoomIds = <int>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final hasToken = await ApiClient.hasToken();
      if (!hasToken) return;

      isLoading.value = true;
      final response = await ApiClient.instance.get('/favorites');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final List list = data['data'];
        final ids = list
            .map((item) => (item['id'] as num?)?.toInt())
            .whereType<int>()
            .toList();
        favoriteRoomIds.assignAll(ids);
      }
    } catch (_) {
      // Keep existing state if offline
    } finally {
      isLoading.value = false;
    }
  }

  bool isFavorite(int roomId) {
    return favoriteRoomIds.contains(roomId);
  }

  Future<void> toggleFavorite(int roomId) async {
    final willBeFavorite = !isFavorite(roomId);
    if (willBeFavorite) {
      favoriteRoomIds.add(roomId);
    } else {
      favoriteRoomIds.remove(roomId);
    }

    try {
      final hasToken = await ApiClient.hasToken();
      if (hasToken) {
        await ApiClient.instance.post('/favorites/toggle/$roomId');
      }
    } catch (_) {}
  }

  Future<void> removeFavorite(int roomId) async {
    favoriteRoomIds.remove(roomId);
    try {
      final hasToken = await ApiClient.hasToken();
      if (hasToken) {
        await ApiClient.instance.post('/favorites/toggle/$roomId');
      }
    } catch (_) {}
  }

  void clearFavorites() {
    favoriteRoomIds.clear();
  }
}
