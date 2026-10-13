import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import '../../models.dart';
import '../../widgets.dart';

class UploadScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;
  const UploadScreen({super.key, required this.go, required this.state});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late final TextEditingController _desc = TextEditingController(
    text: widget.state.desc,
  );
  final _picker = ImagePicker();
  XFile? _pickedFile;
  bool _uploading = false;
  final urgencies = const [
    ['Normal', 'Bisa nunggu'],
    ['Segera', 'Hari ini'],
    ['Darurat', 'Sekarang juga'],
  ];

  Future<void> _pickPhoto(ImageSource source) async {
    final photo = await _picker.pickImage(source: source, imageQuality: 80);
    if (photo == null || !mounted) return;
    setState(() {
      _pickedFile = photo;
      widget.state.hasPhoto = true;
    });
  }

  Future<String?> _uploadPhotoIfAny() async {
    final file = _pickedFile;
    if (file == null) return null;
    SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      return null;
    }
    final userId = client.auth.currentUser?.id ?? 'anon';
    final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
    final path =
        'diagnoses/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    try {
      final bytes = await file.readAsBytes();
      await client.storage.from('diagnoses').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: false, contentType: 'image/jpeg'),
          );
      return client.storage.from('diagnoses').getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final category = diagnosisByLabel(s.cat);
    final navBottom = MediaQuery.of(context).padding.bottom + 120;
    return FloatingBackScaffold(
      onBack: () => widget.go('home'),
      child: ListView(
        padding: EdgeInsets.only(bottom: navBottom),
        children: [
          ScreenHeader(
            title: category.intakeTitle,
            subtitle: 'Langkah 1 dari 3',
            onBack: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.intakeSubtitle,
                  style: pj(fontSize: 13.5, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                BrCard(
                  onTap: () => widget.go('symptomIntake'),
                  padding: const EdgeInsets.all(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8EE), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0xFFFFE9C2)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.accent50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: AppColors.accentDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aku nggak tahu masalahnya apa',
                              style: pj(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ceritakan gejalanya atau upload foto. AI bantu cari tahu jenis masalah dan tukang yang cocok.',
                              style: pj(
                                fontSize: 12,
                                color: AppColors.ink2,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Mulai dari Gejala',
                              style: pj(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accentDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.accentDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => widget.go('fairPrice'),
                    child: Text(
                      'Cuma mau cek harga?',
                      style: pj(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih kategori',
                  style: pj(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink2,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: diagnosisCategories.map((c) {
                    return BrChip(
                      label: c.label,
                      active: s.cat == c.label,
                      variant: 'primary',
                      icon: ServiceIcon(
                        kind: c.serviceKind,
                        categoryId: c.id,
                        size: 20,
                      ),
                      onTap: () => setState(() {
                        s.cat = c.label;
                        s.selectedProblem = c.problemChips.first;
                      }),
                    );
                  }).toList(),
                ),
                if (s.cat.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  BrCard(
                    padding: const EdgeInsets.all(12),
                    color: AppColors.primary50,
                    border: Border.all(color: AppColors.primary100),
                    child: Row(
                      children: [
                        ServiceIcon(
                          kind: category.serviceKind,
                          categoryId: category.id,
                          size: 36,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Masalah yang dipilih',
                                style: pj(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.selectedProblem,
                                style: pj(
                                  fontSize: 13,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        BrTag(label: 'Gratis', color: 'success'),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => setState(() => s.hasPhoto = true),
                  child: Container(
                    height: s.hasPhoto ? 220 : null,
                    padding: s.hasPhoto
                        ? null
                        : const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 32,
                          ),
                    constraints: const BoxConstraints(minHeight: 200),
                    decoration: BoxDecoration(
                      color: s.hasPhoto ? AppColors.ink : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: s.hasPhoto
                          ? null
                          : Border.all(
                              color: const Color(0xFFB7C4BD),
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: s.hasPhoto
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: _pickedFile == null
                                    ? const MockACPhoto()
                                    : Image.file(
                                        File(_pickedFile!.path),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _pickedFile = null;
                                    s.hasPhoto = false;
                                  }),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: .5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: .55),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Color(0xFF7DE0AD),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Foto siap dianalisis',
                                        style: pj(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary50, Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Ambil Foto / Upload',
                                style: pj(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.uploadLabel,
                                textAlign: TextAlign.center,
                                style: pj(
                                  fontSize: 11.5,
                                  color: AppColors.muted,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BrButton(
                                    label: 'Buka Kamera',
                                    size: BrButtonSize.sm,
                                    icon: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    onPressed: () =>
                                        _pickPhoto(ImageSource.camera),
                                    variant: BrButtonVariant.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  BrButton(
                                    label: 'Galeri',
                                    size: BrButtonSize.sm,
                                    variant: BrButtonVariant.secondary,
                                    icon: const Icon(
                                      Icons.image_outlined,
                                      color: AppColors.ink2,
                                      size: 14,
                                    ),
                                    onPressed: () =>
                                        _pickPhoto(ImageSource.gallery),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Ceritakan singkat ',
                        style: pj(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink2,
                        ),
                      ),
                      TextSpan(
                        text: '(opsional)',
                        style: pj(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _desc,
                  maxLines: 4,
                  onChanged: (v) => s.desc = v,
                  style: pj(fontSize: 14, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: category.placeholder,
                    hintStyle: pj(fontSize: 14, color: AppColors.muted),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tingkat keparahan',
                  style: pj(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: urgencies.map((u) {
                    final v = u[0], hint = u[1];
                    final active = s.urgency == v;
                    final isDanger = v == 'Darurat';
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: u == urgencies.last ? 0 : 8,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => s.urgency = v),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? (isDanger
                                        ? const Color(0xFFFBE9E2)
                                        : AppColors.primary50)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                width: 1.5,
                                color: active
                                    ? (isDanger
                                          ? AppColors.danger
                                          : AppColors.primary)
                                    : AppColors.line,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  v,
                                  style: pj(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: active
                                        ? (isDanger
                                              ? const Color(0xFFA93B22)
                                              : AppColors.primaryDark)
                                        : AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hint,
                                  style: pj(
                                    fontSize: 10.5,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                BrButton(
                  label: _uploading ? 'Mengunggah foto…' : 'Analisis dengan AI',
                  size: BrButtonSize.lg,
                  full: true,
                  icon: _uploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 18,
                        ),
                  iconRight: _uploading
                      ? null
                      : const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                  onPressed: _uploading
                      ? null
                      : () async {
                          if (s.urgency.isEmpty) {
                            s.urgency = 'Normal';
                          }
                          if (_pickedFile != null) {
                            setState(() => _uploading = true);
                            final url = await _uploadPhotoIfAny();
                            if (!mounted) return;
                            s.uploadedImageUrl = url;
                            setState(() => _uploading = false);
                          } else {
                            s.uploadedImageUrl = null;
                          }
                          if (!mounted) return;
                          widget.go('analyzing');
                        },
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Estimasi AI gratis · belum otomatis booking tukang',
                    style: pj(fontSize: 11, color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
