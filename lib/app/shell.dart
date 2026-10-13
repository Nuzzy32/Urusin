import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';

class AppShell extends StatelessWidget {
  final String location;
  final Widget child;

  const AppShell({super.key, required this.location, required this.child});

  String get _active {
    if (location == '/') return 'home';
    if (location.startsWith('/check') ||
        location.startsWith('/analysis') ||
        location.startsWith('/price-check')) {
      return 'check';
    }
    if (location.startsWith('/workers/recommended')) return 'check';
    if (location.startsWith('/workers') || location.startsWith('/booking')) {
      return 'workers';
    }
    if (location.startsWith('/history') || location.startsWith('/review')) {
      return 'history';
    }
    if (location.startsWith('/profile')) return 'profile';
    return 'home';
  }

  bool get _showNav {
    // AI flow immersive screens
    const hideNavPaths = {
      '/check/analyzing',
      '/check/symptoms',
      '/check/follow-up',
    };
    if (hideNavPaths.contains(location)) return false;
    // Worker profile detail (/workers/:id) — bukan /workers atau /workers/recommended
    if (location.startsWith('/workers/') &&
        location != '/workers/recommended') {
      return false;
    }
    // Booking detail pages (/booking/:id, /booking/:id/confirmation, /booking/:id/status)
    if (location.startsWith('/booking/')) return false;
    return true;
  }

  void _onNav(BuildContext context, String key) {
    switch (key) {
      case 'home':
        context.goNamed('home');
        break;
      case 'check':
        context.goNamed('upload');
        break;
      case 'workers':
        context.goNamed('workers');
        break;
      case 'history':
        context.goNamed('history');
        break;
      case 'profile':
        context.goNamed('profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _showNav ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            Positioned.fill(child: child),
            if (_showNav)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomNav(
                  active: _active,
                  onChange: (key) => _onNav(context, key),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final String active;
  final void Function(String) onChange;

  const _BottomNav({required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const items = [
      ['home', 'Beranda', Icons.home_rounded, Icons.home_outlined],
      ['workers', 'Tukang', Icons.people_rounded, Icons.people_outline],
      ['check', 'Cek', Icons.camera_alt, Icons.camera_alt_outlined],
      ['history', 'Riwayat', Icons.history_rounded, Icons.history],
      ['profile', 'Profil', Icons.person, Icons.person_outline],
    ];
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 30, 20, bottomPad > 0 ? 10 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bg.withValues(alpha: 0),
            AppColors.bg.withValues(alpha: .94),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, .45],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
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
              BoxShadow(
                color: Colors.white.withValues(alpha: .9),
                blurRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: items.map((it) {
              final key = it[0] as String;
              final label = it[1] as String;
              final iconActive = it[2] as IconData;
              final iconInactive = it[3] as IconData;
              final isActive = active == key;
              final isFab = key == 'check';
              return Expanded(
                child: InkWell(
                  onTap: () => onChange(key),
                  borderRadius: BorderRadius.circular(20),
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                  child: isFab
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
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: isActive
                                          ? [AppColors.accent, Color(0xFFE37614)]
                                          : [AppColors.primary, AppColors.primaryDark],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -28),
                              child: Text(
                                label,
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
                          child: Builder(
                            builder: (context) {
                              final reduce = MediaQuery.of(context).disableAnimations;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedScale(
                                    scale: isActive ? 1.12 : 1.0,
                                    duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    child: Icon(
                                      isActive ? iconActive : iconInactive,
                                      size: 28,
                                      color: isActive
                                          ? AppColors.primaryDark
                                          : AppColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: pj(
                                      fontSize: 13.5,
                                      fontWeight: isActive
                                          ? FontWeight.w900
                                          : FontWeight.w600,
                                      color: isActive
                                          ? AppColors.primary
                                          : AppColors.muted,
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: reduce ? Duration.zero : const Duration(milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    width: isActive ? 18.0 : 0.0,
                                    height: 3,
                                    margin: const EdgeInsets.only(top: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryDark,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
