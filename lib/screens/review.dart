import 'package:flutter/material.dart';

import '../data/mock_ai_result.dart';
import '../data/workers.dart';
import '../repositories/app_repository.dart';
import '../theme.dart';
import '../widgets.dart';

class ReviewScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final String requestId;

  const ReviewScreen({super.key, required this.go, required this.requestId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int rating = 0;
  String priceStatus = '';
  bool _showSuccess = false;
  final _price = TextEditingController();
  final _review = TextEditingController();
  final List<bool> _starBouncing = List.filled(5, false);

  void _onStarTap(int index) {
    final reduce = MediaQuery.of(context).disableAnimations;
    setState(() => rating = index + 1);
    if (reduce) return;
    for (int i = 0; i <= index; i++) {
      Future.delayed(Duration(milliseconds: i * 45), () {
        if (!mounted) return;
        setState(() => _starBouncing[i] = true);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          setState(() => _starBouncing[i] = false);
        });
      });
    }
  }

  @override
  void dispose() {
    _price.dispose();
    _review.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = appRepository.bookingById(widget.requestId);
    final worker = kWorkers.firstWhere(
      (item) => item.id == booking?.workerId,
      orElse: () => kWorkers.first,
    );
    final navBottom = MediaQuery.of(context).padding.bottom + 120;
    final reduce = MediaQuery.of(context).disableAnimations;
    return Stack(
      children: [
        FloatingBackScaffold(
          onBack: () => widget.go('bookingStatus'),
          child: ListView(
            padding: EdgeInsets.only(bottom: navBottom),
            children: [
              ScreenHeader(
                title: 'Layanan Selesai?',
                subtitle: 'Review & harga aktual',
                onBack: () {},
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bantu Beresin menjaga kualitas tukang lokal dengan memberi rating dan harga aktual.',
                      style: pj(
                        fontSize: 13.5,
                        color: AppColors.muted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    BrCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Avatar(name: worker.name, size: 46),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${booking?.problem ?? 'AC bocor'} - ${worker.name}',
                                  style: pj(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  booking == null
                                      ? 'Estimasi ${rupiah(mockAiResult.estimatedPrice.min)}-${rupiah(mockAiResult.estimatedPrice.max)}'
                                      : 'Estimasi ${rupiah(booking.estimatedPriceMin)}-${rupiah(booking.estimatedPriceMax)}',
                                  style: pj(fontSize: 11.5, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          const BrTag(label: 'Selesai', color: 'success'),
                        ],
                      ),
                    ),
                    const SectionTitle('Final price paid'),
                    TextField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      style: pj(fontSize: 16, color: AppColors.ink),
                      decoration: InputDecoration(
                        prefixText: 'Rp',
                        hintText: 'Contoh: Rp100.000',
                        helperText:
                            'Data harga membantu Beresin membuat estimasi harga yang lebih akurat untuk warga sekitar.',
                        helperStyle: pj(fontSize: 11, color: AppColors.muted),
                      ),
                    ),
                    const SectionTitle('Rating layanan'),
                    BrCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              final active = i < rating;
                              return GestureDetector(
                                onTap: () => _onStarTap(i),
                                child: AnimatedScale(
                                  scale: _starBouncing[i] ? 1.35 : 1.0,
                                  duration: reduce
                                      ? Duration.zero
                                      : const Duration(milliseconds: 180),
                                  curve: Curves.easeOutBack,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: reduce
                                          ? Duration.zero
                                          : const Duration(milliseconds: 150),
                                      child: Icon(
                                        Icons.star_rounded,
                                        key: ValueKey(active),
                                        size: 34,
                                        color: active
                                            ? AppColors.accent
                                            : AppColors.line,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rating >= 4 ? 'Pengalaman bagus' : 'Perlu diperbaiki',
                            style: pj(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionTitle('Ceritakan pengalamanmu'),
                    TextField(
                      controller: _review,
                      maxLines: 4,
                      style: pj(fontSize: 14, color: AppColors.ink),
                      decoration: const InputDecoration(
                        hintText: 'Ceritakan pengalamanmu...',
                      ),
                    ),
                    const SectionTitle('Apakah harga akhir sesuai estimasi?'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Sesuai estimasi', 'Lebih mahal', 'Lebih murah']
                          .map(
                            (item) => BrChip(
                              label: item,
                              variant: 'primary',
                              active: priceStatus == item,
                              onTap: () => setState(() => priceStatus = item),
                            ),
                          )
                          .toList(),
                    ),
                    const SectionTitle('Foto hasil pekerjaan'),
                    BrCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload foto opsional',
                                  style: pj(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  'Bisa membantu jika ada komplain atau garansi.',
                                  style: pj(fontSize: 11.5, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          const BrTag(label: 'Opsional', color: 'neutral'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    BrCard(
                      padding: const EdgeInsets.all(12),
                      color: AppColors.primary50,
                      border: Border.all(color: AppColors.primary100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primaryDark,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Data harga membantu Beresin membuat estimasi harga yang lebih akurat untuk warga sekitar.',
                              style: pj(
                                fontSize: 11.5,
                                color: AppColors.primaryDark,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    BrButton(
                      label: 'Kirim Review',
                      size: BrButtonSize.lg,
                      full: true,
                      icon: const Icon(Icons.check, color: Colors.white, size: 18),
                      onPressed: () async {
                        final noAnim = MediaQuery.of(context).disableAnimations;
                        final digits = _price.text.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        final actualPrice = digits.isEmpty
                            ? null
                            : int.parse(digits);
                        final withinEstimate = switch (priceStatus) {
                          'Sesuai estimasi' => true,
                          'Lebih mahal' => false,
                          'Lebih murah' => true,
                          _ => null,
                        };
                        if (booking != null) {
                          await appRepository.submitReview(
                            bookingId: booking.id,
                            workerId: worker.id,
                            rating: rating == 0 ? 5 : rating,
                            text: _review.text.trim(),
                            actualPrice: actualPrice,
                            wasPriceWithinEstimate: withinEstimate,
                          );
                        }
                        if (!mounted) return;
                        if (!noAnim) {
                          setState(() => _showSuccess = true);
                          await Future.delayed(const Duration(milliseconds: 700));
                          if (!mounted) return;
                        }
                        widget.go('history');
                      },
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Celebration overlay
        IgnorePointer(
          ignoring: !_showSuccess,
          child: AnimatedOpacity(
            opacity: _showSuccess ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: Container(
              color: AppColors.primary.withValues(alpha: .93),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: _showSuccess ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      opacity: _showSuccess ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        'Review terkirim!',
                        style: pj(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedOpacity(
                      opacity: _showSuccess ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 350),
                      child: Text(
                        'Terima kasih sudah membantu komunitas!',
                        style: pj(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: .8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
