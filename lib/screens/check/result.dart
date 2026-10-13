import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models.dart';
import '../../widgets.dart';

class ResultScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;
  const ResultScreen({super.key, required this.go, required this.state});

  @override
  Widget build(BuildContext context) {
    final category = diagnosisByLabel(state.cat);
    final navBottom = MediaQuery.of(context).padding.bottom + 120;
    // Sumber harga: AI diagnosis (jika sudah persist), else fallback kategori statis
    final aiMin = state.activeEstimatedMinPrice ?? category.priceMin;
    final aiMax = state.activeEstimatedMaxPrice ?? category.priceMax;
    return FloatingBackScaffold(
      onBack: () => go('upload'),
      child: ListView(
        padding: EdgeInsets.only(bottom: navBottom),
        children: [
          ScreenHeader(
            title: 'Hasil Analisis',
            subtitle: 'Langkah 2 dari 3',
            onBack: () {},
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrCard(
                padding: const EdgeInsets.all(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E8E6C), Color(0xFF0A6E54)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        BrTag(
                          label: 'AKURASI 82%',
                          bgOverride: Colors.white.withValues(alpha: .18),
                          fgOverride: Colors.white,
                          icon: const Icon(
                            Icons.auto_awesome,
                            size: 11,
                            color: Color(0xFFFFD89B),
                          ),
                        ),
                        BrTag(
                          label: category.workerType.toUpperCase(),
                          bgOverride: Colors.white.withValues(alpha: .18),
                          fgOverride: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'KEMUNGKINAN MASALAH',
                      style: pj(
                        color: const Color(0xFFFFD89B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.resultProblem,
                      style: pj(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.resultExplanation,
                      style: pj(
                        color: Colors.white.withValues(alpha: .78),
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const MockACPhoto(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    BrTag(
                                      label: 'SEDANG',
                                      bgOverride: AppColors.accent.withValues(
                                        alpha: .25,
                                      ),
                                      fgOverride: const Color(0xFFFFD89B),
                                    ),
                                    const SizedBox(width: 6),
                                    BrTag(
                                      label: 'SEGERA',
                                      bgOverride: AppColors.danger.withValues(
                                        alpha: .25,
                                      ),
                                      fgOverride: const Color(0xFFFFB59E),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  state.desc.trim().isEmpty
                                      ? '${state.selectedProblem} · ${category.uploadLabel.toLowerCase()}.'
                                      : state.desc,
                                  style: pj(
                                    color: Colors.white.withValues(alpha: .7),
                                    fontSize: 11,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _TrustSummaryCard(
                workerType: category.workerType,
                urgency: state.urgency,
                priceRange: '${rupiah(aiMin)} - ${rupiah(aiMax)}',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BrCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                size: 14,
                                color: AppColors.accentDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ESTIMASI BIAYA',
                                style: pj(
                                  color: AppColors.accentDark,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rupiah(aiMin),
                            style: pj(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.3,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            '– ${rupiah(aiMax)}',
                            style: pj(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.label == 'Lainnya'
                                ? 'estimasi awal di Tebet'
                                : 'harga wajar di Tebet',
                            style: pj(fontSize: 10.5, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BrCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PERKIRAAN',
                                style: pj(
                                  color: AppColors.primaryDark,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${category.durationMin} – ${category.durationMax}',
                            style: pj(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: -.3,
                            ),
                          ),
                          Text(
                            'menit estimasi',
                            style: pj(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.workerType,
                            style: pj(fontSize: 10.5, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BrCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryDark,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rekomendasi Beresin',
                            style: pj(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${category.nextStep} Estimasi ini gratis dan belum otomatis memesan worker.',
                            style: pj(
                              fontSize: 12.5,
                              color: AppColors.ink2,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BrButton(
                label: 'Cari Tukang yang Cocok',
                size: BrButtonSize.lg,
                full: true,
                iconRight: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => go('recommendedWorkers'),
              ),
              const SizedBox(height: 8),
              BrButton(
                label: 'Cek Harga Wajar',
                variant: BrButtonVariant.secondary,
                full: true,
                icon: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
                onPressed: () => go('fairPrice'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        ],
      ),
    );
  }
}

class _TrustSummaryCard extends StatelessWidget {
  final String workerType;
  final String urgency;
  final String priceRange;

  const _TrustSummaryCard({
    required this.workerType,
    required this.urgency,
    required this.priceRange,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.handyman_outlined,
                  label: 'Tukang cocok',
                  value: workerType,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.flag_outlined,
                  label: 'Urgensi',
                  value: urgency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary100),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimasi harga wajar',
                        style: pj(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        priceRange,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pj(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 9),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: pj(
              fontSize: 11.2,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: pj(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
