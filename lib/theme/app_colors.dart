import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0E8E6C);
  static const primaryDark = Color(0xFF0A6E54);
  static const primary50 = Color(0xFFECF7F2);
  static const primary100 = Color(0xFFD8EFE6);
  static const accent = Color(0xFFF59E3C);
  static const accentDark = Color(0xFFE37614);
  static const accent50 = Color(0xFFFFF4E5);
  static const bg = Color(0xFFF5F6F2);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F1F1A);
  static const ink2 = Color(0xFF3A4A45);
  static const muted = Color(0xFF6B7873);
  static const line = Color(0xFFE5EAE5);
  static const line2 = Color(0xFFEFF2EE);
  static const danger = Color(0xFFD6553B);
  static const warn = Color(0xFFE08A1E);
  static const whatsapp = Color(0xFF25D366);
}

String rupiah(num n) {
  final s = n.toInt().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp$b';
}
