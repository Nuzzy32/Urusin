import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme.dart';
import '../../widgets.dart';

class MitraDashboardScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const MitraDashboardScreen({super.key, required this.go});

  @override
  State<MitraDashboardScreen> createState() => _MitraDashboardScreenState();
}

class _MitraDashboardScreenState extends State<MitraDashboardScreen> {
  bool isVerified = false;
  bool isAvailable = true;
  int selectedTab = 0;
  int availabilityIndex = 0;
  MitraOrder? detailOrder;
  String _mitraName = 'Mitra';
  String _mitraBusinessName = 'Dashboard Mitra';

  final List<MitraOrder> incomingOrders = [];
  final List<MitraOrder> activeOrders = [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadDashboard());
  }

  Future<void> _loadDashboard() async {
    try {
      final client = Supabase.instance.client;
      final authUid = client.auth.currentUser?.id;
      if (authUid == null) return;

      final userRows = await client
          .from('users')
          .select('user_id, name')
          .eq('auth_user_id', authUid)
          .limit(1);
      if (userRows.isEmpty) return;

      final userId = userRows.first['user_id'] as String;
      final userName = userRows.first['name'] as String? ?? '';

      final mitraRows = await client
          .from('mitras')
          .select('verification_status, avg_rating')
          .eq('mitra_id', userId)
          .limit(1);

      final verificationStatus = mitraRows.isNotEmpty
          ? mitraRows.first['verification_status'] as String? ?? ''
          : '';

      final bookingRows = await client
          .from('bookings')
          .select(
            'id, problem, category, address, schedule, customer_id, '
            'estimated_price_min, estimated_price_max, final_price, status, ai_summary',
          )
          .eq('worker_id', userId)
          .inFilter('status', [
            'created',
            'accepted',
            'on_the_way',
            'in_progress',
          ])
          .order('created_at', ascending: false);

      final incoming = <MitraOrder>[];
      final active = <MitraOrder>[];
      for (final row in bookingRows) {
        final order = _bookingToOrder(row);
        if (row['status'] == 'created') {
          incoming.add(order);
        } else {
          active.add(order);
        }
      }

      if (!mounted) return;
      setState(() {
        isVerified = verificationStatus == 'approved';
        _mitraName = userName.split(' ').first;
        _mitraBusinessName = userName;
        incomingOrders
          ..clear()
          ..addAll(incoming);
        activeOrders
          ..clear()
          ..addAll(active);
      });
    } catch (_) {}
  }

  MitraOrder _bookingToOrder(Map<String, dynamic> row) {
    final min = row['estimated_price_min'] as int? ?? 0;
    final max = row['estimated_price_max'] as int? ?? 0;
    final finalP = row['final_price'] as int?;
    final priceLabel = finalP != null
        ? rupiah(finalP)
        : '${rupiah(min)}-${rupiah(max)}';
    final addr = (row['address'] as String?) ?? '';
    final location = addr.contains(',') ? addr.split(',').first.trim() : addr;
    return MitraOrder(
      bookingId: (row['id'] as String?) ?? '',
      service:
          (row['problem'] as String?)?.isNotEmpty == true
              ? row['problem'] as String
              : (row['category'] as String?) ?? '',
      location: location.isEmpty ? '-' : location,
      distance: '-',
      estimate: priceLabel,
      schedule: (row['schedule'] as String?) ?? '-',
      customer: 'Customer',
      summary: (row['ai_summary'] as String?) ?? '',
      diagnosis: (row['category'] as String?) ?? '',
      workerRange: priceLabel,
      eta: '-',
      customerRating: 0,
    );
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: pj(fontWeight: FontWeight.w700)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void acceptOrder(MitraOrder order) {
    setState(() {
      incomingOrders.remove(order);
      if (!activeOrders.contains(order)) activeOrders.insert(0, order);
      detailOrder = null;
      selectedTab = 0;
    });
    if (order.bookingId.isNotEmpty) {
      unawaited(
        Supabase.instance.client.from('bookings').update({
          'status': 'accepted',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', order.bookingId),
      );
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SuccessSheet(
        onDetail: () {
          Navigator.pop(context);
          setState(() => detailOrder = order);
        },
        onWhatsapp: () {
          Navigator.pop(context);
          showToast('Membuka WhatsApp Customer.');
        },
      ),
    );
  }

  void confirmAccept(MitraOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AcceptOrderSheet(
        onCancel: () => Navigator.pop(context),
        onAccept: () {
          Navigator.pop(context);
          acceptOrder(order);
        },
      ),
    );
  }

  void declineOrder(MitraOrder order) {
    setState(() => incomingOrders.remove(order));
    if (order.bookingId.isNotEmpty) {
      unawaited(
        Supabase.instance.client.from('bookings').update({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', order.bookingId),
      );
    }
    showToast('Order ditolak. Kami akan carikan Mitra lain.');
  }

  void _showMitraLogoutSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: .16),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE9E2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.danger,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keluar dari mode Mitra?',
                        style: pj(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Order dan data profil tetap tersimpan. Kamu bisa masuk lagi dengan nomor HP yang sama.',
                  style: pj(fontSize: 13, color: AppColors.muted, height: 1.45),
                ),
                const SizedBox(height: 16),
                _MitraDangerButton(
                  label: 'Ya, Keluar',
                  full: true,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.go('login');
                  },
                ),
                const SizedBox(height: 10),
                BrButton(
                  label: 'Batal',
                  full: true,
                  variant: BrButtonVariant.secondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (detailOrder != null) {
      return _MitraOrderDetailScreen(
        order: detailOrder!,
        onBack: () => setState(() => detailOrder = null),
        onAccept: () => confirmAccept(detailOrder!),
        onDecline: () => declineOrder(detailOrder!),
        onWhatsapp: () => showToast('Membuka WhatsApp Customer.'),
        onFinalPrice: () => widget.go('workerFinalPrice'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _PhoneBody(
        child: IndexedStack(
          index: selectedTab,
          children: [
            _DashboardTab(
              isVerified: isVerified,
              onToggleState: (value) {
                setState(() {
                  isVerified = value;
                  selectedTab = 0;
                });
              },
              isAvailable: isAvailable,
              onAvailabilityChanged: (value) =>
                  setState(() => isAvailable = value),
              availabilityIndex: availabilityIndex,
              onAvailabilityOption: (index) =>
                  setState(() => availabilityIndex = index),
              incomingOrders: incomingOrders,
              activeOrders: activeOrders,
              onOpenDetail: (order) => setState(() => detailOrder = order),
              onAccept: confirmAccept,
              onDecline: declineOrder,
              onProfile: () => setState(() => selectedTab = 3),
              onSupport: () => setState(() => selectedTab = 4),
              onEditRegistration: () => widget.go('workerReview'),
              onSchedule: () => setState(() => selectedTab = 2),
              onPrices: () => showToast('Pengaturan harga dibuka.'),
              mitraName: _mitraName,
              businessName: _mitraBusinessName,
            ),
            _OrdersTab(
              incomingOrders: incomingOrders,
              activeOrders: activeOrders,
              onOpenDetail: (order) => setState(() => detailOrder = order),
              onAccept: confirmAccept,
              onDecline: declineOrder,
              onArea: () => showToast('Pengaturan area layanan dibuka.'),
            ),
            _ScheduleTab(),
            _MitraProfileTab(
              onAction: showToast,
              onLogout: () => _showMitraLogoutSheet(context),
            ),
            _SupportTab(onChat: () => showToast('Chat Support dibuka.')),
          ],
        ),
      ),
      bottomNavigationBar: _MitraBottomNav(
        activeIndex: selectedTab,
        onTap: (index) => setState(() => selectedTab = index),
      ),
    );
  }
}

class MitraOrder {
  final String bookingId;
  final String service;
  final String location;
  final String distance;
  final String estimate;
  final String schedule;
  final String customer;
  final String summary;
  final String diagnosis;
  final String workerRange;
  final String eta;
  final double customerRating;

  const MitraOrder({
    required this.bookingId,
    required this.service,
    required this.location,
    required this.distance,
    required this.estimate,
    required this.schedule,
    required this.customer,
    required this.summary,
    required this.diagnosis,
    required this.workerRange,
    required this.eta,
    required this.customerRating,
  });
}

class _DashboardTab extends StatelessWidget {
  final bool isVerified;
  final ValueChanged<bool> onToggleState;
  final bool isAvailable;
  final ValueChanged<bool> onAvailabilityChanged;
  final int availabilityIndex;
  final ValueChanged<int> onAvailabilityOption;
  final List<MitraOrder> incomingOrders;
  final List<MitraOrder> activeOrders;
  final ValueChanged<MitraOrder> onOpenDetail;
  final ValueChanged<MitraOrder> onAccept;
  final ValueChanged<MitraOrder> onDecline;
  final VoidCallback onProfile;
  final VoidCallback onSupport;
  final VoidCallback onEditRegistration;
  final VoidCallback onSchedule;
  final VoidCallback onPrices;
  final String mitraName;
  final String businessName;

  const _DashboardTab({
    required this.isVerified,
    required this.onToggleState,
    required this.isAvailable,
    required this.onAvailabilityChanged,
    required this.availabilityIndex,
    required this.onAvailabilityOption,
    required this.incomingOrders,
    required this.activeOrders,
    required this.onOpenDetail,
    required this.onAccept,
    required this.onDecline,
    required this.onProfile,
    required this.onSupport,
    required this.onEditRegistration,
    required this.onSchedule,
    required this.onPrices,
    required this.mitraName,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    return _MitraScrollView(
      children: [
        _MitraHeader(
          isVerified: isVerified,
          onToggleState: onToggleState,
          mitraName: mitraName,
          businessName: businessName,
          trailing: GestureDetector(
            onTap: onProfile,
            child: Avatar(name: businessName, size: 42),
          ),
        ),
        const SizedBox(height: 14),
        if (isVerified)
          _ActiveDashboard(
            isAvailable: isAvailable,
            onAvailabilityChanged: onAvailabilityChanged,
            availabilityIndex: availabilityIndex,
            onAvailabilityOption: onAvailabilityOption,
            incomingOrders: incomingOrders,
            activeOrders: activeOrders,
            onOpenDetail: onOpenDetail,
            onAccept: onAccept,
            onDecline: onDecline,
            onSchedule: onSchedule,
            onPrices: onPrices,
          )
        else
          _PendingDashboard(
            onEditRegistration: onEditRegistration,
            onSupport: onSupport,
          ),
      ],
    );
  }
}

class _MitraHeader extends StatelessWidget {
  final bool isVerified;
  final ValueChanged<bool> onToggleState;
  final Widget trailing;
  final String mitraName;
  final String businessName;

  const _MitraHeader({
    required this.isVerified,
    required this.onToggleState,
    required this.trailing,
    required this.mitraName,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    businessName,
                    style: pj(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Halo, $mitraName',
                    style: pj(fontSize: 13.5, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
        const SizedBox(height: 14),
        _DemoStateSwitch(isVerified: isVerified, onChanged: onToggleState),
      ],
    );
  }
}

class _DemoStateSwitch extends StatelessWidget {
  final bool isVerified;
  final ValueChanged<bool> onChanged;

  const _DemoStateSwitch({required this.isVerified, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatePill(
              label: 'Menunggu verifikasi',
              active: !isVerified,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _StatePill(
              label: 'Mitra aktif',
              active: isVerified,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _StatePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: pj(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColors.ink2,
          ),
        ),
      ),
    );
  }
}

class _PendingDashboard extends StatelessWidget {
  final VoidCallback onEditRegistration;
  final VoidCallback onSupport;

  const _PendingDashboard({
    required this.onEditRegistration,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WorkerIdentityCard(
          statusLabel: 'Menunggu Verifikasi',
          statusColor: 'accent',
          serviceLine: 'Teknisi AC',
          areaLine: 'Tebet, Jakarta Selatan',
          showRating: false,
        ),
        const SizedBox(height: 12),
        BrCard(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8ED), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFFFE7BF)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBubble(
                icon: Icons.verified_user_outlined,
                bg: AppColors.accent50,
                fg: AppColors.accentDark,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil sedang diverifikasi',
                      style: pj(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Kamu belum bisa menerima order sampai verifikasi selesai.',
                      style: pj(
                        fontSize: 13,
                        color: AppColors.ink2,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _SoftBadge(
                      text: 'Estimasi selesai: 1-2 hari kerja',
                      icon: Icons.schedule_rounded,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tim Beresin sedang mengecek dokumen dan kelengkapan profilmu.',
                      style: pj(
                        fontSize: 12.5,
                        color: AppColors.muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Progress Verifikasi'),
        BrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _VerificationStep(
                icon: Icons.person_rounded,
                title: 'Profil lengkap',
                description: 'Data diri dan layanan sudah diisi',
                state: _StepState.done,
                hasDivider: true,
              ),
              _VerificationStep(
                icon: Icons.description_rounded,
                title: 'Dokumen diterima',
                description: 'KTP, selfie, dan foto pekerjaan diterima',
                state: _StepState.done,
                hasDivider: true,
              ),
              _VerificationStep(
                icon: Icons.manage_search_rounded,
                title: 'Sedang ditinjau',
                description: 'Tim Beresin sedang melakukan pengecekan',
                state: _StepState.active,
                hasDivider: true,
              ),
              _VerificationStep(
                icon: Icons.handshake_rounded,
                title: 'Profil aktif',
                description: 'Kamu bisa mulai menerima order',
                state: _StepState.pending,
              ),
            ],
          ),
        ),
        const SectionTitle('Kelengkapan Profil'),
        BrCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kelengkapan Profil',
                      style: pj(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Text(
                    '85%',
                    style: pj(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: const LinearProgressIndicator(
                  value: .85,
                  minHeight: 9,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primary100,
                ),
              ),
              const SizedBox(height: 14),
              const _ProfileCheck(label: 'Data diri lengkap', done: true),
              const _ProfileCheck(
                label: 'Layanan dan harga lengkap',
                done: true,
              ),
              const _ProfileCheck(label: 'Area kerja lengkap', done: true),
              const _ProfileCheck(
                label: 'Verifikasi identitas diterima',
                done: true,
              ),
              const _ProfileCheck(
                label: 'Referensi pelanggan belum ditambahkan',
                done: false,
              ),
              const SizedBox(height: 12),
              BrButton(
                label: 'Lengkapi Referensi',
                full: true,
                variant: BrButtonVariant.secondary,
                icon: const Icon(Icons.add_comment_outlined, size: 18),
                onPressed: onEditRegistration,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.edit_note_rounded,
                title: 'Edit Pendaftaran',
                onTap: onEditRegistration,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                icon: Icons.support_agent_rounded,
                title: 'Hubungi Support',
                onTap: onSupport,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BrCard(
          color: AppColors.primary50,
          border: Border.all(color: AppColors.primary100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _IconBubble(
                    icon: Icons.help_outline_rounded,
                    bg: Colors.white,
                    fg: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Butuh bantuan verifikasi?',
                      style: pj(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Kalau ada data yang salah atau dokumen belum jelas, hubungi tim Beresin.',
                style: pj(fontSize: 13, color: AppColors.ink2, height: 1.45),
              ),
              const SizedBox(height: 14),
              BrButton(
                label: 'Chat Support',
                variant: BrButtonVariant.primary,
                full: true,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                onPressed: onSupport,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveDashboard extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onAvailabilityChanged;
  final int availabilityIndex;
  final ValueChanged<int> onAvailabilityOption;
  final List<MitraOrder> incomingOrders;
  final List<MitraOrder> activeOrders;
  final ValueChanged<MitraOrder> onOpenDetail;
  final ValueChanged<MitraOrder> onAccept;
  final ValueChanged<MitraOrder> onDecline;
  final VoidCallback onSchedule;
  final VoidCallback onPrices;

  const _ActiveDashboard({
    required this.isAvailable,
    required this.onAvailabilityChanged,
    required this.availabilityIndex,
    required this.onAvailabilityOption,
    required this.incomingOrders,
    required this.activeOrders,
    required this.onOpenDetail,
    required this.onAccept,
    required this.onDecline,
    required this.onSchedule,
    required this.onPrices,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WorkerIdentityCard(
          statusLabel: 'Terverifikasi',
          statusColor: 'success',
          serviceLine: 'Teknisi AC',
          areaLine: 'Tebet & sekitarnya',
          showRating: true,
        ),
        const SizedBox(height: 12),
        _AvailabilityCard(
          isAvailable: isAvailable,
          onChanged: onAvailabilityChanged,
          selectedIndex: availabilityIndex,
          onOption: onAvailabilityOption,
        ),
        const SizedBox(height: 14),
        _StatsGrid(
          incoming: incomingOrders.length,
          active: activeOrders.length,
        ),
        const SectionTitle('Order Masuk'),
        if (incomingOrders.isEmpty)
          _NoOrdersEmptyState(onArea: () {})
        else
          ...incomingOrders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _IncomingOrderCard(
                order: order,
                onDetail: () => onOpenDetail(order),
                onAccept: () => onAccept(order),
                onDecline: () => onDecline(order),
              ),
            ),
          ),
        SectionTitle(
          'Jadwal Hari Ini',
          rightText: 'Lihat Semua Jadwal',
          rightIcon: Icons.calendar_month_rounded,
        ),
        _ScheduleCard(onTap: onSchedule),
        const SectionTitle('Insight Minggu Ini'),
        const _InsightCard(),
        const SectionTitle('Harga Layanan'),
        _PricingCard(onPrices: onPrices),
        const SectionTitle('Ulasan Terbaru'),
        _ReviewCard(onAll: () {}),
      ],
    );
  }
}

class _WorkerIdentityCard extends StatelessWidget {
  final String statusLabel;
  final String statusColor;
  final String serviceLine;
  final String areaLine;
  final bool showRating;

  const _WorkerIdentityCard({
    required this.statusLabel,
    required this.statusColor,
    required this.serviceLine,
    required this.areaLine,
    required this.showRating,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Avatar(name: 'Pak Rudi AC', size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pak Rudi AC',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pj(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    BrTag(label: statusLabel, color: statusColor),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _TinyMeta(icon: Icons.ac_unit_rounded, text: serviceLine),
                    _TinyMeta(icon: Icons.place_outlined, text: areaLine),
                    if (showRating) const Stars(value: 4.9, size: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onChanged;
  final int selectedIndex;
  final ValueChanged<int> onOption;

  const _AvailabilityCard({
    required this.isAvailable,
    required this.onChanged,
    required this.selectedIndex,
    required this.onOption,
  });

  @override
  Widget build(BuildContext context) {
    final options = ['Bisa sekarang', 'Bisa hari ini', 'Penuh', 'Jadwalkan'];
    return BrCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconBubble(
                icon: Icons.power_settings_new_rounded,
                bg: AppColors.primary50,
                fg: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Hari Ini',
                      style: pj(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Terima order hari ini',
                      style: pj(fontSize: 12.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isAvailable,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                onChanged: onChanged,
              ),
            ],
          ),
          const SizedBox(height: 12),
          BrTag(
            label: isAvailable
                ? 'Aktif menerima order'
                : 'Kamu sedang tidak menerima order',
            color: isAvailable ? 'success' : 'neutral',
            icon: Icon(
              isAvailable ? Icons.check_circle_rounded : Icons.pause_circle,
              size: 14,
              color: isAvailable ? const Color(0xFF0F7A45) : AppColors.ink2,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(options.length, (index) {
              return BrChip(
                label: options[index],
                active: selectedIndex == index,
                variant: 'primary',
                onTap: () => onOption(index),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int incoming;
  final int active;

  const _StatsGrid({required this.incoming, required this.active});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ['Order Baru', '$incoming', Icons.notifications_active_rounded],
      ['Order Aktif', '$active', Icons.handyman_rounded],
      ['Rating', '4.9', Icons.star_rounded],
      ['Pendapatan Bulan Ini', 'Rp2,4jt', Icons.account_balance_wallet_rounded],
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.72,
      ),
      itemBuilder: (context, index) {
        final item = stats[index];
        return BrCard(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item[2] as IconData, size: 21, color: AppColors.primary),
              Text(
                item[1] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pj(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              Text(
                item[0] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pj(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IncomingOrderCard extends StatelessWidget {
  final MitraOrder order;
  final VoidCallback onDetail;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _IncomingOrderCard({
    required this.order,
    required this.onDetail,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ServiceIcon(kind: 'AC', size: 44),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.service,
                      style: pj(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 5,
                      children: [
                        _TinyMeta(
                          icon: Icons.place_outlined,
                          text: order.location,
                        ),
                        _TinyMeta(
                          icon: Icons.near_me_outlined,
                          text: order.distance,
                        ),
                        _TinyMeta(
                          icon: Icons.schedule_rounded,
                          text: order.schedule,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.customer,
            style: pj(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            order.summary,
            style: pj(fontSize: 13, color: AppColors.ink2, height: 1.45),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estimasi: ${order.estimate}',
                    style: pj(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BrTag(label: 'Dari AI Beresin', color: 'primary'),
              BrTag(label: 'Harga wajar', color: 'success'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BrButton(
                  label: 'Terima',
                  size: BrButtonSize.sm,
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BrButton(
                  label: 'Tolak',
                  size: BrButtonSize.sm,
                  variant: BrButtonVariant.secondary,
                  onPressed: onDecline,
                ),
              ),
              const SizedBox(width: 8),
              BrButton(
                label: 'Detail',
                size: BrButtonSize.sm,
                variant: BrButtonVariant.ghost,
                onPressed: onDetail,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ScheduleCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      ['10.00', 'Cuci AC', 'Bu Mira', 'Pancoran'],
      ['14.00', 'AC bocor', 'Wira', 'Tebet Barat'],
      ['17.00', 'Isi freon', 'Pak Joko', 'Manggarai'],
    ];
    return BrCard(
      child: Column(
        children: [
          ...List.generate(items.length, (index) {
            final item = items[index];
            return _TimelineRow(
              time: item[0],
              title: item[1],
              customer: item[2],
              area: item[3],
              last: index == items.length - 1,
            );
          }),
          const SizedBox(height: 8),
          BrButton(
            label: 'Lihat Semua Jadwal',
            full: true,
            variant: BrButtonVariant.secondary,
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String time;
  final String title;
  final String customer;
  final String area;
  final bool last;

  const _TimelineRow({
    required this.time,
    required this.title,
    required this.customer,
    required this.area,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Text(
            time,
            style: pj(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            if (!last)
              Container(width: 2, height: 36, color: AppColors.primary100),
          ],
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: pj(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$customer · $area',
                  style: pj(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return BrCard(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(
            'Kamu 12% lebih cepat merespon order dibanding teknisi lain di area Tebet.',
            style: pj(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: _DarkMetric(label: 'Response time', value: '8 menit'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _DarkMetric(label: 'Completion', value: '96%'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _DarkMetric(label: 'Repeat', value: '18 pelanggan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkMetric extends StatelessWidget {
  final String label;
  final String value;

  const _DarkMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: pj(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: pj(fontSize: 10.5, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final VoidCallback onPrices;

  const _PricingCard({required this.onPrices});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pastikan harga final dikonfirmasi sebelum mulai kerja.',
            style: pj(fontSize: 13, color: AppColors.ink2, height: 1.45),
          ),
          const SizedBox(height: 14),
          const _PriceRow(label: 'Cuci AC', value: 'Rp80.000-Rp120.000'),
          const _PriceRow(label: 'Cek AC bocor', value: 'Rp100.000-Rp150.000'),
          const _PriceRow(label: 'Isi freon', value: 'Mulai Rp150.000'),
          const SizedBox(height: 12),
          BrButton(
            label: 'Atur Harga',
            full: true,
            variant: BrButtonVariant.secondary,
            icon: const Icon(Icons.tune_rounded, size: 18),
            onPressed: onPrices,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: pj(fontSize: 13, color: AppColors.ink2)),
          ),
          Text(
            value,
            style: pj(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final VoidCallback onAll;

  const _ReviewCard({required this.onAll});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Avatar(name: 'Mbak Tia', size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mbak Tia',
                      style: pj(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const Stars(value: 5, size: 12),
                  ],
                ),
              ),
              Text(
                '2 hari lalu',
                style: pj(fontSize: 11.5, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Datang cepat, AC langsung dingin lagi. Harganya sesuai estimasi.',
            style: pj(fontSize: 13, color: AppColors.ink2, height: 1.45),
          ),
          const SizedBox(height: 12),
          BrButton(
            label: 'Lihat Semua Ulasan',
            full: true,
            variant: BrButtonVariant.ghost,
            onPressed: onAll,
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final List<MitraOrder> incomingOrders;
  final List<MitraOrder> activeOrders;
  final ValueChanged<MitraOrder> onOpenDetail;
  final ValueChanged<MitraOrder> onAccept;
  final ValueChanged<MitraOrder> onDecline;
  final VoidCallback onArea;

  const _OrdersTab({
    required this.incomingOrders,
    required this.activeOrders,
    required this.onOpenDetail,
    required this.onAccept,
    required this.onDecline,
    required this.onArea,
  });

  @override
  Widget build(BuildContext context) {
    return _MitraScrollView(
      children: [
        _SimpleTitle(
          title: 'Order Mitra',
          subtitle: 'Kelola order masuk dan aktif',
        ),
        const SizedBox(height: 14),
        if (incomingOrders.isEmpty)
          _NoOrdersEmptyState(onArea: onArea)
        else ...[
          const SectionTitle('Order Masuk'),
          ...incomingOrders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _IncomingOrderCard(
                order: order,
                onDetail: () => onOpenDetail(order),
                onAccept: () => onAccept(order),
                onDecline: () => onDecline(order),
              ),
            ),
          ),
        ],
        const SectionTitle('Order Aktif'),
        ...activeOrders.map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ActiveOrderMini(
              order: order,
              onTap: () => onOpenDetail(order),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveOrderMini extends StatelessWidget {
  final MitraOrder order;
  final VoidCallback onTap;

  const _ActiveOrderMini({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const ServiceIcon(kind: 'AC', size: 42),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.service,
                  style: pj(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.customer} · ${order.location} · ${order.schedule}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pj(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _NoOrdersEmptyState extends StatelessWidget {
  final VoidCallback onArea;

  const _NoOrdersEmptyState({required this.onArea});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada order masuk',
            style: pj(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan status kamu aktif dan area layanan sudah benar agar warga sekitar bisa menemukanmu.',
            textAlign: TextAlign.center,
            style: pj(fontSize: 13, color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 16),
          BrButton(
            label: 'Atur Area Layanan',
            full: true,
            icon: const Icon(Icons.map_outlined, size: 18),
            onPressed: onArea,
          ),
          const SizedBox(height: 16),
          const _TipRow(text: 'Lengkapi profil'),
          const _TipRow(text: 'Tambahkan foto pekerjaan'),
          const _TipRow(text: 'Pastikan harga layanan jelas'),
          const _TipRow(text: 'Aktifkan status menerima order'),
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _MitraScrollView(
      children: [
        const _SimpleTitle(
          title: 'Jadwal Hari Ini',
          subtitle: 'Selasa, 12 Mei 2026',
        ),
        const SizedBox(height: 14),
        _ScheduleCard(onTap: () {}),
        const SectionTitle('Pengaturan Jam Kerja'),
        BrCard(
          child: Column(
            children: const [
              _ProfileMenuRow(
                icon: Icons.event_available_rounded,
                title: 'Senin-Jumat',
                subtitle: '08.00-18.00',
              ),
              _ProfileMenuRow(
                icon: Icons.weekend_rounded,
                title: 'Sabtu',
                subtitle: '09.00-15.00',
              ),
              _ProfileMenuRow(
                icon: Icons.block_rounded,
                title: 'Minggu',
                subtitle: 'Tidak menerima order',
                last: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MitraProfileTab extends StatelessWidget {
  final ValueChanged<String> onAction;
  final VoidCallback onLogout;

  const _MitraProfileTab({required this.onAction, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return _MitraScrollView(
      children: [
        const _SimpleTitle(
          title: 'Profil Mitra',
          subtitle: 'Profil publik dan pengaturan akun',
        ),
        const SizedBox(height: 14),
        BrCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Avatar(name: 'Pak Rudi AC', size: 60),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pak Rudi AC',
                          style: pj(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Stars(value: 4.9, size: 12),
                        const SizedBox(height: 6),
                        const BrTag(label: 'Terverifikasi', color: 'success'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Teknisi AC area Tebet dengan pengalaman 7 tahun. Fokus cuci AC, AC bocor, isi freon, dan perawatan rutin rumah.',
                style: pj(fontSize: 13, color: AppColors.ink2, height: 1.45),
              ),
              const SizedBox(height: 14),
              BrButton(
                label: 'Edit Profil Publik',
                full: true,
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => onAction('Edit Profil Publik dibuka.'),
              ),
            ],
          ),
        ),
        const SectionTitle('Detail Profil'),
        BrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const _ProfileMenuRow(
                icon: Icons.verified_user_outlined,
                title: 'Verification status',
                subtitle: 'Identitas dan layanan terverifikasi',
              ),
              const _ProfileMenuRow(
                icon: Icons.handyman_outlined,
                title: 'Services offered',
                subtitle: 'Cuci AC, AC bocor, isi freon',
              ),
              _ProfileMenuRow(
                icon: Icons.payments_outlined,
                title: 'Price list',
                subtitle: '3 layanan dengan harga aktif',
                onTap: () => onAction('Price list dibuka.'),
              ),
              const _ProfileMenuRow(
                icon: Icons.map_outlined,
                title: 'Working area',
                subtitle: 'Tebet, Manggarai, Pancoran',
              ),
              const _ProfileMenuRow(
                icon: Icons.schedule_outlined,
                title: 'Working hours',
                subtitle: 'Senin-Sabtu, 08.00-18.00',
              ),
              const _ProfileMenuRow(
                icon: Icons.photo_library_outlined,
                title: 'Work photos',
                subtitle: '8 foto pekerjaan',
              ),
              const _ProfileMenuRow(
                icon: Icons.rate_review_outlined,
                title: 'Reviews',
                subtitle: '124 ulasan pelanggan',
              ),
              const _ProfileMenuRow(
                icon: Icons.account_balance_outlined,
                title: 'Bank/payment settings',
                subtitle: 'BCA **** 2188',
              ),
              const _ProfileMenuRow(
                icon: Icons.settings_outlined,
                title: 'Account settings',
                subtitle: 'Nomor HP, PIN, dan notifikasi',
                last: true,
              ),
            ],
          ),
        ),
        const SectionTitle('Sesi'),
        _MitraLogoutCard(onTap: onLogout),
      ],
    );
  }
}

class _MitraLogoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MitraLogoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      color: const Color(0xFFFFFCFA),
      border: Border.all(color: const Color(0xFFF7D8CF)),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFBE9E2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: AppColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keluar',
                  style: pj(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Keluar dari Dashboard Mitra di perangkat ini',
                  style: pj(fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.danger),
        ],
      ),
    );
  }
}

class _MitraDangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Widget? icon;
  final bool full;

  const _MitraDangerButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 8)],
        Text(
          label,
          style: pj(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: full ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withValues(alpha: .34),
                blurRadius: 18,
                offset: const Offset(0, 6),
                spreadRadius: -6,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SupportTab extends StatelessWidget {
  final VoidCallback onChat;

  const _SupportTab({required this.onChat});

  @override
  Widget build(BuildContext context) {
    return _MitraScrollView(
      children: [
        const _SimpleTitle(
          title: 'Bantuan Mitra',
          subtitle: 'Support pendaftaran, order, dan pembayaran',
        ),
        const SizedBox(height: 14),
        BrCard(
          color: AppColors.primary50,
          border: Border.all(color: AppColors.primary100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tim Beresin siap bantu',
                style: pj(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chat support untuk masalah verifikasi, jadwal, harga, atau pembayaran order.',
                style: pj(fontSize: 13, color: AppColors.ink2, height: 1.45),
              ),
              const SizedBox(height: 14),
              BrButton(
                label: 'Chat Support',
                full: true,
                icon: const Icon(Icons.support_agent_rounded, size: 18),
                onPressed: onChat,
              ),
            ],
          ),
        ),
        const SectionTitle('Topik Cepat'),
        BrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _ProfileMenuRow(
                icon: Icons.verified_outlined,
                title: 'Status verifikasi',
                subtitle: 'Cek dokumen dan alasan tertahan',
              ),
              _ProfileMenuRow(
                icon: Icons.assignment_late_outlined,
                title: 'Masalah order',
                subtitle: 'Customer batal, lokasi salah, atau jadwal berubah',
              ),
              _ProfileMenuRow(
                icon: Icons.wallet_outlined,
                title: 'Pendapatan',
                subtitle: 'Pencairan, rekening bank, dan komisi',
                last: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MitraOrderDetailScreen extends StatelessWidget {
  final MitraOrder order;
  final VoidCallback onBack;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onWhatsapp;
  final VoidCallback onFinalPrice;

  const _MitraOrderDetailScreen({
    required this.order,
    required this.onBack,
    required this.onAccept,
    required this.onDecline,
    required this.onWhatsapp,
    required this.onFinalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _PhoneBody(
        child: _MitraScrollView(
          bottomExtra: 132,
          children: [
            Row(
              children: [
                _RoundButton(icon: Icons.chevron_left_rounded, onTap: onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detail Order',
                    style: pj(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BrCard(
              child: Row(
                children: [
                  Avatar(name: order.customer, size: 50),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customer,
                          style: pj(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 5,
                          children: [
                            Stars(value: order.customerRating, size: 12),
                            _TinyMeta(
                              icon: Icons.place_outlined,
                              text: order.location,
                            ),
                            _TinyMeta(
                              icon: Icons.near_me_outlined,
                              text: order.distance,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SectionTitle('Problem summary'),
            BrCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.service,
                    style: pj(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AiDiagnosis(text: order.diagnosis),
                  const SizedBox(height: 12),
                  Text(
                    order.summary,
                    style: pj(
                      fontSize: 13,
                      color: AppColors.ink2,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 132,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: const [
                          MockACPhoto(),
                          Positioned(
                            left: 10,
                            bottom: 10,
                            child: BrTag(
                              label: 'Foto customer',
                              color: 'neutral',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SectionTitle('Price estimate'),
            BrCard(
              child: Column(
                children: [
                  _DetailLine(
                    label: 'Harga wajar Beresin',
                    value: order.estimate,
                  ),
                  _DetailLine(
                    label: 'Worker price range',
                    value: order.workerRange,
                  ),
                  const _DetailLine(
                    label: 'Status',
                    value: 'Sesuai estimasi',
                    success: true,
                  ),
                ],
              ),
            ),
            const SectionTitle('Schedule'),
            BrCard(
              child: Column(
                children: [
                  _DetailLine(label: 'Jadwal', value: order.schedule),
                  _DetailLine(label: 'ETA', value: order.eta),
                ],
              ),
            ),
            const SectionTitle('Safety note'),
            BrCard(
              color: AppColors.accent50,
              border: Border.all(color: const Color(0xFFFFE0B1)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.accentDark,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Konfirmasi harga sebelum pekerjaan dimulai. Jangan meminta pembayaran penuh sebelum pengecekan.',
                      style: pj(
                        fontSize: 13,
                        color: AppColors.ink2,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _PhoneWidth(
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: .08),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BrButton(
                        label: 'Terima Order',
                        onPressed: onAccept,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BrButton(
                        label: 'Tolak',
                        variant: BrButtonVariant.secondary,
                        onPressed: onDecline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BrButton(
                  label: 'Ajukan Harga Final',
                  variant: BrButtonVariant.secondary,
                  full: true,
                  icon: const Icon(Icons.price_check_rounded, size: 18),
                  onPressed: onFinalPrice,
                ),
                const SizedBox(height: 8),
                BrButton(
                  label: 'Tanya Customer via WhatsApp',
                  variant: BrButtonVariant.ghost,
                  full: true,
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  onPressed: onWhatsapp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AcceptOrderSheet extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  const _AcceptOrderSheet({required this.onAccept, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return _BottomSheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terima order ini?',
            style: pj(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Setelah diterima, customer akan mendapat notifikasi dan kamu diharapkan datang sesuai jadwal.',
            style: pj(fontSize: 13.5, color: AppColors.ink2, height: 1.5),
          ),
          const SizedBox(height: 18),
          BrButton(
            label: 'Ya, Terima Order',
            full: true,
            size: BrButtonSize.lg,
            onPressed: onAccept,
          ),
          const SizedBox(height: 10),
          BrButton(
            label: 'Batal',
            full: true,
            variant: BrButtonVariant.secondary,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

class _SuccessSheet extends StatelessWidget {
  final VoidCallback onDetail;
  final VoidCallback onWhatsapp;

  const _SuccessSheet({required this.onDetail, required this.onWhatsapp});

  @override
  Widget build(BuildContext context) {
    return _BottomSheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Order diterima',
            style: pj(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jangan lupa konfirmasi lewat WhatsApp dan datang sesuai jadwal.',
            textAlign: TextAlign.center,
            style: pj(fontSize: 13.5, color: AppColors.ink2, height: 1.5),
          ),
          const SizedBox(height: 18),
          BrButton(
            label: 'Lihat Detail Order',
            full: true,
            onPressed: onDetail,
          ),
          const SizedBox(height: 10),
          BrButton(
            label: 'Buka WhatsApp Customer',
            full: true,
            variant: BrButtonVariant.whatsapp,
            icon: const Icon(Icons.chat_outlined, size: 18),
            onPressed: onWhatsapp,
          ),
        ],
      ),
    );
  }
}

class _BottomSheetShell extends StatelessWidget {
  final Widget child;

  const _BottomSheetShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final String text;
  final IconData icon;

  const _SoftBadge({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.accentDark),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: pj(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.accentDark,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MitraBottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _MitraBottomNav({required this.activeIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      ['Dashboard', Icons.dashboard_rounded],
      ['Order', Icons.assignment_rounded],
      ['Jadwal', Icons.calendar_month_rounded],
      ['Profil', Icons.person_rounded],
      ['Bantuan', Icons.help_rounded],
    ];
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return _PhoneWidth(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 26, 20, bottomPad > 0 ? 10 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.bg.withValues(alpha: 0),
              AppColors.bg.withValues(alpha: .95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, .45],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: AppColors.line2),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: .12),
                blurRadius: 28,
                offset: const Offset(0, 10),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final active = activeIndex == index;
              final isCenter = index == 2;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(20),
                  child: isCenter
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -34),
                              child: Container(
                                width: 64,
                                height: 64,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: .28,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 11),
                                      spreadRadius: -6,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDark,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Icon(
                                    items[index][1] as IconData,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -28),
                              child: Text(
                                items[index][0] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pj(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                items[index][1] as IconData,
                                size: 28,
                                color: active
                                    ? AppColors.primaryDark
                                    : AppColors.muted,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                items[index][0] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pj(
                                  fontSize: 13.2,
                                  fontWeight: active
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PhoneWidth extends StatelessWidget {
  final Widget child;

  const _PhoneWidth({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: child,
      ),
    );
  }
}

class _PhoneBody extends StatelessWidget {
  final Widget child;

  const _PhoneBody({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 430 ? constraints.maxWidth : 430.0;
        final mediaHeight = MediaQuery.of(context).size.height;
        final height = constraints.maxHeight > 0
            ? constraints.maxHeight
            : mediaHeight;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, height: height, child: child),
        );
      },
    );
  }
}

class _MitraScrollView extends StatelessWidget {
  final List<Widget> children;
  final double bottomExtra;

  const _MitraScrollView({required this.children, this.bottomExtra = 18});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).viewPadding.top + 18,
        18,
        bottomExtra,
      ),
      children: children,
    );
  }
}

class _SimpleTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SimpleTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: pj(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: pj(fontSize: 13.5, color: AppColors.muted)),
      ],
    );
  }
}

enum _StepState { done, active, pending }

class _VerificationStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final _StepState state;
  final bool hasDivider;

  const _VerificationStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.state,
    this.hasDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final done = state == _StepState.done;
    final active = state == _StepState.active;
    final color = done || active ? AppColors.primary : AppColors.muted;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: hasDivider
            ? const Border(bottom: BorderSide(color: AppColors.line2))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBubble(
            icon: icon,
            bg: done || active ? AppColors.primary50 : const Color(0xFFF1F4F1),
            fg: color,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: pj(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: pj(
                    fontSize: 12.3,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            done
                ? Icons.check_circle_rounded
                : active
                ? Icons.timelapse_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 22,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _ProfileCheck extends StatelessWidget {
  final String label;
  final bool done;

  const _ProfileCheck({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            size: 18,
            color: done ? AppColors.primary : AppColors.warn,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: pj(fontSize: 12.8, color: AppColors.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBubble(
            icon: icon,
            bg: AppColors.primary50,
            fg: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: pj(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;

  const _IconBubble({required this.icon, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 21, color: fg),
    );
  }
}

class _TinyMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TinyMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(
          text,
          style: pj(
            fontSize: 11.8,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;

  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: pj(fontSize: 12.5, color: AppColors.ink2)),
          ),
        ],
      ),
    );
  }
}

class _AiDiagnosis extends StatelessWidget {
  final String text;

  const _AiDiagnosis({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI diagnosis: $text',
              style: pj(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final bool success;

  const _DetailLine({
    required this.label,
    required this.value,
    this.success = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: pj(fontSize: 12.5, color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: pj(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: success ? AppColors.primary : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool last;

  const _ProfileMenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.line2)),
        ),
        child: Row(
          children: [
            _IconBubble(
              icon: icon,
              bg: AppColors.primary50,
              fg: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: pj(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pj(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, color: AppColors.ink),
      ),
    );
  }
}
