enum ComplaintType { noShow, priceMismatch, poorQuality, safety, other }

enum ComplaintStatus { open, inReview, inMediation, resolved, rejected }

extension ComplaintTypeX on ComplaintType {
  String get value => switch (this) {
    ComplaintType.noShow => 'no_show',
    ComplaintType.priceMismatch => 'price_mismatch',
    ComplaintType.poorQuality => 'poor_quality',
    ComplaintType.safety => 'safety',
    ComplaintType.other => 'other',
  };

  String get label => switch (this) {
    ComplaintType.noShow => 'Tukang belum datang',
    ComplaintType.priceMismatch => 'Harga tidak sesuai',
    ComplaintType.poorQuality => 'Kualitas buruk',
    ComplaintType.safety => 'Masalah keamanan',
    ComplaintType.other => 'Lainnya',
  };

  static ComplaintType fromValue(String value) {
    return ComplaintType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ComplaintType.other,
    );
  }
}

extension ComplaintStatusX on ComplaintStatus {
  String get value => switch (this) {
    ComplaintStatus.open => 'open',
    ComplaintStatus.inReview => 'in_review',
    ComplaintStatus.inMediation => 'in_mediation',
    ComplaintStatus.resolved => 'resolved',
    ComplaintStatus.rejected => 'rejected',
  };

  String get label => switch (this) {
    ComplaintStatus.open => 'Terkirim',
    ComplaintStatus.inReview => 'Ditinjau',
    ComplaintStatus.inMediation => 'Dalam mediasi',
    ComplaintStatus.resolved => 'Selesai',
    ComplaintStatus.rejected => 'Ditolak',
  };

  static ComplaintStatus fromValue(String value) {
    return ComplaintStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ComplaintStatus.open,
    );
  }
}

class ComplaintTicket {
  final String id;
  final String bookingId;
  final ComplaintType type;
  final String description;
  final ComplaintStatus status;
  final List<String> evidenceImageUrls;
  final String? reporterId;
  final String? resolutionNote;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  const ComplaintTicket({
    required this.id,
    required this.bookingId,
    required this.type,
    required this.description,
    required this.status,
    required this.createdAt,
    this.evidenceImageUrls = const [],
    this.reporterId,
    this.resolutionNote,
    this.resolvedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'type': type.value,
      'description': description,
      'status': status.value,
      'evidence_image_urls': evidenceImageUrls,
      'reporter_id': reporterId,
      'resolution_note': resolutionNote,
      'resolved_at': resolvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  static ComplaintTicket fromJson(Map<String, dynamic> json) {
    final urls = json['evidence_image_urls'];
    return ComplaintTicket(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      type: ComplaintTypeX.fromValue(json['type'] as String? ?? 'other'),
      description: json['description'] as String? ?? '',
      status: ComplaintStatusX.fromValue(json['status'] as String? ?? 'open'),
      evidenceImageUrls: urls is List ? urls.cast<String>() : const [],
      reporterId: json['reporter_id'] as String?,
      resolutionNote: json['resolution_note'] as String?,
      resolvedAt: DateTime.tryParse(json['resolved_at'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
