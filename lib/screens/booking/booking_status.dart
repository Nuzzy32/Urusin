import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models.dart';
import '../../repositories/app_repository.dart';
import '../../theme.dart';
import '../../widgets.dart';

class BookingStatusScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;

  const BookingStatusScreen({super.key, required this.go, required this.state});

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_pollBooking());
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _pollBooking());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _pollBooking() async {
    final bookingId = widget.state.activeBookingId;
    if (bookingId.isEmpty || bookingId.startsWith('booking-')) return;
    try {
      final row = await Supabase.instance.client
          .from('bookings')
          .select('id, status, final_price, final_price_note')
          .eq('id', bookingId)
          .single();
      final status = BookingStatusX.fromValue(row['status'] as String? ?? 'created');
      final existing = appRepository.bookingById(bookingId);
      if (existing != null && existing.status != status) {
        await appRepository.updateBookingStatus(bookingId, status);
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final worker = kWorkers.firstWhere(
      (item) => item.id == widget.state.workerId,
      orElse: () => kWorkers.first,
    );
    final category = diagnosisByLabel(widget.state.cat);
    final booking = appRepository.bookingById(widget.state.activeBookingId);
    final bookingStatus = booking?.status ?? BookingStatus.created;
    final complaints = booking == null
        ? const <ComplaintTicket>[]
        : appRepository.complaintsForBooking(booking.id);
    final bottom = MediaQuery.of(context).padding.bottom + 120;
    return FloatingBackScaffold(
      onBack: () => widget.go('history'),
      child: ListView(
        padding: EdgeInsets.only(bottom: bottom),
        children: [
          ScreenHeader(
            title: 'Status Booking',
            subtitle: bookingStatus.label,
            onBack: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrCard(
                  padding: const EdgeInsets.all(14),
                  border: Border.all(color: AppColors.accent, width: 1.5),
                  child: Row(
                    children: [
                      Avatar(name: worker.name, size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker.name,
                              style: pj(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              '${worker.service} · ${worker.distance} km · ${worker.eta}',
                              style: pj(fontSize: 11.5, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      BrTag(
                        label: bookingStatus == BookingStatus.disputed
                            ? 'Dispute'
                            : bookingStatus.label,
                        color: bookingStatus == BookingStatus.disputed
                            ? 'danger'
                            : 'accent',
                      ),
                    ],
                  ),
                ),
                const SectionTitle('Ringkasan'),
                BrCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoLine(
                        icon: Icons.home_repair_service_outlined,
                        title: booking?.problem ?? widget.state.selectedProblem,
                        subtitle: category.resultProblem,
                      ),
                      _InfoLine(
                        icon: Icons.event_outlined,
                        title: booking?.schedule ?? 'Hari ini',
                        subtitle: 'Tukang akan konfirmasi sebelum berangkat',
                      ),
                      _InfoLine(
                        icon: Icons.location_on_outlined,
                        title:
                            booking?.address ??
                            'Jl. Tebet Barat Dalam IV No. 12',
                        subtitle:
                            booking?.accessNote ??
                            'Rumah pagar hitam, tekan bel kanan',
                      ),
                      _InfoLine(
                        icon: Icons.payments_outlined,
                        title: booking?.finalPrice == null
                            ? '${rupiah(category.priceMin)}-${rupiah(category.priceMax)}'
                            : rupiah(booking!.finalPrice!),
                        subtitle: 'Bayar setelah selesai',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SectionTitle('Timeline'),
                BrCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _StatusStep(
                        title: 'Booking dikirim',
                        done: true,
                        active: bookingStatus == BookingStatus.created,
                      ),
                      _StatusStep(
                        title: 'Dikonfirmasi tukang',
                        done: _statusIndex(bookingStatus) > 1,
                        active: bookingStatus == BookingStatus.accepted,
                      ),
                      _StatusStep(
                        title: 'Dalam perjalanan',
                        done: _statusIndex(bookingStatus) > 2,
                        active: bookingStatus == BookingStatus.onTheWay,
                      ),
                      _StatusStep(
                        title: 'Pekerjaan dimulai',
                        done: _statusIndex(bookingStatus) > 3,
                        active: bookingStatus == BookingStatus.inProgress,
                      ),
                      _StatusStep(
                        title: 'Selesai',
                        done: _statusIndex(bookingStatus) > 4,
                        active: bookingStatus == BookingStatus.completed,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                if (complaints.isNotEmpty) ...[
                  const SectionTitle('Komplain Aktif'),
                  BrCard(
                    padding: const EdgeInsets.all(14),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: .28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: complaints.map((ticket) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.report_outlined,
                                size: 18,
                                color: AppColors.danger,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${ticket.type.label} · ${ticket.status.label}',
                                  style: pj(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                BrCard(
                  padding: const EdgeInsets.all(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8EE), Color(0xFFFFFCF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Color(0xFFFFE9C2)),
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
                          'Konfirmasi harga sebelum pekerjaan dimulai. Gunakan riwayat booking ini jika perlu komplain atau memberi rating.',
                          style: pj(
                            fontSize: 11.5,
                            color: Color(0xFF8A5A14),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BrButton(
                  label: 'Konfirmasi Harga Final',
                  full: true,
                  size: BrButtonSize.lg,
                  icon: const Icon(
                    Icons.price_check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () =>
                      widget.go('customerFinalPrice', {'workerId': worker.id}),
                ),
                const SizedBox(height: 10),
                BrButton(
                  label: 'Chat dengan ${worker.name}',
                  full: true,
                  variant: BrButtonVariant.secondary,
                  icon: const Icon(Icons.chat_bubble_outline, color: AppColors.ink2, size: 17),
                  onPressed: () => widget.go('chat', {'workerId': worker.id}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: BrButton(
                        label: 'Batalkan Booking',
                        full: true,
                        variant: BrButtonVariant.secondary,
                        onPressed: booking == null
                            ? null
                            : () async {
                                await appRepository.updateBookingStatus(
                                  booking.id,
                                  BookingStatus.cancelled,
                                );
                                if (!context.mounted) return;
                                _toast(context, 'Booking dibatalkan.');
                                widget.go('history');
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BrButton(
                        label: 'Hubungi Support',
                        full: true,
                        variant: BrButtonVariant.secondary,
                        onPressed: booking == null
                            ? null
                            : () => _showComplaintSheet(context, booking.id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                BrButton(
                  label: booking?.finalPrice == null
                      ? 'Konfirmasi harga final dulu'
                      : 'Tandai Layanan Selesai',
                  full: true,
                  variant: BrButtonVariant.accent,
                  onPressed: (booking == null || booking.finalPrice == null)
                      ? null
                      : () async {
                          try {
                            await appRepository.updateBookingStatus(
                              booking.id,
                              BookingStatus.completed,
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            _toast(context, 'Gagal menyelesaikan: $e');
                            return;
                          }
                          if (!context.mounted) return;
                          widget.go('review', {'requestId': booking.id});
                        },
                ),
                if (booking?.finalPrice == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Status pekerjaan terkunci sampai harga final disepakati.',
                      style: pj(fontSize: 11.5, color: AppColors.muted),
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

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  const _InfoLine({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.line2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.primaryDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: pj(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: pj(fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

int _statusIndex(BookingStatus status) {
  return switch (status) {
    BookingStatus.created => 1,
    BookingStatus.accepted => 2,
    BookingStatus.onTheWay => 3,
    BookingStatus.inProgress => 4,
    BookingStatus.finalPricePending => 4,
    BookingStatus.completed => 5,
    BookingStatus.reviewed => 6,
    BookingStatus.cancelled => 0,
    BookingStatus.disputed => 0,
  };
}

Future<List<String>> _uploadComplaintEvidence(
  List<XFile> files,
  String bookingId,
) async {
  if (files.isEmpty) return const [];
  SupabaseClient client;
  try {
    client = Supabase.instance.client;
  } catch (_) {
    return const [];
  }
  final uploaded = <String>[];
  for (final f in files) {
    final ext = f.name.contains('.') ? f.name.split('.').last : 'jpg';
    final path =
        '$bookingId/${DateTime.now().millisecondsSinceEpoch}_${uploaded.length}.$ext';
    try {
      final bytes = await f.readAsBytes();
      await client.storage.from('complaint-evidence').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: false),
          );
      // Simpan object path; admin membuat signed URL saat butuh (bucket privat).
      uploaded.add(path);
    } catch (_) {
      // skip file yang gagal
    }
  }
  return uploaded;
}

Future<void> _showComplaintSheet(BuildContext context, String bookingId) {
  ComplaintType selected = ComplaintType.noShow;
  final detail = TextEditingController();
  final picker = ImagePicker();
  final List<XFile> evidence = [];
  bool submitting = false;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pusat Komplain',
                  style: pj(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Laporan tersimpan ke booking ini dan status akan masuk mediasi. Upload bukti foto bila ada.',
                  style: pj(
                    fontSize: 12.5,
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ComplaintType.values.map((type) {
                    return BrChip(
                      label: type.label,
                      active: selected == type,
                      variant: 'primary',
                      onTap: () => setSheetState(() => selected = type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: detail,
                  maxLines: 4,
                  style: pj(fontSize: 14, color: AppColors.ink),
                  decoration: const InputDecoration(
                    hintText: 'Ceritakan kronologi singkat...',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: BrButton(
                        label: evidence.isEmpty
                            ? 'Tambah Bukti Foto'
                            : 'Bukti (${evidence.length}) • tambah lagi',
                        variant: BrButtonVariant.secondary,
                        full: true,
                        icon: const Icon(
                          Icons.attach_file,
                          size: 16,
                          color: AppColors.ink2,
                        ),
                        onPressed: () async {
                          final picked = await picker.pickMultiImage(imageQuality: 80);
                          if (picked.isEmpty) return;
                          setSheetState(() => evidence.addAll(picked));
                        },
                      ),
                    ),
                    if (evidence.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      BrButton(
                        label: 'Hapus',
                        variant: BrButtonVariant.ghost,
                        size: BrButtonSize.sm,
                        onPressed: () => setSheetState(evidence.clear),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                BrButton(
                  label: submitting ? 'Mengirim…' : 'Kirim Komplain',
                  full: true,
                  size: BrButtonSize.lg,
                  icon: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.report_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                  onPressed: submitting
                      ? null
                      : () async {
                          setSheetState(() => submitting = true);
                          final urls =
                              await _uploadComplaintEvidence(evidence, bookingId);
                          await appRepository.createComplaint(
                            bookingId: bookingId,
                            type: selected,
                            description: detail.text.trim().isEmpty
                                ? selected.label
                                : detail.text.trim(),
                            evidenceImageUrls: urls,
                          );
                          if (!context.mounted) return;
                          Navigator.of(sheetContext).pop();
                          _toast(context, 'Komplain terkirim untuk ditinjau.');
                        },
                ),
              ],
            ),
          );
        },
      );
    },
  ).whenComplete(detail.dispose);
}

void _toast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
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

class _StatusStep extends StatelessWidget {
  final String title;
  final bool done;
  final bool active;
  final bool isLast;

  const _StatusStep({
    required this.title,
    this.done = false,
    this.active = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done || active ? AppColors.primary : AppColors.line,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: anim,
                  curve: Curves.easeOutBack,
                ),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: done
                  ? const Icon(
                      Icons.check,
                      key: ValueKey('done'),
                      color: Colors.white,
                      size: 13,
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: pj(
                fontSize: 13,
                fontWeight: done || active ? FontWeight.w800 : FontWeight.w600,
                color: done || active ? AppColors.ink : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
