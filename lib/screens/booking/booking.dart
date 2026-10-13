import 'package:flutter/material.dart';

import '../../models.dart';
import '../../repositories/app_repository.dart';
import '../../theme.dart';
import '../../widgets.dart';

class BookingScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;

  const BookingScreen({super.key, required this.go, required this.state});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String schedule = '';
  String payment = '';
  late final Worker worker = kWorkers.firstWhere(
    (x) => x.id == widget.state.workerId,
    orElse: () => kWorkers[0],
  );
  late final DiagnosisCategory category = diagnosisByLabel(widget.state.cat);
  late final TextEditingController aiSummary = TextEditingController(
    text: _defaultAiSummary(widget.state, category),
  );
  late final TextEditingController requestNote = TextEditingController(
    text:
        '${widget.state.selectedProblem} dari dalam sejak 2 hari lalu. Masih bisa dipakai, tapi perlu dicek langsung.',
  );
  late final TextEditingController address = TextEditingController(
    text: 'Jl. Tebet Barat Dalam IV No. 12, RT 03',
  );
  late final TextEditingController accessNote = TextEditingController(
    text: 'Rumah pagar hitam, tekan bel kanan.',
  );

  @override
  void dispose() {
    aiSummary.dispose();
    requestNote.dispose();
    address.dispose();
    accessNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 120;
    return FloatingBackScaffold(
      onBack: () =>
          widget.go(widget.state.bookingFromRoute, {'workerId': worker.id}),
      child: ListView(
        padding: EdgeInsets.only(bottom: bottom),
        children: [
          ScreenHeader(
            title: 'Booking Layanan',
            subtitle: 'Konfirmasi kebutuhanmu',
            onBack: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konfirmasi kebutuhanmu sebelum tukang datang.',
                  style: pj(fontSize: 13.5, color: AppColors.muted),
                ),
                const SectionTitle('Tukang pilihan'),
                BrCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Avatar(name: worker.name, size: 48),
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
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            Text(
                              worker.service,
                              style: pj(fontSize: 12, color: AppColors.muted),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Stars(value: worker.rating, size: 12),
                                _Meta(
                                  icon: Icons.location_on_outlined,
                                  text: '${worker.distance} km',
                                ),
                                _Meta(
                                  icon: Icons.access_time,
                                  text: worker.eta,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const BrTag(label: 'Terverifikasi', color: 'success'),
                    ],
                  ),
                ),
                if (widget.state.cat.isNotEmpty) ...[
                  const SectionTitle('Ringkasan Masalah'),
                  BrCard(
                    padding: const EdgeInsets.all(14),
                    color: AppColors.primary50,
                    border: Border.all(color: AppColors.primary100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: AppColors.primaryDark,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${widget.state.selectedProblem}. Kemungkinan ${category.resultProblem.toLowerCase()}.',
                                style: pj(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryPill(
                                label: 'Estimasi wajar',
                                value:
                                    '${rupiah(category.priceMin)}-${rupiah(category.priceMax)}',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _SummaryPill(
                                label: 'Durasi',
                                value:
                                    '${category.durationMin}-${category.durationMax} menit',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SectionTitle('Ringkasan yang dikirim ke tukang'),
                  TextField(
                    controller: aiSummary,
                    maxLines: 6,
                    style: pj(
                      fontSize: 13.5,
                      color: AppColors.ink,
                      height: 1.45,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Edit ringkasan untuk tukang',
                      helperText:
                          'Kamu bisa edit ringkasan ini sebelum booking dikirim.',
                      helperStyle: pj(fontSize: 11, color: AppColors.muted),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
                const SectionTitle('Catatan untuk tukang'),
                TextField(
                  controller: requestNote,
                  maxLines: 4,
                  style: pj(fontSize: 14, color: AppColors.ink, height: 1.45),
                  decoration: InputDecoration(
                    hintText:
                        'Tambahkan detail seperti lokasi AC, akses masuk, atau waktu yang kamu inginkan.',
                    hintStyle: pj(fontSize: 13, color: AppColors.muted),
                  ),
                ),
                const SectionTitle('Kapan tukang datang?'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Sekarang', 'Hari ini', 'Besok', 'Pilih Jadwal']
                      .map(
                        (item) => BrChip(
                          label: item,
                          active: schedule == item,
                          variant: 'primary',
                          onTap: () => setState(() => schedule = item),
                        ),
                      )
                      .toList(),
                ),
                const SectionTitle('Alamat'),
                BrCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.primary50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primaryDark,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alamat tersimpan',
                                  style: pj(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  'Tebet, Jakarta Selatan',
                                  style: pj(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BrButton(
                            label: 'Pin lokasi',
                            size: BrButtonSize.sm,
                            variant: BrButtonVariant.secondary,
                            icon: const Icon(
                              Icons.my_location,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: address,
                        maxLines: 2,
                        style: pj(fontSize: 13, color: AppColors.ink),
                        decoration: const InputDecoration(
                          labelText: 'Detail alamat',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: accessNote,
                        maxLines: 2,
                        style: pj(fontSize: 13, color: AppColors.ink),
                        decoration: const InputDecoration(
                          labelText: 'Catatan akses',
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionTitle('Metode Pembayaran'),
                _PaymentOption(
                  title: 'Bayar setelah selesai',
                  description:
                      'Bayar langsung setelah pekerjaan dicek dan disepakati.',
                  selected: payment == 'Bayar setelah selesai',
                  onTap: () =>
                      setState(() => payment = 'Bayar setelah selesai'),
                ),
                const SizedBox(height: 10),
                _PaymentOption(
                  title: 'Booking fee via Beresin',
                  description:
                      'Bayar biaya booking kecil agar jadwal lebih aman.',
                  amount: 'Rp15.000',
                  selected: payment == 'Booking fee via Beresin',
                  onTap: () =>
                      setState(() => payment = 'Booking fee via Beresin'),
                ),
                const SizedBox(height: 10),
                BrCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.muted,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'QRIS, e-wallet, dan transfer bank',
                          style: pj(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink2,
                          ),
                        ),
                      ),
                      const BrTag(label: 'Segera hadir', color: 'neutral'),
                    ],
                  ),
                ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tips aman dari Beresin',
                              style: pj(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF8A5A14),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Konfirmasi harga sebelum pekerjaan dimulai. Jangan bayar penuh sebelum masalah dicek langsung. Simpan bukti pembayaran dan foto hasil pekerjaan.',
                              style: pj(
                                fontSize: 11.5,
                                color: Color(0xFF8A5A14),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                BrButton(
                  label: 'Konfirmasi Booking',
                  full: true,
                  size: BrButtonSize.lg,
                  iconRight: const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    final s = widget.state;
                    final booking = await appRepository.createBooking(
                      BookingDraft(
                        workerId: worker.id,
                        category: category.label,
                        problem: s.selectedProblem,
                        aiSummary: aiSummary.text,
                        estimatedPriceMin:
                            s.activeEstimatedMinPrice ?? category.priceMin,
                        estimatedPriceMax:
                            s.activeEstimatedMaxPrice ?? category.priceMax,
                        schedule: schedule.isEmpty ? 'Hari ini' : schedule,
                        address: address.text,
                        accessNote: accessNote.text,
                        customerNote: requestNote.text,
                        paymentMethod: payment.isEmpty
                            ? 'Bayar setelah selesai'
                            : payment,
                        chatChannel: ChatChannel.whatsapp,
                        diagnosisId: s.activeDiagnosisId,
                      ),
                    );
                    s.activeBookingId = booking.id;
                    if (!context.mounted) return;
                    widget.go('bookingConfirmation', {'workerId': worker.id});
                  },
                ),
                const SizedBox(height: 10),
                BrButton(
                  label: 'Kembali',
                  variant: BrButtonVariant.secondary,
                  full: true,
                  onPressed: () => widget.go('worker', {'workerId': worker.id}),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Meta({required this.icon, required this.text});

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

String _defaultAiSummary(FlowState state, DiagnosisCategory category) {
  if (state.unknownMode || category.id == 'pipa') {
    return 'Customer mengalami air menetes dari plafon dekat kamar mandi sejak pagi. AI Beresin memperkirakan kemungkinan pipa bocor atau rembesan dari area kamar mandi. Urgensi segera. Estimasi harga wajar Rp100.000-Rp250.000. Mohon cek kondisi langsung sebelum menentukan harga final.';
  }
  return 'Customer mengalami ${state.selectedProblem.toLowerCase()}. AI Beresin memperkirakan kemungkinan ${category.resultProblem.toLowerCase()}. Urgensi ${state.urgency.toLowerCase()}. Estimasi harga wajar ${rupiah(category.priceMin)}-${rupiah(category.priceMax)}. Mohon cek kondisi langsung sebelum menentukan harga final.';
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: pj(fontSize: 10.5, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: pj(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String description;
  final String? amount;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.description,
    this.amount,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.line,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: pj(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      if (amount != null)
                        Text(
                          amount!,
                          style: pj(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                    ],
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
          ],
        ),
      ),
    );
  }
}
