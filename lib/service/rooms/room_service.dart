import 'package:dio/dio.dart';
import 'package:roomdz_frontend/const/port.dart';
import 'package:roomdz_frontend/model/roomModel.dart';
import 'package:roomdz_frontend/rooms/room_detail_model.dart';

class RoomServer {
  final Dio _dio;

  RoomServer({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: '$port/api',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );
  Future<RoomDetialModel> getRoomsDetail(int id) async {
    try {
      final res = await _dio.get('/room/$id');

      if (res.statusCode == 200) {
        return RoomDetialModel.fromJson(res.data);
      }

      throw Exception('Failed to load room detail');
    } catch (e) {
      print('ERROR: $e');
      throw Exception('Something went wrong: $e');
    }
  }

  Future<RoomModel> getRooms() async {
    try {
      final response = await _dio.get('/room');
      if (response.statusCode == 200) {
        return RoomModel.fromJson(response.data);
      }

      throw Exception('Failed to load rooms: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      print('ERROR: $e');
      throw Exception('Something went wrong: $e');
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      return 'Server error ${e.response?.statusCode}: '
          '${e.response?.data}';
    }

    return '${e.type}: ${e.message}';
  }
}
