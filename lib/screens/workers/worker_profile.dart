import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import '../../models.dart';
import '../../widgets.dart';
import '../../widgets/whatsapp_lead_sheet.dart';

class WorkerProfileScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;
  const WorkerProfileScreen({super.key, required this.go, required this.state});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _reviewsLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadReviews());
  }

  Future<void> _loadReviews() async {
    try {
      final rows = await Supabase.instance.client
          .from('reviews')
          .select('user_name, rating, text, created_at')
          .eq('worker_id', widget.state.workerId)
          .order('created_at', ascending: false)
          .limit(5);
      if (!mounted) return;
      setState(() {
        _reviews = List<Map<String, dynamic>>.from(rows);
        _reviewsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _reviewsLoading = false);
    }
  }

  String _reviewDateLabel(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} bulan lalu';
    return '${(diff.inDays / 365).floor()} tahun lalu';
  }

  @override
  Widget build(BuildContext context) {
    final w = kWorkers.firstWhere(
      (x) => x.id == widget.state.workerId,
      orElse: () => kWorkers[0],
    );
    final verifications = [
      [
        Icons.shield_outlined,
        'Identitas terverifikasi',
        'KTP & nomor HP dicek',
      ],
      [Icons.phone, 'Nomor aktif', 'Diverifikasi tim Beresin'],
      [
        Icons.payments_outlined,
        'Harga transparan',
        'Mengikuti standar Beresin',
      ],
      [
        Icons.location_on_outlined,
        'Direkomendasikan warga',
        '${w.reviews}× ulasan dari pelanggan',
      ],
    ];

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E8E6C), Color(0xFF0A6E54)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 70),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PressScale(
                    onTap: () => widget.go(widget.state.workerFromRoute),
                    scaleTo: 0.88,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 20,
                      ),
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
                      Icons.bookmark_border,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BrCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: AppColors.line2,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.ink.withValues(
                                        alpha: .08,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                      spreadRadius: -8,
                                    ),
                                  ],
                                ),
                                child: Avatar(name: w.name, size: 64),
                              ),
                              const SizedBox(width: 14),
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.ink,
                                              letterSpacing: -.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified,
                                          size: 15,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      w.service,
                                      style: pj(
                                        color: AppColors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 13,
                                          color: AppColors.accent,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${w.rating} ',
                                          style: pj(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        Text(
                                          '(${w.reviews})',
                                          style: pj(
                                            fontSize: 12,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '•',
                                          style: pj(color: AppColors.line),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${w.jobsDone} pekerjaan',
                                          style: pj(
                                            fontSize: 12,
                                            color: AppColors.ink2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.line,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                _StatTile(
                                  icon: Icons.location_on_outlined,
                                  value: '${w.distance} km',
                                  label: 'Jarak',
                                ),
                                _Divider(),
                                _StatTile(
                                  icon: Icons.access_time,
                                  value: w.eta,
                                  label: 'ETA',
                                ),
                                _Divider(),
                                _StatTile(
                                  icon: Icons.payments_outlined,
                                  value: rupiah(w.priceMin),
                                  label: 'Mulai',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            w.bio,
                            style: pj(
                              fontSize: 12.5,
                              color: AppColors.ink2,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionTitle('Verifikasi & Kepercayaan'),
                    BrCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: List.generate(verifications.length, (i) {
                          final v = verifications[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: i < verifications.length - 1
                                    ? const BorderSide(color: AppColors.line2)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    v[0] as IconData,
                                    size: 16,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v[1] as String,
                                        style: pj(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      Text(
                                        v[2] as String,
                                        style: pj(
                                          fontSize: 11,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    const SectionTitle(
                      'Layanan & Harga',
                      rightText: 'Lengkap di chat',
                    ),
                    BrCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: List.generate(w.services.length, (i) {
                          final s = w.services[i];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: i < w.services.length - 1
                                    ? const BorderSide(color: AppColors.line2)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Row(
                              children: [
                                ServiceIcon(kind: w.serviceKind, size: 36),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: pj(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      Text(
                                        'Termasuk garansi 7 hari',
                                        style: pj(
                                          fontSize: 11,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: s.max != null
                                      ? [
                                          Text(
                                            rupiah(s.min),
                                            style: pj(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                          Text(
                                            '– ${rupiah(s.max!)}',
                                            style: pj(
                                              fontSize: 11,
                                              color: AppColors.muted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ]
                                      : [
                                          Text(
                                            'Mulai',
                                            style: pj(
                                              fontSize: 11,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                          Text(
                                            rupiah(s.min),
                                            style: pj(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                        ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    SectionTitle(
                      'Ulasan Terbaru',
                      rightText: 'Lihat ${w.reviews}',
                    ),
                    if (_reviewsLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Belum ada ulasan.',
                          style: pj(fontSize: 12.5, color: AppColors.muted),
                        ),
                      )
                    else
                      ..._reviews.map(
                      (r) {
                        final name = r['user_name'] as String? ?? 'Pelanggan';
                        final text = r['text'] as String? ?? '';
                        final rating = r['rating'] as int? ?? 0;
                        final dateLabel = _reviewDateLabel(
                          r['created_at'] as String? ?? '',
                        );
                        return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BrCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Avatar(name: name, size: 28),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: pj(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                          Text(
                                            dateLabel,
                                            style: pj(
                                              fontSize: 10.5,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (n) => Icon(
                                        Icons.star_rounded,
                                        size: 12,
                                        color: n < rating
                                            ? AppColors.accent
                                            : AppColors.line,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                text,
                                style: pj(
                                  fontSize: 12.5,
                                  color: AppColors.ink2,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      },
                    ),
                    const SizedBox(height: 170),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              16,
              14,
              16,
              14 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrButton(
                  label: 'Booking via Beresin',
                  size: BrButtonSize.lg,
                  variant: BrButtonVariant.primary,
                  full: true,
                  icon: const Icon(
                    Icons.event_available,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => widget.go('booking', {'workerId': w.id, 'from': 'worker'}),
                ),
                const SizedBox(height: 8),
                BrButton(
                  label: 'Tanya via WhatsApp',
                  size: BrButtonSize.md,
                  variant: BrButtonVariant.secondary,
                  full: true,
                  icon: const Icon(
                    Icons.chat_outlined,
                    size: 16,
                    color: AppColors.ink2,
                  ),
                  onPressed: () => showWhatsappLeadSheet(
                    context: context,
                    worker: w,
                    state: widget.state,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Booking lewat Beresin membantu menyimpan riwayat, estimasi harga, dan perlindungan komplain.',
                  textAlign: TextAlign.center,
                  style: pj(
                    fontSize: 10.5,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        color: Colors.white,
        child: Column(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(height: 3),
            Text(
              value,
              style: pj(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            Text(label, style: pj(fontSize: 10.5, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: AppColors.line);
}
