import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/worker.dart';

List<Worker> kWorkers = _fallbackWorkers;

final List<Worker> _fallbackWorkers = [
  Worker(
    id: 'rudi',
    name: 'Pak Rudi',
    phone: '6281211100001',
    service: 'Teknisi AC',
    serviceKind: 'AC',
    rating: 4.9,
    reviews: 186,
    distance: 1.2,
    eta: '20 menit',
    priceMin: 80000,
    priceMax: 130000,
    review: 'Datang cepat, AC langsung dingin lagi.',
    badges: ['Terverifikasi', 'Harga Transparan', '12x direkomendasikan warga'],
    jobsDone: 328,
    yearsExperience: 9,
    services: [
      Service('Cuci AC', 80000, 120000),
      Service('Cek AC bocor', 100000, 150000),
      Service('Isi freon', 150000),
      Service('Bongkar pasang', 250000, 350000),
    ],
    bio:
        'Sudah 9 tahun nukang AC di Tebet. Spesialis split & cassette. Garansi 7 hari setelah service.',
    available: 'Bisa hari ini · 09.00 - 21.00',
  ),
  Worker(
    id: 'budi',
    name: 'Pak Budi',
    phone: '6281211100002',
    service: 'Teknisi AC',
    serviceKind: 'AC',
    rating: 4.6,
    reviews: 94,
    distance: 2.4,
    eta: '40 menit',
    priceMin: 70000,
    priceMax: 110000,
    review: 'Ramah, jelasin masalahnya detail.',
    badges: ['Terverifikasi', 'Harga Transparan'],
    jobsDone: 142,
    yearsExperience: 6,
    services: [
      Service('Cuci AC', 70000, 110000),
      Service('Cek AC', 80000, 120000),
      Service('Cek AC bocor', 90000, 140000),
    ],
    bio:
        'Teknisi AC area Tebet dan Pancoran. Terbiasa menangani kos, rumah, dan ruko kecil.',
    available: 'Bisa hari ini · 10.00 - 18.00',
  ),
  Worker(
    id: 'sari',
    name: 'Bu Sari Clean',
    phone: '6281211100006',
    service: 'Cleaning Service',
    serviceKind: 'Cleaning',
    rating: 4.8,
    reviews: 142,
    distance: 2.1,
    eta: 'Bisa hari ini',
    priceMin: 100000,
    priceMax: 250000,
    review: 'Rapi dan teliti, cocok untuk bersih-bersih kos.',
    badges: ['Terverifikasi', 'Tim Wanita'],
    jobsDone: 211,
    yearsExperience: 5,
    services: [
      Service('Bersih kamar kos', 100000, 150000),
      Service('Bersih rumah 2BR', 200000, 250000),
      Service('Cuci sofa', 150000, 250000),
    ],
    bio:
        'Tim cleaning area Tebet yang membawa alat dan bahan sendiri. Cocok untuk kos, apartemen, dan rumah kecil.',
    available: 'Bisa hari ini · 08.00 - 17.00',
  ),
  Worker(
    id: 'arif',
    name: 'Mas Arif',
    phone: '6281211100003',
    service: 'Teknisi AC',
    serviceKind: 'AC',
    rating: 4.8,
    reviews: 121,
    distance: 3.1,
    eta: '55 menit',
    priceMin: 90000,
    priceMax: 160000,
    review: 'Cepat respon, kerja bersih, harga masih wajar.',
    badges: ['Terverifikasi', 'Garansi 7 hari'],
    jobsDone: 207,
    yearsExperience: 7,
    services: [
      Service('Cuci AC', 90000, 130000),
      Service('AC bocor', 100000, 160000),
      Service('Isi freon', 160000, 250000),
    ],
    bio:
        'Spesialis AC split dan masalah kebocoran. Membawa alat lengkap untuk pengecekan awal.',
    available: 'Bisa hari ini · 13.00 - 20.00',
  ),
  Worker(
    id: 'dedi',
    name: 'Pak Dedi',
    phone: '6281211100004',
    service: 'Tukang Ledeng',
    serviceKind: 'Plumbing',
    rating: 4.7,
    reviews: 98,
    distance: 1.8,
    eta: '35 menit',
    priceMin: 75000,
    priceMax: 200000,
    review: 'Harga sesuai estimasi, kerja cepat.',
    badges: ['Terverifikasi', 'Harga Transparan'],
    jobsDone: 174,
    yearsExperience: 11,
    services: [
      Service('Pipa mampet', 75000, 150000),
      Service('Bocor wastafel', 100000, 200000),
      Service('Ganti kran', 50000, 120000),
    ],
    bio:
        'Tukang ledeng senior, area Tebet dan Manggarai. Jaminan tidak balik bocor 14 hari.',
    available: 'Bisa hari ini · 07.00 - 22.00',
  ),
  Worker(
    id: 'hendra',
    name: 'Mas Hendra',
    phone: '6281211100005',
    service: 'Teknisi Listrik',
    serviceKind: 'Listrik',
    rating: 4.8,
    reviews: 76,
    distance: 2.7,
    eta: '50 menit',
    priceMin: 100000,
    priceMax: 250000,
    review: 'Aman dan teliti, bantu cek MCB juga.',
    badges: ['Terverifikasi', 'Nomor Aktif', 'Safety-first'],
    jobsDone: 118,
    yearsExperience: 8,
    services: [
      Service('Cek listrik mati', 100000, 180000),
      Service('Ganti stop kontak', 75000, 150000),
      Service('Cek MCB', 120000, 250000),
    ],
    bio:
        'Menangani pengecekan listrik rumah skala ringan. Selalu mulai dengan pengecekan risiko dasar.',
    available: 'Bisa hari ini · 11.00 - 19.00',
  ),
];

Future<void> loadWorkersFromSupabase() async {
  try {
    final client = Supabase.instance.client;
    final rows = await client
        .from('mitras')
        .select(
          '*, users!mitras_mitra_id_fkey(name, phone_number), mitra_badges(badges(badge_name)), mitra_services(*), categories(category_name, display_name)',
        )
        .eq('verification_status', 'approved')
        .eq('registration_status', 'approved');

    if (rows.isEmpty) return;

    final loaded = rows.map((row) {
      final badgesNested =
          (row['mitra_badges'] as List<dynamic>?)
              ?.map((b) =>
                  (b as Map<String, dynamic>)['badges']?['badge_name']
                      as String?)
              .whereType<String>()
              .toList() ??
          <String>[];
      final enriched = Map<String, dynamic>.from(row);
      enriched['badges'] = badgesNested;
      return Worker.fromJson(enriched);
    }).toList();

    kWorkers = loaded;
  } catch (_) {
    // keep fallback list
  }
}
