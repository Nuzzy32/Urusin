import 'dart:async';
import 'package:flutter/material.dart';
import '../../models.dart';
import '../../services/ai_diagnosis_service.dart';
import '../../theme.dart';
import '../../widgets.dart';

class AnalyzingScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;
  const AnalyzingScreen({super.key, required this.go, required this.state});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  int step = 0;
  final timers = <Timer>[];
  final steps = const [
    'Membaca foto kerusakan…',
    'Mendeteksi pola masalah…',
    'Mencari estimasi harga wajar…',
    'Memilih tukang terdekat…',
  ];

  @override
  void initState() {
    super.initState();
    // UI progress steps berjalan paralel; navigasi terjadi setelah AI selesai.
    timers.add(
      Timer(const Duration(milliseconds: 600), () => _safeStep(1)),
    );
    timers.add(
      Timer(const Duration(milliseconds: 1300), () => _safeStep(2)),
    );
    timers.add(
      Timer(const Duration(milliseconds: 2000), () => _safeStep(3)),
    );
    unawaited(_runDiagnosis());
  }

  void _safeStep(int next) {
    if (mounted) setState(() => step = next);
  }

  Future<void> _runDiagnosis() async {
    final s = widget.state;
    final categoryId = s.categoryIdFor(s.cat);
    final input = AiDiagnosisInput(
      categoryId: categoryId,
      categoryLabel: s.cat,
      problem: s.selectedProblem,
      description: s.desc,
      urgency: s.urgency.isEmpty ? 'Normal' : s.urgency,
      uploadedImageUrl: s.uploadedImageUrl,
    );
    final record = await AiDiagnosisService.instance.analyzeAndPersist(input);
    if (record != null) {
      s.activeDiagnosisId = record.diagnosisId;
      s.activeEstimatedMinPrice = record.estimatedMinPrice;
      s.activeEstimatedMaxPrice = record.estimatedMaxPrice;
      s.activeAiAnalysis = record.aiAnalysisResult;
    }
    // tunggu minimal 2.4s supaya animasi step tidak terlalu cepat
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    widget.go('result');
  }

  @override
  void dispose() {
    for (final t in timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E8E6C), Color(0xFF0A6E54)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                height: 165,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const MockACPhoto(),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'BERESIN AI',
                style: pj(
                  color: const Color(0xFFFFD89B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lagi mikir…',
                style: pj(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'AI sedang menganalisis foto dan mencari pola masalah dari ribuan kasus sejenis.',
                textAlign: TextAlign.center,
                style: pj(
                  color: Colors.white.withValues(alpha: .7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Column(
                  children: List.generate(steps.length, (i) {
                    final done = i < step;
                    final current = i == step;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: i <= step ? 1 : .4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: done
                                    ? const Color(0xFFFFD89B)
                                    : (current
                                          ? Colors.white.withValues(alpha: .2)
                                          : Colors.white.withValues(
                                              alpha: .08,
                                            )),
                                shape: BoxShape.circle,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.easeOutBack,
                                      ),
                                      child: FadeTransition(
                                        opacity: anim,
                                        child: child,
                                      ),
                                    ),
                                child: done
                                    ? const Icon(
                                        Icons.check,
                                        key: ValueKey('done'),
                                        size: 12,
                                        color: AppColors.ink,
                                      )
                                    : current
                                    ? const Padding(
                                        key: ValueKey('current'),
                                        padding: EdgeInsets.all(4),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                            Color(0xFFFFD89B),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        key: ValueKey('num-$i'),
                                        child: Text(
                                          '${i + 1}',
                                          style: pj(
                                            color: Colors.white.withValues(
                                              alpha: .6,
                                            ),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                steps[i],
                                style: pj(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
