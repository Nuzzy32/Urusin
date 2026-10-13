enum BookingStatus {
  created,
  accepted,
  onTheWay,
  inProgress,
  finalPricePending,
  completed,
  reviewed,
  cancelled,
  disputed,
}

enum ChatChannel { whatsapp, inApp }

extension BookingStatusX on BookingStatus {
  String get value => switch (this) {
    BookingStatus.created => 'created',
    BookingStatus.accepted => 'accepted',
    BookingStatus.onTheWay => 'on_the_way',
    BookingStatus.inProgress => 'in_progress',
    BookingStatus.finalPricePending => 'final_price_pending',
    BookingStatus.completed => 'completed',
    BookingStatus.reviewed => 'reviewed',
    BookingStatus.cancelled => 'cancelled',
    BookingStatus.disputed => 'disputed',
  };

  String get label => switch (this) {
    BookingStatus.created => 'Menunggu konfirmasi',
    BookingStatus.accepted => 'Dikonfirmasi tukang',
    BookingStatus.onTheWay => 'Dalam perjalanan',
    BookingStatus.inProgress => 'Pekerjaan dimulai',
    BookingStatus.finalPricePending => 'Konfirmasi harga final',
    BookingStatus.completed => 'Selesai',
    BookingStatus.reviewed => 'Sudah direview',
    BookingStatus.cancelled => 'Dibatalkan',
    BookingStatus.disputed => 'Dalam mediasi',
  };

  static BookingStatus fromValue(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BookingStatus.created,
    );
  }
}

extension ChatChannelX on ChatChannel {
  String get value => switch (this) {
    ChatChannel.whatsapp => 'whatsapp',
    ChatChannel.inApp => 'in_app',
  };

  String get label => switch (this) {
    ChatChannel.whatsapp => 'WhatsApp',
    ChatChannel.inApp => 'In-app chat',
  };

  static ChatChannel fromValue(String value) {
    return ChatChannel.values.firstWhere(
      (channel) => channel.value == value,
      orElse: () => ChatChannel.whatsapp,
    );
  }
}

class BookingDraft {
  final String workerId;
  final String category;
  final String problem;
  final String aiSummary;
  final int estimatedPriceMin;
  final int estimatedPriceMax;
  final String schedule;
  final String address;
  final String accessNote;
  final String customerNote;
  final String paymentMethod;
  final ChatChannel chatChannel;
  final String? diagnosisId;

  const BookingDraft({
    required this.workerId,
    required this.category,
    required this.problem,
    required this.aiSummary,
    required this.estimatedPriceMin,
    required this.estimatedPriceMax,
    required this.schedule,
    required this.address,
    required this.accessNote,
    required this.customerNote,
    required this.paymentMethod,
    this.chatChannel = ChatChannel.whatsapp,
    this.diagnosisId,
  });
}

class ServiceBooking {
  final String id;
  final String? bookingCode;
  final String? diagnosisId;
  final String customerId;
  final String workerId;
  final String category;
  final String problem;
  final String aiSummary;
  final int estimatedPriceMin;
  final int estimatedPriceMax;
  final int? finalPrice;
  final String? finalPriceNote;
  final BookingStatus status;
  final String schedule;
  final String address;
  final String accessNote;
  final String customerNote;
  final String paymentMethod;
  final ChatChannel chatChannel;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceBooking({
    required this.id,
    required this.customerId,
    required this.workerId,
    required this.category,
    required this.problem,
    required this.aiSummary,
    required this.estimatedPriceMin,
    required this.estimatedPriceMax,
    required this.status,
    required this.schedule,
    required this.address,
    required this.accessNote,
    required this.customerNote,
    required this.paymentMethod,
    required this.chatChannel,
    required this.createdAt,
    required this.updatedAt,
    this.bookingCode,
    this.diagnosisId,
    this.finalPrice,
    this.finalPriceNote,
  });

  ServiceBooking copyWith({
    BookingStatus? status,
    int? finalPrice,
    String? finalPriceNote,
    String? bookingCode,
    String? diagnosisId,
    DateTime? updatedAt,
  }) {
    return ServiceBooking(
      id: id,
      bookingCode: bookingCode ?? this.bookingCode,
      diagnosisId: diagnosisId ?? this.diagnosisId,
      customerId: customerId,
      workerId: workerId,
      category: category,
      problem: problem,
      aiSummary: aiSummary,
      estimatedPriceMin: estimatedPriceMin,
      estimatedPriceMax: estimatedPriceMax,
      finalPrice: finalPrice ?? this.finalPrice,
      finalPriceNote: finalPriceNote ?? this.finalPriceNote,
      status: status ?? this.status,
      schedule: schedule,
      address: address,
      accessNote: accessNote,
      customerNote: customerNote,
      paymentMethod: paymentMethod,
      chatChannel: chatChannel,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_code': bookingCode,
      'diagnosis_id': diagnosisId,
      'customer_id': customerId,
      'worker_id': workerId,
      'category': category,
      'problem': problem,
      'ai_summary': aiSummary,
      'estimated_price_min': estimatedPriceMin,
      'estimated_price_max': estimatedPriceMax,
      'final_price': finalPrice,
      'final_price_note': finalPriceNote,
      'status': status.value,
      'schedule': schedule,
      'address': address,
      'access_note': accessNote,
      'customer_note': customerNote,
      'payment_method': paymentMethod,
      'chat_channel': chatChannel.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static ServiceBooking fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      id: json['id'] as String,
      bookingCode: json['booking_code'] as String?,
      diagnosisId: json['diagnosis_id'] as String?,
      customerId: json['customer_id'] as String? ?? 'demo-customer',
      workerId: json['worker_id'] as String,
      category: json['category'] as String? ?? '',
      problem: json['problem'] as String? ?? '',
      aiSummary: json['ai_summary'] as String? ?? '',
      estimatedPriceMin: json['estimated_price_min'] as int? ?? 0,
      estimatedPriceMax: json['estimated_price_max'] as int? ?? 0,
      finalPrice: json['final_price'] as int?,
      finalPriceNote: json['final_price_note'] as String?,
      status: BookingStatusX.fromValue(json['status'] as String? ?? 'created'),
      schedule: json['schedule'] as String? ?? '',
      address: json['address'] as String? ?? '',
      accessNote: json['access_note'] as String? ?? '',
      customerNote: json['customer_note'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      chatChannel: ChatChannelX.fromValue(
        json['chat_channel'] as String? ?? 'whatsapp',
      ),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
