class AiDiagnosisRecord {
  final String diagnosisId;
  final String? customerId;
  final int? categoryId;
  final String? uploadedImageUrl;
  final String? aiAnalysisResult;
  final String? problemSummary;
  final int? estimatedMinPrice;
  final int? estimatedMaxPrice;
  final String? preventiveTips;
  final String? urgency;
  final DateTime createdAt;

  const AiDiagnosisRecord({
    required this.diagnosisId,
    required this.createdAt,
    this.customerId,
    this.categoryId,
    this.uploadedImageUrl,
    this.aiAnalysisResult,
    this.problemSummary,
    this.estimatedMinPrice,
    this.estimatedMaxPrice,
    this.preventiveTips,
    this.urgency,
  });

  static AiDiagnosisRecord fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.round();
      return int.tryParse(value.toString());
    }

    return AiDiagnosisRecord(
      diagnosisId: json['diagnosis_id'] as String,
      customerId: json['customer_id'] as String?,
      categoryId: toInt(json['category_id']),
      uploadedImageUrl: json['uploaded_image_url'] as String?,
      aiAnalysisResult: json['ai_analysis_result'] as String?,
      problemSummary: json['problem_summary'] as String?,
      estimatedMinPrice: toInt(json['estimated_min_price']),
      estimatedMaxPrice: toInt(json['estimated_max_price']),
      preventiveTips: json['preventive_tips'] as String?,
      urgency: json['urgency'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
