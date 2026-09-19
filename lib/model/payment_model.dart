class PaymentQrResponse {
  final bool success;
  final String message;
  final PaymentQrData? data;

  PaymentQrResponse({required this.success, required this.message, this.data});

  factory PaymentQrResponse.fromJson(Map<String, dynamic> json) {
    return PaymentQrResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] != null && json['data'] is Map
          ? PaymentQrData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class PaymentQrData {
  final int paymentId;
  final String billNumber;
  final double amount;
  final String currency;
  final String paymentType;
  final String status;
  final String qrString;
  final String? qrImage;
  final String md5;
  final String bakongAccountId;
  final String merchantName;
  final String? customerName;
  final String? customerPhone;
  final String? description;
  final DateTime? expiresAt;
  final PaymentRoomInfo? room;

  PaymentQrData({
    required this.paymentId,
    required this.billNumber,
    required this.amount,
    required this.currency,
    required this.paymentType,
    required this.status,
    required this.qrString,
    this.qrImage,
    required this.md5,
    required this.bakongAccountId,
    required this.merchantName,
    this.customerName,
    this.customerPhone,
    this.description,
    this.expiresAt,
    this.room,
  });

  factory PaymentQrData.fromJson(Map<String, dynamic> json) {
    DateTime? parsedExpiry;
    if (json['expires_at'] != null) {
      parsedExpiry = DateTime.tryParse(json['expires_at'].toString());
    }

    return PaymentQrData(
      paymentId: json['payment_id'] is num
          ? (json['payment_id'] as num).toInt()
          : (int.tryParse(json['payment_id']?.toString() ?? '0') ?? 0),
      billNumber: (json['bill_number'] ?? '').toString(),
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : (double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0),
      currency: (json['currency'] ?? 'USD').toString(),
      paymentType: (json['payment_type'] ?? 'booking_deposit').toString(),
      status: (json['status'] ?? 'pending').toString(),
      qrString: (json['qr_string'] ?? '').toString(),
      qrImage: json['qr_image']?.toString(),
      md5: (json['md5'] ?? '').toString(),
      bakongAccountId: (json['bakong_account_id'] ?? '').toString(),
      merchantName: (json['merchant_name'] ?? '').toString(),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      description: json['description']?.toString(),
      expiresAt: parsedExpiry,
      room: json['room'] != null && json['room'] is Map
          ? PaymentRoomInfo.fromJson(Map<String, dynamic>.from(json['room']))
          : null,
    );
  }
}

class PaymentRoomInfo {
  final int id;
  final String name;
  final double price;
  final double? depositPrice;
  final String? pricePeriod;
  final String? image;

  PaymentRoomInfo({
    required this.id,
    required this.name,
    required this.price,
    this.depositPrice,
    this.pricePeriod,
    this.image,
  });

  factory PaymentRoomInfo.fromJson(Map<String, dynamic> json) {
    return PaymentRoomInfo(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: (json['name'] ?? '').toString(),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0),
      depositPrice: json['deposit_price'] is num
          ? (json['deposit_price'] as num).toDouble()
          : (double.tryParse(json['deposit_price']?.toString() ?? '')),
      pricePeriod: json['price_period']?.toString(),
      image: json['image']?.toString(),
    );
  }
}

class PaymentCheckStatusResponse {
  final bool success;
  final String status;
  final bool isPaid;
  final String message;
  final PaymentCheckStatusData? data;

  PaymentCheckStatusResponse({
    required this.success,
    required this.status,
    required this.isPaid,
    required this.message,
    this.data,
  });

  factory PaymentCheckStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentCheckStatusResponse(
      success: json['success'] == true,
      status: (json['status'] ?? 'pending').toString(),
      isPaid: json['is_paid'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] != null && json['data'] is Map
          ? PaymentCheckStatusData.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
    );
  }
}

class PaymentCheckStatusData {
  final int paymentId;
  final String billNumber;
  final double amount;
  final String currency;
  final DateTime? paidAt;
  final String? bakongHash;

  PaymentCheckStatusData({
    required this.paymentId,
    required this.billNumber,
    required this.amount,
    required this.currency,
    this.paidAt,
    this.bakongHash,
  });

  factory PaymentCheckStatusData.fromJson(Map<String, dynamic> json) {
    DateTime? parsedPaidAt;
    if (json['paid_at'] != null) {
      parsedPaidAt = DateTime.tryParse(json['paid_at'].toString());
    }

    return PaymentCheckStatusData(
      paymentId: json['payment_id'] is num
          ? (json['payment_id'] as num).toInt()
          : (int.tryParse(json['payment_id']?.toString() ?? '0') ?? 0),
      billNumber: (json['bill_number'] ?? '').toString(),
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : (double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0),
      currency: (json['currency'] ?? 'USD').toString(),
      paidAt: parsedPaidAt,
      bakongHash: json['bakong_hash']?.toString(),
    );
  }
}
