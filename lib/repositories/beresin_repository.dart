import '../models.dart';

abstract class BeresinRepository {
  List<ServiceBooking> bookings();

  ServiceBooking? bookingById(String id);

  List<ComplaintTicket> complaintsForBooking(String bookingId);

  Future<ServiceBooking> createBooking(
    BookingDraft draft, {
    String customerId = 'demo-customer',
  });

  Future<ServiceBooking?> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  );

  Future<ServiceBooking?> confirmFinalPrice({
    required String bookingId,
    required int finalPrice,
    required String note,
  });

  Future<ComplaintTicket> createComplaint({
    required String bookingId,
    required ComplaintType type,
    required String description,
    List<String> evidenceImageUrls,
  });

  Future<Review> submitReview({
    required String bookingId,
    required String workerId,
    required int rating,
    required String text,
    required int? actualPrice,
    required bool? wasPriceWithinEstimate,
  });

  Future<WorkerApplication> submitWorkerApplication(WorkerApplication draft);
}
