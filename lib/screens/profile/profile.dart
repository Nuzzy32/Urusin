import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/app_repository.dart';
import '../../theme.dart';
import '../../widgets.dart';

class ProfileScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final bool isWorkerMode;

  const ProfileScreen({super.key, required this.go, this.isWorkerMode = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Customer Beresin';
  String _phone = '';
  int _bookingCount = 0;
  int _workerCount = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      return; // demo tanpa Supabase
    }
    final user = client.auth.currentUser;
    if (user == null) return;
    client
        .from('users')
        .select('role')
        .eq('user_id', user.id)
        .maybeSingle()
        .then((row) {
          if (mounted && row?['role'] == 'admin') {
            setState(() => _isAdmin = true);
          }
        })
        .catchError((_) => null);
    final meta = user.userMetadata ?? {};
    final rawName =
        (meta['full_name'] ?? meta['name'] ?? user.email ?? '').toString().trim();
    final bookings = appRepository.bookings();
    setState(() {
      _name = rawName.isNotEmpty ? rawName : 'Customer Beresin';
      _phone =
          user.phone ??
          (meta['phone'] as String?) ??
          (meta['phone_number'] as String?) ??
          '';
      _bookingCount = bookings.length;
      _workerCount = bookings.map((b) => b.workerId).toSet().length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = [
      _ProfileMenuItem(
        icon: Icons.location_on_outlined,
        title: 'Alamat tersimpan',
        subtitle: '2 alamat',
        route: 'profileAddresses',
      ),
      _ProfileMenuItem(
        icon: Icons.payments_outlined,
        title: 'Riwayat harga',
        subtitle: 'Lihat estimasi vs aktual',
        route: 'profilePrices',
      ),
      _ProfileMenuItem(
        icon: Icons.bookmark_border,
        title: 'Tukang tersimpan',
        subtitle: '3 tukang',
        route: 'profileSavedWorkers',
      ),
      _ProfileMenuItem(
        icon: Icons.notifications_outlined,
        title: 'Notifikasi',
        subtitle: 'WhatsApp & in-app',
        route: 'profileNotifications',
      ),
      _ProfileMenuItem(
        icon: Icons.shield_outlined,
        title: 'Keamanan & privasi',
        subtitle: 'PIN, verifikasi nomor',
        route: 'profileSecurity',
      ),
    ];
    final help = [
      _ProfileMenuItem(
        icon: Icons.auto_awesome,
        title: 'Kenapa Beresin?',
        subtitle: 'Cara kerja AI & tukang',
        route: 'profileWhy',
      ),
      _ProfileMenuItem(
        icon: Icons.phone,
        title: 'Hubungi support',
        subtitle: 'Senin-Sabtu 09-20',
        route: 'profileSupport',
      ),
    ];

    final navBottom = MediaQuery.of(context).padding.bottom + 120;
    return ListView(
      padding: EdgeInsets.only(bottom: navBottom),
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0E8E6C), Color(0xFF0A6E54)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(18, 54, 18, 60),
          child: Row(
            children: [
              Avatar(
                name: _name.isEmpty ? 'C' : _name,
                size: 64,
                palette: const [
                  [Color(0xFFFFD89B), Color(0xFFF59E3C)],
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: pj(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_phone.isNotEmpty)
                      Text(
                        _phone,
                        style: pj(
                          color: Colors.white.withValues(alpha: .75),
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 10,
                            color: Color(0xFFFFD89B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.isWorkerMode
                                ? 'MITRA TERVERIFIKASI'
                                : 'BERESIN USER',
                            style: pj(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -42),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      _Stat(
                        '$_bookingCount',
                        widget.isWorkerMode ? 'Order' : 'Layanan',
                      ),
                      _DividerV(),
                      _Stat(
                        '$_workerCount',
                        widget.isWorkerMode ? 'Rating' : 'Tukang',
                      ),
                      _DividerV(),
                      _Stat(
                        widget.isWorkerMode ? '-' : '-',
                        widget.isWorkerMode ? 'Bulan ini' : 'Hemat',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _RoleSwitcherCard(isWorkerMode: widget.isWorkerMode, go: widget.go),
                if (_isAdmin) ...[
                  const SizedBox(height: 12),
                  BrButton(
                    label: 'Panel Admin',
                    full: true,
                    variant: BrButtonVariant.secondary,
                    icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                    onPressed: () => widget.go('admin'),
                  ),
                ],
                const SectionTitle('Akun'),
                _MenuList(items: account, go: widget.go),
                const SectionTitle('Bantuan'),
                _MenuList(items: help, go: widget.go),
                const SectionTitle('Sesi'),
                _LogoutCard(
                  modeLabel: widget.isWorkerMode ? 'Mitra' : 'Customer',
                  onTap: () => _showLogoutSheet(context, widget.go),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Beresin · v1.0 hackathon · made with care in Jakarta',
                    style: pj(fontSize: 11, color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void _showLogoutSheet(
  BuildContext context,
  void Function(String, [Map<String, dynamic>?]) go,
) {
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
                      'Keluar dari Beresin?',
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
                'Kamu bisa masuk lagi kapan saja dengan nomor HP yang sama.',
                style: pj(fontSize: 13, color: AppColors.muted, height: 1.45),
              ),
              const SizedBox(height: 16),
              _DangerButton(
                label: 'Ya, Keluar',
                full: true,
                icon: const Icon(Icons.logout_rounded, size: 18),
                onPressed: () {
                  Navigator.pop(context);
                  go('login');
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

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Widget? icon;
  final bool full;

  const _DangerButton({
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

class _LogoutCard extends StatelessWidget {
  final String modeLabel;
  final VoidCallback onTap;

  const _LogoutCard({required this.modeLabel, required this.onTap});

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
                  'Keluar dari mode $modeLabel di perangkat ini',
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

class _RoleSwitcherCard extends StatelessWidget {
  final bool isWorkerMode;
  final void Function(String, [Map<String, dynamic>?]) go;

  const _RoleSwitcherCard({required this.isWorkerMode, required this.go});

  @override
  Widget build(BuildContext context) {
    final title = isWorkerMode
        ? 'Mode saat ini: Mitra'
        : 'Mode saat ini: Customer';
    final description = isWorkerMode
        ? 'Kamu sedang mengelola order dan profil layanan.'
        : 'Kamu sedang memakai Beresin untuk mencari layanan.';
    final cta = isWorkerMode
        ? 'Beralih ke Mode Customer'
        : 'Beralih ke Mode Mitra';
    final icon = isWorkerMode ? Icons.handyman_outlined : Icons.home_outlined;
    return BrCard(
      padding: const EdgeInsets.all(14),
      gradient: LinearGradient(
        colors: isWorkerMode
            ? const [Color(0xFFFFF8EE), Color(0xFFFFFFFF)]
            : const [AppColors.primary50, Color(0xFFFFFFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: isWorkerMode ? const Color(0xFFFFE9C2) : AppColors.primary100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isWorkerMode
                      ? AppColors.accentDark
                      : AppColors.primaryDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pj(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: pj(
                        fontSize: 11.8,
                        color: AppColors.muted,
                        height: 1.35,
                      ),
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
            variant: isWorkerMode
                ? BrButtonVariant.secondary
                : BrButtonVariant.primary,
            onPressed: () => go(isWorkerMode ? 'home' : 'workerDashboard'),
          ),
          if (!isWorkerMode) ...[
            const SizedBox(height: 8),
            BrButton(
              label: 'Daftar jadi Mitra',
              full: true,
              size: BrButtonSize.sm,
              variant: BrButtonVariant.secondary,
              onPressed: () => go('workerOnboarding1'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: pj(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          Text(label, style: pj(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _DividerV extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.line);
}

class _MenuList extends StatelessWidget {
  final List<_ProfileMenuItem> items;
  final void Function(String, [Map<String, dynamic>?]) go;

  const _MenuList({required this.items, required this.go});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => go(item.route),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: i < items.length - 1
                        ? const BorderSide(color: AppColors.line2)
                        : BorderSide.none,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 16, color: AppColors.ink2),
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
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            item.subtitle,
                            style: pj(fontSize: 11, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
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
