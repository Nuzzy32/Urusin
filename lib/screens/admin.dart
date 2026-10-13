import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

/// Panel operator: review pendaftaran mitra & mediasi komplain.
/// Gerbang sebenarnya ada di RLS + RPC `admin_review_application`; cek role di
/// sini hanya untuk UX.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

enum _Gate { loading, noBackend, signedOut, denied, error, ready }

class _AdminScreenState extends State<AdminScreen> {
  _Gate _gate = _Gate.loading;
  int _tab = 0;
  List<Map<String, dynamic>> _applications = const [];
  List<Map<String, dynamic>> _complaints = const [];
  Map<String, String> _urls = const {}; // object path → signed URL
  final Map<String, TextEditingController> _notes = {};
  final Map<String, ComplaintStatus> _statusDraft = {};
  final Set<String> _busy = {};

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _notes.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _note(String id, [String? initial]) =>
      _notes.putIfAbsent(id, () => TextEditingController(text: initial));

  Future<void> _load() async {
    final client = _client;
    if (client == null) return setState(() => _gate = _Gate.noBackend);
    final uid = client.auth.currentUser?.id;
    if (uid == null) return setState(() => _gate = _Gate.signedOut);
    setState(() => _gate = _Gate.loading);
    try {
      final me = await client
          .from('users')
          .select('role')
          .eq('user_id', uid)
          .maybeSingle();
      if (me?['role'] != 'admin') {
        if (mounted) setState(() => _gate = _Gate.denied);
        return;
      }
      final results = await Future.wait<List<Map<String, dynamic>>>([
        client
            .from('worker_applications')
            .select(
              '*, worker_application_services(service_name, is_sub_service), '
              'worker_application_areas(area_name), '
              'worker_application_schedules(day_name, start_time, end_time), '
              'worker_application_prices(service_name, price_from, price_to), '
              'worker_application_portfolios(asset_path, sort_order)',
            )
            .inFilter('status', ['submitted', 'pending'])
            .order('created_at'),
        client
            .from('complaints')
            .select(
              '*, bookings(booking_code, category, problem, address, status, '
              'estimated_price_min, estimated_price_max, final_price)',
            )
            .inFilter('status', ['open', 'in_review', 'in_mediation'])
            .order('created_at'),
      ]);
      final apps = results[0], complaints = results[1];
      final urls = {
        ...await _sign(client, 'worker-verification', [
          for (final a in apps) ...[
            a['ktp_asset_path'],
            a['selfie_asset_path'],
            for (final p in a['worker_application_portfolios'] as List? ?? [])
              p['asset_path'],
          ],
        ]),
        ...await _sign(client, 'complaint-evidence', [
          for (final c in complaints)
            ...(c['evidence_image_urls'] as List? ?? []),
        ]),
      };
      if (!mounted) return;
      setState(() {
        _applications = apps;
        _complaints = complaints;
        _urls = urls;
        _statusDraft.clear();
        _gate = _Gate.ready;
      });
    } catch (_) {
      if (mounted) setState(() => _gate = _Gate.error);
    }
  }

  /// Bucket privat → buat signed URL 1 jam. Path demo ('local/...') dilewati.
  Future<Map<String, String>> _sign(
    SupabaseClient client,
    String bucket,
    List<dynamic> paths,
  ) async {
    final valid = paths
        .whereType<String>()
        .where((p) => p.isNotEmpty && !p.startsWith('local/'))
        .toSet()
        .toList();
    if (valid.isEmpty) return {};
    final signed = await client.storage
        .from(bucket)
        .createSignedUrls(valid, 3600);
    return {for (final s in signed) s.path: s.signedUrl};
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: pj(fontWeight: FontWeight.w700)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
      ),
    );
  }

  Future<void> _run(String id, Future<void> Function() op, String ok) async {
    setState(() => _busy.add(id));
    try {
      await op();
      _toast(ok);
      _notes.remove(id)?.dispose();
      await _load();
    } on PostgrestException catch (e) {
      _toast('Gagal: ${e.message}');
    } catch (_) {
      _toast('Gagal menyimpan. Cek koneksi lalu coba lagi.');
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  Future<void> _review(Map<String, dynamic> app, bool approve) async {
    final id = app['id'] as String;
    final note = _note(id).text.trim();
    if (!approve) {
      if (note.isEmpty) {
        _toast(
          'Tulis alasan penolakan supaya pendaftar tahu yang harus diperbaiki.',
        );
        return;
      }
      final sure = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tolak pendaftaran?'),
          content: Text(
            '${app['full_name']} akan menerima status Ditolak dengan catatan:\n\n"$note"',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Tolak'),
            ),
          ],
        ),
      );
      if (sure != true) return;
    }
    await _run(
      id,
      () => _client!.rpc(
        'admin_review_application',
        params: {
          'p_application_id': id,
          'p_approve': approve,
          'p_note': note.isEmpty ? null : note,
        },
      ),
      approve
          ? 'Mitra disetujui dan sudah tampil di aplikasi.'
          : 'Pendaftaran ditolak.',
    );
  }

  Future<void> _saveComplaint(Map<String, dynamic> c) async {
    final id = c['id'] as String;
    final status =
        _statusDraft[id] ?? ComplaintStatusX.fromValue(c['status'] as String);
    final note = _note(id, c['resolution_note'] as String?).text.trim();
    final closing =
        status == ComplaintStatus.resolved ||
        status == ComplaintStatus.rejected;
    if (closing && note.isEmpty) {
      _toast('Isi catatan penyelesaian sebelum menutup komplain.');
      return;
    }
    await _run(
      id,
      () => _client!
          .from('complaints')
          .update({
            'status': status.value,
            'resolution_note': note.isEmpty ? null : note,
            'resolved_at': closing
                ? DateTime.now().toUtc().toIso8601String()
                : null,
          })
          .eq('id', id),
      closing ? 'Komplain ditutup.' : 'Status komplain diperbarui.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final navBottom = MediaQuery.of(context).padding.bottom + 120;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: navBottom),
        children: [
          const ScreenHeader(title: 'Admin', subtitle: 'Operator Beresin'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: switch (_gate) {
              _Gate.loading => const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              _Gate.noBackend => const _Notice(
                icon: Icons.cloud_off_rounded,
                title: 'Supabase belum dikonfigurasi',
                body:
                    'Jalankan app dengan --dart-define SUPABASE_URL dan SUPABASE_PUBLISHABLE_KEY.',
              ),
              _Gate.signedOut => const _Notice(
                icon: Icons.login_rounded,
                title: 'Masuk dulu',
                body: 'Panel admin hanya untuk akun operator yang sudah login.',
              ),
              _Gate.denied => const _Notice(
                icon: Icons.lock_outline_rounded,
                title: 'Akses ditolak',
                body:
                    'Akun ini bukan admin. Minta operator mengubah role akunmu menjadi admin.',
              ),
              _Gate.error => _Notice(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuat data',
                body: 'Cek koneksi internet lalu coba lagi.',
                action: BrButton(
                  label: 'Coba Lagi',
                  full: true,
                  onPressed: _load,
                ),
              ),
              _Gate.ready => _buildReady(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReady() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                value: '${_applications.length}',
                label: 'Pendaftaran',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                value: '${_complaints.length}',
                label: 'Komplain aktif',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            BrChip(
              label: 'Pendaftaran (${_applications.length})',
              active: _tab == 0,
              onTap: () => setState(() => _tab = 0),
            ),
            BrChip(
              label: 'Komplain (${_complaints.length})',
              active: _tab == 1,
              onTap: () => setState(() => _tab = 1),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_tab == 0)
          if (_applications.isEmpty)
            const _Notice(
              icon: Icons.task_alt_rounded,
              title: 'Tidak ada pendaftaran menunggu',
              body: 'Pendaftaran mitra baru akan muncul di sini.',
            )
          else
            for (final a in _applications) _applicationCard(a)
        else if (_complaints.isEmpty)
          const _Notice(
            icon: Icons.task_alt_rounded,
            title: 'Tidak ada komplain aktif',
            body: 'Komplain customer yang perlu dimediasi akan muncul di sini.',
          )
        else
          for (final c in _complaints) _complaintCard(c),
      ],
    );
  }

  Widget _applicationCard(Map<String, dynamic> a) {
    final id = a['id'] as String;
    final busy = _busy.contains(id);
    List<dynamic> rel(String key) => a[key] as List? ?? const [];
    final services = [
      for (final s in rel('worker_application_services')) s['service_name'],
    ];
    final areas = [
      for (final s in rel('worker_application_areas')) s['area_name'],
    ];
    final days = [
      for (final s in rel('worker_application_schedules')) s['day_name'],
    ];
    final schedule = rel('worker_application_schedules').firstOrNull;
    final prices = [
      for (final p in rel('worker_application_prices'))
        '${p['service_name']}: ${rupiah(p['price_from'] as num? ?? 0)}'
            '${p['price_to'] == null ? '+' : '-${rupiah(p['price_to'] as num)}'}',
    ];
    final portfolios = [
      for (final p in rel('worker_application_portfolios'))
        p['asset_path'] as String,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: BrCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(name: a['full_name'] as String? ?? '?', size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['full_name'] as String? ?? '-',
                        style: pj(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        [a['business_name'], a['whatsapp']]
                            .whereType<String>()
                            .where((s) => s.isNotEmpty)
                            .join(' · '),
                        style: pj(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const BrTag(label: 'Menunggu', color: 'accent'),
              ],
            ),
            const SizedBox(height: 12),
            _Info('Domisili', a['domicile'] as String?),
            _Info('Layanan', services.join(', ')),
            _Info('Area', areas.join(', ')),
            _Info(
              'Jadwal',
              days.isEmpty
                  ? null
                  : '${days.join(', ')} · ${schedule?['start_time']}-${schedule?['end_time']}',
            ),
            _Info('Harga', prices.join('\n')),
            _Info('Bio', a['bio'] as String?),
            const SizedBox(height: 8),
            Text(
              'Dokumen',
              style: pj(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Thumb(label: 'KTP', url: _urls[a['ktp_asset_path']]),
                _Thumb(label: 'Selfie', url: _urls[a['selfie_asset_path']]),
                for (var i = 0; i < portfolios.length; i++)
                  _Thumb(
                    label: 'Portofolio ${i + 1}',
                    url: _urls[portfolios[i]],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note(id),
              enabled: !busy,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Catatan untuk pendaftar',
                helperText: 'Wajib diisi kalau ditolak.',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BrButton(
                    label: 'Tolak',
                    full: true,
                    variant: BrButtonVariant.secondary,
                    onPressed: busy ? null : () => _review(a, false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BrButton(
                    label: busy ? 'Menyimpan...' : 'Setujui',
                    full: true,
                    onPressed: busy ? null : () => _review(a, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _complaintCard(Map<String, dynamic> c) {
    final id = c['id'] as String;
    final busy = _busy.contains(id);
    final booking = c['bookings'] as Map<String, dynamic>? ?? const {};
    final current = ComplaintStatusX.fromValue(c['status'] as String);
    final selected = _statusDraft[id] ?? current;
    final evidence = [
      for (final p in c['evidence_image_urls'] as List? ?? []) '$p',
    ];
    final estimate =
        '${rupiah(booking['estimated_price_min'] as num? ?? 0)}-${rupiah(booking['estimated_price_max'] as num? ?? 0)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: BrCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ComplaintTypeX.fromValue(c['type'] as String).label,
                    style: pj(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                BrTag(label: current.label, color: 'accent'),
              ],
            ),
            const SizedBox(height: 10),
            _Info('Booking', booking['booking_code'] as String?),
            _Info(
              'Masalah',
              '${booking['category'] ?? ''} · ${booking['problem'] ?? ''}',
            ),
            _Info('Alamat', booking['address'] as String?),
            _Info(
              'Harga',
              booking['final_price'] == null
                  ? 'Estimasi $estimate'
                  : 'Estimasi $estimate · Final ${rupiah(booking['final_price'] as num)}',
            ),
            _Info('Keterangan', c['description'] as String?),
            if (evidence.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < evidence.length; i++)
                    _Thumb(label: 'Bukti ${i + 1}', url: _urls[evidence[i]]),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Ubah status',
              style: pj(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in ComplaintStatus.values)
                  BrChip(
                    label: s.label,
                    active: s == selected,
                    onTap: busy
                        ? null
                        : () => setState(() => _statusDraft[id] = s),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note(id, c['resolution_note'] as String?),
              enabled: !busy,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Catatan penyelesaian',
                helperText: 'Wajib saat status Selesai atau Ditolak.',
              ),
            ),
            const SizedBox(height: 12),
            BrButton(
              label: busy ? 'Menyimpan...' : 'Simpan',
              full: true,
              onPressed: busy ? null : () => _saveComplaint(c),
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String? value;

  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(label, style: pj(fontSize: 12, color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              v,
              style: pj(fontSize: 12.5, color: AppColors.ink, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail dokumen; ketuk untuk lihat besar.
class _Thumb extends StatelessWidget {
  final String label;
  final String? url;

  const _Thumb({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? Center(
              child: Text(
                '$label\n(tidak ada)',
                textAlign: TextAlign.center,
                style: pj(fontSize: 10, color: AppColors.muted),
              ),
            )
          : Image.network(
              url!,
              fit: BoxFit.cover,
              semanticLabel: label,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                color: AppColors.muted,
              ),
            ),
    );
    return Semantics(
      button: url != null,
      label: 'Lihat $label',
      child: GestureDetector(
        onTap: url == null
            ? null
            : () => showDialog<void>(
                context: context,
                builder: (ctx) => Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InteractiveViewer(
                        child: Image.network(url!, semanticLabel: label),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                ),
              ),
        child: Column(
          children: [
            box,
            const SizedBox(height: 4),
            Text(label, style: pj(fontSize: 10.5, color: AppColors.ink2)),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  const _Notice({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: pj(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: pj(fontSize: 12.5, color: AppColors.muted, height: 1.45),
          ),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;

  const _MetricCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Text(
            value,
            style: pj(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: pj(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}
