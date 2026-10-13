import 'package:flutter/material.dart';

import '../../models.dart';
import '../../repositories/app_repository.dart';
import '../../theme.dart';
import '../../widgets.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;

  const BookingConfirmationScreen({
    super.key,
    required this.go,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final worker = kWorkers.firstWhere(
      (item) => item.id == state.workerId,
      orElse: () => kWorkers.first,
    );
    final category = diagnosisByLabel(state.cat);
    final booking = appRepository.bookingById(state.activeBookingId);
    final bottom = MediaQuery.of(context).padding.bottom + 120;
    return FloatingBackScaffold(
      onBack: () => go('booking', {'workerId': worker.id}),
      child: ListView(
        padding: EdgeInsets.only(bottom: bottom),
        children: [
          ScreenHeader(
            title: 'Booking Terkirim',
            subtitle: 'Menunggu konfirmasi',
            onBack: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrCard(
                  padding: const EdgeInsets.all(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E8E6C), Color(0xFF0A6E54)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.transparent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xFFFFD89B),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${worker.name} akan menerima ringkasan masalah dan jadwal yang kamu pilih.',
                        style: pj(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Riwayat booking, estimasi harga, dan review akan tersimpan di Beresin.',
                        style: pj(
                          color: Colors.white.withValues(alpha: .74),
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionTitle('Status booking'),
                BrCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: const [
                      _TimelineStep(
                        title: 'Booking dikirim',
                        active: true,
                        done: true,
                      ),
                      _TimelineStep(title: 'Menunggu konfirmasi tukang'),
                      _TimelineStep(title: 'Tukang menuju lokasi'),
                      _TimelineStep(title: 'Pekerjaan selesai'),
                      _TimelineStep(title: 'Beri rating', isLast: true),
                    ],
                  ),
                ),
                const SectionTitle('Detail booking'),
                BrCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _DetailRow(label: 'Worker', value: worker.name),
                      _DetailRow(label: 'Service', value: worker.service),
                      _DetailRow(
                        label: 'Problem',
                        value: booking?.problem ?? state.selectedProblem,
                      ),
                      _DetailRow(
                        label: 'Estimasi harga',
                        value: booking == null
                            ? '${rupiah(category.priceMin)}-${rupiah(category.priceMax)}'
                            : '${rupiah(booking.estimatedPriceMin)}-${rupiah(booking.estimatedPriceMax)}',
                      ),
                      _DetailRow(
                        label: 'Payment',
                        value:
                            booking?.paymentMethod ?? 'Bayar setelah selesai',
                      ),
                      _DetailRow(
                        label: 'Schedule',
                        value: booking?.schedule ?? 'Hari ini',
                      ),
                      _DetailRow(
                        label: 'Address',
                        value: booking?.address ?? 'Tebet, Jakarta Selatan',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                BrButton(
                  label: 'Lihat Status Booking',
                  full: true,
                  size: BrButtonSize.lg,
                  iconRight: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => go('bookingStatus', {'workerId': worker.id}),
                ),
                const SizedBox(height: 10),
                BrButton(
                  label: 'Chat dengan ${worker.name}',
                  full: true,
                  variant: BrButtonVariant.secondary,
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.ink2,
                    size: 16,
                  ),
                  onPressed: () => go('chat', {'workerId': worker.id}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final bool active;
  final bool done;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    this.active = false,
    this.done = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: done || active ? AppColors.primary : AppColors.line,
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 13)
                    : null,
              ),
              if (!isLast)
                Container(width: 2, height: 24, color: AppColors.line2),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: pj(
                fontSize: 13,
                fontWeight: active || done ? FontWeight.w800 : FontWeight.w600,
                color: active || done ? AppColors.ink : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
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
          SizedBox(
            width: 104,
            child: Text(label, style: pj(fontSize: 12, color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
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
  }
}
