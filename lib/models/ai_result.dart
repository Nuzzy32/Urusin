class AiPriceEstimate {
  final String currency;
  final int min;
  final int max;
  final String label;

  const AiPriceEstimate({
    required this.currency,
    required this.min,
    required this.max,
    required this.label,
  });
}

class AiDurationEstimate {
  final int min;
  final int max;

  const AiDurationEstimate({required this.min, required this.max});
}

class AiResult {
  final String problemTitle;
  final String category;
  final String recommendedWorkerType;
  final String severity;
  final String urgency;
  final double confidence;
  final List<String> likelyCauses;
  final String explanation;
  final AiPriceEstimate estimatedPrice;
  final AiDurationEstimate estimatedDuration;
  final String recommendedNextStep;
  final String safetyNote;
  final String whatsappMessage;

  const AiResult({
    required this.problemTitle,
    required this.category,
    required this.recommendedWorkerType,
    required this.severity,
    required this.urgency,
    required this.confidence,
    required this.likelyCauses,
    required this.explanation,
    required this.estimatedPrice,
    required this.estimatedDuration,
    required this.recommendedNextStep,
    required this.safetyNote,
    required this.whatsappMessage,
  });
}
