import 'package:dio/dio.dart';
import 'package:roomdz_frontend/model/payment_model.dart';
import 'package:roomdz_frontend/service/api_client.dart';

class PaymentService {
  final Dio dio;

  PaymentService({Dio? dio}) : dio = dio ?? ApiClient.instance;

  /// Generate a dynamic Bakong KHQR for room deposit, rent, or custom payment
  Future<PaymentQrResponse> createQr({
    required int roomId,
    double? amount,
    String? currency = 'USD',
    String? paymentType = 'booking_deposit',
    String? customerName,
    String? customerPhone,
    String? description,
  }) async {
    try {
      final response = await dio.post(
        '/payments/create-qr',
        data: {
          'room_id': roomId,
          if (amount != null && amount > 0) 'amount': amount,
          'currency': currency ?? 'USD',
          'payment_type': paymentType ?? 'booking_deposit',
          if (customerName != null && customerName.isNotEmpty)
            'customer_name': customerName,
          if (customerPhone != null && customerPhone.isNotEmpty)
            'customer_phone': customerPhone,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );

      return PaymentQrResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          'មិនអាចបង្កើត QR កូដទូទាត់ប្រាក់បាគងបានទេ';
      throw Exception(errorMsg);
    }
  }

  /// Check payment status by Payment ID
  /// Queries NBC Bakong Open API through backend
  Future<PaymentCheckStatusResponse> checkStatus(int paymentId) async {
    try {
      final response = await dio.get('/payments/$paymentId/status');
      return PaymentCheckStatusResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'មិនអាចពិនិត្យស្ថានភាពបង់ប្រាក់បានទេ';
      throw Exception(errorMsg);
    }
  }

  /// Simulate a successful payment completion (Useful for testing UI flow)
  Future<PaymentCheckStatusResponse> simulateSuccess(int paymentId) async {
    try {
      final response = await dio.post('/payments/$paymentId/simulate-success');
      return PaymentCheckStatusResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'មិនអាចសាកល្បងបង់ប្រាក់បានទេ';
      throw Exception(errorMsg);
    }
  }

  /// Fetch payment history
  Future<List<dynamic>> getPayments({bool myRoomsOnly = false}) async {
    try {
      final response = await dio.get(
        '/payments',
        queryParameters: {if (myRoomsOnly) 'my_rooms_only': 1},
      );
      final data = response.data?['data']?['data'] ?? response.data?['data'];
      if (data is List) {
        return data;
      }
      return [];
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Failed to load payments';
      throw Exception(errorMsg);
    }
  }
}
