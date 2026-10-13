import 'package:supabase_flutter/supabase_flutter.dart';

import '../models.dart';

class CatalogCategory {
  final int categoryId;
  final String categoryName;
  final String displayName;
  final String? description;
  final String? iconUrl;

  const CatalogCategory({
    required this.categoryId,
    required this.categoryName,
    required this.displayName,
    this.description,
    this.iconUrl,
  });

  static CatalogCategory fromJson(Map<String, dynamic> json) {
    return CatalogCategory(
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String? ?? '',
      displayName:
          (json['display_name'] as String?) ??
          (json['category_name'] as String? ?? ''),
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }
}

class CatalogService {
  CatalogService._();
  static final CatalogService instance = CatalogService._();

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<CatalogCategory>> fetchCategories() async {
    final client = _client;
    if (client == null) return const [];
    try {
      final rows = await client
          .from('categories')
          .select('category_id, category_name, display_name, description, icon_url')
          .order('category_id');
      return (rows as List)
          .map((r) => CatalogCategory.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<MitraNearby>> nearbyMitras({
    required double latitude,
    required double longitude,
    int? categoryId,
    double radiusKm = 5,
  }) async {
    final client = _client;
    if (client == null) return const [];
    try {
      final rows = await client.rpc(
        'nearby_mitras',
        params: {
          'p_lat': latitude,
          'p_lng': longitude,
          'p_category_id': categoryId,
          'p_radius_km': radiusKm,
        },
      );
      return (rows as List)
          .map((r) => MitraNearby.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
