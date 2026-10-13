import 'package:flutter/material.dart';

import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../../widgets/whatsapp_lead_sheet.dart';

class WorkersDirectoryScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const WorkersDirectoryScreen({super.key, required this.go});

  @override
  State<WorkersDirectoryScreen> createState() => _WorkersDirectoryScreenState();
}

class _WorkersDirectoryScreenState extends State<WorkersDirectoryScreen> {
  String category = '';
  String sort = '';

  static const categories = [
    'Semua',
    'AC',
    'Pipa',
    'Listrik',
    'Cleaning',
    'Kebun',
    'Cat',
    'Tukang',
  ];

  static const sorts = [
    'Terdekat',
    'Rating Tertinggi',
    'Harga Transparan',
    'Bisa Hari Ini',
    'Terverifikasi',
  ];

  List<Worker> get workers {
    var result = [...kWorkers];
    if (category.isNotEmpty && category != 'Semua') {
      result = result.where((worker) {
        return switch (category) {
          'Pipa' => worker.serviceKind == 'Plumbing',
          'Tukang' => worker.serviceKind == 'Lainnya',
          'Cat' => worker.service.toLowerCase().contains('cat'),
          'Kebun' => worker.serviceKind == 'Kebun',
          _ => worker.serviceKind == category,
        };
      }).toList();
    }

    switch (sort) {
      case 'Rating Tertinggi':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Harga Transparan':
        result.sort((a, b) {
          final aTransparent = a.badges.contains('Harga Transparan') ? 0 : 1;
          final bTransparent = b.badges.contains('Harga Transparan') ? 0 : 1;
          return aTransparent.compareTo(bTransparent);
        });
        break;
      case 'Bisa Hari Ini':
        result.sort((a, b) {
          final aToday =
              a.eta.toLowerCase().contains('hari ini') ||
              a.eta.toLowerCase().contains('menit');
          final bToday =
              b.eta.toLowerCase().contains('hari ini') ||
              b.eta.toLowerCase().contains('menit');
          return (aToday ? 0 : 1).compareTo(bToday ? 0 : 1);
        });
        break;
      case 'Terverifikasi':
        result.sort(
          (a, b) => (a.isIdentityVerified ? 0 : 1).compareTo(
            b.isIdentityVerified ? 0 : 1,
          ),
        );
        break;
      case 'Terdekat':
        result.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      // default: tidak di-sort sampai user memilih
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 120;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).viewPadding.top + 18,
        18,
        bottomPadding,
      ),
      children: [
        Row(
          children: [
            const BrLogo(size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tukang Terdekat',
                    style: pj(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tebet, Jakarta Selatan',
                        style: pj(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
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
        Text(
          'Cari dan hubungi pekerja lokal terpercaya di sekitar kamu.',
          style: pj(fontSize: 13.5, color: AppColors.muted, height: 1.45),
        ),
        const SizedBox(height: 16),
        BrCard(
          padding: const EdgeInsets.all(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF0E8E6C), Color(0xFF0A6E54)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.transparent),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFD89B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belum tahu butuh tukang apa?',
                      style: pj(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Upload foto masalah rumahmu, nanti AI bantu cari jenis tukang yang tepat.',
                      style: pj(
                        color: Colors.white.withValues(alpha: .78),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    BrButton(
                      label: 'Cek Masalah dengan AI',
                      size: BrButtonSize.sm,
                      variant: BrButtonVariant.accent,
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      onPressed: () => widget.go('upload'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 19, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cari teknisi AC, tukang ledeng, cleaning...',
                  style: pj(fontSize: 13, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ChipScroller(
          labels: categories,
          active: category,
          onSelected: (value) => setState(() => category = value),
        ),
        const SizedBox(height: 10),
        _ChipScroller(
          labels: sorts,
          active: sort,
          onSelected: (value) => setState(() => sort = value),
        ),
        const SizedBox(height: 14),
        if (workers.isEmpty)
          BrCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.search_off, size: 30, color: AppColors.muted),
                const SizedBox(height: 8),
                Text(
                  'Belum ada tukang untuk filter ini',
                  style: pj(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coba pilih kategori Semua atau cek masalah dengan AI.',
                  textAlign: TextAlign.center,
                  style: pj(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          )
        else
          ...workers.map(
            (worker) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DirectoryWorkerCard(worker: worker, go: widget.go),
            ),
          ),
      ],
    );
  }
}

class _ChipScroller extends StatelessWidget {
  final List<String> labels;
  final String active;
  final ValueChanged<String> onSelected;

  const _ChipScroller({
    required this.labels,
    required this.active,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final label = labels[index];
          return BrChip(
            label: label,
            active: active == label,
            variant: 'primary',
            onTap: () => onSelected(label),
          );
        },
      ),
    );
  }
}

class _DirectoryWorkerCard extends StatelessWidget {
  final Worker worker;
  final void Function(String, [Map<String, dynamic>?]) go;

  const _DirectoryWorkerCard({required this.worker, required this.go});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      onTap: () => go('worker', {'workerId': worker.id, 'from': 'workers'}),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(name: worker.name, size: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            worker.name,
                            overflow: TextOverflow.ellipsis,
                            style: pj(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (worker.isIdentityVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      worker.service,
                      style: pj(fontSize: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 7,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Stars(value: worker.rating, size: 12),
                        _MetaIconText(
                          icon: Icons.location_on_outlined,
                          text: '${worker.distance} km',
                        ),
                        _MetaIconText(
                          icon: Icons.access_time,
                          text: worker.eta,
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
            spacing: 6,
            runSpacing: 6,
            children: worker.badges.take(3).map((badge) {
              final lower = badge.toLowerCase();
              final color = lower.contains('transparan')
                  ? 'accent'
                  : lower.contains('terverifikasi')
                  ? 'success'
                  : 'neutral';
              return BrTag(label: badge, color: color);
            }).toList(),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '"${worker.review}"',
              style: pj(
                fontSize: 11.5,
                color: AppColors.ink2,
                height: 1.45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mulai ${rupiah(worker.priceMin)}',
                  style: pj(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              BrButton(
                label: 'Tanya',
                size: BrButtonSize.sm,
                variant: BrButtonVariant.ghost,
                onPressed: () =>
                    showWhatsappLeadSheet(context: context, worker: worker),
              ),
              const SizedBox(width: 8),
              BrButton(
                label: 'Booking',
                size: BrButtonSize.sm,
                icon: const Icon(
                  Icons.event_available,
                  size: 14,
                  color: Colors.white,
                ),
                onPressed: () => go('booking', {'workerId': worker.id, 'from': 'workers'}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaIconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaIconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.muted),
        const SizedBox(width: 3),
        Text(
          text,
          style: pj(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.ink2,
          ),
        ),
      ],
    );
  }
}
