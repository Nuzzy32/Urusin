import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models.dart';
import 'beresin_repository.dart';

final BeresinRepository appRepository = HybridBeresinRepository();

class HybridBeresinRepository implements BeresinRepository {
  final Map<String, ServiceBooking> _bookings = {};
  final Map<String, ComplaintTicket> _complaints = {};
  final Map<String, WorkerApplication> _workerApplications = {};
  final List<Review> _reviews = [];

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  List<ServiceBooking> bookings() {
    final items = _bookings.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  ServiceBooking? bookingById(String id) {
    return _bookings[id];
  }

  @override
  List<ComplaintTicket> complaintsForBooking(String bookingId) {
    final items =
        _complaints.values
            .where((ticket) => ticket.bookingId == bookingId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<ServiceBooking> createBooking(
    BookingDraft draft, {
    String customerId = 'demo-customer',
  }) async {
    final now = DateTime.now();
    final resolvedCustomerId = _supabase?.auth.currentUser?.id ?? customerId;
    final payload = <String, dynamic>{
      'customer_id': resolvedCustomerId,
      'worker_id': draft.workerId,
      'category': draft.category,
      'problem': draft.problem,
      'ai_summary': draft.aiSummary,
      'estimated_price_min': draft.estimatedPriceMin,
      'estimated_price_max': draft.estimatedPriceMax,
      'status': BookingStatus.created.value,
      'schedule': draft.schedule,
      'address': draft.address,
      'access_note': draft.accessNote,
      'customer_note': draft.customerNote,
      'payment_method': draft.paymentMethod,
      'chat_channel': draft.chatChannel.value,
      if (draft.diagnosisId != null) 'diagnosis_id': draft.diagnosisId,
    };

    String bookingId = _id('booking');
    String? bookingCode;
    final client = _supabase;
    if (client != null) {
      try {
        final row = await client
            .from('bookings')
            .insert(payload)
            .select('id, booking_code')
            .single();
        bookingId = row['id'] as String;
        bookingCode = row['booking_code'] as String?;
      } catch (_) {}
    }

    final booking = ServiceBooking(
      id: bookingId,
      bookingCode: bookingCode,
      diagnosisId: draft.diagnosisId,
      customerId: resolvedCustomerId,
      workerId: draft.workerId,
      category: draft.category,
      problem: draft.problem,
      aiSummary: draft.aiSummary,
      estimatedPriceMin: draft.estimatedPriceMin,
      estimatedPriceMax: draft.estimatedPriceMax,
      status: BookingStatus.created,
      schedule: draft.schedule,
      address: draft.address,
      accessNote: draft.accessNote,
      customerNote: draft.customerNote,
      paymentMethod: draft.paymentMethod,
      chatChannel: draft.chatChannel,
      createdAt: now,
      updatedAt: now,
    );
    _bookings[booking.id] = booking;
    return booking;
  }

  @override
  Future<ServiceBooking?> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    final booking = _bookings[bookingId];
    if (booking == null) return null;
    final updated = booking.copyWith(status: status);
    _bookings[bookingId] = updated;
    unawaited(_upsert('bookings', updated.toJson()));
    return updated;
  }

  @override
  Future<ServiceBooking?> confirmFinalPrice({
    required String bookingId,
    required int finalPrice,
    required String note,
  }) async {
    final booking = _bookings[bookingId];
    if (booking == null) return null;
    final updated = booking.copyWith(
      finalPrice: finalPrice,
      finalPriceNote: note,
      status: BookingStatus.inProgress,
    );
    _bookings[bookingId] = updated;
    unawaited(_upsert('bookings', updated.toJson()));
    return updated;
  }

  @override
  Future<ComplaintTicket> createComplaint({
    required String bookingId,
    required ComplaintType type,
    required String description,
    List<String> evidenceImageUrls = const [],
  }) async {
    final reporterId = _supabase?.auth.currentUser?.id;
    final now = DateTime.now();
    String complaintId = _id('complaint');

    final payload = <String, dynamic>{
      'booking_id': bookingId,
      'type': type.value,
      'description': description,
      'status': ComplaintStatus.open.value,
      'evidence_image_urls': evidenceImageUrls,
      'reporter_id': ?reporterId,
    };

    final client = _supabase;
    if (client != null) {
      try {
        final row = await client
            .from('complaints')
            .insert(payload)
            .select('id')
            .single();
        complaintId = row['id'] as String;
      } catch (_) {}
    }

    final ticket = ComplaintTicket(
      id: complaintId,
      bookingId: bookingId,
      type: type,
      description: description,
      status: ComplaintStatus.open,
      evidenceImageUrls: evidenceImageUrls,
      reporterId: reporterId,
      createdAt: now,
    );
    _complaints[ticket.id] = ticket;
    final booking = _bookings[bookingId];
    if (booking != null) {
      _bookings[bookingId] = booking.copyWith(status: BookingStatus.disputed);
      unawaited(
        _supabase
                ?.from('bookings')
                .update({'status': BookingStatus.disputed.value})
                .eq('id', bookingId) ??
            Future<void>.value(),
      );
    }
    return ticket;
  }

  @override
  Future<Review> submitReview({
    required String bookingId,
    required String workerId,
    required int rating,
    required String text,
    required int? actualPrice,
    required bool? wasPriceWithinEstimate,
  }) async {
    final userMeta = _supabase?.auth.currentUser?.userMetadata ?? {};
    final userName =
        ((userMeta['full_name'] ?? userMeta['name'] ?? '') as String)
            .trim()
            .isNotEmpty
        ? (userMeta['full_name'] ?? userMeta['name']).toString().trim()
        : 'Customer Beresin';
    final review = Review(
      id: _id('review'),
      workerId: workerId,
      userName: userName,
      rating: rating,
      text: text,
      actualPrice: actualPrice,
      wasPriceWithinEstimate: wasPriceWithinEstimate,
      arrivedOnTime: null,
      wouldRecommend: rating >= 4,
      createdAtLabel: 'Baru saja',
    );
    _reviews.add(review);
    await updateBookingStatus(bookingId, BookingStatus.reviewed);
    unawaited(
      _upsert('reviews', {
        'id': review.id,
        'booking_id': bookingId,
        'worker_id': workerId,
        'user_name': review.userName,
        'rating': review.rating,
        'text': review.text,
        'actual_price': review.actualPrice,
        'was_price_within_estimate': review.wasPriceWithinEstimate,
        'would_recommend': review.wouldRecommend,
      }),
    );
    return review;
  }

  @override
  Future<WorkerApplication> submitWorkerApplication(
    WorkerApplication draft,
  ) async {
    _workerApplications[draft.id] = draft;
    final client = _supabase;
    if (client == null) return draft; // demo/test tanpa Supabase

    final uid = client.auth.currentUser?.id;
    if (uid == null) throw StateError('Silakan masuk dulu sebelum mendaftar.');

    // FK worker_applications.user_id butuh baris users; biasanya sudah dibuat saat login.
    await client
        .from('users')
        .upsert(
          {
            'auth_user_id': uid,
            'name': draft.fullName,
            'phone_number': draft.whatsapp,
          },
          onConflict: 'auth_user_id',
          ignoreDuplicates: true,
        );

    // Tulis sebagai draft dulu → anak-anaknya → baru pending, supaya admin
    // tidak pernah melihat pendaftaran setengah jadi. Aman di-retry (id stabil).
    await client.from('worker_applications').upsert({
      ...draft.toJson(),
      'status': WorkerVerificationStatus.draft.value,
    });
    final children = {
      'worker_application_services': draft.servicesToRows(),
      'worker_application_areas': draft.areasToRows(),
      'worker_application_schedules': draft.schedulesToRows(),
      'worker_application_prices': draft.pricesToRows(),
      'worker_application_portfolios': draft.portfoliosToRows(),
    };
    for (final MapEntry(key: table, value: rows) in children.entries) {
      await client.from(table).delete().eq('application_id', draft.id);
      if (rows.isNotEmpty) await client.from(table).insert(rows);
    }
    await client
        .from('worker_applications')
        .update({'status': draft.status.value})
        .eq('id', draft.id);
    return draft;
  }

  Future<void> loadFromSupabase(String userId) async {
    final client = _supabase;
    if (client == null) return;
    try {
      final rows = await client
          .from('bookings')
          .select()
          .eq('customer_id', userId)
          .order('created_at', ascending: false);
      for (final row in rows) {
        final booking = ServiceBooking.fromJson(row);
        _bookings[booking.id] = booking;
      }
    } catch (_) {}
    try {
      final bookingIds = _bookings.keys.toList();
      if (bookingIds.isEmpty) return;
      final rows = await client
          .from('complaints')
          .select()
          .inFilter('booking_id', bookingIds);
      for (final row in rows) {
        final ticket = ComplaintTicket.fromJson(row);
        _complaints[ticket.id] = ticket;
      }
    } catch (_) {}
  }

  Future<void> _upsert(String table, Map<String, dynamic> payload) async {
    final client = _supabase;
    if (client == null) return;
    try {
      await client.from(table).upsert(payload);
    } catch (_) {
      // Demo fallback must remain usable when Supabase tables are not created yet.
    }
  }
}

String _id(String prefix) {
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}
