import 'package:flutter/material.dart';

import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../../widgets/whatsapp_lead_sheet.dart';

class SavedAddressesScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const SavedAddressesScreen({super.key, required this.go});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddress {
  final String label;
  final String phone;
  final String address;
  final String access;
  final bool primary;

  const _SavedAddress({
    required this.label,
    required this.phone,
    required this.address,
    required this.access,
    required this.primary,
  });

  _SavedAddress copyWith({
    String? label,
    String? phone,
    String? address,
    String? access,
    bool? primary,
  }) {
    return _SavedAddress(
      label: label ?? this.label,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      access: access ?? this.access,
      primary: primary ?? this.primary,
    );
  }
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  late List<_SavedAddress> addresses = const [
    _SavedAddress(
      label: 'Rumah',
      phone: '+62 812-3456-7890',
      address: 'Jl. Tebet Barat Dalam IV No. 12, RT 03, Tebet, Jakarta Selatan',
      access: 'Rumah pagar hitam, tekan bel kanan.',
      primary: true,
    ),
    _SavedAddress(
      label: 'Kos',
      phone: '+62 812-8888-2040',
      address: 'Jl. Saharjo No. 88, Jakarta Selatan',
      access: 'Lantai 2, kamar 204.',
      primary: false,
    ),
  ];

  Future<void> _openAddressSheet({_SavedAddress? address, int? index}) async {
    final saved = await _showAddressSheet(context, address: address);
    if (saved == null || !mounted) return;
    setState(() {
      if (index == null) {
        addresses = [
          ...addresses.map((item) => item.copyWith(primary: false)),
          saved.copyWith(primary: addresses.isEmpty),
        ];
      } else {
        addresses[index] = saved.copyWith(primary: addresses[index].primary);
      }
    });
    _showToast(context, 'Alamat ${saved.label} tersimpan.');
  }

  void _setPrimary(int index) {
    setState(() {
      addresses = [
        for (var i = 0; i < addresses.length; i++)
          addresses[i].copyWith(primary: i == index),
      ];
    });
    _showToast(context, '${addresses[index].label} dijadikan alamat utama.');
  }

  void _deleteAddress(int index) {
    final removed = addresses[index];
    setState(() {
      addresses = [...addresses]..removeAt(index);
      if (!addresses.any((item) => item.primary) && addresses.isNotEmpty) {
        addresses[0] = addresses[0].copyWith(primary: true);
      }
    });
    _showToast(context, 'Alamat ${removed.label} dihapus dari daftar.');
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileFlowScaffold(
      title: 'Alamat Tersimpan',
      subtitle: 'Kelola alamat yang sering kamu pakai untuk booking layanan.',
      onBack: () => widget.go('profile'),
      children: [
        for (var i = 0; i < addresses.length; i++) ...[
          _AddressCard(
            address: addresses[i],
            onEdit: () => _openAddressSheet(address: addresses[i], index: i),
            onDelete: () => _deleteAddress(i),
            onSetPrimary: addresses[i].primary ? null : () => _setPrimary(i),
          ),
          const SizedBox(height: 12),
        ],
        BrButton(
          label: 'Tambah Alamat Baru',
          full: true,
          size: BrButtonSize.lg,
          icon: const Icon(
            Icons.add_location_alt,
            color: Colors.white,
            size: 18,
          ),
          onPressed: _openAddressSheet,
        ),
      ],
    );
  }
}

class PriceHistoryScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const PriceHistoryScreen({super.key, required this.go});

  @override
  Widget build(BuildContext context) {
    const records = [
      _PriceRecord(
        service: 'Cuci AC',
        worker: 'Pak Rudi',
        estimate: 'Rp75.000-Rp150.000',
        actual: 'Rp95.000',
        status: 'Sesuai estimasi',
        date: '12 Apr 2026',
        kind: 'AC',
      ),
      _PriceRecord(
        service: 'Bersih rumah 2BR',
        worker: 'Bu Sari Clean',
        estimate: 'Rp180.000-Rp280.000',
        actual: 'Rp220.000',
        status: 'Sesuai estimasi',
        date: '2 Apr 2026',
        kind: 'Cleaning',
      ),
      _PriceRecord(
        service: 'Perbaikan pipa',
        worker: 'Pak Dedi',
        estimate: 'Rp75.000-Rp200.000',
        actual: 'Rp140.000',
        status: 'Sesuai estimasi',
        date: '14 Mar 2026',
        kind: 'Plumbing',
      ),
    ];

    return _ProfileFlowScaffold(
      title: 'Riwayat Harga',
      subtitle:
          'Bandingkan estimasi Beresin dengan harga aktual yang kamu bayar.',
      onBack: () => go('profile'),
      children: [
        Row(
          children: const [
            Expanded(
              child: _MetricCard(value: '~Rp420rb', label: 'Total hemat'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _MetricCard(value: '12', label: 'Transaksi tercatat'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _MetricCard(value: '86%', label: 'Akurasi estimasi'),
            ),
          ],
        ),
        const SectionTitle('Layanan sebelumnya'),
        ...records.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PriceRecordCard(record: item),
          ),
        ),
        BrCard(
          padding: const EdgeInsets.all(14),
          color: AppColors.primary50,
          border: Border.all(color: AppColors.primary100),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.insights_outlined, color: AppColors.primaryDark),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insight Beresin',
                      style: pj(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selama 3 bulan terakhir, harga aktual kamu 86% sesuai dengan estimasi Beresin.',
                      style: pj(
                        fontSize: 12.5,
                        color: AppColors.ink2,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BrButton(
          label: 'Lihat Detail Penghematan',
          full: true,
          iconRight: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => showSavingsDetailSheet(context),
        ),
      ],
    );
  }
}

class SavedWorkersScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const SavedWorkersScreen({super.key, required this.go});

  @override
  State<SavedWorkersScreen> createState() => _SavedWorkersScreenState();
}

class _SavedWorkersScreenState extends State<SavedWorkersScreen> {
  final savedIds = <String>{'rudi', 'sari', 'dedi'};

  @override
  Widget build(BuildContext context) {
    final workers = kWorkers
        .where((worker) => ['rudi', 'sari', 'dedi'].contains(worker.id))
        .toList();
    final lastUsed = {
      'rudi': 'Terakhir dipakai 12 Apr',
      'sari': 'Terakhir dipakai 2 Apr',
      'dedi': 'Terakhir dipakai 14 Mar',
    };

    return _ProfileFlowScaffold(
      title: 'Tukang Tersimpan',
      subtitle: 'Tukang langganan yang kamu simpan untuk dipanggil lagi.',
      onBack: () => widget.go('profile'),
      children: [
        for (final worker in workers)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SavedWorkerCard(
              worker: worker,
              lastUsed: lastUsed[worker.id] ?? 'Terakhir dipakai bulan ini',
              saved: savedIds.contains(worker.id),
              onToggleSaved: () {
                setState(() {
                  if (savedIds.contains(worker.id)) {
                    savedIds.remove(worker.id);
                  } else {
                    savedIds.add(worker.id);
                  }
                });
                _showToast(
                  context,
                  savedIds.contains(worker.id)
                      ? '${worker.name} disimpan lagi.'
                      : '${worker.name} dihapus dari tersimpan.',
                );
              },
              onTap: () => widget.go('worker', {'workerId': worker.id, 'from': 'profileSavedWorkers'}),
              onBook: () => widget.go('booking', {'workerId': worker.id, 'from': 'profileSavedWorkers'}),
              onAsk: () =>
                  showWhatsappLeadSheet(context: context, worker: worker),
            ),
          ),
      ],
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const NotificationSettingsScreen({super.key, required this.go});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final values = <String, bool>{
    'WhatsApp': true,
    'Push Notification': true,
    'Email': false,
    'Status booking': true,
    'Reminder jadwal': true,
    'Promo sekitar kamu': true,
    'Tips perawatan rumah': false,
    'Review setelah layanan': true,
    'Keamanan akun': true,
    'Jangan ganggu': true,
  };

  void _toggle(String key, bool value) {
    setState(() => values[key] = value);
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileFlowScaffold(
      title: 'Notifikasi',
      subtitle: 'Atur cara Beresin mengingatkan kamu.',
      onBack: () => widget.go('profile'),
      children: [
        const SectionTitle('Channel Notifikasi'),
        _ToggleCard(
          items: [
            _ToggleItemData(
              title: 'WhatsApp',
              description: 'Reminder booking dan status layanan',
              value: values['WhatsApp']!,
              onChanged: (value) => _toggle('WhatsApp', value),
            ),
            _ToggleItemData(
              title: 'Push Notification',
              description: 'Update real-time dari aplikasi',
              value: values['Push Notification']!,
              onChanged: (value) => _toggle('Push Notification', value),
            ),
            _ToggleItemData(
              title: 'Email',
              description: 'Kwitansi dan ringkasan layanan',
              value: values['Email']!,
              onChanged: (value) => _toggle('Email', value),
            ),
          ],
        ),
        const SectionTitle('Jenis Notifikasi'),
        _ToggleCard(
          items: [
            for (final key in [
              'Status booking',
              'Reminder jadwal',
              'Promo sekitar kamu',
              'Tips perawatan rumah',
              'Review setelah layanan',
              'Keamanan akun',
            ])
              _ToggleItemData(
                title: key,
                value: values[key]!,
                onChanged: (value) => _toggle(key, value),
              ),
          ],
        ),
        const SectionTitle('Quiet hours'),
        _ToggleCard(
          items: [
            _ToggleItemData(
              title: 'Jangan ganggu',
              description: '22.00-07.00',
              value: values['Jangan ganggu']!,
              onChanged: (value) => _toggle('Jangan ganggu', value),
            ),
          ],
        ),
        const SizedBox(height: 14),
        BrButton(
          label: 'Simpan Pengaturan',
          full: true,
          icon: const Icon(Icons.check, color: Colors.white, size: 18),
          onPressed: () =>
              _showToast(context, 'Pengaturan notifikasi tersimpan.'),
        ),
      ],
    );
  }
}

class SecurityPrivacyScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const SecurityPrivacyScreen({super.key, required this.go});

  @override
  Widget build(BuildContext context) {
    return _ProfileFlowScaffold(
      title: 'Keamanan & Privasi',
      subtitle: 'Kontrol keamanan akun dan data layananmu.',
      onBack: () => go('profile'),
      children: [
        const SectionTitle('Keamanan Akun'),
        _ActionListCard(
          items: [
            _ActionItemData(
              icon: Icons.verified_user_outlined,
              title: 'Verifikasi nomor HP',
              status: 'Terverifikasi',
              onTap: () => showInfoSheet(
                context,
                title: 'Nomor HP terverifikasi',
                body:
                    'Nomor +62 812-3456-7890 sudah aktif untuk login, WhatsApp booking, dan pemulihan akun.',
              ),
            ),
            _ActionItemData(
              icon: Icons.lock_outline,
              title: 'PIN aplikasi',
              status: 'Aktif',
              onTap: () => showPinSheet(context),
            ),
            _ActionItemData(
              icon: Icons.devices_outlined,
              title: 'Login perangkat',
              description: '1 perangkat aktif',
              onTap: () => showInfoSheet(
                context,
                title: 'Perangkat aktif',
                body:
                    'iPhone Wira masuk terakhir hari ini pukul 10.18. Belum ada perangkat lain yang aktif.',
              ),
            ),
            _ActionItemData(
              icon: Icons.phone_android_outlined,
              title: 'Ubah nomor HP',
              onTap: () => showInfoSheet(
                context,
                title: 'Ubah nomor HP',
                body:
                    'Kami akan mengirim kode OTP ke nomor baru sebelum mengganti nomor utama akun.',
                cta: 'Kirim OTP',
              ),
            ),
          ],
        ),
        const SectionTitle('Privasi Data'),
        _ActionListCard(
          items: [
            _ActionItemData(
              icon: Icons.location_on_outlined,
              title: 'Data alamat',
              description: 'Digunakan hanya untuk booking layanan',
              onTap: () => showInfoSheet(
                context,
                title: 'Data alamat',
                body:
                    'Alamat lengkap hanya ditampilkan saat kamu mengonfirmasi booking. Sebelum itu tukang hanya melihat area umum.',
              ),
            ),
            _ActionItemData(
              icon: Icons.receipt_long_outlined,
              title: 'Riwayat layanan',
              description: 'Membantu estimasi harga lebih akurat',
              onTap: () => showInfoSheet(
                context,
                title: 'Riwayat layanan',
                body:
                    'Riwayat dipakai untuk membuat rekomendasi harga dan memudahkan kamu booking tukang langganan.',
              ),
            ),
            _ActionItemData(
              icon: Icons.my_location_outlined,
              title: 'Izin lokasi',
              status: 'Aktif saat digunakan',
              onTap: () => _showToast(
                context,
                'Izin lokasi bisa diubah dari pengaturan perangkat.',
              ),
            ),
            _ActionItemData(
              icon: Icons.photo_camera_outlined,
              title: 'Izin kamera',
              status: 'Aktif saat upload foto',
              onTap: () => _showToast(
                context,
                'Izin kamera dipakai saat kamu upload foto masalah.',
              ),
            ),
          ],
        ),
        const SectionTitle('Safety controls'),
        _ActionListCard(
          items: [
            _ActionItemData(
              icon: Icons.block_outlined,
              title: 'Blokir tukang',
              onTap: () => showInfoSheet(
                context,
                title: 'Blokir tukang',
                body:
                    'Kamu belum memblokir tukang. Setelah diblokir, tukang tidak akan muncul di rekomendasi dan tidak bisa menerima booking kamu.',
              ),
            ),
            _ActionItemData(
              icon: Icons.report_problem_outlined,
              title: 'Laporkan masalah keamanan',
              onTap: () => showInfoSheet(
                context,
                title: 'Laporan keamanan',
                body:
                    'Tim safety Beresin akan meninjau laporan prioritas dalam 1x24 jam.',
                cta: 'Buat Laporan',
              ),
            ),
            _ActionItemData(
              icon: Icons.delete_outline,
              title: 'Hapus akun',
              danger: true,
              onTap: () => showDeleteAccountSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BrCard(
          padding: const EdgeInsets.all(14),
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
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Beresin tidak membagikan alamat lengkap ke tukang sebelum booking dikonfirmasi.',
                  style: pj(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8A5A14),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WhyBeresinScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const WhyBeresinScreen({super.key, required this.go});

  @override
  Widget build(BuildContext context) {
    const cards = [
      _WhyCardData(
        icon: Icons.auto_awesome,
        title: 'AI bantu cek masalah',
        text:
            'Upload foto atau jelaskan gejala. Beresin AI membantu mengenali jenis masalah dan tukang yang dibutuhkan.',
      ),
      _WhyCardData(
        icon: Icons.payments_outlined,
        title: 'Harga lebih transparan',
        text:
            'Kami menampilkan estimasi harga wajar berdasarkan jenis layanan, area, dan riwayat harga aktual.',
      ),
      _WhyCardData(
        icon: Icons.verified_user_outlined,
        title: 'Tukang lebih terpercaya',
        text:
            'Profil tukang menampilkan rating, riwayat pekerjaan, verifikasi, dan ulasan warga sekitar.',
      ),
      _WhyCardData(
        icon: Icons.history_rounded,
        title: 'Riwayat tersimpan',
        text:
            'Booking, estimasi, harga aktual, dan review tersimpan agar kamu bisa memanggil tukang favorit lagi.',
      ),
    ];

    return _ProfileFlowScaffold(
      title: 'Kenapa Beresin?',
      subtitle: 'Cara Beresin membantu kamu menemukan tukang lokal terpercaya.',
      onBack: () => go('profile'),
      children: [
        for (final card in cards)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _WhyCard(data: card),
          ),
        const SectionTitle('Alur layanan'),
        BrCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _FlowStep(
                index: 1,
                label: 'Foto masalah',
                icon: Icons.photo_camera_outlined,
              ),
              _FlowStep(
                index: 2,
                label: 'AI analisis',
                icon: Icons.auto_awesome,
              ),
              _FlowStep(
                index: 3,
                label: 'Estimasi harga',
                icon: Icons.payments_outlined,
              ),
              _FlowStep(
                index: 4,
                label: 'Pilih tukang',
                icon: Icons.people_outline,
              ),
              _FlowStep(
                index: 5,
                label: 'Booking',
                icon: Icons.event_available_outlined,
              ),
              _FlowStep(
                index: 6,
                label: 'Review',
                icon: Icons.star_border_rounded,
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BrButton(
          label: 'Cek Masalah Sekarang',
          full: true,
          size: BrButtonSize.lg,
          icon: const Icon(
            Icons.camera_alt_outlined,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => go('upload'),
        ),
      ],
    );
  }
}

class SupportScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const SupportScreen({super.key, required this.go});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String selectedIssue = '';

  @override
  Widget build(BuildContext context) {
    const issues = [
      'Booking bermasalah',
      'Tukang belum datang',
      'Harga tidak sesuai',
      'Ingin refund booking fee',
      'Laporkan tukang',
      'Masalah akun',
    ];

    return _ProfileFlowScaffold(
      title: 'Hubungi Support',
      subtitle:
          'Kami siap bantu untuk booking, pembayaran, atau kendala layanan.',
      onBack: () => widget.go('profile'),
      children: [
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
                  Icons.support_agent,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support aktif',
                      style: pj(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Senin-Sabtu, 09.00-20.00',
                      style: pj(
                        color: Colors.white.withValues(alpha: .78),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const BrTag(
                label: 'Online',
                fgOverride: Colors.white,
                bgOverride: Color(0x3325D366),
              ),
            ],
          ),
        ),
        const SectionTitle('Pilih kendala cepat'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: issues
              .map(
                (issue) => BrChip(
                  label: issue,
                  active: issue == selectedIssue,
                  variant: 'primary',
                  onTap: () => setState(() => selectedIssue = issue),
                ),
              )
              .toList(),
        ),
        const SectionTitle('Kontak'),
        _SupportOption(
          icon: Icons.chat,
          title: 'WhatsApp Support',
          description: 'Respon tercepat',
          cta: 'Chat WhatsApp',
          variant: BrButtonVariant.whatsapp,
          onPressed: () => showSupportWhatsappSheet(context, selectedIssue),
        ),
        const SizedBox(height: 10),
        _SupportOption(
          icon: Icons.confirmation_number_outlined,
          title: 'Buat Tiket Bantuan',
          description: 'Untuk masalah yang perlu dicek lebih lanjut',
          cta: 'Buat Tiket',
          onPressed: () =>
              showTicketSheet(context, initialCategory: selectedIssue),
        ),
        const SizedBox(height: 10),
        _SupportOption(
          icon: Icons.help_outline,
          title: 'Pusat Bantuan',
          description: 'Baca pertanyaan umum',
          cta: 'Lihat FAQ',
          variant: BrButtonVariant.secondary,
          onPressed: () => showFaqSheet(context),
        ),
      ],
    );
  }
}

class _ProfileFlowScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final List<Widget> children;

  const _ProfileFlowScaffold({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final navBottom = MediaQuery.of(context).padding.bottom + 120;
    return FloatingBackScaffold(
      onBack: onBack,
      child: ListView(
        padding: EdgeInsets.only(bottom: navBottom),
        children: [
          ScreenHeader(title: title, subtitle: 'Profil', onBack: () {}),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: pj(
                    fontSize: 13.5,
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                ...children,
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final _SavedAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetPrimary;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryDark,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        address.label,
                        overflow: TextOverflow.ellipsis,
                        style: pj(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (address.primary) ...[
                      const SizedBox(width: 8),
                      const BrTag(label: 'Utama', color: 'success'),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address.address,
            style: pj(fontSize: 12.8, color: AppColors.ink2, height: 1.45),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.notes_outlined,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address.access,
                  style: pj(fontSize: 12, color: AppColors.muted, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniAction(
                label: 'Edit',
                icon: Icons.edit_outlined,
                onTap: onEdit,
              ),
              _MiniAction(
                label: 'Hapus',
                icon: Icons.delete_outline,
                danger: true,
                onTap: onDelete,
              ),
              if (onSetPrimary != null)
                _MiniAction(
                  label: 'Jadikan utama',
                  icon: Icons.push_pin_outlined,
                  onTap: onSetPrimary!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRecord {
  final String service;
  final String worker;
  final String estimate;
  final String actual;
  final String status;
  final String date;
  final String kind;

  const _PriceRecord({
    required this.service,
    required this.worker,
    required this.estimate,
    required this.actual,
    required this.status,
    required this.date,
    required this.kind,
  });
}

class _PriceRecordCard extends StatelessWidget {
  final _PriceRecord record;

  const _PriceRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceIcon(kind: record.kind, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.service,
                        style: pj(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      record.date,
                      style: pj(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  record.worker,
                  style: pj(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PricePill(
                        label: 'Estimasi',
                        value: record.estimate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PricePill(
                        label: 'Aktual',
                        value: record.actual,
                        strong: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                BrTag(
                  label: record.status,
                  color: 'success',
                  icon: const Icon(
                    Icons.check_circle,
                    size: 12,
                    color: Color(0xFF0F7A45),
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

class _PricePill extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _PricePill({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: strong ? AppColors.primary50 : AppColors.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: pj(fontSize: 10.5, color: AppColors.muted)),
          const SizedBox(height: 2),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: pj(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: strong ? AppColors.primaryDark : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 13),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: pj(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: pj(
              fontSize: 10.3,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedWorkerCard extends StatelessWidget {
  final Worker worker;
  final String lastUsed;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onBook;
  final VoidCallback onAsk;
  final VoidCallback onToggleSaved;

  const _SavedWorkerCard({
    required this.worker,
    required this.lastUsed,
    required this.saved,
    required this.onTap,
    required this.onBook,
    required this.onAsk,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: BrCard(
          padding: const EdgeInsets.all(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: .10),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -16,
            ),
          ],
          child: Column(
            children: [
              Row(
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
                                  fontSize: 15,
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
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Stars(value: worker.rating, size: 12),
                            _InlineMeta(
                              icon: Icons.task_alt,
                              text: '${worker.jobsDone} selesai',
                            ),
                            _InlineMeta(
                              icon: Icons.location_on_outlined,
                              text: '${worker.distance} km',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _IconTap(
                    icon: saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? AppColors.primary : AppColors.muted,
                    onTap: onToggleSaved,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lastUsed,
                  style: pj(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BrButton(
                      label: 'Booking Lagi',
                      size: BrButtonSize.sm,
                      full: true,
                      onPressed: onBook,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BrButton(
                      label: 'Tanya',
                      size: BrButtonSize.sm,
                      full: true,
                      variant: BrButtonVariant.whatsapp,
                      icon: const Icon(
                        Icons.chat,
                        color: Colors.white,
                        size: 14,
                      ),
                      onPressed: onAsk,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InlineMeta({required this.icon, required this.text});

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

class _ToggleItemData {
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItemData({
    required this.title,
    this.description,
    required this.value,
    required this.onChanged,
  });
}

class _ToggleCard extends StatelessWidget {
  final List<_ToggleItemData> items;

  const _ToggleCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => item.onChanged(!item.value),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: index < items.length - 1
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
                            item.title,
                            style: pj(
                              fontSize: 13.2,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          if (item.description != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.description!,
                              style: pj(
                                fontSize: 11.5,
                                color: AppColors.muted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: item.value,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary100,
                      onChanged: item.onChanged,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ActionItemData {
  final IconData icon;
  final String title;
  final String? description;
  final String? status;
  final bool danger;
  final VoidCallback onTap;

  const _ActionItemData({
    required this.icon,
    required this.title,
    this.description,
    this.status,
    this.danger = false,
    required this.onTap,
  });
}

class _ActionListCard extends StatelessWidget {
  final List<_ActionItemData> items;

  const _ActionListCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final color = item.danger ? AppColors.danger : AppColors.ink;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: index < items.length - 1
                        ? const BorderSide(color: AppColors.line2)
                        : BorderSide.none,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: item.danger
                            ? const Color(0xFFFBE9E2)
                            : AppColors.bg,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        item.icon,
                        size: 17,
                        color: item.danger ? AppColors.danger : AppColors.ink2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: pj(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                          if (item.description != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.description!,
                              style: pj(fontSize: 11.2, color: AppColors.muted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (item.status != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          item.status!,
                          textAlign: TextAlign.right,
                          style: pj(
                            fontSize: 11.2,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _WhyCardData {
  final IconData icon;
  final String title;
  final String text;

  const _WhyCardData({
    required this.icon,
    required this.title,
    required this.text,
  });
}

class _WhyCard extends StatelessWidget {
  final _WhyCardData data;

  const _WhyCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: AppColors.primaryDark, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: pj(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.text,
                  style: pj(
                    fontSize: 12.4,
                    color: AppColors.muted,
                    height: 1.45,
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

class _FlowStep extends StatelessWidget {
  final int index;
  final String label;
  final IconData icon;
  final bool last;

  const _FlowStep({
    required this.index,
    required this.label,
    required this.icon,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary100),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 17),
            ),
            if (!last)
              Container(width: 2, height: 24, color: AppColors.primary100),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 24),
            child: Text(
              '$index. $label',
              style: pj(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String cta;
  final BrButtonVariant variant;
  final VoidCallback onPressed;

  const _SupportOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.cta,
    this.variant = BrButtonVariant.primary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryDark, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pj(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: pj(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BrButton(
            label: cta,
            full: true,
            size: BrButtonSize.sm,
            variant: variant,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool danger;
  final VoidCallback onTap;

  const _MiniAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.primaryDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: danger ? const Color(0xFFFBE9E2) : AppColors.primary50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: pj(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconTap({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

Future<_SavedAddress?> _showAddressSheet(
  BuildContext context, {
  _SavedAddress? address,
}) async {
  final label = TextEditingController(text: address?.label ?? '');
  final phone = TextEditingController(text: address?.phone ?? '+62 ');
  final fullAddress = TextEditingController(text: address?.address ?? '');
  final access = TextEditingController(text: address?.access ?? '');
  String pin = 'Tebet, Jakarta Selatan';

  final result = await showModalBottomSheet<_SavedAddress>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return _SheetFrame(
            title: 'Tambah Alamat',
            child: Column(
              children: [
                _SheetField(
                  controller: label,
                  label: 'Label alamat',
                  hint: 'Rumah, Kos, Kantor',
                ),
                const SizedBox(height: 10),
                _SheetField(
                  controller: phone,
                  label: 'Nomor HP penerima',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                _SheetField(
                  controller: fullAddress,
                  label: 'Alamat lengkap',
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                _SheetField(
                  controller: access,
                  label: 'Detail akses',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setSheetState(
                      () => pin = 'Pin dipasang di Tebet Barat Dalam',
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary100),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: AppColors.primaryDark,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              pin,
                              style: pj(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.primaryDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BrButton(
                  label: 'Simpan Alamat',
                  full: true,
                  onPressed: () {
                    Navigator.of(sheetContext).pop(
                      _SavedAddress(
                        label: label.text.trim().isEmpty
                            ? 'Alamat baru'
                            : label.text.trim(),
                        phone: phone.text.trim(),
                        address: fullAddress.text.trim().isEmpty
                            ? 'Alamat lengkap belum diisi'
                            : fullAddress.text.trim(),
                        access: access.text.trim().isEmpty
                            ? 'Tidak ada catatan akses.'
                            : access.text.trim(),
                        primary: address?.primary ?? false,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );

  label.dispose();
  phone.dispose();
  fullAddress.dispose();
  access.dispose();
  return result;
}

Future<void> showSavingsDetailSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _SheetFrame(
        title: 'Detail Penghematan',
        child: Column(
          children: [
            _DetailLine(label: 'Estimasi pasar 3 bulan', value: 'Rp1.420.000'),
            _DetailLine(label: 'Total aktual dibayar', value: 'Rp1.000.000'),
            _DetailLine(
              label: 'Selisih hemat',
              value: '~Rp420.000',
              highlight: true,
            ),
            const SizedBox(height: 12),
            BrCard(
              padding: const EdgeInsets.all(12),
              color: AppColors.primary50,
              border: Border.all(color: AppColors.primary100),
              child: Text(
                'Penghematan dihitung dari batas atas estimasi area Tebet dibanding harga aktual yang kamu konfirmasi setelah layanan.',
                style: pj(
                  fontSize: 12.2,
                  color: AppColors.primaryDark,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 14),
            BrButton(
              label: 'Mengerti',
              full: true,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required String body,
  String cta = 'Mengerti',
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _SheetFrame(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: pj(fontSize: 13, color: AppColors.ink2, height: 1.5),
            ),
            const SizedBox(height: 16),
            BrButton(
              label: cta,
              full: true,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showPinSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _SheetFrame(
        title: 'PIN aplikasi',
        child: Column(
          children: [
            BrCard(
              padding: const EdgeInsets.all(12),
              color: AppColors.primary50,
              border: Border.all(color: AppColors.primary100),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock,
                    color: AppColors.primaryDark,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'PIN aktif untuk membuka data alamat dan riwayat booking.',
                      style: pj(
                        fontSize: 12.5,
                        color: AppColors.primaryDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BrButton(
              label: 'Ubah PIN',
              full: true,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _showToast(context, 'Alur ubah PIN siap dibuka.');
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showDeleteAccountSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _SheetFrame(
        title: 'Hapus akun?',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akun, alamat, riwayat layanan, dan tukang tersimpan akan masuk antrean penghapusan. Tiket aktif tetap ditangani sampai selesai.',
              style: pj(fontSize: 13, color: AppColors.ink2, height: 1.5),
            ),
            const SizedBox(height: 14),
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
                    label: 'Minta Hapus',
                    variant: BrButtonVariant.accent,
                    full: true,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _showToast(context, 'Permintaan hapus akun dicatat.');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showSupportWhatsappSheet(BuildContext context, String issue) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _SheetFrame(
        title: 'Chat WhatsApp Support',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kami akan membuka chat dengan ringkasan kendala: "$issue". Tim support biasanya membalas dalam beberapa menit saat jam aktif.',
              style: pj(fontSize: 13, color: AppColors.ink2, height: 1.5),
            ),
            const SizedBox(height: 16),
            BrButton(
              label: 'Buka WhatsApp',
              variant: BrButtonVariant.whatsapp,
              full: true,
              icon: const Icon(Icons.chat, color: Colors.white, size: 16),
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _showToast(context, 'Membuka WhatsApp Support untuk $issue.');
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showTicketSheet(
  BuildContext context, {
  required String initialCategory,
}) async {
  final booking = TextEditingController();
  final story = TextEditingController();
  String category = initialCategory;
  bool hasEvidence = false;

  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return _SheetFrame(
            title: 'Buat Tiket Bantuan',
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Kategori masalah',
                  ),
                  items:
                      [
                            'Booking bermasalah',
                            'Tukang belum datang',
                            'Harga tidak sesuai',
                            'Ingin refund booking fee',
                            'Laporkan tukang',
                            'Masalah akun',
                          ]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) setSheetState(() => category = value);
                  },
                ),
                const SizedBox(height: 10),
                _SheetField(
                  controller: booking,
                  label: 'Nomor booking optional',
                  hint: 'BR-2026-0412',
                ),
                const SizedBox(height: 10),
                _SheetField(
                  controller: story,
                  label: 'Ceritakan masalah',
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        setSheetState(() => hasEvidence = !hasEvidence),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: hasEvidence ? AppColors.primary50 : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasEvidence
                              ? AppColors.primary100
                              : AppColors.line,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            hasEvidence
                                ? Icons.check_circle
                                : Icons.upload_file_outlined,
                            color: hasEvidence
                                ? AppColors.primaryDark
                                : AppColors.muted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              hasEvidence
                                  ? 'Bukti/foto siap dilampirkan'
                                  : 'Upload bukti/foto optional',
                              style: pj(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: hasEvidence
                                    ? AppColors.primaryDark
                                    : AppColors.ink2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BrButton(
                  label: 'Kirim Tiket',
                  full: true,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _showToast(
                      context,
                      'Tiket bantuan untuk $category terkirim.',
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );

  booking.dispose();
  story.dispose();
}

Future<void> showFaqSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      const faqs = [
        [
          'Apakah estimasi harga mengikat?',
          'Estimasi adalah rentang wajar. Harga final dikonfirmasi sebelum pekerjaan dimulai.',
        ],
        [
          'Bagaimana kalau tukang tidak datang?',
          'Laporkan dari Riwayat atau Support. Kami bantu follow up dan ganti rekomendasi.',
        ],
        [
          'Apakah bisa refund booking fee?',
          'Bisa jika booking dibatalkan karena tukang tidak datang atau kendala dari pihak layanan.',
        ],
      ];
      return _SheetFrame(
        title: 'Pusat Bantuan',
        child: Column(
          children: [
            for (final item in faqs)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BrCard(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.bg,
                  boxShadow: const [],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item[0],
                        style: pj(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item[1],
                        style: pj(
                          fontSize: 12,
                          color: AppColors.muted,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            BrButton(
              label: 'Tutup FAQ',
              full: true,
              variant: BrButtonVariant.secondary,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      );
    },
  );
}

class _SheetFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom +
        12;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .84,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: .18),
              blurRadius: 32,
              offset: const Offset(0, 14),
              spreadRadius: -14,
            ),
          ],
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
              Text(
                title,
                style: pj(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _SheetField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: pj(fontSize: 13.5, color: AppColors.ink, height: 1.4),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _DetailLine({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primary50 : AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: pj(fontSize: 12.5, color: AppColors.muted),
            ),
          ),
          Text(
            value,
            style: pj(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: highlight ? AppColors.primaryDark : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

void _showToast(BuildContext context, String message) {
  final messenger = context.findAncestorStateOfType<ScaffoldMessengerState>();
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
