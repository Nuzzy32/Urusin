import 'package:flutter/material.dart';

import '../../models.dart';
import '../../repositories/app_repository.dart';
import '../../theme.dart';
import '../../widgets.dart';

class FairPriceScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;

  const FairPriceScreen({super.key, required this.go, required this.state});

  @override
  State<FairPriceScreen> createState() => _FairPriceScreenState();
}

class _FairPriceScreenState extends State<FairPriceScreen> {
  bool showResult = false;
  DiagnosisCategory? selectedCat;
  String selectedProblem = '';
  String urgency = '';
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 120;
    return FloatingBackScaffold(
      onBack: () =>
          showResult ? setState(() => showResult = false) : widget.go('home'),
      child: ListView(
        padding: EdgeInsets.only(bottom: bottom),
        children: [
          ScreenHeader(
            title: showResult ? 'Estimasi Harga Wajar' : 'Cek Harga Wajar',
            subtitle: showResult
                ? search.text
                : 'Cari tahu kisaran harga layanan rumah sebelum booking tukang.',
            onBack: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: showResult ? _buildResult() : _buildInput(),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrCard(
          padding: const EdgeInsets.all(14),
          child: TextField(
            controller: search,
            style: pj(fontSize: 14, color: AppColors.ink),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.muted,
              ),
              hintText: 'Contoh: Cuci AC 1 unit di Tebet',
              hintStyle: pj(fontSize: 13.5, color: AppColors.muted),
              border: InputBorder.none,
            ),
          ),
        ),
        const SectionTitle('Kategori'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: diagnosisCategories
              .map(
                (cat) => BrChip(
                  label: cat.label,
                  active: selectedCat?.id == cat.id,
                  variant: 'primary',
                  icon: ServiceIcon(
                    kind: cat.serviceKind,
                    categoryId: cat.id,
                    size: 20,
                  ),
                  onTap: () => setState(() {
                    selectedCat = cat;
                    selectedProblem = cat.problemChips.first;
                  }),
                ),
              )
              .toList(),
        ),
        if (selectedCat != null) ...[
          const SectionTitle('Jenis masalah'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedCat!.problemChips
                .map(
                  (p) => BrChip(
                    label: p,
                    active: selectedProblem == p,
                    variant: 'primary',
                    onTap: () => setState(() => selectedProblem = p),
                  ),
                )
                .toList(),
          ),
        ],
        const SectionTitle('Lokasi'),
        BrCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.place_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tebet, Jakarta Selatan',
                  style: pj(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              BrButton(
                label: 'Ubah lokasi',
                size: BrButtonSize.sm,
                variant: BrButtonVariant.secondary,
                onPressed: () {},
              ),
            ],
          ),
        ),
        if (selectedCat != null) ...[
          const SectionTitle('Detail layanan'),
          BrCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  label: 'Jenis layanan',
                  value: selectedProblem.isNotEmpty
                      ? selectedProblem
                      : selectedCat!.label,
                ),
                const _DetailRow(
                  label: 'Lokasi',
                  value: 'Tebet, Jakarta Selatan',
                ),
                const SizedBox(height: 10),
                Text(
                  'Urgensi',
                  style: pj(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Normal', 'Hari ini', 'Darurat'].map((item) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: item == 'Darurat' ? 0 : 8,
                        ),
                        child: Center(
                          child: BrChip(
                            label: item,
                            active: urgency == item,
                            variant: 'primary',
                            onTap: () => setState(() => urgency = item),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        BrButton(
          label: 'Lihat Estimasi Harga',
          full: true,
          size: BrButtonSize.lg,
          iconRight: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: selectedCat == null
              ? null
              : () => setState(() => showResult = true),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final cat = selectedCat!;
    final avg = ((cat.priceMin + cat.priceMax) / 2).round();
    final ceiling = (cat.priceMax * 1.3).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrCard(
          padding: const EdgeInsets.all(18),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.transparent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedProblem,
                style: pj(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFFD89B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${rupiah(cat.priceMin)} – ${rupiah(cat.priceMax)}',
                style: pj(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              _PriceMeta(label: 'Rata-rata warga sekitar', value: rupiah(avg)),
              _PriceMeta(
                label: 'Terlalu mahal jika di atas',
                value: rupiah(ceiling),
              ),
              _PriceMeta(
                label: 'Estimasi durasi',
                value: '${cat.durationMin}–${cat.durationMax} menit',
              ),
            ],
          ),
        ),
        const SectionTitle('Faktor yang bisa membuat harga naik'),
        const _BulletCard(
          items: [
            'Kondisi lebih parah dari perkiraan',
            'Perlu material atau suku cadang tambahan',
            'Akses lokasi sulit dijangkau',
            'Panggilan darurat atau di luar jam kerja',
          ],
        ),
        const SectionTitle('Tips sebelum booking'),
        const _BulletCard(
          accent: true,
          items: [
            'Tanyakan apakah harga sudah termasuk pengecekan',
            'Konfirmasi biaya tambahan sebelum pekerjaan dimulai',
            'Simpan bukti chat dan pembayaran',
          ],
        ),
        const SizedBox(height: 18),
        BrButton(
          label: 'Cari ${cat.workerType}',
          full: true,
          size: BrButtonSize.lg,
          onPressed: () => widget.go('workers'),
        ),
        const SizedBox(height: 10),
        BrButton(
          label: 'Cek Masalah dengan AI',
          full: true,
          variant: BrButtonVariant.secondary,
          icon: const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          onPressed: () => widget.go('upload'),
        ),
      ],
    );
  }
}

class SymptomIntakeScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;

  const SymptomIntakeScreen({super.key, required this.go, required this.state});

  @override
  State<SymptomIntakeScreen> createState() => _SymptomIntakeScreenState();
}

class _SymptomIntakeScreenState extends State<SymptomIntakeScreen> {
  late final TextEditingController symptom = TextEditingController(
    text: widget.state.symptomText,
  );
  String urgency = '';
  bool hasPhoto = false;
  bool hasVoice = false;

  @override
  void dispose() {
    symptom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 120;
    return FloatingBackScaffold(
      onBack: () => widget.go('upload'),
      child: ListView(
        padding: EdgeInsets.only(bottom: bottom),
        children: [
          ScreenHeader(
            title: 'Ceritakan Gejalanya',
            subtitle: 'Nggak perlu tahu istilah teknis.',
            onBack: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jelaskan saja apa yang kamu lihat, dengar, atau rasakan.',
                  style: pj(
                    fontSize: 13.5,
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                BrCard(
                  onTap: () => setState(() => hasPhoto = true),
                  padding: const EdgeInsets.all(16),
                  color: hasPhoto ? AppColors.primary50 : Colors.white,
                  border: Border.all(
                    color: hasPhoto ? AppColors.primary100 : AppColors.line,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasPhoto
                            ? Icons.check_circle_rounded
                            : Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasPhoto
                                  ? 'Foto area bermasalah siap dianalisis'
                                  : 'Upload foto area yang bermasalah',
                              style: pj(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Foto membantu AI memahami kondisi awal.',
                              style: pj(fontSize: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionTitle('Ceritakan singkat'),
                TextField(
                  controller: symptom,
                  maxLines: 5,
                  onChanged: (value) => widget.state.symptomText = value,
                  style: pj(fontSize: 14, color: AppColors.ink, height: 1.45),
                  decoration: InputDecoration(
                    hintText:
                        'Contoh: Air netes dari plafon dekat kamar mandi, sudah dari tadi pagi.',
                    hintStyle: pj(fontSize: 13, color: AppColors.muted),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                BrCard(
                  onTap: () => setState(() => hasVoice = !hasVoice),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        hasVoice
                            ? Icons.graphic_eq_rounded
                            : Icons.mic_none_rounded,
                        color: hasVoice ? AppColors.primary : AppColors.ink2,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          hasVoice
                              ? 'Voice note 18 detik siap dipakai'
                              : 'Rekam suara',
                          style: pj(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      Text(
                        'Kalau lebih mudah, ceritakan lewat suara.',
                        style: pj(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SectionTitle('Urgensi'),
                ...[
                  ['Normal', 'Bisa nunggu'],
                  ['Segera', 'Hari ini'],
                  ['Darurat', 'Sekarang juga'],
                ].map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SelectableRow(
                      title: item[0],
                      subtitle: item[1],
                      selected: urgency == item[0],
                      onTap: () => setState(() => urgency = item[0]),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                BrButton(
                  label: 'Bantu Cek dengan AI',
                  full: true,
                  size: BrButtonSize.lg,
                  icon: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    widget.state
                      ..unknownMode = true
                      ..hasPhoto = hasPhoto
                      ..desc = symptom.text
                      ..symptomText = symptom.text
                      ..selectedProblem =
                          'Air netes dari plafon dekat kamar mandi'
                      ..cat = 'Pipa'
                      ..urgency = urgency;
                    widget.go('aiFollowUp');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AiFollowUpScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;

  const AiFollowUpScreen({super.key, required this.go, required this.state});

  @override
  State<AiFollowUpScreen> createState() => _AiFollowUpScreenState();
}

class _AiFollowUpScreenState extends State<AiFollowUpScreen> {
  String timing = '';
  String moisture = '';
  String severity = '';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 120;
    return FloatingBackScaffold(
      onBack: () => widget.go('symptomIntake'),
      child: ListView(
        padding: EdgeInsets.only(bottom: bottom),
        children: [
          ScreenHeader(
            title: 'AI butuh sedikit info lagi',
            subtitle: 'Pertanyaan 1 dari 3',
            onBack: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jawabanmu membantu estimasi lebih akurat.',
                  style: pj(fontSize: 13.5, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                _QuestionCard(
                  question:
                      'Air menetes terus-menerus atau hanya saat kamar mandi dipakai?',
                  options: const [
                    'Terus-menerus',
                    'Hanya saat dipakai',
                    'Setelah hujan',
                    'Tidak yakin',
                  ],
                  selected: timing,
                  onSelect: (value) => setState(() => timing = value),
                ),
                _QuestionCard(
                  question: 'Apakah ada bau lembap atau noda kuning di plafon?',
                  options: const ['Ada', 'Tidak ada', 'Tidak yakin'],
                  selected: moisture,
                  onSelect: (value) => setState(() => moisture = value),
                ),
                _QuestionCard(
                  question: 'Seberapa parah tetesannya?',
                  options: const ['Sedikit', 'Cukup banyak', 'Deras / darurat'],
                  selected: severity,
                  onSelect: (value) => setState(() => severity = value),
                ),
                BrCard(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.primary50,
                  border: Border.all(color: AppColors.primary100),
                  child: Text(
                    'Contoh pertanyaan lain: AC menetes saat menyala, MCB turun saat alat tertentu dinyalakan, atau pipa bocor terlihat langsung.',
                    style: pj(
                      fontSize: 11.5,
                      color: AppColors.primaryDark,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                BrButton(
                  label: 'Lihat Hasil Analisis',
                  full: true,
                  size: BrButtonSize.lg,
                  onPressed: () {
                    widget.state
                      ..followUpTiming = timing
                      ..followUpMoisture = moisture
                      ..followUpSeverity = severity;
                    widget.go('analyzing');
                  },
                ),
                const SizedBox(height: 8),
                BrButton(
                  label: 'Lewati pertanyaan',
                  full: true,
                  variant: BrButtonVariant.ghost,
                  onPressed: () => widget.go('analyzing'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerFinalPriceScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;

  const CustomerFinalPriceScreen({
    super.key,
    required this.go,
    required this.state,
  });

  @override
  State<CustomerFinalPriceScreen> createState() =>
      _CustomerFinalPriceScreenState();
}

class _CustomerFinalPriceScreenState extends State<CustomerFinalPriceScreen> {
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  int? get _parsedPrice {
    final digits = _priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  @override
  Widget build(BuildContext context) {
    final worker = kWorkers.firstWhere(
      (item) => item.id == widget.state.workerId,
      orElse: () => kWorkers.first,
    );
    final category = diagnosisByLabel(widget.state.cat);
    final booking = appRepository.bookingById(widget.state.activeBookingId);
    final estMin = booking?.estimatedPriceMin ?? category.priceMin;
    final estMax = booking?.estimatedPriceMax ?? category.priceMax;
    final parsedPrice = _parsedPrice;
    final isAbove = parsedPrice != null && parsedPrice > estMax;
    final bottom = MediaQuery.of(context).padding.bottom + 120;

    return FloatingBackScaffold(
      onBack: () => widget.go('bookingStatus', {'workerId': worker.id}),
      child: ListView(
        padding: EdgeInsets.only(bottom: bottom),
        children: [
          ScreenHeader(
            title: 'Konfirmasi Harga Final',
            subtitle: 'Setujui sebelum pekerjaan dimulai.',
            onBack: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tukang sudah mengecek kondisi di lokasi. Masukkan harga yang disepakati sebelum pekerjaan dimulai.',
                  style: pj(fontSize: 13.5, color: AppColors.muted, height: 1.45),
                ),
                const SizedBox(height: 14),
                BrCard(
                  child: Row(
                    children: [
                      Avatar(name: worker.name, size: 50),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker.name,
                              style: pj(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              worker.service,
                              style: pj(fontSize: 12, color: AppColors.muted),
                            ),
                            const SizedBox(height: 5),
                            const Stars(value: 4.7, size: 12),
                          ],
                        ),
                      ),
                      const BrTag(label: 'Terverifikasi', color: 'success'),
                    ],
                  ),
                ),
                const SectionTitle('Estimasi awal Beresin'),
                BrCard(
                  child: _FinalPriceLine(
                    label: 'Kisaran harga wajar',
                    value: '${rupiah(estMin)}–${rupiah(estMax)}',
                  ),
                ),
                const SectionTitle('Harga final yang disepakati'),
                BrCard(
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    style: pj(fontSize: 16, color: AppColors.ink),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      prefixStyle: pj(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                      hintText: '0',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                if (parsedPrice != null) ...[
                  const SizedBox(height: 8),
                  BrCard(
                    padding: const EdgeInsets.all(12),
                    color: isAbove
                        ? const Color(0xFFFFF3F3)
                        : AppColors.primary50,
                    border: Border.all(
                      color: isAbove
                          ? AppColors.danger.withValues(alpha: .3)
                          : AppColors.primary100,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isAbove
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline,
                          size: 16,
                          color: isAbove
                              ? AppColors.danger
                              : AppColors.primaryDark,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isAbove
                                ? 'Harga ini melebihi estimasi wajar Beresin. Pastikan kamu sudah diskusikan dengan tukang.'
                                : 'Harga sesuai estimasi wajar Beresin.',
                            style: pj(
                              fontSize: 12,
                              color: isAbove
                                  ? AppColors.danger
                                  : AppColors.primaryDark,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SectionTitle('Catatan (opsional)'),
                BrCard(
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    style: pj(fontSize: 14, color: AppColors.ink),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: sudah termasuk material pipa baru...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SectionTitle('Sebelum menyetujui'),
                const _BulletCard(
                  items: [
                    'Harga sudah dijelaskan oleh tukang',
                    'Pekerjaan yang dilakukan sudah jelas',
                    'Belum ada pembayaran penuh sebelum disetujui',
                  ],
                ),
                const SizedBox(height: 18),
                BrButton(
                  label: 'Setujui & Mulai Pekerjaan',
                  full: true,
                  size: BrButtonSize.lg,
                  onPressed: parsedPrice == null
                      ? null
                      : () async {
                          if (booking != null) {
                            await appRepository.confirmFinalPrice(
                              bookingId: booking.id,
                              finalPrice: parsedPrice,
                              note: _noteCtrl.text.trim(),
                            );
                          }
                          widget.go('bookingStatus', {'workerId': worker.id});
                        },
                ),
                const SizedBox(height: 10),
                BrButton(
                  label: 'Diskusikan Lagi',
                  full: true,
                  variant: BrButtonVariant.secondary,
                  onPressed: booking == null
                      ? null
                      : () async {
                          await appRepository.createComplaint(
                            bookingId: booking.id,
                            type: ComplaintType.priceMismatch,
                            description:
                                'Customer melaporkan harga final perlu ditinjau ulang.',
                          );
                          widget.go('bookingStatus', {'workerId': worker.id});
                        },
                ),
                const SizedBox(height: 8),
                BrButton(
                  label: 'Laporkan harga tidak wajar',
                  full: true,
                  variant: BrButtonVariant.ghost,
                  onPressed: booking == null
                      ? null
                      : () async {
                          await appRepository.createComplaint(
                            bookingId: booking.id,
                            type: ComplaintType.priceMismatch,
                            description:
                                'Customer melaporkan harga tidak wajar di luar estimasi Beresin.',
                          );
                          widget.go('bookingStatus', {'workerId': worker.id});
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerFinalPriceScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;

  const WorkerFinalPriceScreen({
    super.key,
    required this.go,
    required this.state,
  });

  @override
  State<WorkerFinalPriceScreen> createState() => _WorkerFinalPriceScreenState();
}

class _WorkerFinalPriceScreenState extends State<WorkerFinalPriceScreen> {
  final price = TextEditingController(text: 'Rp180.000');
  final work = TextEditingController(
    text: 'Buka panel plafon kecil dan ganti sambungan pipa yang rembes.',
  );
  final extraName = TextEditingController();
  final extraAmount = TextEditingController();
  final extraReason = TextEditingController();
  bool hasExtra = false;

  bool get aboveEstimate {
    final digits = price.text.replaceAll(RegExp(r'[^0-9]'), '');
    final value = int.tryParse(digits) ?? 0;
    return value > 250000;
  }

  @override
  void dispose() {
    price.dispose();
    work.dispose();
    extraName.dispose();
    extraAmount.dispose();
    extraReason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FloatingBackScaffold(
        onBack: () => widget.go('workerDashboard'),
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 28,
          ),
          children: [
            ScreenHeader(
              title: 'Ajukan Harga Final',
              subtitle: 'Customer harus menyetujui sebelum pekerjaan dimulai.',
              onBack: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BrCard(
                    color: AppColors.primary50,
                    border: Border.all(color: AppColors.primary100),
                    child: const _FinalPriceLine(
                      label: 'Estimasi Beresin',
                      value: 'Rp100.000-Rp250.000',
                      large: true,
                    ),
                  ),
                  const SectionTitle('Harga setelah pengecekan'),
                  TextField(
                    controller: price,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: pj(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Harga final',
                      hintText: 'Contoh: Rp180.000',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: work,
                    maxLines: 4,
                    style: pj(fontSize: 14, color: AppColors.ink, height: 1.45),
                    decoration: const InputDecoration(
                      labelText: 'Pekerjaan yang akan dilakukan',
                      hintText:
                          'Jelaskan pekerjaan yang akan dilakukan. Contoh: buka panel plafon kecil dan ganti sambungan pipa.',
                    ),
                  ),
                  if (aboveEstimate) ...[
                    const SizedBox(height: 14),
                    BrCard(
                      color: const Color(0xFFFFF8EE),
                      border: Border.all(color: const Color(0xFFFFE0B1)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harga di atas estimasi wajar',
                            style: pj(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Harga ini lebih tinggi dari estimasi awal Beresin. Tambahkan alasan yang jelas agar customer memahami biaya tambahan.',
                            style: pj(
                              fontSize: 12.5,
                              color: AppColors.ink2,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: extraReason,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Alasan harga lebih tinggi',
                              hintText:
                                  'Contoh: Perlu penggantian pipa tambahan dan akses plafon sulit.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SectionTitle('Biaya tambahan'),
                  _SwitchRow(
                    title: 'Ada biaya tambahan',
                    value: hasExtra,
                    onChanged: (value) => setState(() => hasExtra = value),
                  ),
                  if (hasExtra) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: extraName,
                      decoration: const InputDecoration(
                        labelText: 'Nama biaya',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: extraAmount,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nominal'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: extraReason,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Alasan'),
                    ),
                  ],
                  const SizedBox(height: 14),
                  BrCard(
                    color: AppColors.accent50,
                    border: Border.all(color: const Color(0xFFFFE0B1)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: AppColors.accentDark,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Harga final wajib dikonfirmasi sebelum pekerjaan dimulai.',
                            style: pj(
                              fontSize: 12.5,
                              color: AppColors.ink2,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  BrButton(
                    label: 'Kirim ke Customer',
                    full: true,
                    size: BrButtonSize.lg,
                    onPressed: aboveEstimate && extraReason.text.trim().isEmpty
                        ? null
                        : () => widget.go('workerDashboard'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: pj(fontSize: 12.5, color: AppColors.muted),
            ),
          ),
          Text(
            value,
            style: pj(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceMeta extends StatelessWidget {
  final String label;
  final String value;

  const _PriceMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: pj(fontSize: 12, color: Colors.white70)),
          ),
          Text(
            value,
            style: pj(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  final List<String> items;
  final bool accent;

  const _BulletCard({required this.items, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      color: accent ? const Color(0xFFFFFCF6) : Colors.white,
      border: Border.all(
        color: accent ? const Color(0xFFFFE9C2) : AppColors.line2,
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: accent ? AppColors.accentDark : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: pj(
                          fontSize: 12.8,
                          color: AppColors.ink2,
                          height: 1.35,
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

class _SelectableRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: pj(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: pj(fontSize: 11.5, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _QuestionCard({
    required this.question,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BrCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: pj(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options
                  .map(
                    (item) => BrChip(
                      label: item,
                      active: selected == item,
                      variant: 'primary',
                      onTap: () => onSelect(item),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalPriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool large;

  const _FinalPriceLine({
    required this.label,
    required this.value,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: pj(fontSize: 12.5, color: AppColors.muted),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: pj(
                fontSize: large ? 18 : 13,
                fontWeight: FontWeight.w900,
                color: large ? AppColors.primaryDark : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: pj(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
