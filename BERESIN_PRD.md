# PRD — Beresin

## AI-Powered Hyperlocal Home Service Platform

Version: 1.1  
Status: Production MVP Definition

---

# 1. Executive Summary

## What is Beresin?

Beresin adalah platform hyperlocal berbasis AI yang membantu masyarakat menemukan tukang terpercaya dengan proses yang lebih aman, transparan, dan cepat.

Beresin tidak hanya menjadi marketplace tukang biasa, tetapi juga:
- membantu user memahami masalah rumah,
- memberikan estimasi harga wajar,
- mengurangi scam harga,
- meningkatkan trust antara customer dan tukang,
- membantu tukang lokal mendapatkan pekerjaan secara konsisten.

---

# 2. Problem Statement

## Masalah Customer

### Sulit mencari tukang terpercaya
Mayoritas orang mendapatkan nomor tukang dari:
- tetangga,
- grup WhatsApp,
- Facebook,
- rekomendasi mulut ke mulut.

Masalah:
- kualitas tidak jelas,
- tidak ada verifikasi,
- harga tidak transparan,
- sering no-show,
- komunikasi buruk.

### Tidak tahu kerusakan sebenarnya
User sering:
- tidak paham istilah teknis,
- takut ditipu,
- bingung estimasi harga normal.

### Harga berubah di lokasi
Masalah umum:
- estimasi awal murah,
- harga final tiba-tiba naik.

---

## Masalah Tukang

### Sulit mendapat pelanggan tetap
Banyak tukang:
- bergantung pada kenalan,
- tidak punya branding digital,
- sulit dipercaya customer baru.

### Komunikasi melelahkan
Tukang harus:
- menjawab pertanyaan sama,
- mengatur jadwal manual,
- menjelaskan harga berulang.

---

# 3. Vision

“Membuat layanan rumah tangga lokal menjadi lebih terpercaya, transparan, dan mudah diakses melalui AI dan sistem reputasi komunitas.”

---

# 4. Product Goals

## Customer Goals
- Membantu user memahami masalah rumah
- Membantu user menemukan tukang terpercaya
- Mengurangi ketidakjelasan harga
- Membuat proses booking lebih aman

## Mitra Goals
- Membantu tukang mendapatkan order
- Membantu tukang membangun reputasi
- Membantu tukang mengatur jadwal & komunikasi

---

# 5. Target Users

## Customer
- Anak kos
- Keluarga muda
- Pemilik rumah

## Mitra
- Tukang tradisional
- Teknisi profesional

---

# 6. Core Features

## Customer Features

### Home Screen
Kategori:
- AC
- Pipa
- Listrik
- Bersih
- Kebun
- Cat
- Renovasi
- Elektronik
- Atap
- Lainnya

### AI Diagnose
User bisa:
- upload foto,
- menjawab pertanyaan AI,
- mendapat estimasi awal.

### Fair Price Estimation
AI menampilkan:
- estimasi harga,
- kisaran normal,
- warning jika terlalu mahal.

### Tukang Discovery
Menampilkan:
- tukang terdekat,
- rating,
- badge,
- estimasi respon.

### Booking Flow
1. Pilih layanan
2. AI diagnosis
3. Pilih tukang
4. Chat
5. Booking
6. Tracking
7. Review

### In-App Chat
- chat customer ↔ tukang
- quick reply
- order summary

### Complaint Center
Customer bisa:
- lapor no-show,
- lapor harga tidak sesuai,
- lapor kualitas buruk.

---

## Mitra Features

### Mitra Registration
Verifikasi:
- KTP
- WhatsApp
- Selfie
- Portfolio

### Mitra Dashboard
Menampilkan:
- order aktif,
- penghasilan,
- jadwal,
- status verifikasi.

### Schedule Management
- jam kerja
- availability
- hari kerja

### Quick Reply Templates
Template:
- terima order
- konfirmasi harga
- info terlambat

### Reputation Badges
Contoh:
- Identitas Terverifikasi
- Cepat Respon
- Harga Transparan

---

# 7. AI Features

## AI Diagnose
AI membantu mengidentifikasi:
- kerusakan rumah,
- tingkat kerusakan,
- kemungkinan penyebab.

## AI Preventive Tips
Contoh:
“Filter AC sebaiknya dibersihkan setiap 2 bulan.”

## AI Summary
AI membuat summary untuk tukang:
- masalah,
- lokasi,
- estimasi.

---

# 8. Trust & Safety

## Verification
- KTP verification
- Phone verification
- Selfie verification

## No-show Protection
Customer bisa:
- report no-show,
- cari tukang pengganti,
- reschedule.

## Transparent Pricing
Harga final wajib dikonfirmasi sebelum kerja dimulai.

## Complaint Mediation
Beresin menjadi mediator antara customer dan tukang.

---

# 9. Monetization

## Phase 1
Free platform.

## Phase 2
- commission fee,
- featured workers.

## Phase 3
- subscription,
- warranty package,
- priority listing.

---

# 10. MVP Scope

## In Scope for Production MVP
- Customer auth with phone/social login
- Customer home and category discovery
- AI-assisted diagnosis with structured result
- Fair price range and final price confirmation
- Worker discovery with verified profile, service area, rating, and price range
- WhatsApp-first chat handoff with saved booking context
- Booking lifecycle from created to reviewed
- Mitra registration with KTP, selfie, portfolio, area, schedule, and pricing
- Complaint center for no-show, price mismatch, poor quality, and safety issue
- Admin/operator review for worker verification and complaints

## Out of Scope for MVP
- Full in-app realtime chat
- Escrow payment and refund automation
- AI voice assistant
- Warranty package
- Subscription and featured listing monetization

## MVP Acceptance Criteria
- A customer can create a booking from an AI diagnosis or worker profile, and the booking is persisted with status `created`.
- A booking can move through `created`, `accepted`, `on_the_way`, `in_progress`, `final_price_pending`, `completed`, `reviewed`, `cancelled`, or `disputed`.
- A customer can submit final price, review, and complaint records tied to a booking.
- A worker can submit registration data and verification assets for operator review.
- WhatsApp chat opens with a generated summary and the booking record keeps the preferred chat channel.
- The app works with Supabase when configured and can run with local fallback data for demos/tests.

---

# 11. Core Data Model

## User Profile
- id
- role: customer / worker / admin
- name
- phone
- area
- created_at

## Worker
- id
- user_id
- name
- phone
- service_kind
- rating
- reviews_count
- area
- badges
- verification_status
- price_min
- price_max
- availability

## Booking
- id
- customer_id
- worker_id
- category
- problem
- ai_summary
- estimated_price_min
- estimated_price_max
- final_price
- status
- schedule
- address
- payment_method
- chat_channel
- created_at
- updated_at

## Complaint
- id
- booking_id
- type
- description
- status
- created_at

## Worker Verification
- id
- worker_id
- ktp_url
- selfie_url
- portfolio_urls
- status
- reviewer_note
- created_at
- updated_at

---

# 12. Tech Stack

## Frontend
- Flutter
- Dart
- go_router

## Backend
- Supabase Auth
- Supabase Postgres
- Supabase Storage
- Supabase Realtime for later in-app chat

## AI
- Gemini API / OpenAI API

## Chat
- MVP: WhatsApp-first handoff using generated booking summary.
- Later: in-app chat backed by Supabase Realtime.

---

# 13. Design System

## Brand Personality
- Trustworthy
- Friendly
- Local
- Clean

## Color Palette
- #0F9B78
- #063B2F
- #EAF7F1
- #F7F8F4
- #F7F1E3

---

# 14. Roadmap

## Level 1
- AI diagnosis
- booking flow
- WhatsApp-first chat handoff
- worker discovery
- worker registration
- complaint intake

## Level 2
- smart scheduling
- auto reply
- badge system
- complaint center
- in-app chat

## Level 3
- maintenance reminders
- emergency service
- AI voice assistant

---

# 15. Competitive Advantage

Beresin berbeda karena:
- AI diagnosis,
- fair price guidance,
- hyperlocal worker system,
- trust badge,
- complaint mediation.

---

# 16. Launch Strategy

Fokus awal:
- Jakarta Selatan
- Depok
- Tangerang Selatan

Growth:
- komunitas RT/RW,
- WhatsApp groups,
- TikTok,
- komunitas lokal.

---

# 17. Success Definition

Beresin berhasil jika:
- user tidak bingung cari tukang,
- harga lebih transparan,
- tukang lokal mendapat order stabil,
- home service menjadi lebih terpercaya.

---

# 18. Closing

Beresin bukan sekadar aplikasi tukang.

Beresin adalah platform yang membantu masyarakat menyelesaikan masalah rumah dengan lebih aman, jelas, dan terpercaya sambil membantu tukang lokal berkembang di era digital.
