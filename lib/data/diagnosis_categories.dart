class DiagnosisCategory {
  final String id;
  final String label;
  final String serviceKind;
  final String sheetTitle;
  final List<String> problemChips;
  final String intakeTitle;
  final String intakeSubtitle;
  final String uploadLabel;
  final String placeholder;
  final String resultProblem;
  final String resultExplanation;
  final String workerType;
  final int priceMin;
  final int priceMax;
  final int durationMin;
  final int durationMax;
  final String nextStep;
  final String safetyNote;

  const DiagnosisCategory({
    required this.id,
    required this.label,
    required this.serviceKind,
    required this.sheetTitle,
    required this.problemChips,
    required this.intakeTitle,
    required this.intakeSubtitle,
    required this.uploadLabel,
    required this.placeholder,
    required this.resultProblem,
    required this.resultExplanation,
    required this.workerType,
    required this.priceMin,
    required this.priceMax,
    required this.durationMin,
    required this.durationMax,
    required this.nextStep,
    required this.safetyNote,
  });
}

const diagnosisCategories = [
  DiagnosisCategory(
    id: 'ac',
    label: 'AC',
    serviceKind: 'AC',
    sheetTitle: 'Masalah AC apa yang kamu alami?',
    problemChips: [
      'AC bocor',
      'AC tidak dingin',
      'AC berisik',
      'AC mati total',
      'Mau cuci AC',
      'Lainnya',
    ],
    intakeTitle: 'Cek Masalah AC',
    intakeSubtitle:
        'Upload foto atau ceritakan gejalanya supaya AI bisa bantu estimasi masalah dan harga wajar.',
    uploadLabel: 'Upload foto unit AC atau bagian yang bermasalah',
    placeholder:
        'Contoh: AC bocor dari dalam, sudah 2 hari, masih dingin tapi air menetes.',
    resultProblem: 'Saluran drainase AC tersumbat',
    resultExplanation:
        'Gejala ini biasanya terjadi karena saluran pembuangan air kotor tersumbat atau evaporator terlalu kotor.',
    workerType: 'Teknisi AC',
    priceMin: 75000,
    priceMax: 150000,
    durationMin: 30,
    durationMax: 60,
    nextStep: 'Panggil teknisi AC untuk pengecekan dan pembersihan saluran.',
    safetyNote:
        'Matikan AC jika air menetes dekat stop kontak. Jangan bongkar unit sendiri jika tidak berpengalaman.',
  ),
  DiagnosisCategory(
    id: 'pipa',
    label: 'Pipa',
    serviceKind: 'Plumbing',
    sheetTitle: 'Masalah pipa apa yang kamu alami?',
    problemChips: [
      'Pipa bocor',
      'Saluran mampet',
      'Kran rusak',
      'Wastafel bocor',
      'Toilet mampet',
      'Lainnya',
    ],
    intakeTitle: 'Cek Masalah Pipa',
    intakeSubtitle:
        'Ceritakan lokasi bocor atau mampetnya supaya AI bisa bantu estimasi tukang dan biaya.',
    uploadLabel: 'Upload foto pipa, kran, saluran, atau area yang bocor',
    placeholder:
        'Contoh: Pipa bawah wastafel bocor, air menetes kalau kran dibuka.',
    resultProblem: 'Sambungan pipa atau seal kemungkinan bocor',
    resultExplanation:
        'Masalah seperti ini sering terjadi karena seal aus, sambungan longgar, atau tekanan air terlalu tinggi.',
    workerType: 'Tukang Ledeng',
    priceMin: 75000,
    priceMax: 200000,
    durationMin: 30,
    durationMax: 90,
    nextStep: 'Panggil tukang ledeng untuk pengecekan sambungan dan seal.',
    safetyNote:
        'Tutup keran utama jika air mengalir deras. Konfirmasi harga sebelum penggantian spare part.',
  ),
  DiagnosisCategory(
    id: 'listrik',
    label: 'Listrik',
    serviceKind: 'Listrik',
    sheetTitle: 'Masalah listrik apa yang kamu alami?',
    problemChips: [
      'Listrik mati sebagian',
      'MCB turun terus',
      'Stop kontak rusak',
      'Lampu kedip',
      'Kabel panas',
      'Lainnya',
    ],
    intakeTitle: 'Cek Masalah Listrik',
    intakeSubtitle:
        'Jelaskan gejalanya tanpa membongkar instalasi. AI akan bantu estimasi risiko dan teknisi yang tepat.',
    uploadLabel: 'Upload foto panel, stop kontak, atau area yang aman difoto',
    placeholder:
        'Contoh: MCB turun terus saat pompa dinyalakan, beberapa stop kontak mati.',
    resultProblem: 'Beban listrik atau jalur tertentu kemungkinan bermasalah',
    resultExplanation:
        'Gejala ini bisa terkait beban berlebih, perangkat rusak, atau jalur listrik yang perlu dicek teknisi.',
    workerType: 'Teknisi Listrik',
    priceMin: 100000,
    priceMax: 250000,
    durationMin: 45,
    durationMax: 120,
    nextStep: 'Panggil teknisi listrik untuk pengecekan aman di lokasi.',
    safetyNote:
        'Jangan bongkar stop kontak atau panel listrik sendiri. Matikan MCB jika ada bau gosong atau kabel panas.',
  ),
  DiagnosisCategory(
    id: 'bersih',
    label: 'Bersih',
    serviceKind: 'Cleaning',
    sheetTitle: 'Area mana yang perlu dibersihkan?',
    problemChips: [
      'Kamar kos',
      'Rumah 2 kamar',
      'Dapur berminyak',
      'Kamar mandi',
      'Sofa/kasur',
      'Lainnya',
    ],
    intakeTitle: 'Cek Kebutuhan Bersih',
    intakeSubtitle:
        'Upload foto area atau ceritakan kondisinya supaya AI bisa bantu estimasi durasi dan harga.',
    uploadLabel: 'Upload foto area yang ingin dibersihkan',
    placeholder:
        'Contoh: Kamar mandi berkerak, lantai licin, sudah lama tidak dibersihkan.',
    resultProblem: 'Pembersihan detail area rumah',
    resultExplanation:
        'Kondisi area menentukan jumlah tenaga, alat, dan durasi pembersihan yang dibutuhkan.',
    workerType: 'Cleaning Service',
    priceMin: 100000,
    priceMax: 300000,
    durationMin: 60,
    durationMax: 180,
    nextStep: 'Pilih worker cleaning yang membawa alat dan bahan sendiri.',
    safetyNote:
        'Simpan barang berharga sebelum layanan dimulai dan sepakati area kerja lebih dulu.',
  ),
  DiagnosisCategory(
    id: 'kebun',
    label: 'Kebun',
    serviceKind: 'Kebun',
    sheetTitle: 'Kebun atau tanamanmu butuh apa?',
    problemChips: [
      'Potong rumput',
      'Rapikan tanaman',
      'Buang daun',
      'Tanaman layu',
      'Bersih halaman',
      'Lainnya',
    ],
    intakeTitle: 'Cek Kebutuhan Kebun',
    intakeSubtitle:
        'Ceritakan ukuran area dan kondisi tanaman supaya estimasi pekerjaannya lebih masuk akal.',
    uploadLabel: 'Upload foto halaman, tanaman, atau area kebun',
    placeholder:
        'Contoh: Rumput halaman sudah tinggi, luas kira-kira 3x5 meter.',
    resultProblem: 'Perawatan halaman dan tanaman ringan',
    resultExplanation:
        'Estimasi pekerjaan tergantung luas area, tinggi rumput, dan apakah sampah tanaman perlu diangkut.',
    workerType: 'Tukang Kebun',
    priceMin: 100000,
    priceMax: 250000,
    durationMin: 60,
    durationMax: 150,
    nextStep:
        'Panggil tukang kebun untuk merapikan area dan mengangkut sisa tanaman.',
    safetyNote:
        'Pastikan akses halaman jelas dan sepakati apakah sampah tanaman ikut dibuang.',
  ),
  DiagnosisCategory(
    id: 'tukang',
    label: 'Tukang',
    serviceKind: 'Lainnya',
    sheetTitle: 'Pekerjaan tukang apa yang kamu butuhkan?',
    problemChips: [
      'Pasang rak',
      'Pintu macet',
      'Engsel rusak',
      'Perbaikan kecil',
      'Bor dinding',
      'Lainnya',
    ],
    intakeTitle: 'Cek Kebutuhan Tukang',
    intakeSubtitle:
        'Jelaskan pekerjaan kecil di rumah supaya AI bisa bantu estimasi waktu dan alat yang dibutuhkan.',
    uploadLabel: 'Upload foto bagian rumah atau barang yang perlu diperbaiki',
    placeholder: 'Contoh: Pintu kamar macet dan engsel bawah terlihat longgar.',
    resultProblem: 'Perbaikan rumah ringan',
    resultExplanation:
        'Pekerjaan ringan biasanya perlu pengecekan alat, jenis material, dan tingkat kerusakan.',
    workerType: 'Tukang Serbaguna',
    priceMin: 80000,
    priceMax: 250000,
    durationMin: 45,
    durationMax: 150,
    nextStep: 'Panggil tukang serbaguna dengan detail foto dan ukuran area.',
    safetyNote:
        'Konfirmasi harga jasa dan biaya material sebelum pekerjaan dimulai.',
  ),
  DiagnosisCategory(
    id: 'cat',
    label: 'Cat',
    serviceKind: 'Lainnya',
    sheetTitle: 'Masalah cat apa yang kamu alami?',
    problemChips: [
      'Cat mengelupas',
      'Dinding lembap',
      'Cat ulang kamar',
      'Retak rambut',
      'Noda dinding',
      'Lainnya',
    ],
    intakeTitle: 'Cek Kebutuhan Cat',
    intakeSubtitle:
        'Upload foto dinding dan ceritakan luas area supaya estimasi harga lebih transparan.',
    uploadLabel: 'Upload foto dinding atau area yang ingin dicat',
    placeholder:
        'Contoh: Cat kamar mengelupas di dekat jendela, area sekitar 2 meter.',
    resultProblem: 'Cat dinding mengelupas atau lembap',
    resultExplanation:
        'Dinding lembap atau cat lama yang rusak perlu dicek sebelum dicat ulang agar hasil tidak cepat rusak.',
    workerType: 'Tukang Cat',
    priceMin: 150000,
    priceMax: 600000,
    durationMin: 120,
    durationMax: 360,
    nextStep:
        'Pilih tukang cat yang bisa cek kondisi dinding dan kebutuhan material.',
    safetyNote:
        'Pastikan ventilasi ruangan baik dan sepakati apakah harga termasuk cat/material.',
  ),
  DiagnosisCategory(
    id: 'elektronik',
    label: 'Elektronik',
    serviceKind: 'Lainnya',
    sheetTitle: 'Elektronik rumah apa yang bermasalah?',
    problemChips: [
      'Mesin cuci rusak',
      'Kulkas tidak dingin',
      'Pompa air mati',
      'TV bermasalah',
      'Kompor listrik',
      'Lainnya',
    ],
    intakeTitle: 'Cek Elektronik Rumah',
    intakeSubtitle:
        'Foto unit, merek, dan gejalanya supaya AI bisa bantu estimasi teknisi dan biaya pengecekan.',
    uploadLabel: 'Upload foto elektronik, label merek, atau bagian yang rusak',
    placeholder:
        'Contoh: Mesin cuci tidak mau spin, muncul bunyi keras sejak kemarin.',
    resultProblem: 'Elektronik rumah perlu pengecekan teknisi',
    resultExplanation:
        'Gejala elektronik bisa berasal dari komponen, jalur listrik internal, atau pemakaian yang perlu dicek langsung.',
    workerType: 'Teknisi Elektronik',
    priceMin: 100000,
    priceMax: 350000,
    durationMin: 45,
    durationMax: 150,
    nextStep:
        'Panggil teknisi elektronik dan siapkan detail merek, tipe, serta gejala kerusakan.',
    safetyNote:
        'Cabut listrik perangkat jika ada bau gosong, suara aneh, atau bodi terasa panas.',
  ),
  DiagnosisCategory(
    id: 'renovasi',
    label: 'Renovasi',
    serviceKind: 'Lainnya',
    sheetTitle: 'Renovasi kecil apa yang kamu rencanakan?',
    problemChips: [
      'Bongkar pasang',
      'Sekat ruangan',
      'Keramik',
      'Plafon',
      'Perbaikan dinding',
      'Lainnya',
    ],
    intakeTitle: 'Cek Kebutuhan Renovasi',
    intakeSubtitle:
        'Ceritakan area, ukuran, dan target pekerjaan supaya estimasi tukang dan material lebih jelas.',
    uploadLabel: 'Upload foto area yang ingin direnovasi',
    placeholder:
        'Contoh: Mau pasang keramik area dapur sekitar 2x3 meter, material belum ada.',
    resultProblem: 'Renovasi kecil rumah',
    resultExplanation:
        'Estimasi renovasi dipengaruhi ukuran area, jenis material, kondisi lama, dan apakah perlu bongkar pasang.',
    workerType: 'Tukang Renovasi',
    priceMin: 250000,
    priceMax: 1500000,
    durationMin: 180,
    durationMax: 480,
    nextStep:
        'Pilih tukang renovasi untuk survei area dan rincian kebutuhan material.',
    safetyNote:
        'Sepakati ruang lingkup, material, dan jadwal sebelum pekerjaan dimulai.',
  ),
  DiagnosisCategory(
    id: 'atap',
    label: 'Atap',
    serviceKind: 'Lainnya',
    sheetTitle: 'Masalah atap apa yang perlu diperbaiki?',
    problemChips: [
      'Atap bocor',
      'Genteng geser',
      'Talang mampet',
      'Plafon rembes',
      'Rangka rusak',
      'Lainnya',
    ],
    intakeTitle: 'Cek Perbaikan Atap',
    intakeSubtitle:
        'Upload foto rembesan atau area atap yang aman difoto supaya AI bisa bantu estimasi risiko dan biaya.',
    uploadLabel: 'Upload foto rembesan, plafon, talang, atau bagian atap',
    placeholder:
        'Contoh: Plafon rembes kalau hujan deras, titiknya dekat kamar depan.',
    resultProblem: 'Atap atau talang kemungkinan bocor',
    resultExplanation:
        'Kebocoran atap sering terkait genteng bergeser, talang tersumbat, seal rusak, atau retakan kecil.',
    workerType: 'Tukang Atap',
    priceMin: 150000,
    priceMax: 800000,
    durationMin: 60,
    durationMax: 240,
    nextStep:
        'Panggil tukang atap untuk pengecekan aman dan perbaikan titik bocor.',
    safetyNote:
        'Jangan naik ke atap sendiri, terutama saat basah atau setelah hujan.',
  ),
  DiagnosisCategory(
    id: 'lainnya',
    label: 'Lainnya',
    serviceKind: 'Lainnya',
    sheetTitle: 'Masalah rumah apa yang ingin kamu cek?',
    problemChips: [
      'Belum yakin kategorinya',
      'Appliance rusak',
      'Pest control',
      'Renovasi kecil',
      'Butuh saran',
      'Lainnya',
    ],
    intakeTitle: 'Cek Masalah Rumah',
    intakeSubtitle:
        'Ceritakan masalahnya dengan sederhana. AI akan bantu arahkan ke tipe tukang yang paling cocok.',
    uploadLabel: 'Upload foto bagian rumah atau barang yang bermasalah',
    placeholder:
        'Contoh: Ada bagian rumah yang rusak, saya belum tahu harus panggil tukang apa.',
    resultProblem: 'Butuh pengecekan kategori layanan',
    resultExplanation:
        'AI akan membaca gejala awal untuk mengarahkan ke tipe worker yang paling relevan.',
    workerType: 'Tukang yang Sesuai',
    priceMin: 75000,
    priceMax: 300000,
    durationMin: 30,
    durationMax: 180,
    nextStep:
        'Mulai dari pengecekan awal, lalu pilih worker sesuai kategori yang disarankan.',
    safetyNote:
        'Jangan lakukan perbaikan berisiko sendiri. Tunggu pengecekan langsung jika menyangkut listrik, gas, atau struktur.',
  ),
];

DiagnosisCategory diagnosisByLabel(String label) {
  return diagnosisCategories.firstWhere(
    (category) => category.label.toLowerCase() == label.toLowerCase(),
    orElse: () => diagnosisCategories.first,
  );
}

DiagnosisCategory diagnosisById(String id) {
  return diagnosisCategories.firstWhere(
    (category) => category.id == id,
    orElse: () => diagnosisCategories.first,
  );
}
