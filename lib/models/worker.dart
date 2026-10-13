class Service {
  final String name;
  final int min;
  final int? max;
  const Service(this.name, this.min, [this.max]);
}

class Worker {
  final String id;
  final String name;
  final String phone;
  final String service;
  final String serviceKind;
  final double rating;
  final int reviews;
  final double distance;
  final String eta;
  final int priceMin;
  final int priceMax;
  final String review;
  final List<String> badges;
  final int jobsDone;
  final int yearsExperience;
  final List<Service> services;
  final String bio;
  final String available;
  final bool isIdentityVerified;
  final bool isPhoneVerified;
  final bool isPriceTransparent;

  factory Worker.fromJson(Map<String, dynamic> json) {
    final servicesRaw = (json['mitra_services'] as List<dynamic>?) ?? [];
    final services = servicesRaw.map((s) {
      final m = s as Map<String, dynamic>;
      return Service(
        m['service_name'] as String,
        (m['price_min'] as num).toInt(),
        m['price_max'] != null ? (m['price_max'] as num).toInt() : null,
      );
    }).toList();

    final badgesRaw = (json['badges'] as List<dynamic>?) ?? [];

    return Worker(
      id: json['mitra_id'] as String,
      name: ((json['users'] as Map<String, dynamic>?)?['name'] as String?) ??
          '',
      phone:
          ((json['users'] as Map<String, dynamic>?)?['phone_number']
              as String?) ??
          '',
      service: ((json['categories'] as Map<String, dynamic>?)?['display_name']
              as String?) ??
          '',
      serviceKind:
          ((json['categories'] as Map<String, dynamic>?)?['category_name']
              as String?) ??
          '',
      rating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      distance: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      eta: (json['eta_text'] as String?) ?? '',
      priceMin: (json['price_min'] as num?)?.toInt() ?? 0,
      priceMax: (json['price_max'] as num?)?.toInt() ?? 0,
      review: (json['sample_review'] as String?) ?? '',
      badges: badgesRaw.map((b) => b as String).toList(),
      jobsDone: (json['jobs_done'] as num?)?.toInt() ?? 0,
      yearsExperience: (json['years_experience'] as num?)?.toInt() ?? 0,
      services: services,
      bio: (json['bio'] as String?) ?? '',
      available: (json['available_text'] as String?) ?? '',
      isIdentityVerified: (json['is_verified'] as bool?) ?? false,
    );
  }

  const Worker({
    required this.id,
    required this.name,
    required this.phone,
    required this.service,
    required this.serviceKind,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.eta,
    required this.priceMin,
    required this.priceMax,
    required this.review,
    required this.badges,
    required this.jobsDone,
    required this.yearsExperience,
    required this.services,
    required this.bio,
    required this.available,
    this.isIdentityVerified = true,
    this.isPhoneVerified = true,
    this.isPriceTransparent = true,
  });
}
