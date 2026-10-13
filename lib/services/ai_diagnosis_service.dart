import 'package:supabase_flutter/supabase_flutter.dart';

import '../models.dart';

class AiDiagnosisInput {
  final int? categoryId;
  final String categoryLabel;
  final String problem;
  final String description;
  final String urgency;
  final String? uploadedImageUrl;

  const AiDiagnosisInput({
    required this.categoryLabel,
    required this.problem,
    required this.description,
    required this.urgency,
    this.categoryId,
    this.uploadedImageUrl,
  });
}

class AiDiagnosisService {
  AiDiagnosisService._();
  static final AiDiagnosisService instance = AiDiagnosisService._();

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Run AI analysis (Edge Function bila tersedia, else heuristic), lalu
  /// PERSIST hasilnya ke tabel `ai_diagnoses` dan kembalikan record.
  Future<AiDiagnosisRecord?> analyzeAndPersist(AiDiagnosisInput input) async {
    final client = _client;
    if (client == null) return null;
    final customerAuthId = client.auth.currentUser?.id;
    if (customerAuthId == null) return null;

    Map<String, dynamic>? aiOutput;
    try {
      final fn = await client.functions.invoke(
        'ai-diagnose',
        body: {
          'category_id': input.categoryId,
          'category_label': input.categoryLabel,
          'problem': input.problem,
          'description': input.description,
          'urgency': input.urgency,
          'image_url': input.uploadedImageUrl,
        },
      );
      final data = fn.data;
      if (data is Map<String, dynamic>) aiOutput = data;
    } catch (_) {
      // Edge function not deployed yet → fall back to heuristic
    }

    aiOutput ??= _heuristicResult(input);

    // Resolve internal customer user_id from auth_user_id
    String? customerId;
    try {
      final row = await client
          .from('users')
          .select('user_id')
          .eq('auth_user_id', customerAuthId)
          .maybeSingle();
      customerId = row?['user_id'] as String?;
    } catch (_) {}

    final payload = <String, dynamic>{
      'customer_id': ?customerId,
      'category_id': ?input.categoryId,
      'uploaded_image_url': ?input.uploadedImageUrl,
      'ai_analysis_result': aiOutput['analysis'],
      'problem_summary': aiOutput['summary'],
      'estimated_min_price': aiOutput['min_price'],
      'estimated_max_price': aiOutput['max_price'],
      'preventive_tips': aiOutput['tips'],
      'urgency': input.urgency,
    };

    try {
      final row = await client
          .from('ai_diagnoses')
          .insert(payload)
          .select()
          .single();
      return AiDiagnosisRecord.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _heuristicResult(AiDiagnosisInput input) {
    final ranges = _kCategoryPriceHeuristics[input.categoryLabel.toLowerCase()];
    final minPrice = ranges?[0] ?? 80000;
    final maxPrice = ranges?[1] ?? 250000;
    final urgencyBoost = input.urgency.toLowerCase() == 'darurat' ? 1.25 : 1.0;
    return {
      'analysis':
          'Indikasi awal: ${input.problem}. ${input.description.trim().isEmpty ? '' : input.description.trim()} '
              'Disarankan dicek oleh teknisi untuk konfirmasi sebab pasti.',
      'summary': input.problem,
      'min_price': (minPrice * urgencyBoost).round(),
      'max_price': (maxPrice * urgencyBoost).round(),
      'tips': 'Matikan unit / sumber daya terkait sebelum tukang datang untuk keamanan.',
    };
  }
}

const _kCategoryPriceHeuristics = <String, List<int>>{
  'ac': [80000, 250000],
  'pipa': [70000, 220000],
  'plumbing': [70000, 220000],
  'listrik': [90000, 300000],
  'cleaning': [100000, 250000],
  'kebun': [120000, 350000],
  'cat': [150000, 500000],
  'tukang': [100000, 400000],
};
