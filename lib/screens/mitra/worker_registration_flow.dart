import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models.dart';
import '../../repositories/app_repository.dart';
import '../../theme.dart';
import '../../widgets.dart';

final mitraDraft = MitraRegistrationDraft();

enum UploadState { empty, uploading, uploaded, failed, tooLarge, blurry }

class MitraRegistrationDraft {
  String fullName = '';
  String businessName = '';
  String whatsapp = '';
  bool whatsappVerified = false;
  UploadState profilePhoto = UploadState.empty;
  String domicile = '';
  String bio = '';

  final Set<String> services = {};
  final Set<String> subServices = {};
  String experience = '';
  String tools = '';

  final Set<String> areas = {};
  String areaQuery = '';
  String radius = '';
  final Set<String> days = {};
  String startTime = '';
  String endTime = '';
  String availability = '';
  bool emergency = false;
  String emergencyFee = '';
  String emergencyHours = '';

  final Map<String, String> priceFrom = {};
  final Map<String, String> priceTo = {};
  final Set<String> payments = {};
  bool bookingFee = false;
  String bookingFeeAmount = '';

  UploadState ktp = UploadState.empty;
  UploadState selfie = UploadState.empty;
  String? applicationId;
  String ktpPath = '';
  String selfiePath = '';
  final List<String> portfolioPaths = [];
  int get workPhotos => portfolioPaths.length;
  String referenceName = '';
  String referencePhone = '';
  String referenceNote = '';
  bool agreement = false;

  bool get step1Ready =>
      fullName.trim().isNotEmpty &&
      businessName.trim().isNotEmpty &&
      whatsapp.trim().isNotEmpty &&
      profilePhoto == UploadState.uploaded &&
      domicile.trim().isNotEmpty;

  bool get step2Ready => services.isNotEmpty && experience.isNotEmpty;

  bool get step3Ready =>
      areas.isNotEmpty &&
      days.isNotEmpty &&
      startTime.trim().isNotEmpty &&
      endTime.trim().isNotEmpty;

  bool get step4Ready {
    final chosen = subServices.isNotEmpty ? subServices : services;
    return chosen.any(
      (service) => (priceFrom[service] ?? '').trim().isNotEmpty,
    );
  }

  bool get verificationReady =>
      ktp == UploadState.uploaded &&
      selfie == UploadState.uploaded &&
      whatsappVerified &&
      workPhotos >= 2;

  bool get canSubmit =>
      step1Ready &&
      step2Ready &&
      step3Ready &&
      step4Ready &&
      verificationReady &&
      agreement;
}

const _serviceIcons = <String, IconData>{
  'Teknisi AC': Icons.ac_unit,
  'Tukang Ledeng': Icons.plumbing,
  'Tukang Listrik': Icons.electrical_services,
  'Cleaning Service': Icons.cleaning_services,
  'Tukang Kebun': Icons.yard_outlined,
  'Tukang Cat': Icons.format_paint_outlined,
  'Tukang Bangunan': Icons.construction_outlined,
  'Jasa Harian': Icons.handyman_outlined,
  'Lainnya': Icons.more_horiz,
};

const _subServiceMap = <String, List<String>>{
  'Teknisi AC': [
    'Cuci AC',
    'AC bocor',
    'AC tidak dingin',
    'Isi freon',
    'Bongkar pasang AC',
    'Perawatan rutin',
  ],
  'Tukang Ledeng': [
    'Pipa bocor',
    'Saluran mampet',
    'Keran rusak',
    'Pompa air',
    'Instalasi pipa',
  ],
  'Tukang Listrik': [
    'Listrik mati',
    'Ganti stop kontak',
    'Cek MCB',
    'Instalasi lampu',
  ],
  'Cleaning Service': [
    'Bersih rumah',
    'Bersih kos',
    'Cuci sofa',
    'Deep cleaning',
  ],
};

class MitraDataDiriScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const MitraDataDiriScreen({super.key, required this.go});

  @override
  State<MitraDataDiriScreen> createState() => _MitraDataDiriScreenState();
}

class _MitraDataDiriScreenState extends State<MitraDataDiriScreen> {
  late final fullName = TextEditingController(text: mitraDraft.fullName);
  late final businessName = TextEditingController(
    text: mitraDraft.businessName,
  );
  late final whatsapp = TextEditingController(text: mitraDraft.whatsapp);
  late final domicile = TextEditingController(text: mitraDraft.domicile);
  late final bio = TextEditingController(text: mitraDraft.bio);
  bool submitted = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      fullName,
      businessName,
      whatsapp,
      domicile,
      bio,
    ]) {
      controller.addListener(_sync);
    }
  }

  void _sync() {
    mitraDraft
      ..fullName = fullName.text
      ..businessName = businessName.text
      ..whatsapp = whatsapp.text
      ..domicile = domicile.text
      ..bio = bio.text;
    setState(() {});
  }

  @override
  void dispose() {
    fullName.dispose();
    businessName.dispose();
    whatsapp.dispose();
    domicile.dispose();
    bio.dispose();
    super.dispose();
  }

  void _next() {
    setState(() => submitted = true);
    if (!mitraDraft.step1Ready) {
      _showMitraToast(context, 'Lengkapi data wajib dulu ya.');
      return;
    }
    widget.go('workerOnboarding2');
  }

  @override
  Widget build(BuildContext context) {
    return _MitraStepScaffold(
      title: 'Data Diri Mitra',
      subtitle:
          'Isi data dasar agar warga tahu siapa yang akan datang membantu.',
      progress: 1,
      onBack: () => widget.go('roleSelection'),
      children: [
        _RequiredField(
          label: 'Nama lengkap',
          controller: fullName,
          hint: 'Contoh: Rudi Hartono',
          submitted: submitted,
        ),
        _RequiredField(
          label: 'Nama panggilan / nama usaha',
          controller: businessName,
          hint: 'Contoh: Pak Rudi AC',
          submitted: submitted,
        ),
        _RequiredField(
          label: 'Nomor WhatsApp aktif',
          controller: whatsapp,
          hint: '+62 812-3456-7890',
          submitted: submitted,
          suffix: const BrTag(label: 'Nomor terverifikasi', color: 'success'),
        ),
        _UploadActionCard(
          title: 'Foto profil',
          required: true,
          state: mitraDraft.profilePhoto,
          emptyText: 'Upload foto wajah atau logo usaha',
          uploadedText: 'Foto profil siap ditampilkan',
          buttonText: 'Upload Foto',
          onUpload: () => _uploadInto(
            context: context,
            setState: setState,
            name: 'profile',
            apply: (state, _) => mitraDraft.profilePhoto = state,
          ),
        ),
        if (submitted && mitraDraft.profilePhoto != UploadState.uploaded)
          const _InlineError('Foto profil wajib diunggah.'),
        _RequiredField(
          label: 'Domisili',
          controller: domicile,
          hint: 'Contoh: Tebet, Jakarta Selatan',
          submitted: submitted,
        ),
        _OptionalField(
          label: 'Deskripsi singkat',
          controller: bio,
          hint:
              'Ceritakan pengalamanmu secara singkat. Contoh: Teknisi AC rumahan dengan pengalaman 9 tahun di area Tebet.',
          maxLines: 4,
          helper: '${bio.text.length}/160',
        ),
        _EdgeStatePanel(),
        _FlowCta(
          label: 'Lanjut ke Layanan',
          enabled: mitraDraft.step1Ready,
          onTap: _next,
        ),
      ],
    );
  }
}

class MitraLayananScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const MitraLayananScreen({super.key, required this.go});

  @override
  State<MitraLayananScreen> createState() => _MitraLayananScreenState();
}

class _MitraLayananScreenState extends State<MitraLayananScreen> {
  late final tools = TextEditingController(text: mitraDraft.tools);
  bool submitted = false;

  @override
  void initState() {
    super.initState();
    tools.addListener(() {
      mitraDraft.tools = tools.text;
      setState(() {});
    });
  }

  @override
  void dispose() {
    tools.dispose();
    super.dispose();
  }

  void _toggleService(String service) {
    setState(() {
      if (mitraDraft.services.contains(service)) {
        mitraDraft.services.remove(service);
        for (final sub in _subServiceMap[service] ?? <String>[]) {
          mitraDraft.subServices.remove(sub);
        }
      } else {
        mitraDraft.services.add(service);
      }
    });
  }

  void _next() {
    setState(() => submitted = true);
    if (!mitraDraft.step2Ready) {
      _showMitraToast(context, 'Pilih layanan dan pengalaman kerja dulu ya.');
      return;
    }
    widget.go('workerOnboarding3');
  }

  @override
  Widget build(BuildContext context) {
    final visibleSubs = [
      for (final service in mitraDraft.services)
        ...(_subServiceMap[service] ?? <String>[]),
    ];
    return _MitraStepScaffold(
      title: 'Layanan yang Kamu Tawarkan',
      subtitle:
          'Pilih layanan yang benar-benar kamu kuasai agar rekomendasi ke warga lebih tepat.',
      progress: 2,
      onBack: () => widget.go('workerOnboarding1'),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _serviceIcons.keys.map((service) {
            return _ServiceSelectCard(
              label: service,
              icon: _serviceIcons[service]!,
              active: mitraDraft.services.contains(service),
              onTap: () => _toggleService(service),
            );
          }).toList(),
        ),
        if (submitted && mitraDraft.services.isEmpty)
          const _InlineError('Pilih minimal satu layanan.'),
        if (visibleSubs.isNotEmpty) ...[
          const SectionTitle('Detail layanan'),
          BrCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: List.generate(visibleSubs.length, (index) {
                final sub = visibleSubs[index];
                return _CheckRow(
                  title: sub,
                  active: mitraDraft.subServices.contains(sub),
                  border: index < visibleSubs.length - 1,
                  onTap: () {
                    setState(() {
                      if (mitraDraft.subServices.contains(sub)) {
                        mitraDraft.subServices.remove(sub);
                      } else {
                        mitraDraft.subServices.add(sub);
                      }
                    });
                  },
                );
              }),
            ),
          ),
        ],
        const SectionTitle('Pengalaman kerja'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['<1 tahun', '1-3 tahun', '3-5 tahun', '5+ tahun'].map((
            item,
          ) {
            return BrChip(
              label: item,
              active: mitraDraft.experience == item,
              variant: 'primary',
              onTap: () => setState(() => mitraDraft.experience = item),
            );
          }).toList(),
        ),
        if (submitted && mitraDraft.experience.isEmpty)
          const _InlineError('Pilih pengalaman kerja.'),
        _OptionalField(
          label: 'Peralatan yang dimiliki',
          controller: tools,
          hint: 'Contoh: Jet cleaner AC, tangga, alat ukur freon',
          maxLines: 2,
        ),
        _FlowCta(
          label: 'Lanjut ke Area & Jadwal',
          enabled: mitraDraft.step2Ready,
          onTap: _next,
        ),
      ],
    );
  }
}

class MitraAreaJadwalScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const MitraAreaJadwalScreen({super.key, required this.go});

  @override
  State<MitraAreaJadwalScreen> createState() => _MitraAreaJadwalScreenState();
}

class _MitraAreaJadwalScreenState extends State<MitraAreaJadwalScreen> {
  late final area = TextEditingController(text: mitraDraft.areaQuery);
  late final emergencyFee = TextEditingController(
    text: mitraDraft.emergencyFee,
  );
  late final emergencyHours = TextEditingController(
    text: mitraDraft.emergencyHours,
  );
  bool submitted = false;

  @override
  void initState() {
    super.initState();
    if (mitraDraft.areas.isEmpty) {
      mitraDraft.areas.addAll(['Tebet', 'Pancoran', 'Manggarai']);
    }
    if (mitraDraft.days.isEmpty) {
      mitraDraft.days.addAll([
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
      ]);
    }
    mitraDraft.availability = mitraDraft.availability.isEmpty
        ? 'Bisa hari ini'
        : mitraDraft.availability;
    area.addListener(() => mitraDraft.areaQuery = area.text);
    emergencyFee.addListener(() => mitraDraft.emergencyFee = emergencyFee.text);
    emergencyHours.addListener(
      () => mitraDraft.emergencyHours = emergencyHours.text,
    );
  }

  @override
  void dispose() {
    area.dispose();
    emergencyFee.dispose();
    emergencyHours.dispose();
    super.dispose();
  }

  void _next() {
    setState(() => submitted = true);
    if (!mitraDraft.step3Ready) {
      _showMitraToast(context, 'Lengkapi area, hari, dan jam kerja dulu ya.');
      return;
    }
    widget.go('workerOnboarding4');
  }

  @override
  Widget build(BuildContext context) {
    return _MitraStepScaffold(
      title: 'Area Kerja & Jadwal',
      subtitle: 'Tentukan area layanan dan kapan kamu bisa menerima pekerjaan.',
      progress: 3,
      onBack: () => widget.go('workerOnboarding2'),
      children: [
        _RequiredTextInput(
          label: 'Area kerja utama',
          controller: area,
          hint: 'Cari kecamatan atau area',
          onSubmit: () {
            if (area.text.trim().isEmpty) return;
            setState(() {
              mitraDraft.areas.add(area.text.trim());
              area.clear();
            });
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...mitraDraft.areas.map((item) {
              return BrChip(
                label: item,
                active: true,
                variant: 'primary',
                onTap: () => setState(() => mitraDraft.areas.remove(item)),
              );
            }),
            BrChip(
              label: 'Setiabudi',
              variant: 'primary',
              onTap: () => setState(() => mitraDraft.areas.add('Setiabudi')),
            ),
          ],
        ),
        if (submitted && mitraDraft.areas.isEmpty)
          const _InlineError('Pilih minimal satu area kerja.'),
        const SectionTitle('Radius layanan'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['2 km', '5 km', '10 km', 'Custom'].map((item) {
            return BrChip(
              label: item,
              active: mitraDraft.radius == item,
              variant: 'primary',
              onTap: () => setState(() => mitraDraft.radius = item),
            );
          }).toList(),
        ),
        const SectionTitle('Hari kerja'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                'Senin',
                'Selasa',
                'Rabu',
                'Kamis',
                'Jumat',
                'Sabtu',
                'Minggu',
              ].map((day) {
                return BrChip(
                  label: day,
                  active: mitraDraft.days.contains(day),
                  variant: 'primary',
                  onTap: () {
                    setState(() {
                      if (mitraDraft.days.contains(day)) {
                        mitraDraft.days.remove(day);
                      } else {
                        mitraDraft.days.add(day);
                      }
                    });
                  },
                );
              }).toList(),
        ),
        if (submitted && mitraDraft.days.isEmpty)
          const _InlineError('Pilih minimal satu hari kerja.'),
        const SectionTitle('Jam kerja'),
        Row(
          children: [
            Expanded(
              child: _TimePill(
                label: 'Mulai',
                value: mitraDraft.startTime,
                onTap: () => setState(() => mitraDraft.startTime = '08.00'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TimePill(
                label: 'Selesai',
                value: mitraDraft.endTime,
                onTap: () => setState(() => mitraDraft.endTime = '19.00'),
              ),
            ),
          ],
        ),
        const SectionTitle('Ketersediaan'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Bisa hari ini', 'By schedule', 'Hanya akhir pekan'].map((
            item,
          ) {
            return BrChip(
              label: item,
              active: mitraDraft.availability == item,
              variant: 'primary',
              onTap: () => setState(() => mitraDraft.availability = item),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _SwitchCard(
          title: 'Terima panggilan darurat',
          description:
              'Untuk pekerjaan mendesak seperti pipa bocor atau listrik mati.',
          value: mitraDraft.emergency,
          onChanged: (value) => setState(() => mitraDraft.emergency = value),
        ),
        if (mitraDraft.emergency) ...[
          _OptionalField(
            label: 'Emergency fee',
            controller: emergencyFee,
            hint: 'Contoh: Rp50.000',
          ),
          _OptionalField(
            label: 'Emergency hours',
            controller: emergencyHours,
            hint: 'Contoh: 18.00-22.00',
          ),
        ],
        _FlowCta(
          label: 'Lanjut ke Harga',
          enabled: mitraDraft.step3Ready,
          onTap: _next,
        ),
      ],
    );
  }
}

class MitraHargaScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const MitraHargaScreen({super.key, required this.go});

  @override
  State<MitraHargaScreen> createState() => _MitraHargaScreenState();
}

class _MitraHargaScreenState extends State<MitraHargaScreen> {
  final fromControllers = <String, TextEditingController>{};
  final toControllers = <String, TextEditingController>{};
  late final bookingFee = TextEditingController(
    text: mitraDraft.bookingFeeAmount,
  );
  bool submitted = false;

  List<String> get pricedServices {
    final chosen = mitraDraft.subServices.isNotEmpty
        ? mitraDraft.subServices
        : mitraDraft.services;
    return chosen.isEmpty
        ? ['Cuci AC', 'AC bocor', 'Isi freon']
        : chosen.toList();
  }

  @override
  void initState() {
    super.initState();
    bookingFee.addListener(() => mitraDraft.bookingFeeAmount = bookingFee.text);
  }

  TextEditingController _from(String key) {
    return fromControllers.putIfAbsent(key, () {
      final controller = TextEditingController(
        text: mitraDraft.priceFrom[key] ?? _sampleFrom(key),
      );
      controller.addListener(() {
        mitraDraft.priceFrom[key] = controller.text;
        setState(() {});
      });
      mitraDraft.priceFrom[key] = controller.text;
      return controller;
    });
  }

  TextEditingController _to(String key) {
    return toControllers.putIfAbsent(key, () {
      final controller = TextEditingController(
        text: mitraDraft.priceTo[key] ?? _sampleTo(key),
      );
      controller.addListener(() {
        mitraDraft.priceTo[key] = controller.text;
        setState(() {});
      });
      mitraDraft.priceTo[key] = controller.text;
      return controller;
    });
  }

  @override
  void dispose() {
    for (final controller in [
      ...fromControllers.values,
      ...toControllers.values,
    ]) {
      controller.dispose();
    }
    bookingFee.dispose();
    super.dispose();
  }

  void _next() {
    setState(() => submitted = true);
    if (!mitraDraft.step4Ready) {
      _showMitraToast(context, 'Isi minimal satu harga mulai dari dulu ya.');
      return;
    }
    widget.go('workerOnboarding5');
  }

  @override
  Widget build(BuildContext context) {
    return _MitraStepScaffold(
      title: 'Atur Harga Layanan',
      subtitle:
          'Harga transparan membantu warga percaya sebelum menghubungi kamu.',
      progress: 4,
      onBack: () => widget.go('workerOnboarding3'),
      children: [
        ...pricedServices.map((service) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PriceRowCard(
              service: service,
              from: _from(service),
              to: _to(service),
            ),
          );
        }),
        if (submitted && !mitraDraft.step4Ready)
          const _InlineError('Isi minimal satu harga utama.'),
        const _TrustNote(
          icon: Icons.info_outline,
          text:
              'Harga final tetap bisa berubah setelah pengecekan langsung, tapi wajib dikonfirmasi ke customer sebelum pekerjaan dimulai.',
        ),
        const SectionTitle('Preferensi pembayaran'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                'Bayar setelah selesai',
                'Booking fee',
                'QRIS pribadi',
                'Transfer bank',
                'Tunai',
              ].map((item) {
                return BrChip(
                  label: item,
                  active: mitraDraft.payments.contains(item),
                  variant: 'primary',
                  onTap: () {
                    setState(() {
                      if (mitraDraft.payments.contains(item)) {
                        mitraDraft.payments.remove(item);
                      } else {
                        mitraDraft.payments.add(item);
                      }
                      if (mitraDraft.payments.isEmpty) {
                        mitraDraft.payments.add('Bayar setelah selesai');
                      }
                    });
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 12),
        _SwitchCard(
          title: 'Terima booking fee via Beresin',
          description: 'Opsional untuk mengamankan jadwal sebelum kunjungan.',
          value: mitraDraft.bookingFee,
          onChanged: (value) => setState(() => mitraDraft.bookingFee = value),
        ),
        if (mitraDraft.bookingFee)
          _OptionalField(
            label: 'Nominal booking fee',
            controller: bookingFee,
            hint: 'Rp15.000',
          ),
        _FlowCta(
          label: 'Lanjut ke Verifikasi',
          enabled: mitraDraft.step4Ready,
          onTap: _next,
        ),
      ],
    );
  }
}

class MitraVerifikasiScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const MitraVerifikasiScreen({super.key, required this.go});

  @override
  State<MitraVerifikasiScreen> createState() => _MitraVerifikasiScreenState();
}

class _MitraVerifikasiScreenState extends State<MitraVerifikasiScreen> {
  late final refName = TextEditingController(text: mitraDraft.referenceName);
  late final refPhone = TextEditingController(text: mitraDraft.referencePhone);
  late final refNote = TextEditingController(text: mitraDraft.referenceNote);
  bool submitted = false;
  bool _portfolioBusy = false;

  @override
  void initState() {
    super.initState();
    refName.addListener(() => mitraDraft.referenceName = refName.text);
    refPhone.addListener(() => mitraDraft.referencePhone = refPhone.text);
    refNote.addListener(() => mitraDraft.referenceNote = refNote.text);
  }

  @override
  void dispose() {
    refName.dispose();
    refPhone.dispose();
    refNote.dispose();
    super.dispose();
  }

  void _next() {
    setState(() => submitted = true);
    if (!mitraDraft.verificationReady) {
      _showMitraToast(context, 'Lengkapi verifikasi wajib dulu ya.');
      return;
    }
    widget.go('workerReview');
  }

  @override
  Widget build(BuildContext context) {
    return _MitraStepScaffold(
      title: 'Verifikasi untuk Membangun Kepercayaan',
      subtitle: 'Data ini membantu warga merasa aman saat booking layanan.',
      progress: 5,
      onBack: () => widget.go('workerOnboarding4'),
      children: [
        _UploadActionCard(
          title: 'Upload KTP',
          required: true,
          state: mitraDraft.ktp,
          emptyText: 'Upload foto KTP',
          uploadedText: 'KTP berhasil diunggah',
          buttonText: 'Upload KTP',
          onUpload: () => _uploadInto(
            context: context,
            setState: setState,
            name: 'ktp',
            apply: (state, path) {
              mitraDraft.ktp = state;
              if (path != null) mitraDraft.ktpPath = path;
            },
          ),
        ),
        _UploadActionCard(
          title: 'Selfie wajah',
          required: true,
          state: mitraDraft.selfie,
          emptyText: 'Ambil selfie wajah',
          uploadedText: 'Selfie berhasil diunggah',
          buttonText: 'Buka Kamera',
          onUpload: () => _uploadInto(
            context: context,
            setState: setState,
            name: 'selfie',
            source: ImageSource.camera,
            apply: (state, path) {
              mitraDraft.selfie = state;
              if (path != null) mitraDraft.selfiePath = path;
            },
          ),
        ),
        BrCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nomor aktif dan terverifikasi',
                  style: pj(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const BrTag(label: 'Terverifikasi', color: 'success'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _WorkPhotoCard(
          count: mitraDraft.workPhotos,
          busy: _portfolioBusy,
          onUpload: () async {
            setState(() => _portfolioBusy = true);
            await _addPortfolioPhotos(context);
            if (mounted) setState(() => _portfolioBusy = false);
          },
        ),
        const SectionTitle('Referensi pelanggan'),
        _OptionalField(
          label: 'Nama pelanggan',
          controller: refName,
          hint: 'Contoh: Ibu Mira',
        ),
        _OptionalField(
          label: 'Nomor WhatsApp pelanggan',
          controller: refPhone,
          hint: '+62 812-xxxx-xxxx',
        ),
        _OptionalField(
          label: 'Catatan',
          controller: refNote,
          hint: 'Contoh: Pernah service AC rumah Ibu Mira di Tebet.',
          maxLines: 3,
        ),
        BrButton(
          label: 'Tambah Referensi',
          full: true,
          size: BrButtonSize.sm,
          variant: BrButtonVariant.secondary,
          onPressed: () =>
              _showMitraToast(context, 'Referensi pelanggan disimpan.'),
        ),
        const SizedBox(height: 12),
        const _TrustNote(
          icon: Icons.privacy_tip_outlined,
          text:
              "Data KTP tidak akan ditampilkan ke publik. Beresin hanya menampilkan status 'Identitas terverifikasi'.",
        ),
        const SizedBox(height: 10),
        const _TrustNote(
          icon: Icons.shield_outlined,
          text:
              'Pendaftaran bisa ditinjau manual oleh tim Beresin sebelum profil aktif.',
        ),
        if (submitted && !mitraDraft.verificationReady)
          const _InlineError(
            'Lengkapi KTP, selfie, WhatsApp, dan minimal 2 foto pekerjaan.',
          ),
        _FlowCta(
          label: 'Review Pendaftaran',
          enabled: mitraDraft.verificationReady,
          onTap: _next,
        ),
      ],
    );
  }
}

class MitraReviewScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const MitraReviewScreen({super.key, required this.go});

  @override
  State<MitraReviewScreen> createState() => _MitraReviewScreenState();
}

class _MitraReviewScreenState extends State<MitraReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final services = mitraDraft.subServices.isEmpty
        ? mitraDraft.services.toList()
        : mitraDraft.subServices.toList();
    return _MitraStepScaffold(
      title: 'Review Pendaftaran',
      subtitle: 'Cek lagi data kamu sebelum dikirim untuk verifikasi.',
      progress: 6,
      onBack: () => widget.go('workerOnboarding5'),
      children: [
        _ReviewSection(
          title: 'Profil',
          lines: [
            'Nama: ${_fallback(mitraDraft.fullName, 'Rudi Hartono')}',
            'Nama usaha: ${_fallback(mitraDraft.businessName, 'Pak Rudi AC')}',
            'WhatsApp: ${mitraDraft.whatsapp}',
            'Domisili: ${_fallback(mitraDraft.domicile, 'Tebet, Jakarta Selatan')}',
            'Foto profil: Terunggah',
          ],
          onEdit: () => widget.go('workerOnboarding1'),
        ),
        _ReviewSection(
          title: 'Layanan',
          lines: [
            ...mitraDraft.services.map((item) => item),
            ...services.take(5).map((item) => '- $item'),
            'Experience: ${mitraDraft.experience == '5+ tahun' ? '9 tahun' : mitraDraft.experience}',
          ],
          onEdit: () => widget.go('workerOnboarding2'),
        ),
        _ReviewSection(
          title: 'Area & Jadwal',
          lines: [
            'Area: ${mitraDraft.areas.join(', ')}',
            'Radius: ${mitraDraft.radius}',
            'Jam kerja: ${_daysSummary()}, ${mitraDraft.startTime}-${mitraDraft.endTime}',
            'Darurat: ${mitraDraft.emergency ? 'Aktif' : 'Tidak aktif'}',
          ],
          onEdit: () => widget.go('workerOnboarding3'),
        ),
        _ReviewSection(
          title: 'Harga',
          lines: [
            for (final service in services.take(4))
              '$service: ${_priceSummary(service)}',
            'Pembayaran: ${mitraDraft.payments.join(', ')}',
          ],
          onEdit: () => widget.go('workerOnboarding4'),
        ),
        _ReviewSection(
          title: 'Verifikasi',
          lines: [
            'KTP: Terunggah',
            'Selfie: Terunggah',
            'WhatsApp: Terverifikasi',
            'Foto pekerjaan: ${mitraDraft.workPhotos} foto',
            'Referensi: ${mitraDraft.referenceName.trim().isEmpty ? '0 pelanggan' : '1 pelanggan'}',
          ],
          onEdit: () => widget.go('workerOnboarding5'),
        ),
        BrCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: mitraDraft.agreement,
                activeColor: AppColors.primary,
                onChanged: (value) =>
                    setState(() => mitraDraft.agreement = value ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Saya menyatakan data yang saya isi benar dan bersedia mengikuti standar layanan Beresin.',
                    style: pj(
                      fontSize: 12.5,
                      color: AppColors.ink2,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _FlowCta(
          label: 'Kirim Pendaftaran',
          enabled: mitraDraft.canSubmit,
          onTap: () {
            if (!mitraDraft.canSubmit) {
              _showMitraToast(context, 'Centang pernyataan dulu ya.');
              return;
            }
            widget.go('workerSubmitting');
          },
        ),
      ],
    );
  }
}

class MitraSubmittingScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const MitraSubmittingScreen({super.key, required this.go});

  @override
  State<MitraSubmittingScreen> createState() => _MitraSubmittingScreenState();
}

class _MitraSubmittingScreenState extends State<MitraSubmittingScreen> {
  int step = 0;
  Timer? timer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _submit();
  }

  Future<void> _submit() async {
    setState(() {
      step = 0;
      _error = null;
    });
    // Timer hanya animasi; navigasi menunggu submit benar-benar selesai.
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted || step >= 3) return timer.cancel();
      setState(() => step++);
    });
    try {
      await Future.wait([
        appRepository.submitWorkerApplication(_workerApplicationFromDraft()),
        Future<void>.delayed(const Duration(milliseconds: 2600)),
      ]);
      if (mounted) widget.go('workerSubmitted');
    } catch (e) {
      timer?.cancel();
      if (!mounted) return;
      setState(
        () => _error = e is StateError
            ? e.message
            : 'Pendaftaran gagal dikirim. Cek koneksi lalu coba lagi.',
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Mengunggah data profil',
      'Menyimpan layanan dan harga',
      'Mengirim dokumen verifikasi',
      'Menyiapkan review oleh tim Beresin',
    ];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          MediaQuery.of(context).viewPadding.top + 40,
          18,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrLogo(size: 48),
            const SizedBox(height: 28),
            Text(
              'Mengirim Pendaftaran...',
              style: pj(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tunggu sebentar, data kamu sedang disiapkan untuk tim verifikasi.',
              style: pj(fontSize: 13.5, color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 24),
            BrCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: List.generate(steps.length, (index) {
                  return _ProgressRow(
                    title: steps[index],
                    active: index <= step,
                    loading: _error == null && index == step,
                    border: index < steps.length - 1,
                  );
                }),
              ),
            ),
            if (_error != null) ...[
              _InlineError(_error!),
              const SizedBox(height: 16),
              BrButton(label: 'Coba Lagi', full: true, onPressed: _submit),
              const SizedBox(height: 8),
              BrButton(
                label: 'Kembali ke Ringkasan',
                full: true,
                variant: BrButtonVariant.secondary,
                onPressed: () => widget.go('workerReview'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MitraSubmittedScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const MitraSubmittedScreen({super.key, required this.go});

  @override
  Widget build(BuildContext context) {
    return _MitraBaseScaffold(
      title: 'Pendaftaran Terkirim',
      subtitle:
          'Tim Beresin akan meninjau profilmu sebelum ditampilkan ke warga sekitar.',
      children: [
        BrCard(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary50,
          border: Border.all(color: AppColors.primary100),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top, color: AppColors.primaryDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menunggu Verifikasi',
                      style: pj(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Estimasi 1-2 hari kerja',
                      style: pj(fontSize: 12, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Timeline'),
        BrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _ProgressRow(
                title: 'Data profil diterima',
                active: true,
                border: true,
              ),
              _ProgressRow(title: 'Dokumen dicek', border: true),
              _ProgressRow(title: 'Layanan diverifikasi', border: true),
              _ProgressRow(title: 'Profil aktif'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _TrustNote(
          icon: Icons.edit_note,
          text:
              'Kamu tetap bisa melengkapi atau mengubah data selama proses verifikasi.',
        ),
        const SizedBox(height: 18),
        BrButton(
          label: 'Lihat Dashboard Mitra',
          full: true,
          size: BrButtonSize.lg,
          onPressed: () => go('workerDashboard'),
        ),
        const SizedBox(height: 10),
        BrButton(
          label: 'Kembali ke Mode Customer',
          full: true,
          variant: BrButtonVariant.secondary,
          onPressed: () => go('home'),
        ),
      ],
    );
  }
}

class MitraDashboardPendingScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const MitraDashboardPendingScreen({super.key, required this.go});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 18;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).viewPadding.top + 18,
        18,
        bottom,
      ),
      children: [
        Row(
          children: [
            const Avatar(name: 'Pak Rudi AC', size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Mitra',
                    style: pj(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Halo, ${_fallback(mitraDraft.businessName, 'Pak Rudi AC')}',
                    style: pj(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            _RoundIconButton(
              icon: Icons.person_outline,
              onTap: () => go('profileWorkerMode'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BrCard(
          padding: const EdgeInsets.all(15),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8EE), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFFFE9C2)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.pending_actions, color: AppColors.accentDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil sedang diverifikasi',
                      style: pj(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Kamu belum bisa menerima order sampai verifikasi selesai.',
                      style: pj(
                        fontSize: 12.5,
                        color: AppColors.muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Progress verifikasi'),
        BrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _ProgressRow(title: 'Profil lengkap', active: true, border: true),
              _ProgressRow(
                title: 'Dokumen diterima',
                active: true,
                border: true,
              ),
              _ProgressRow(
                title: 'Sedang ditinjau',
                loading: true,
                border: true,
              ),
              _ProgressRow(title: 'Profil aktif'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        BrButton(
          label: 'Edit Pendaftaran',
          full: true,
          onPressed: () => go('workerReview'),
        ),
        const SizedBox(height: 10),
        BrButton(
          label: 'Hubungi Support',
          full: true,
          variant: BrButtonVariant.secondary,
          onPressed: () => _showMitraToast(context, 'Support Mitra dibuka.'),
        ),
      ],
    );
  }
}

class _MitraStepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final int progress;
  final VoidCallback onBack;
  final List<Widget> children;

  const _MitraStepScaffold({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.onBack,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return _MitraBaseScaffold(
      title: title,
      subtitle: subtitle,
      onBack: onBack,
      children: [
        _ProgressHeader(progress: progress),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _MitraBaseScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final List<Widget> children;

  const _MitraBaseScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 18;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FloatingBackScaffold(
        onBack: onBack,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            18,
            MediaQuery.of(context).viewPadding.top + (onBack != null ? 72 : 14),
            18,
            bottom,
          ),
          children: [
            Text(
              title,
              style: pj(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: pj(fontSize: 13.5, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int progress;

  const _ProgressHeader({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BrTag(label: 'Langkah $progress dari 6', color: 'success'),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress / 6,
              backgroundColor: AppColors.line,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7, top: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: pj(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ),
          BrTag(
            label: required ? 'Wajib' : 'Opsional',
            color: required ? 'accent' : 'neutral',
          ),
        ],
      ),
    );
  }
}

class _RequiredField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool submitted;
  final Widget? suffix;

  const _RequiredField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.submitted,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final missing = submitted && controller.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: true),
        TextField(
          controller: controller,
          style: pj(fontSize: 13.5, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            errorText: missing ? 'Wajib diisi' : null,
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(widthFactor: 1, child: suffix),
                  ),
          ),
        ),
      ],
    );
  }
}

class _RequiredTextInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmit;

  const _RequiredTextInput({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: true),
        TextField(
          controller: controller,
          style: pj(fontSize: 13.5, color: AppColors.ink),
          onSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onSubmit,
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionalField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? helper;

  const _OptionalField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: false),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: helper == null ? null : 160,
          style: pj(fontSize: 13.5, color: AppColors.ink, height: 1.4),
          decoration: InputDecoration(hintText: hint, counterText: helper),
        ),
      ],
    );
  }
}

class _UploadActionCard extends StatelessWidget {
  final String title;
  final bool required;
  final UploadState state;
  final String emptyText;
  final String uploadedText;
  final String buttonText;
  final VoidCallback onUpload;

  const _UploadActionCard({
    required this.title,
    required this.required,
    required this.state,
    required this.emptyText,
    required this.uploadedText,
    required this.buttonText,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final isUploaded = state == UploadState.uploaded;
    final isUploading = state == UploadState.uploading;
    final error = switch (state) {
      UploadState.failed => 'Upload gagal. Coba lagi atau pilih foto lain.',
      UploadState.tooLarge => 'Ukuran file terlalu besar. Maksimal 5 MB.',
      UploadState.blurry => 'Foto KTP kurang jelas. Pastikan tulisan terbaca.',
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: title, required: required),
        BrCard(
          padding: const EdgeInsets.all(14),
          color: isUploaded ? AppColors.primary50 : Colors.white,
          border: Border.all(
            color: isUploaded ? AppColors.primary100 : AppColors.line,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _UploadPreview(uploaded: isUploaded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUploading
                              ? 'Mengunggah...'
                              : isUploaded
                              ? uploadedText
                              : emptyText,
                          style: pj(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isUploaded
                              ? 'Preview berhasil dibuat'
                              : 'JPG, PNG · maksimal 5 MB',
                          style: pj(fontSize: 11.5, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isUploading) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const LinearProgressIndicator(
                    minHeight: 7,
                    color: AppColors.primary,
                    backgroundColor: AppColors.line,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              BrButton(
                label: isUploaded ? 'Ganti' : buttonText,
                full: true,
                size: BrButtonSize.sm,
                onPressed: isUploading ? null : onUpload,
              ),
            ],
          ),
        ),
        if (error != null) _InlineError(error),
      ],
    );
  }
}

class _UploadPreview extends StatelessWidget {
  final bool uploaded;

  const _UploadPreview({required this.uploaded});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: uploaded ? AppColors.primary : AppColors.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        uploaded ? Icons.image : Icons.upload_file_outlined,
        color: uploaded ? Colors.white : AppColors.muted,
      ),
    );
  }
}

class _WorkPhotoCard extends StatelessWidget {
  final int count;
  final bool busy;
  final VoidCallback onUpload;

  const _WorkPhotoCard({
    required this.count,
    required this.busy,
    required this.onUpload,
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
                child: Text(
                  'Foto contoh pekerjaan',
                  style: pj(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const BrTag(label: 'Wajib', color: 'accent'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Upload minimal 2 foto hasil pekerjaan',
            style: pj(fontSize: 12, color: AppColors.muted),
          ),
          if (count > 0) ...[
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(count, (index) {
                final labels = ['Before', 'After', 'Sample 1', 'Sample 2'];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary100),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[index.clamp(0, labels.length - 1)],
                    textAlign: TextAlign.center,
                    style: pj(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 12),
          BrButton(
            label: busy ? 'Mengunggah...' : 'Upload Foto',
            full: true,
            size: BrButtonSize.sm,
            onPressed: busy || count >= _maxPortfolio ? null : onUpload,
          ),
        ],
      ),
    );
  }
}

class _ServiceSelectCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ServiceSelectCard({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.line,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? AppColors.primaryDark : AppColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: pj(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String title;
  final bool active;
  final bool border;
  final VoidCallback onTap;

  const _CheckRow({
    required this.title,
    required this.active,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              bottom: border
                  ? const BorderSide(color: AppColors.line2)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              Icon(
                active ? Icons.check_circle : Icons.radio_button_unchecked,
                color: active ? AppColors.primary : AppColors.muted,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: pj(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimePill({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: pj(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 3),
          Text(
            value,
            style: pj(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchCard({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Row(
        children: [
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
                const SizedBox(height: 3),
                Text(
                  description,
                  style: pj(
                    fontSize: 11.5,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary100,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PriceRowCard extends StatelessWidget {
  final String service;
  final TextEditingController from;
  final TextEditingController to;

  const _PriceRowCard({
    required this.service,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service,
            style: pj(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: from,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga mulai dari',
                    hintText: 'Rp80.000',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: to,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Sampai',
                    hintText: 'Rp120.000',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<String> lines;
  final VoidCallback onEdit;

  const _ReviewSection({
    required this.title,
    required this.lines,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BrCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: pj(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                BrButton(
                  label: 'Edit',
                  size: BrButtonSize.sm,
                  variant: BrButtonVariant.secondary,
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  line,
                  style: pj(
                    fontSize: 12.4,
                    color: AppColors.ink2,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String title;
  final bool active;
  final bool loading;
  final bool border;

  const _ProgressRow({
    required this.title,
    this.active = false,
    this.loading = false,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        border: Border(
          bottom: border
              ? const BorderSide(color: AppColors.line2)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          if (loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            Icon(
              active ? Icons.check_circle : Icons.radio_button_unchecked,
              color: active ? AppColors.primary : AppColors.muted,
              size: 20,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: pj(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowCta extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _FlowCta({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
            decoration: BoxDecoration(
              color: enabled ? AppColors.primary : AppColors.line,
              borderRadius: BorderRadius.circular(18),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                        spreadRadius: -6,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: pj(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: enabled ? Colors.white : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 15, color: AppColors.danger),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: pj(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EdgeStatePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const states = [
      'Nomor ini sudah terdaftar sebagai mitra.',
      'Pendaftaran belum terkirim. Periksa koneksi dan coba lagi.',
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: BrCard(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFFFFBF4),
        border: Border.all(color: const Color(0xFFFFE9C2)),
        boxShadow: const [],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contoh state error',
              style: pj(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: AppColors.accentDark,
              ),
            ),
            const SizedBox(height: 6),
            ...states.map(
              (state) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  state,
                  style: pj(
                    fontSize: 11.3,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustNote extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustNote({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(12),
      color: AppColors.primary50,
      border: Border.all(color: AppColors.primary100),
      boxShadow: const [],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: pj(
                fontSize: 11.8,
                color: AppColors.primaryDark,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line),
          ),
          child: Icon(icon, color: AppColors.ink, size: 22),
        ),
      ),
    );
  }
}

String _sampleFrom(String service) {
  if (service.toLowerCase().contains('bocor')) return 'Rp100.000';
  if (service.toLowerCase().contains('freon')) return 'Rp150.000';
  return 'Rp80.000';
}

String _sampleTo(String service) {
  if (service.toLowerCase().contains('freon')) return '';
  if (service.toLowerCase().contains('bocor')) return 'Rp150.000';
  return 'Rp120.000';
}

String _priceSummary(String service) {
  final from = mitraDraft.priceFrom[service] ?? _sampleFrom(service);
  final to = mitraDraft.priceTo[service] ?? _sampleTo(service);
  if (to.trim().isEmpty) return 'mulai $from';
  return '$from-$to';
}

WorkerApplication _workerApplicationFromDraft() {
  final now = DateTime.now();
  return WorkerApplication(
    // Id stabil supaya "Coba Lagi" menimpa pendaftaran yang sama.
    id: mitraDraft.applicationId ??=
        'worker-application-${now.microsecondsSinceEpoch}',
    fullName: mitraDraft.fullName,
    businessName: mitraDraft.businessName,
    whatsapp: mitraDraft.whatsapp,
    domicile: mitraDraft.domicile,
    bio: mitraDraft.bio,
    services: mitraDraft.services.toList(),
    subServices: mitraDraft.subServices.toList(),
    areas: mitraDraft.areas.toList(),
    days: mitraDraft.days.toList(),
    startTime: mitraDraft.startTime,
    endTime: mitraDraft.endTime,
    priceFrom: Map<String, String>.from(mitraDraft.priceFrom),
    priceTo: Map<String, String>.from(mitraDraft.priceTo),
    ktpAssetPath: mitraDraft.ktpPath,
    selfieAssetPath: mitraDraft.selfiePath,
    portfolioAssetPaths: List.of(mitraDraft.portfolioPaths),
    status: WorkerVerificationStatus.pending,
    createdAt: now,
    updatedAt: now,
  );
}

String _fallback(String value, String fallback) =>
    value.trim().isEmpty ? fallback : value.trim();

String _daysSummary() {
  final days = mitraDraft.days.toList();
  if (days.length >= 6 && days.contains('Senin') && days.contains('Sabtu')) {
    return 'Senin-Sabtu';
  }
  return days.join(', ');
}

const _maxUploadBytes = 5 * 1024 * 1024; // = file_size_limit bucket
const _maxPortfolio = 6;

class _NotSignedIn implements Exception {}

/// Unggah ke bucket privat `worker-verification/<uid>/<name>.<ext>` dan
/// kembalikan object path-nya. Tanpa Supabase (demo/test) → path lokal.
Future<String> _uploadVerificationFile(
  String name,
  XFile file,
  Uint8List bytes,
) async {
  final ext = file.name.contains('.')
      ? file.name.split('.').last.toLowerCase()
      : 'jpg';
  final SupabaseClient client;
  try {
    client = Supabase.instance.client;
  } catch (_) {
    return 'local/$name.$ext';
  }
  final uid = client.auth.currentUser?.id;
  if (uid == null) throw _NotSignedIn();
  final path = '$uid/$name.$ext';
  await client.storage
      .from('worker-verification')
      .uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: file.mimeType ?? 'image/${ext == 'jpg' ? 'jpeg' : ext}',
        ),
      );
  return path;
}

String _uploadErrorText(Object error) => error is _NotSignedIn
    ? 'Masuk dulu ke akun Beresin sebelum mengunggah dokumen.'
    : 'Upload gagal. Cek koneksi lalu coba lagi.';

Future<void> _uploadInto({
  required BuildContext context,
  required StateSetter setState,
  required String name,
  required void Function(UploadState state, String? path) apply,
  ImageSource source = ImageSource.gallery,
}) async {
  final file = await ImagePicker().pickImage(
    source: source,
    imageQuality: 80,
    maxWidth: 1600,
  );
  if (file == null || !context.mounted) return;
  setState(() => apply(UploadState.uploading, null));
  try {
    final bytes = await file.readAsBytes();
    if (bytes.length > _maxUploadBytes) {
      if (context.mounted) setState(() => apply(UploadState.tooLarge, null));
      return;
    }
    final path = await _uploadVerificationFile(name, file, bytes);
    if (context.mounted) setState(() => apply(UploadState.uploaded, path));
  } catch (e) {
    if (!context.mounted) return;
    setState(() => apply(UploadState.failed, null));
    _showMitraToast(context, _uploadErrorText(e));
  }
}

Future<void> _addPortfolioPhotos(BuildContext context) async {
  final files = await ImagePicker().pickMultiImage(
    imageQuality: 80,
    maxWidth: 1600,
  );
  for (final file in files) {
    if (mitraDraft.portfolioPaths.length >= _maxPortfolio) break;
    try {
      final bytes = await file.readAsBytes();
      if (bytes.length > _maxUploadBytes) {
        if (context.mounted) {
          _showMitraToast(context, '${file.name} lebih dari 5 MB, dilewati.');
        }
        continue;
      }
      final n = mitraDraft.portfolioPaths.length + 1;
      mitraDraft.portfolioPaths.add(
        await _uploadVerificationFile('portfolio-$n', file, bytes),
      );
    } catch (e) {
      if (context.mounted) _showMitraToast(context, _uploadErrorText(e));
      return;
    }
  }
}

void _showMitraToast(BuildContext context, String message) {
  final messenger = context.findAncestorStateOfType<ScaffoldMessengerState>();
  messenger?.hideCurrentSnackBar();
  messenger?.showSnackBar(
    SnackBar(
      content: Text(message, style: pj(color: Colors.white)),
      backgroundColor: AppColors.ink,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1600),
    ),
  );
}
