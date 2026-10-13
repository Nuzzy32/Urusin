import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:urusin/app/router.dart';
import 'package:urusin/main.dart';
import 'package:urusin/screens/mitra/worker_registration_flow.dart';

void main() {
  testWidgets('Beresin app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const BeresinApp());
    await tester.pump();
    expect(find.text('Beresin'), findsWidgets);
  });

  testWidgets('Profile menu destinations open without framework errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BeresinApp());
    appRouter.go('/profile');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();

    for (final item in [
      'Alamat tersimpan',
      'Riwayat harga',
      'Tukang tersimpan',
      'Notifikasi',
      'Keamanan & privasi',
      'Kenapa Beresin?',
      'Hubungi support',
    ]) {
      await tester.ensureVisible(find.text(item));
      await tester.pumpAndSettle();
      await tester.tap(find.text(item));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.chevron_left).first);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Auth screen exposes real OTP methods', (
    WidgetTester tester,
  ) async {
    appRouter.go('/splash');
    await tester.pumpWidget(const BeresinApp());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Beresin'), findsOneWidget);
    expect(find.text('Nomor HP'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kirim OTP'), findsOneWidget);

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();
    expect(find.text('nama@email.com'), findsOneWidget);
  });

  testWidgets(
    'Worker registration requires data and reaches pending dashboard',
    (WidgetTester tester) async {
      appRouter.go('/onboarding/worker/basic');
      await tester.pumpWidget(const BeresinApp());
      appRouter.go('/onboarding/worker/basic');
      await tester.pumpAndSettle();
      expect(find.text('Data Diri Mitra'), findsOneWidget);

      Future<void> scrollTo(Finder finder) {
        return tester.scrollUntilVisible(
          finder,
          300,
          scrollable: find.byType(Scrollable).first,
        );
      }

      await scrollTo(find.text('Lanjut ke Layanan'));
      await tester.tap(find.text('Lanjut ke Layanan'));
      await tester.pumpAndSettle();
      expect(find.text('Lengkapi data wajib dulu ya.'), findsOneWidget);

      mitraDraft
        ..fullName = 'Rudi Hartono'
        ..businessName = 'Pak Rudi AC'
        ..domicile = 'Tebet, Jakarta Selatan'
        ..profilePhoto = UploadState.uploaded;
      appRouter.go('/onboarding/worker/services');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Teknisi AC'));
      await tester.pumpAndSettle();
      await scrollTo(find.text('5+ tahun'));
      await tester.tap(find.text('5+ tahun'));
      await tester.pumpAndSettle();
      appRouter.go('/onboarding/worker/area');
      await tester.pumpAndSettle();
      expect(find.text('Area Kerja & Jadwal'), findsOneWidget);

      appRouter.go('/onboarding/worker/pricing');
      await tester.pumpAndSettle();
      expect(find.text('Atur Harga Layanan'), findsOneWidget);

      appRouter.go('/onboarding/worker/verification');
      await tester.pumpAndSettle();
      expect(
        find.text('Verifikasi untuk Membangun Kepercayaan'),
        findsOneWidget,
      );

      await scrollTo(find.text('Upload KTP').last);
      await tester.tap(find.text('Upload KTP').last);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await scrollTo(find.text('Buka Kamera'));
      await tester.tap(find.text('Buka Kamera'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await scrollTo(find.text('Upload Foto'));
      await tester.tap(find.text('Upload Foto'));
      await tester.pumpAndSettle();
      appRouter.go('/onboarding/worker/review');
      await tester.pumpAndSettle();
      expect(find.text('Review Pendaftaran'), findsOneWidget);

      mitraDraft.agreement = true;
      appRouter.go('/onboarding/worker/submitting');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Pendaftaran Terkirim'), findsOneWidget);
      appRouter.go('/mitra');
      await tester.pumpAndSettle();
      expect(
        find.text('Profil sedang diverifikasi', skipOffstage: false),
        findsOneWidget,
      );
    },
  );
}
