import 'package:dio/dio.dart';
import 'package:roomdz_frontend/model/payment_model.dart';
import 'package:roomdz_frontend/service/api_client.dart';

/// Exception thrown when Bakong Open API rate limit (100 requests) is reached
class BakongLimitException implements Exception {
  final String message;
  final int requestCount;
  final int requestLimit;

  BakongLimitException(
    this.message, {
    this.requestCount = 100,
    this.requestLimit = 100,
  });

  @override
  String toString() => message;
}

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
      final result = PaymentCheckStatusResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      if (result.limitReached) {
        throw BakongLimitException(
          result.message.isNotEmpty
              ? result.message
              : 'ការស្នើសុំទៅកាន់ Bakong ដល់កម្រិតកំណត់ 100 ដងហើយ (Bakong Limit Reached)',
          requestCount: result.bakongRequestCount,
          requestLimit: result.bakongRequestLimit,
        );
      }

      return result;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (e.response?.statusCode == 429 ||
          (data is Map &&
              (data['limit_reached'] == true ||
                  data['status'] == 'limit_reached'))) {
        final count =
            (data is Map ? data['bakong_request_count'] : null) ?? 100;
        final limit =
            (data is Map ? data['bakong_request_limit'] : null) ?? 100;
        final msg = (data is Map ? data['message'] : null) ??
            'ការស្នើសុំទៅកាន់ Bakong ដល់កម្រិតកំណត់ $count/$limit ដងហើយ (Bakong Limit Reached)។';
        throw BakongLimitException(
          msg.toString(),
          requestCount: count is num ? count.toInt() : 100,
          requestLimit: limit is num ? limit.toInt() : 100,
        );
      }

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