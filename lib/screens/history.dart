import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../models.dart';
import '../repositories/app_repository.dart';
import '../widgets.dart';

class HistoryScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  const HistoryScreen({super.key, required this.go});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _past = [];
  bool _loadingPast = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPast());
  }

  Future<void> _loadPast() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) {
        setState(() => _loadingPast = false);
        return;
      }
      final rows = await client
          .from('bookings')
          .select(
            'id, category, problem, worker_id, final_price, estimated_price_min, status, created_at, reviews(rating)',
          )
          .eq('customer_id', uid)
          .inFilter('status', ['completed', 'reviewed', 'cancelled'])
          .order('created_at', ascending: false)
          .limit(20);
      if (!mounted) return;
      setState(() {
        _past = List<Map<String, dynamic>>.from(rows);
        _loadingPast = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingPast = false);
    }
  }

  String _workerName(String workerId) {
    try {
      return kWorkers.firstWhere((w) => w.id == workerId).name;
    } catch (_) {
      return 'Tukang';
    }
  }

  String _dateLabel(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final navBottom = MediaQuery.of(context).padding.bottom + 120;
    final activeBookings = appRepository.bookings().where((booking) {
      return !{
        BookingStatus.completed,
        BookingStatus.reviewed,
        BookingStatus.cancelled,
      }.contains(booking.status);
    }).toList();
    final activeBooking = activeBookings.isEmpty ? null : activeBookings.first;
    final activeWorker = activeBooking == null
        ? kWorkers.first
        : kWorkers.firstWhere(
            (worker) => worker.id == activeBooking.workerId,
            orElse: () => kWorkers.first,
          );
    return ListView(
      padding: EdgeInsets.only(bottom: navBottom),
      children: [
        const ScreenHeader(title: 'Riwayat', subtitle: 'Layanan kamu'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Permintaan Aktif', rightText: 'Detail'),
              BrCard(
                padding: EdgeInsets.zero,
                border: Border.all(color: AppColors.accent, width: 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.accent, AppColors.accentDark],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (activeBooking?.status.label ??
                                    'MENUNGGU RESPON TEKNISI')
                                .toUpperCase(),
                            style: pj(
                              color: Colors.white,
                              fontSize: 11,
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
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: const MockACPhoto(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${activeBooking?.problem ?? 'AC bocor'} — ${activeWorker.name}',
                                      style: pj(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    Text(
                                      activeBooking == null
                                          ? 'Dikirim 2 menit lalu · Estimasi ${rupiah(75000)}–${rupiah(150000)}'
                                          : 'Dikirim baru saja · Estimasi ${rupiah(activeBooking.estimatedPriceMin)}–${rupiah(activeBooking.estimatedPriceMax)}',
                                      style: pj(
                                        fontSize: 11.5,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children:
                                [
                                  'Terkirim',
                                  'Dibaca',
                                  'Dikonfirmasi',
                                  'Selesai',
                                ].asMap().entries.map((e) {
                                  final i = e.key;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: i < 3 ? 4 : 0,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: i <= 1
                                                  ? AppColors.accent
                                                  : AppColors.line,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            e.value,
                                            style: pj(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: i <= 1
                                                  ? AppColors.ink
                                                  : AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: BrButton(
                                  label: 'Lihat Tukang',
                                  size: BrButtonSize.sm,
                                  variant: BrButtonVariant.secondary,
                                  full: true,
                                  onPressed: () => widget.go(
                                    activeBooking == null
                                        ? 'worker'
                                        : 'bookingStatus',
                                    {
                                      'workerId': activeWorker.id,
                                      'from': 'history',
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BrButton(
                                  label: 'Buka Chat',
                                  size: BrButtonSize.sm,
                                  variant: BrButtonVariant.whatsapp,
                                  full: true,
                                  icon: const Icon(
                                    Icons.chat,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SectionTitle('Layanan Lalu', rightText: 'Semua'),
              if (_loadingPast)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_past.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Belum ada riwayat layanan.',
                      style: pj(fontSize: 13, color: AppColors.muted),
                    ),
                  ),
                )
              else
                BrCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: List.generate(_past.length, (i) {
                      final row = _past[i];
                      final category =
                          (row['category'] as String?)?.trim() ?? '';
                      final problem =
                          (row['problem'] as String?)?.trim() ?? '';
                      final serviceLabel =
                          problem.isNotEmpty ? problem : category;
                      final workerName = _workerName(
                        row['worker_id'] as String? ?? '',
                      );
                      final date = _dateLabel(
                        row['created_at'] as String? ?? '',
                      );
                      final price =
                          (row['final_price'] as int?) ??
                          (row['estimated_price_min'] as int? ?? 0);
                      final status = row['status'] as String? ?? '';
                      final reviewed = status == 'reviewed';
                      final reviewList =
                          row['reviews'] as List<dynamic>? ?? [];
                      final rating = reviewList.isNotEmpty
                          ? (reviewList.first
                                  as Map<String, dynamic>)['rating']
                              as int? ??
                              0
                          : 0;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: i < _past.length - 1
                                ? const BorderSide(color: AppColors.line2)
                                : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          children: [
                            ServiceIcon(kind: category, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceLabel,
                                    style: pj(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    '$workerName · $date',
                                    style: pj(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  if (!reviewed)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: GestureDetector(
                                        onTap: () => widget.go('review', {
                                          'requestId':
                                              row['id'] as String? ?? 'demo',
                                        }),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent50,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                size: 11,
                                                color: AppColors.accentDark,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Beri rating?',
                                                style: pj(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.accentDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (reviewed)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: List.generate(
                                          5,
                                          (n) => Icon(
                                            Icons.star_rounded,
                                            size: 10,
                                            color: n < rating
                                                ? AppColors.accent
                                                : AppColors.line,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              rupiah(price),
                              style: pj(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              const SectionTitle('Tukang Tersimpan', rightText: 'Lihat semua'),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kWorkers.length.clamp(0, 3),
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final w = kWorkers[i];
                    return _EntranceItem(
                      delay: Duration(milliseconds: i * 70),
                      child: PressScale(
                        onTap: () => widget.go(
                          'worker',
                          {'workerId': w.id, 'from': 'history'},
                        ),
                        scaleTo: 0.95,
                        child: Container(
                          width: 130,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Avatar(name: w.name, size: 48),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      w.name.split(' ').take(2).join(' '),
                                      overflow: TextOverflow.ellipsis,
                                      style: pj(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.verified,
                                    size: 11,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                              Text(
                                w.service,
                                style: pj(
                                  fontSize: 10.5,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 11,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${w.rating}',
                                    style: pj(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _EntranceItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _EntranceItem({required this.child, required this.delay});

  @override
  State<_EntranceItem> createState() => _EntranceItemState();
}

class _EntranceItemState extends State<_EntranceItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final show = reduce || _visible;
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: show ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
