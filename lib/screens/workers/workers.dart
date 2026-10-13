import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/catalog_service.dart';
import '../../theme.dart';
import '../../models.dart';
import '../../widgets.dart';
import '../../widgets/whatsapp_lead_sheet.dart';

class AIRecommendedWorkersScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;

  const AIRecommendedWorkersScreen({
    super.key,
    required this.go,
    required this.state,
  });

  @override
  State<AIRecommendedWorkersScreen> createState() =>
      _AIRecommendedWorkersScreenState();
}

class _AIRecommendedWorkersScreenState
    extends State<AIRecommendedWorkersScreen> {
  String filter = '';
  final filters = const [
    'Terdekat',
    'Rating Tertinggi',
    'Harga Terjangkau',
    'Bisa Hari Ini',
  ];

  List<Worker> _liveWorkers = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadNearby());
  }

  Future<void> _loadNearby() async {
    final s = widget.state;
    final categoryId = s.categoryIdFor(s.cat);
    // Default ke Tebet bila lokasi user belum diset
    final lat = s.currentLatitude ?? -6.2289;
    final lng = s.currentLongitude ?? 106.8570;
    final rows = await CatalogService.instance.nearbyMitras(
      latitude: lat,
      longitude: lng,
      categoryId: categoryId,
      radiusKm: 5,
    );
    if (!mounted) return;
    setState(() {
      _liveWorkers = rows.map(_mitraToWorker).toList();
    });
  }

  Worker _mitraToWorker(MitraNearby m) {
    return Worker(
      id: m.mitraId,
      name: m.name,
      phone: '',
      service: diagnosisByLabel(widget.state.cat).workerType,
      serviceKind: diagnosisByLabel(widget.state.cat).serviceKind,
      rating: m.avgRating == 0 ? 4.8 : m.avgRating,
      reviews: m.totalReviews,
      jobsDone: m.jobsDone,
      yearsExperience: m.yearsExperience,
      distance: m.distanceKm,
      eta: m.etaText ?? '~30 menit',
      priceMin: m.priceMin,
      priceMax: m.priceMax,
      badges: const ['Terverifikasi'],
      review: m.sampleReview ?? 'Pekerjaan rapi, harga sesuai estimasi.',
      services: const [],
      bio: m.bio ?? '',
      available: m.availableText ?? 'Tersedia hari ini',
    );
  }

  List<Worker> get sorted {
    final base = _liveWorkers.isEmpty
        ? (() {
            final category = diagnosisByLabel(widget.state.cat);
            final matches = kWorkers
                .where((worker) => worker.serviceKind == category.serviceKind)
                .toList();
            return matches.isEmpty ? [...kWorkers] : matches;
          })()
        : [..._liveWorkers];

    switch (filter) {
      case 'Terdekat':
        base.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'Rating Tertinggi':
        base.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Harga Terjangkau':
        base.sort((a, b) => a.priceMin.compareTo(b.priceMin));
        break;
      case 'Bisa Hari Ini':
        base.sort(
          (a, b) =>
              (a.eta.contains('menit') ? -1 : 1) -
              (b.eta.contains('menit') ? -1 : 1),
        );
        break;
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final category = diagnosisByLabel(widget.state.cat);
    final navBottom = MediaQuery.of(context).padding.bottom + 120;
    return FloatingBackScaffold(
      onBack: () => widget.go('result'),
      child: ListView(
        padding: EdgeInsets.only(bottom: navBottom),
        children: [
          ScreenHeader(
            title: 'Rekomendasi AI',
            subtitle: 'Langkah 3 dari 3',
            onBack: () {},
            right: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(Icons.search, size: 18, color: AppColors.ink2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC5E2D6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Untuk: ${category.resultProblem}',
                        style: pj(
                          color: AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${sorted.length} tukang cocok · radius 3 km · Tebet',
                        style: pj(color: AppColors.ink2, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: BrCard(
            padding: const EdgeInsets.all(14),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF8EE), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFFFE9C2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.accentDark,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ringkasan untuk Tukang',
                        style: pj(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const BrTag(
                      label: 'Dibuat oleh AI Beresin',
                      color: 'accent',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Beresin akan mengirim ringkasan masalah ini agar tukang langsung paham sebelum datang.',
                  style: pj(fontSize: 12.5, color: AppColors.ink2, height: 1.4),
                ),
                const SizedBox(height: 12),
                _SummaryPreview(category: category, state: widget.state),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => BrChip(
              label: filters[i],
              active: filter == filters[i],
              onTap: () => setState(() => filter = filters[i]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...sorted.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: _WorkerCard(
              w: e.value,
              go: widget.go,
              state: widget.state,
              featured: e.key == 0,
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final Worker w;
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;
  final bool featured;
  const _WorkerCard({
    required this.w,
    required this.go,
    required this.state,
    required this.featured,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      onTap: () =>
          go('worker', {'workerId': w.id, 'from': 'recommendedWorkers'}),
      padding: EdgeInsets.zero,
      border: featured
          ? Border.all(color: AppColors.primary, width: 1.5)
          : Border.all(color: Colors.black.withValues(alpha: .04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (featured)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: AppColors.primary,
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 11,
                    color: Color(0xFFFFD89B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'PALING DIREKOMENDASIKAN AI',
                    style: pj(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .4,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Avatar(name: w.name, size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  w.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: pj(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                    letterSpacing: -.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          Text(
                            '${w.service} · ${w.jobsDone} pekerjaan',
                            style: pj(fontSize: 11.5, color: AppColors.muted),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Stars(value: w.rating, size: 12),
                              const SizedBox(width: 6),
                              Text('•', style: pj(color: AppColors.line)),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${w.distance} km',
                                style: pj(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('•', style: pj(color: AppColors.line)),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  w.eta,
                                  overflow: TextOverflow.ellipsis,
                                  style: pj(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: List.generate(w.badges.length, (i) {
                    final color = i == 0
                        ? 'success'
                        : i == 1
                        ? 'accent'
                        : 'neutral';
                    return BrTag(
                      label: w.badges[i],
                      color: color,
                      icon: i == 0
                          ? const Icon(
                              Icons.check,
                              size: 10,
                              color: Color(0xFF0F7A45),
                            )
                          : null,
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '“ ${w.review}',
                    style: pj(
                      fontSize: 11.5,
                      color: AppColors.ink2,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HARGA',
                            style: pj(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                              letterSpacing: .3,
                            ),
                          ),
                          Text(
                            '${rupiah(w.priceMin)} – ${rupiah(w.priceMax)}',
                            style: pj(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BrButton(
                      label: 'Tanya',
                      size: BrButtonSize.sm,
                      variant: BrButtonVariant.ghost,
                      onPressed: () => showWhatsappLeadSheet(
                        context: context,
                        worker: w,
                        state: state,
                      ),
                    ),
                    const SizedBox(width: 6),
                    BrButton(
                      label: 'Booking',
                      size: BrButtonSize.sm,
                      icon: const Icon(
                        Icons.event_available,
                        size: 14,
                        color: Colors.white,
                      ),
                      onPressed: () => go('booking', {'workerId': w.id, 'from': 'workers'}),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPreview extends StatelessWidget {
  final DiagnosisCategory category;
  final FlowState state;

  const _SummaryPreview({required this.category, required this.state});

  @override
  Widget build(BuildContext context) {
    final problem = state.unknownMode
        ? 'Air netes dari plafon dekat kamar mandi'
        : state.selectedProblem;
    final note = state.unknownMode
        ? 'Ada noda lembap di plafon, tetesan cukup banyak'
        : (state.desc.trim().isEmpty ? category.resultExplanation : state.desc);
    final rows = [
      ['Masalah', problem],
      ['Kemungkinan', category.resultProblem],
      ['Urgensi', state.urgency],
      [
        'Estimasi harga',
        '${rupiah(category.priceMin)}-${rupiah(category.priceMax)}',
      ],
      ['Catatan', note],
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line2),
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(
                        '${row[0]}:',
                        style: pj(fontSize: 11.8, color: AppColors.muted),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row[1],
                        style: pj(
                          fontSize: 12.2,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
