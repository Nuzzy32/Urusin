enum WorkerVerificationStatus { draft, submitted, pending, approved, rejected }

extension WorkerVerificationStatusX on WorkerVerificationStatus {
  String get value => switch (this) {
    WorkerVerificationStatus.draft => 'draft',
    WorkerVerificationStatus.submitted => 'submitted',
    WorkerVerificationStatus.pending => 'pending',
    WorkerVerificationStatus.approved => 'approved',
    WorkerVerificationStatus.rejected => 'rejected',
  };

  String get label => switch (this) {
    WorkerVerificationStatus.draft => 'Draft',
    WorkerVerificationStatus.submitted => 'Terkirim',
    WorkerVerificationStatus.pending => 'Menunggu Verifikasi',
    WorkerVerificationStatus.approved => 'Terverifikasi',
    WorkerVerificationStatus.rejected => 'Ditolak',
  };

  static WorkerVerificationStatus fromValue(String value) {
    return WorkerVerificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => WorkerVerificationStatus.draft,
    );
  }
}

class WorkerApplication {
  final String id;
  final String fullName;
  final String businessName;
  final String whatsapp;
  final String domicile;
  final String bio;
  final List<String> services;
  final List<String> subServices;
  final List<String> areas;
  final List<String> days;
  final String startTime;
  final String endTime;
  final Map<String, String> priceFrom;
  final Map<String, String> priceTo;
  final String ktpAssetPath;
  final String selfieAssetPath;
  final List<String> portfolioAssetPaths;
  final WorkerVerificationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkerApplication({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.whatsapp,
    required this.domicile,
    required this.bio,
    required this.services,
    required this.subServices,
    required this.areas,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.priceFrom,
    required this.priceTo,
    required this.ktpAssetPath,
    required this.selfieAssetPath,
    required this.portfolioAssetPaths,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'business_name': businessName,
      'whatsapp': whatsapp,
      'domicile': domicile,
      'bio': bio,
      'ktp_asset_path': ktpAssetPath,
      'selfie_asset_path': selfieAssetPath,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  List<Map<String, dynamic>> servicesToRows() => [
    for (final s in services)
      {'application_id': id, 'service_name': s, 'is_sub_service': false},
    for (final s in subServices)
      {'application_id': id, 'service_name': s, 'is_sub_service': true},
  ];

  List<Map<String, dynamic>> areasToRows() => [
    for (final a in areas) {'application_id': id, 'area_name': a},
  ];

  List<Map<String, dynamic>> schedulesToRows() => [
    for (final d in days)
      {
        'application_id': id,
        'day_name': d,
        // UI pakai '08.00'; Postgres time butuh '08:00'.
        'start_time': startTime.replaceAll('.', ':'),
        'end_time': endTime.replaceAll('.', ':'),
      },
  ];

  List<Map<String, dynamic>> pricesToRows() => [
    for (final entry in priceFrom.entries)
      {
        'application_id': id,
        'service_name': entry.key,
        'price_from': int.tryParse(
          entry.value.replaceAll(RegExp(r'[^0-9]'), ''),
        ),
        'price_to': int.tryParse(
          (priceTo[entry.key] ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
        ),
      },
  ];

  List<Map<String, dynamic>> portfoliosToRows() => [
    for (var i = 0; i < portfolioAssetPaths.length; i++)
      {
        'application_id': id,
        'asset_path': portfolioAssetPaths[i],
        'sort_order': i,
      },
  ];
}
