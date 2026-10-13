import '../models/ai_result.dart';

const mockAiResult = AiResult(
  problemTitle: 'Saluran drainase AC tersumbat',
  category: 'AC',
  recommendedWorkerType: 'Teknisi AC',
  severity: 'medium',
  urgency: 'soon',
  confidence: 0.87,
  likelyCauses: [
    'Saluran pembuangan air tersumbat',
    'Evaporator terlalu kotor',
  ],
  explanation:
      'Gejala ini biasanya terjadi karena saluran pembuangan air kotor tersumbat atau evaporator terlalu kotor.',
  estimatedPrice: AiPriceEstimate(
    currency: 'IDR',
    min: 75000,
    max: 150000,
    label: 'Harga wajar untuk area Tebet',
  ),
  estimatedDuration: AiDurationEstimate(min: 30, max: 60),
  recommendedNextStep:
      'Panggil teknisi AC untuk pengecekan dan pembersihan saluran drainase.',
  safetyNote:
      'Jangan membongkar unit AC sendiri jika tidak berpengalaman. Matikan AC jika air menetes dekat stop kontak.',
  whatsappMessage:
      'Halo Pak, saya butuh bantuan untuk AC bocor. Berdasarkan analisis Beresin, kemungkinan saluran drainase tersumbat. Apakah bisa datang hari ini?',
);
