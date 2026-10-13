import 'package:flutter/material.dart';

import '../models.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import '../widgets.dart';

Future<void> showWhatsappLeadSheet({
  required BuildContext context,
  required Worker worker,
  FlowState? state,
}) async {
  final category = state == null
      ? diagnosisCategories.first
      : diagnosisByLabel(state.cat);
  final problem = state?.selectedProblem ?? category.problemChips.first;
  final priceText = '${rupiah(category.priceMin)}-${rupiah(category.priceMax)}';
  final defaultMessage = state?.unknownMode == true || category.id == 'pipa'
      ? 'Halo ${worker.name}, saya dapat rekomendasi dari Beresin. Saya butuh bantuan karena ada air menetes dari plafon dekat kamar mandi. Berdasarkan analisis Beresin, kemungkinan ada pipa bocor atau rembesan. Estimasi harga wajar Rp100.000-Rp250.000. Apakah bisa cek hari ini?'
      : 'Halo ${worker.name}, saya dapat rekomendasi dari Beresin. Saya butuh bantuan untuk $problem. Berdasarkan analisis Beresin, kemungkinan ${category.resultProblem.toLowerCase()}. Estimasi harga wajar $priceText. Apakah bisa cek hari ini?';
  final controller = TextEditingController(text: defaultMessage);
  const whatsapp = WhatsappService();

  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * .85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Avatar(name: worker.name, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanya dulu ke ${worker.name}?',
                            style: pj(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kami akan menyiapkan pesan otomatis berisi ringkasan masalah agar tukang langsung paham.',
                            style: pj(
                              fontSize: 12,
                              color: AppColors.muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Preview pesan',
                  style: pj(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink2,
                  ),
                ),
                const SizedBox(height: 8),
                BrCard(
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: controller,
                    maxLines: 6,
                    minLines: 4,
                    style: pj(fontSize: 13, color: AppColors.ink, height: 1.45),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                BrCard(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.primary50,
                  border: Border.all(color: AppColors.primary100),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lead ini tetap disimpan di Beresin agar kamu bisa memberi rating setelah layanan selesai.',
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: BrButton(
                        label: 'Batal',
                        variant: BrButtonVariant.secondary,
                        full: true,
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BrButton(
                        label: 'Buka WhatsApp',
                        variant: BrButtonVariant.whatsapp,
                        full: true,
                        icon: const Icon(
                          Icons.chat,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: () async {
                          final opened = await whatsapp.openChat(
                            worker: worker,
                            message: controller.text,
                          );
                          if (!sheetContext.mounted) return;
                          if (opened) {
                            Navigator.of(sheetContext).pop();
                            return;
                          }
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                'WhatsApp belum bisa dibuka di device ini.',
                                style: pj(color: Colors.white),
                              ),
                              backgroundColor: AppColors.ink,
                            ),
                          );
                        },
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
  );

  controller.dispose();
}

