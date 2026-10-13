import 'package:flutter/material.dart';
import 'theme.dart';

// ─────────── Press scale wrapper ───────────
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleTo;
  const PressScale({super.key, required this.child, this.onTap, this.scaleTo = 0.95});

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    final reduce = MediaQuery.of(context).disableAnimations;
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: (!reduce && _pressed) ? widget.scaleTo : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

// ─────────── Avatar ───────────
class Avatar extends StatelessWidget {
  final String name;
  final double size;
  final List<List<Color>>? palette;
  const Avatar({super.key, required this.name, this.size = 44, this.palette});

  @override
  Widget build(BuildContext context) {
    final palettes =
        palette ??
        const [
          [Color(0xFF0E8E6C), Color(0xFF1FB18A)],
          [Color(0xFF1F8A5B), Color(0xFF5BC196)],
          [Color(0xFF0A6E54), Color(0xFF3FA683)],
          [Color(0xFFF59E3C), Color(0xFFFFC178)],
          [Color(0xFF3FA683), Color(0xFF7DD0AC)],
          [Color(0xFF146F58), Color(0xFF4DAC8E)],
        ];
    final i = (name.codeUnitAt(0) + name.length) % palettes.length;
    final colors = palettes[i];
    final initials = name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: pj(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}

// ─────────── Chip ───────────
class BrChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final String variant; // default | primary | soft
  final Widget? icon;
  const BrChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.variant = 'default',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    Border? border;
    switch (variant) {
      case 'primary':
        bg = active ? AppColors.primary : Colors.white;
        fg = active ? Colors.white : AppColors.primary;
        if (!active) border = Border.all(color: AppColors.primary);
        break;
      case 'soft':
        bg = active ? Colors.white : Colors.transparent;
        fg = AppColors.ink2;
        border = Border.all(
          color: active ? AppColors.ink : Colors.black.withValues(alpha: .08),
        );
        break;
      default:
        bg = active ? AppColors.ink : Colors.white;
        fg = active ? Colors.white : AppColors.ink;
        if (!active) border = Border.all(color: AppColors.line);
    }
    return PressScale(
      onTap: onTap,
      scaleTo: 0.93,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 6)],
            Text(
              label,
              style: pj(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────── Button ───────────
enum BrButtonVariant { primary, accent, secondary, ghost, whatsapp }

enum BrButtonSize { sm, md, lg }

class BrButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final BrButtonVariant variant;
  final BrButtonSize size;
  final Widget? icon;
  final Widget? iconRight;
  final bool full;
  const BrButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BrButtonVariant.primary,
    this.size = BrButtonSize.md,
    this.icon,
    this.iconRight,
    this.full = false,
  });

  @override
  State<BrButton> createState() => _BrButtonState();
}

class _BrButtonState extends State<BrButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final onPressed = widget.onPressed;
    final variant = widget.variant;
    final size = widget.size;
    final icon = widget.icon;
    final iconRight = widget.iconRight;
    final full = widget.full;
    final pad = switch (size) {
      BrButtonSize.sm => const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      BrButtonSize.md => const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      BrButtonSize.lg => const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 17,
      ),
    };
    final fs = switch (size) {
      BrButtonSize.sm => 13.0,
      BrButtonSize.md => 15.0,
      BrButtonSize.lg => 16.0,
    };
    final radius = switch (size) {
      BrButtonSize.sm => 12.0,
      BrButtonSize.md => 14.0,
      BrButtonSize.lg => 18.0,
    };
    Color bg, fg;
    Border? border;
    List<BoxShadow>? shadow;
    switch (variant) {
      case BrButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        shadow = [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .45),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: -6,
          ),
        ];
        break;
      case BrButtonVariant.accent:
        bg = AppColors.accent;
        fg = Colors.white;
        shadow = [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: .5),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: -6,
          ),
        ];
        break;
      case BrButtonVariant.secondary:
        bg = Colors.white;
        fg = AppColors.ink;
        border = Border.all(color: AppColors.line);
        break;
      case BrButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.ink2;
        break;
      case BrButtonVariant.whatsapp:
        bg = AppColors.whatsapp;
        fg = Colors.white;
        shadow = [
          BoxShadow(
            color: AppColors.whatsapp.withValues(alpha: .5),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: -6,
          ),
        ];
        break;
    }
    final rowChild = Row(
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon, const SizedBox(width: 8)],
        Text(
          label,
          style: pj(
            fontSize: fs,
            fontWeight: FontWeight.w700,
            color: fg,
            letterSpacing: -.1,
          ),
        ),
        if (iconRight != null) ...[const SizedBox(width: 8), iconRight],
      ],
    );
    final reduce = MediaQuery.of(context).disableAnimations;
    return Listener(
      onPointerDown: onPressed != null
          ? (_) => setState(() => _pressed = true)
          : null,
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: (!reduce && _pressed && onPressed != null) ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              padding: pad,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(radius),
                border: border,
                boxShadow: shadow,
              ),
              width: full ? double.infinity : null,
              child: rowChild,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────── Card ───────────
class BrCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;
  const BrCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.gradient,
    this.border,
    this.onTap,
    this.borderRadius,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    final deco = BoxDecoration(
      color: gradient == null ? (color ?? Colors.white) : null,
      gradient: gradient,
      borderRadius: radius,
      border: border ?? Border.all(color: Colors.black.withValues(alpha: .04)),
      boxShadow:
          boxShadow ??
          [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: .10),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -16,
            ),
          ],
    );
    final content = Container(
      padding: padding,
      decoration: deco,
      clipBehavior: clipBehavior,
      child: child,
    );
    return PressScale(onTap: onTap, scaleTo: 0.97, child: content);
  }
}

// ─────────── Tag ───────────
class BrTag extends StatelessWidget {
  final String label;
  final String color;
  final Widget? icon;
  final Color? bgOverride;
  final Color? fgOverride;
  const BrTag({
    super.key,
    required this.label,
    this.color = 'primary',
    this.icon,
    this.bgOverride,
    this.fgOverride,
  });

  @override
  Widget build(BuildContext context) {
    final palettes = <String, List<Color>>{
      'primary': [AppColors.primary50, AppColors.primaryDark],
      'accent': [AppColors.accent50, AppColors.accentDark],
      'neutral': [const Color(0xFFF1F4F1), AppColors.ink2],
      'danger': [const Color(0xFFFBE9E2), const Color(0xFFA93B22)],
      'blue': [const Color(0xFFE5EEFB), const Color(0xFF2A4FA0)],
      'success': [const Color(0xFFE5F5EB), const Color(0xFF0F7A45)],
    };
    final p = palettes[color] ?? palettes['primary']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgOverride ?? p[0],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 4)],
          Text(
            label,
            style: pj(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fgOverride ?? p[1],
              letterSpacing: .1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────── Screen header ───────────
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Back button is now rendered by [FloatingBackScaffold] as a floating
  /// overlay. This field is kept as a topPad signal — when non-null the
  /// header reserves space for the floating pill above the title.
  final VoidCallback? onBack;
  final Widget? right;
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).viewPadding.top;
    // Reserve space for the floating back pill so the title doesn't overlap with it
    final topPad = onBack != null ? safeTop + 72 : safeTop + 14;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, topPad, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (right != null) ...[
            Align(alignment: Alignment.centerRight, child: right!),
            const SizedBox(height: 12),
          ],
          if (subtitle != null)
            Text(
              subtitle!.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pj(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: .35,
                height: 1.35,
              ),
            ),
          if (subtitle != null) const SizedBox(height: 4),
          Text(
            title,
            style: pj(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              letterSpacing: -.45,
              height: 1.12,
            ),
          ),
        ],
      ),
    );
  }
}

// Floating back button — stays visible while user scrolls.
// Wrap your screen content in a Stack, then place this as a Positioned child.
class FloatingBackPill extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const FloatingBackPill({
    super.key,
    required this.onTap,
    this.label = 'Kembali',
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 38,
          padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: .12),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chevron_left, size: 22, color: AppColors.ink),
              const SizedBox(width: 2),
              Text(
                label,
                style: pj(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Wraps a scrollable child with a floating back pill that stays visible.
// Most screens that show a back button should use this instead of raw ListView.
class FloatingBackScaffold extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;
  const FloatingBackScaffold({super.key, required this.child, this.onBack});

  @override
  Widget build(BuildContext context) {
    if (onBack == null) return child;
    final safeTop = MediaQuery.of(context).viewPadding.top;
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: safeTop + 14,
          left: 18,
          child: FloatingBackPill(onTap: onBack!),
        ),
      ],
    );
  }
}

// ─────────── Compact screen header ───────────
class CompactScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? right;

  const CompactScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).viewPadding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, safeTop + 14, 18, 14),
      child: Row(
        children: [
          if (onBack != null) ...[
            PressScale(
              onTap: onBack,
              scaleTo: 0.88,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(Icons.chevron_left, size: 22),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!.toUpperCase(),
                    style: pj(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                      letterSpacing: .4,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: pj(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -.4,
                  ),
                ),
              ],
            ),
          ),
          ?right,
        ],
      ),
    );
  }
}

// ─────────── Service icon tile ───────────
class ServiceIcon extends StatelessWidget {
  final String kind;
  final String? categoryId;
  final double size;
  const ServiceIcon({
    super.key,
    required this.kind,
    this.categoryId,
    this.size = 48,
  });

  static const _map = {
    'AC': [Color(0xFFE5F0FB), Color(0xFF2A4FA0), Icons.ac_unit],
    'Plumbing': [Color(0xFFE0F2EE), Color(0xFF0E8E6C), Icons.plumbing],
    'Listrik': [
      Color(0xFFFFF1D9),
      Color(0xFFB57008),
      Icons.electrical_services,
    ],
    'Cleaning': [Color(0xFFF1ECFA), Color(0xFF6B4FBF), Icons.cleaning_services],
    'Kebun': [Color(0xFFE6F3DC), Color(0xFF3F7B1F), Icons.local_florist],
    'Lainnya': [Color(0xFFF2F0EC), Color(0xFF4A4036), Icons.build],
  };

  static const _assetByCategory = {
    'ac': 'assets/AC.png',
    'pipa': 'assets/pipa.png',
    'listrik': 'assets/listrik.png',
    'bersih': 'assets/bersih bersih.png',
    'kebun': 'assets/berkebun.png',
    'tukang': 'assets/tukang.png',
    'cat': 'assets/cat.png',
    'elektronik': 'assets/elektronik.png',
    'renovasi': 'assets/renovasi.png',
    'atap': 'assets/perbaikan atap.png',
    'lainnya': 'assets/lainnya.png',
  };

  static const _assetByKind = {
    'AC': 'assets/AC.png',
    'Plumbing': 'assets/pipa.png',
    'Listrik': 'assets/listrik.png',
    'Cleaning': 'assets/bersih bersih.png',
    'Kebun': 'assets/berkebun.png',
    'Lainnya': 'assets/lainnya.png',
  };

  @override
  Widget build(BuildContext context) {
    final entry = _map[kind] ?? _map['Lainnya']!;
    final asset = categoryId == null
        ? _assetByKind[kind]
        : _assetByCategory[categoryId] ?? _assetByKind[kind];
    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.32),
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) => _buildFallback(entry),
        ),
      );
    }
    return _buildFallback(entry);
  }

  Widget _buildFallback(List<Object> entry) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: entry[0] as Color,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(
        entry[2] as IconData,
        size: size * 0.5,
        color: entry[1] as Color,
      ),
    );
  }
}

// ─────────── Stars ───────────
class Stars extends StatelessWidget {
  final double value;
  final double size;
  const Stars({super.key, this.value = 4.5, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.star_rounded, size: size + 2, color: AppColors.accent),
        const SizedBox(width: 2),
        Text(
          value.toStringAsFixed(1),
          style: pj(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

// ─────────── Section title ───────────
class SectionTitle extends StatelessWidget {
  final String text;
  final String? rightText;
  final IconData? rightIcon;
  const SectionTitle(this.text, {super.key, this.rightText, this.rightIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              style: pj(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -.1,
              ),
            ),
          ),
          if (rightText != null)
            Row(
              children: [
                if (rightIcon != null) ...[
                  Icon(rightIcon, size: 12, color: AppColors.primary),
                  const SizedBox(width: 3),
                ],
                Text(
                  rightText!,
                  style: pj(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────── Logo ───────────
class BrLogo extends StatelessWidget {
  final double size;
  const BrLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD89B), Color(0xFFF59E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Text(
        'B',
        style: pj(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.55,
          height: 1,
        ),
      ),
    );
  }
}

// ─────────── Mock AC photo ───────────
class MockACPhoto extends StatelessWidget {
  const MockACPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFC9D7CF), Color(0xFF889B92)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (ctx, c) {
              final w = c.maxWidth;
              final h = c.maxHeight;
              return Stack(
                children: [
                  // AC unit
                  Positioned(
                    left: w * 0.15,
                    right: w * 0.15,
                    top: h * 0.18,
                    height: h * 0.38,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFAFAFA), Color(0xFFD6D6D6)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .4),
                            blurRadius: 30,
                            offset: const Offset(0, 20),
                            spreadRadius: -15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // drip
                  Positioned(
                    left: w * 0.32,
                    top: h * 0.56,
                    width: 4,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF508CB4).withValues(alpha: .85),
                            const Color(0xFF508CB4).withValues(alpha: .2),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // scan box
                  Positioned(
                    left: w * 0.28,
                    top: h * 0.52,
                    width: 70,
                    height: 90,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFFD89B),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
