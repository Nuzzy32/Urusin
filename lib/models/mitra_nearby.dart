class MitraNearby {
  final String mitraId;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final double avgRating;
  final int totalReviews;
  final int jobsDone;
  final int yearsExperience;
  final String? sampleReview;
  final int priceMin;
  final int priceMax;
  final String? availableText;
  final String? etaText;
  final double distanceKm;
  final int? primaryCategoryId;

  const MitraNearby({
    required this.mitraId,
    required this.name,
    required this.avgRating,
    required this.totalReviews,
    required this.jobsDone,
    required this.yearsExperience,
    required this.priceMin,
    required this.priceMax,
    required this.distanceKm,
    this.avatarUrl,
    this.bio,
    this.sampleReview,
    this.availableText,
    this.etaText,
    this.primaryCategoryId,
  });

  static MitraNearby fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.round();
      return int.tryParse(value.toString()) ?? 0;
    }

    return MitraNearby(
      mitraId: json['mitra_id'] as String,
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      avgRating: toDouble(json['avg_rating']),
      totalReviews: toInt(json['total_reviews']),
      jobsDone: toInt(json['jobs_done']),
      yearsExperience: toInt(json['years_experience']),
      sampleReview: json['sample_review'] as String?,
      priceMin: toInt(json['price_min']),
      priceMax: toInt(json['price_max']),
      availableText: json['available_text'] as String?,
      etaText: json['eta_text'] as String?,
      distanceKm: toDouble(json['distance_km']),
      primaryCategoryId: json['primary_category_id'] == null
          ? null
          : toInt(json['primary_category_id']),
    );
  }
}
