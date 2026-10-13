import 'dart:async';

import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../theme.dart';
import '../models.dart';
import '../widgets.dart';

const _primaryServiceTiles = <List<String>>[
  ['ac', 'AC', 'AC'],
  ['pipa', 'Plumbing', 'Pipa'],
  ['listrik', 'Listrik', 'Listrik'],
  ['bersih', 'Cleaning', 'Bersih'],
  ['kebun', 'Kebun', 'Kebun'],
  ['tukang', 'Lainnya', 'Tukang'],
  ['cat', 'Lainnya', 'Cat'],
  ['lainnya', 'Lainnya', 'Lainnya'],
];

const _moreServiceTiles = <List<String>>[
  ['elektronik', 'Lainnya', 'Elektronik'],
  ['renovasi', 'Lainnya', 'Renovasi'],
  ['atap', 'Lainnya', 'Atap'],
];

class HomeScreen extends StatefulWidget {
  final void Function(String route, [Map<String, dynamic>? patch]) go;
  final FlowState state;
  const HomeScreen({super.key, required this.go, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCategories());
  }

  Future<void> _loadCategories() async {
    if (widget.state.categoryIdByLabel.isNotEmpty) return;
    final rows = await CatalogService.instance.fetchCategories();
    if (!mounted || rows.isEmpty) return;
    final map = <String, int>{};
    for (final c in rows) {
      map[c.categoryName.toLowerCase()] = c.categoryId;
      map[c.displayName.toLowerCase()] = c.categoryId;
    }
    setState(() => widget.state.categoryIdByLabel = map);
  }

  @override
  Widget build(BuildContext context) {
    final go = widget.go;
    final navBarHeight = MediaQuery.of(context).padding.bottom + 120;
    return ListView(
      padding: EdgeInsets.only(bottom: navBarHeight),
      children: [
        // Hero
        Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E8E6C), Color(0xFF0B7257)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(18, 56, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BrLogo(size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Beresin',
                              style: pj(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.4,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 11,
                                  color: Colors.white.withValues(alpha: .7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tebet, Jakarta Selatan',
                                  style: pj(
                                    color: Colors.white.withValues(alpha: .7),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFFFD89B),
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI ASSISTANT • BARU',
                          style: pj(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: pj(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.18,
                        letterSpacing: -.6,
                      ),
                      children: const [
                        TextSpan(text: 'Rusak di rumah?\n'),
                        TextSpan(
                          text: 'Foto aja',
                          style: TextStyle(color: Color(0xFFFFD89B)),
                        ),
                        TextSpan(text: ', Beresin bantu\ncari tukangnya.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AI bantu analisis masalah, kasih estimasi harga, dan rekomendasi tukang terpercaya di sekitar kamu.',
                    style: pj(
                      color: Colors.white.withValues(alpha: .85),
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  PressScale(
                    onTap: () => go('upload'),
                    scaleTo: 0.97,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .25),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                            spreadRadius: -10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.accent, Color(0xFFE37614)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cek Masalah Sekarang',
                                  style: pj(
                                    color: AppColors.ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Upload foto atau ceritakan gejala',
                                  style: pj(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: AppColors.ink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _CoreFeatureCard(
                        icon: Icons.payments_outlined,
                        title: 'Cek Harga Wajar',
                        text: 'Tahu kisaran harga sebelum booking.',
                        cta: 'Cek Harga',
                        onTap: () => go('fairPrice'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CoreFeatureCard(
                        icon: Icons.help_outline_rounded,
                        title: 'Aku nggak tahu harus\npanggil siapa',
                        text: 'AI bantu arahkan ke tukang yang tepat.',
                        cta: 'Mulai dari Gejala',
                        onTap: () => go('symptomIntake'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Quick services
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Lagi butuh tukang apa nih?',
                  style: pj(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: _primaryServiceTiles.map((s) {
              return _ServiceTile(
                id: s[0],
                kind: s[1],
                label: s[2],
                active: selectedCategoryId == s[0],
                onTap: () => _handleServiceTileTap(s[0]),
              );
            }).toList(),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: selectedCategoryId == 'lainnya'
              ? Padding(
                  key: const ValueKey('more-categories'),
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: _MoreCategoriesPanel(
                    activeId: selectedCategoryId,
                    onSelected: (id) => _openDiagnosisSheet(diagnosisById(id)),
                    onGeneralTap: () =>
                        _openDiagnosisSheet(diagnosisById('lainnya')),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('more-categories-empty')),
        ),

        // Trust strip
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: BrCard(
            padding: const EdgeInsets.all(14),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF8EE), Color(0xFFFFFCF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFFFE9C2)),
            child: Row(
              children: const [
                Expanded(
                  child: _TrustItem(
                    icon: Icons.payments_outlined,
                    label: 'Estimasi harga\ntransparan',
                  ),
                ),
                Expanded(
                  child: _TrustItem(
                    icon: Icons.shield_outlined,
                    label: 'Tukang\nterverifikasi',
                  ),
                ),
                Expanded(
                  child: _TrustItem(
                    icon: Icons.location_on_outlined,
                    label: 'Rekomendasi\ndekat lokasi',
                  ),
                ),
              ],
            ),
          ),
        ),

        // Nearby workers
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tukang dekat kamu',
                      style: pj(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${kWorkers.length} tukang seed untuk area Tebet',
                      style: pj(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => go('workers'),
                child: Text(
                  'Lihat semua',
                  style: pj(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 152,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final w = kWorkers[i];
              return PressScale(
                onTap: () => go('worker', {'workerId': w.id, 'from': 'home'}),
                scaleTo: 0.96,
                child: Container(
                  width: 230,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: .05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: .12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: -16,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Avatar(name: w.name, size: 42),
                          const SizedBox(width: 10),
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
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.ink,
                                          letterSpacing: -.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified,
                                      size: 12,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                                Text(
                                  w.service,
                                  style: pj(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${w.rating}',
                            style: pj(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('•', style: pj(color: AppColors.line)),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${w.distance} km',
                            style: pj(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('•', style: pj(color: AppColors.line)),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.access_time,
                            size: 11,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              w.eta,
                              overflow: TextOverflow.ellipsis,
                              style: pj(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${rupiah(w.priceMin)} – ${rupiah(w.priceMax)}',
                                style: pj(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: AppColors.primaryDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleServiceTileTap(String id) {
    if (id == 'lainnya') {
      setState(() => selectedCategoryId = selectedCategoryId == 'lainnya' ? null : 'lainnya');
      return;
    }
    _openDiagnosisSheet(diagnosisById(id));
  }

  Future<void> _openDiagnosisSheet(DiagnosisCategory category) async {
    setState(() => selectedCategoryId = category.id);
    var selectedProblem = category.problemChips.first;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final media = MediaQuery.of(context);
            final bottomClearance = media.padding.bottom + 96;
            return Padding(
              padding: EdgeInsets.only(bottom: bottomClearance),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: media.size.height * .78),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: .18),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                        spreadRadius: -14,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.line,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            ServiceIcon(
                              kind: category.serviceKind,
                              categoryId: category.id,
                              size: 42,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.sheetTitle,
                                    style: pj(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Estimasi AI gratis dan belum otomatis booking tukang.',
                                    style: pj(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: category.problemChips.map((problem) {
                            final active = selectedProblem == problem;
                            return BrChip(
                              label: problem,
                              active: active,
                              variant: 'primary',
                              onTap: () {
                                setSheetState(() => selectedProblem = problem);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        BrCard(
                          padding: const EdgeInsets.all(12),
                          color: AppColors.primary50,
                          border: Border.all(color: AppColors.primary100),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Kamu tetap bisa edit detail, upload foto, dan memilih urgensi sebelum AI menganalisis.',
                                  style: pj(
                                    fontSize: 11.5,
                                    color: AppColors.primaryDark,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        BrButton(
                          label: 'Lanjut Cek Masalah',
                          full: true,
                          size: BrButtonSize.lg,
                          iconRight: const Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.go('upload', {
                              'category': category.label,
                              'problem': selectedProblem,
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MoreCategoriesPanel extends StatelessWidget {
  final String? activeId;
  final ValueChanged<String> onSelected;
  final VoidCallback onGeneralTap;

  const _MoreCategoriesPanel({
    required this.activeId,
    required this.onSelected,
    required this.onGeneralTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FCF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary100),
        gradient: const LinearGradient(
          colors: [Color(0xFFF3FCF8), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori lainnya',
                      style: pj(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pilih yang paling dekat dengan kebutuhanmu.',
                      style: pj(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onGeneralTap,
                child: Text(
                  'Cek umum',
                  style: pj(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 16) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _moreServiceTiles.map((s) {
                  return SizedBox(
                    width: itemWidth,
                    child: _MoreCategoryPill(
                      id: s[0],
                      kind: s[1],
                      label: s[2],
                      active: activeId == s[0],
                      onTap: () => onSelected(s[0]),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MoreCategoryPill extends StatelessWidget {
  final String id;
  final String kind;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _MoreCategoryPill({
    required this.id,
    required this.kind,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.line,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ServiceIcon(kind: kind, categoryId: id, size: 34),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pj(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: active ? AppColors.primaryDark : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String id;
  final String kind;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ServiceTile({
    required this.id,
    required this.kind,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: active ? AppColors.primary50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active
                  ? AppColors.primary
                  : AppColors.ink.withValues(alpha: .05),
              width: active ? 1.5 : 1,
            ),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  spreadRadius: -10,
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ServiceIcon(kind: kind, categoryId: id, size: 32),
              const SizedBox(height: 4),
              Text(
                label,
                style: pj(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: active ? AppColors.primaryDark : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoreFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final String cta;
  final VoidCallback onTap;
  const _CoreFeatureCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      border: Border.all(color: AppColors.line2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CoreIcon(icon: icon),
          const SizedBox(height: 11),
          _CoreText(title: title, text: text, cta: cta),
        ],
      ),
    );
  }
}

class _CoreIcon extends StatelessWidget {
  final IconData icon;

  const _CoreIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _CoreText extends StatelessWidget {
  final String title;
  final String text;
  final String cta;

  const _CoreText({required this.title, required this.text, required this.cta});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: pj(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: pj(fontSize: 11.5, color: AppColors.muted, height: 1.3),
        ),
        const SizedBox(height: 8),
        Text(
          cta,
          style: pj(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppColors.accentDark),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: pj(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.ink2,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}
