class FlowState {
  bool hasPhoto;
  String desc;
  String cat;
  String urgency;
  String area;
  String workerId;
  String selectedProblem;
  String workerFromRoute;
  String bookingFromRoute;
  bool unknownMode;
  String symptomText;
  String followUpTiming;
  String followUpMoisture;
  String followUpSeverity;
  String activeBookingId;

  // Hasil AI diagnosis terbaru (di-fill di analyzing screen)
  String? activeDiagnosisId;
  int? activeEstimatedMinPrice;
  int? activeEstimatedMaxPrice;
  String? activeAiAnalysis;
  String? uploadedImageUrl;

  // Lokasi user (di-fill dari onboarding / geo permission)
  double? currentLatitude;
  double? currentLongitude;

  // Cache pemetaan category label → category_id dari tabel `categories`
  Map<String, int> categoryIdByLabel;

  FlowState({
    this.hasPhoto = false,
    this.desc = '',
    this.cat = '',
    this.urgency = '',
    this.area = 'Tebet, Jakarta Selatan',
    this.workerId = 'rudi',
    this.selectedProblem = 'AC bocor',
    this.workerFromRoute = 'workers',
    this.bookingFromRoute = 'worker',
    this.unknownMode = false,
    this.symptomText = '',
    this.followUpTiming = '',
    this.followUpMoisture = '',
    this.followUpSeverity = '',
    this.activeBookingId = '',
    this.activeDiagnosisId,
    this.activeEstimatedMinPrice,
    this.activeEstimatedMaxPrice,
    this.activeAiAnalysis,
    this.uploadedImageUrl,
    this.currentLatitude,
    this.currentLongitude,
    Map<String, int>? categoryIdByLabel,
  }) : categoryIdByLabel = categoryIdByLabel ?? <String, int>{};

  int? categoryIdFor(String label) {
    if (label.isEmpty) return null;
    return categoryIdByLabel[label.toLowerCase()];
  }
}

class ServiceRequest {
  final String id;
  final String problemDescription;
  final String area;
  final String category;
  final String urgency;
  final String status;
  final String? selectedWorkerId;

  const ServiceRequest({
    required this.id,
    required this.problemDescription,
    required this.area,
    required this.category,
    required this.urgency,
    required this.status,
    this.selectedWorkerId,
  });
}
