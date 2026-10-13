import 'package:flutter/material.dart';

import '../data/workers.dart';
import '../theme.dart';
import '../widgets.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navBottom = MediaQuery.of(context).padding.bottom + 120;
    final requests = [
      ['AC bocor', 'Tebet Barat', 'analyzed', 'Rp75.000-Rp150.000'],
      ['Pipa mampet', 'Tebet Timur', 'contacted', 'Rp75.000-Rp200.000'],
      [
        'Listrik mati sebagian',
        'Menteng Dalam',
        'draft',
        'Rp100.000-Rp250.000',
      ],
    ];

    return ListView(
      padding: EdgeInsets.only(bottom: navBottom),
      children: [
        const ScreenHeader(title: 'Admin', subtitle: 'Operator Beresin'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Expanded(
                    child: _MetricCard(value: '5', label: 'Tukang'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(value: '3', label: 'Request'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(value: '2', label: 'Review'),
                  ),
                ],
              ),
              const SectionTitle('Tukang Aktif', rightText: 'Tambah'),
              BrCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: List.generate(kWorkers.length, (i) {
                    final worker = kWorkers[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: i < kWorkers.length - 1
                              ? const BorderSide(color: AppColors.line2)
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                          ServiceIcon(kind: worker.serviceKind, size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  worker.name,
                                  style: pj(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  '${worker.service} - ${worker.jobsDone} pekerjaan',
                                  style: pj(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BrTag(
                            label: worker.isIdentityVerified
                                ? 'verified'
                                : 'pending',
                            color: worker.isIdentityVerified
                                ? 'success'
                                : 'neutral',
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SectionTitle('Request Masuk'),
              BrCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: List.generate(requests.length, (i) {
                    final request = requests[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: i < requests.length - 1
                              ? const BorderSide(color: AppColors.line2)
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request[0],
                                  style: pj(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  '${request[1]} - ${request[3]}',
                                  style: pj(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BrTag(label: request[2], color: 'accent'),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;

  const _MetricCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Text(
            value,
            style: pj(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: pj(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}
