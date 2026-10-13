import 'package:flutter_test/flutter_test.dart';
import 'package:urusin/models.dart';
import 'package:urusin/repositories/app_repository.dart';

void main() {
  test('booking lifecycle stores final price, complaint, and review', () async {
    final repo = HybridBeresinRepository();

    final booking = await repo.createBooking(
      const BookingDraft(
        workerId: 'rudi',
        category: 'AC',
        problem: 'AC bocor',
        aiSummary: 'AC bocor, estimasi harga wajar Rp100.000-Rp150.000.',
        estimatedPriceMin: 100000,
        estimatedPriceMax: 150000,
        schedule: 'Hari ini',
        address: 'Tebet',
        accessNote: 'Pagar hitam',
        customerNote: 'Air menetes',
        paymentMethod: 'Bayar setelah selesai',
      ),
    );

    expect(booking.status, BookingStatus.created);
    expect(repo.bookingById(booking.id), isNotNull);

    final priced = await repo.confirmFinalPrice(
      bookingId: booking.id,
      finalPrice: 120000,
      note: 'Ganti sambungan pipa kecil.',
    );
    expect(priced?.status, BookingStatus.inProgress);
    expect(priced?.finalPrice, 120000);

    final ticket = await repo.createComplaint(
      bookingId: booking.id,
      type: ComplaintType.priceMismatch,
      description: 'Harga perlu dicek ulang.',
    );
    expect(ticket.status, ComplaintStatus.open);
    expect(repo.bookingById(booking.id)?.status, BookingStatus.disputed);
    expect(repo.complaintsForBooking(booking.id), hasLength(1));

    final review = await repo.submitReview(
      bookingId: booking.id,
      workerId: 'rudi',
      rating: 5,
      text: 'Rapi dan cepat.',
      actualPrice: 120000,
      wasPriceWithinEstimate: true,
    );
    expect(review.rating, 5);
    expect(repo.bookingById(booking.id)?.status, BookingStatus.reviewed);
  });

  test(
    'worker application submission is accepted into pending verification',
    () async {
      final repo = HybridBeresinRepository();
      final now = DateTime(2026, 5, 26);

      final application = await repo.submitWorkerApplication(
        WorkerApplication(
          id: 'app-1',
          fullName: 'Rudi Hartono',
          businessName: 'Pak Rudi AC',
          whatsapp: '+6281211100001',
          domicile: 'Tebet',
          bio: 'Teknisi AC',
          services: const ['Teknisi AC'],
          subServices: const ['Cuci AC'],
          areas: const ['Tebet'],
          days: const ['Senin'],
          startTime: '09.00',
          endTime: '17.00',
          priceFrom: const {'Cuci AC': 'Rp80.000'},
          priceTo: const {'Cuci AC': 'Rp120.000'},
          ktpAssetPath: 'worker-verification/local/ktp.jpg',
          selfieAssetPath: 'worker-verification/local/selfie.jpg',
          portfolioAssetPaths: const [
            'worker-verification/local/portfolio-1.jpg',
            'worker-verification/local/portfolio-2.jpg',
          ],
          status: WorkerVerificationStatus.pending,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(application.status, WorkerVerificationStatus.pending);
      expect(application.portfolioAssetPaths, hasLength(2));
    },
  );
}
