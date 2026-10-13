# Beresin — 1-Month Venture Prototype Brief

> Shared context for Codex, Claude Code, designers, and future contributors.
>
> This project is **not just a hackathon demo**. The goal is to build a useful, validated, investor-ready prototype within 1 month.

---

## 1. Product Summary

**Beresin** is an AI-powered hyperlocal home service platform for Indonesia.

It helps people solve urgent home problems by letting them upload a photo or describe the issue. AI then analyzes the problem, estimates fair pricing, and recommends trusted local workers nearby.

### Tagline

> Rusak di rumah? Foto aja, Beresin bantu cari tukangnya.

### Core Promise

Beresin solves three painful problems:

1. **Discovery** — users do not know where to find reliable local workers.
2. **Trust** — users are afraid of being scammed, overcharged, or inviting unsafe strangers.
3. **Price Transparency** — users do not know what a fair price is.

Beresin is not merely a marketplace. It is a **trust and intelligence layer** for local home services.

---

## 2. Product Positioning

### One-Liner

> Beresin is an AI home repair assistant that diagnoses home issues from photos, estimates fair local prices, and connects users with verified nearby workers.

### Investor Framing

Indonesia has millions of informal skilled workers, but discovery and trust are fragmented across WhatsApp groups, neighbors, Facebook posts, and personal referrals. Beresin digitizes this offline trust network and adds AI-based diagnosis, price transparency, and structured service requests.

### Why Now

- AI vision can understand images of home problems.
- Users are already comfortable using WhatsApp to contact workers.
- Informal service workers need better digital visibility.
- Urban households increasingly need fast, reliable home services.
- Trust, verification, and transparent pricing remain unsolved in local service marketplaces.

---

## 3. Target Users

### Primary Customer Segment

Urban and semi-urban residents in Indonesia who need home repair or maintenance services.

Examples:

- Homeowners
- Renters
- Anak kos
- Apartment residents
- Small shop owners
- Busy families
- Working professionals

### Initial Launch Area

Start hyperlocal. Do not launch nationwide.

Recommended first pilot area:

- Tebet, Jakarta Selatan
- Depok
- Bandung city area
- Yogyakarta student/kos area
- Surabaya residential area

For development and demo, use **Tebet, Jakarta Selatan** as the default seed location.

---

## 4. Service Focus

Do **not** start as a general marketplace for every service.

### Initial Wedge

Focus on urgent, high-frequency home repair problems:

1. AC service and AC leakage
2. Plumbing / pipe leaks / clogged drains
3. Electrical problems

### Why These Three

- Clear pain
- Urgent enough for users to act quickly
- Pricing anxiety is common
- Photo diagnosis is useful
- Workers are common in most neighborhoods
- Strong repeat usage potential

### Future Expansion

After the first category works:

- Cleaning service
- Gardening
- Painting
- Appliance repair
- Pest control
- Pet sitting
- Elderly assistance

---

## 5. Core User Journey

### Main Flow

1. User opens Beresin.
2. User uploads a photo or describes the home problem.
3. AI analyzes the problem.
4. AI returns:
   - likely problem
   - severity
   - recommended worker type
   - fair local price range
   - estimated duration
   - safety note
5. User sees recommended verified workers nearby.
6. User reviews worker profiles.
7. User sends a structured WhatsApp message to the worker.
8. After service, user records actual price and leaves a review.
9. Beresin improves future price estimates and trust scoring.

### Main Magical Moment

> Photo of broken AC → AI says likely issue → fair price range → recommended technician → WhatsApp message ready.

---

## 6. MVP Scope for 1 Month

The goal is not to build everything. The goal is to build a product that can be used, tested, and pitched.

### Must-Have Features

#### User Side

- Mobile-first landing page
- Problem upload screen
- Text problem description
- Category selector
- Urgency selector
- AI analysis result screen
- Worker recommendation list
- Worker profile page
- WhatsApp contact handoff
- Service request history
- Post-service review form

#### AI Features

- Image-based or text-based problem analysis
- Structured JSON output
- Service category detection
- Severity detection
- Fair price estimate
- Worker matching explanation
- WhatsApp message generation

#### Trust Features

- Worker verification badges
- Price transparency card
- Review snippets
- “Why this worker?” explanation
- Safety warning before contacting worker
- Actual price vs estimated price tracking

#### Admin / Operator Side

This is important for a real 1-month product.

- Basic admin page for managing workers
- Add/edit worker data
- Add service categories
- View incoming service requests
- View user reviews
- View actual price submitted by users

### Should-Have Features

- Login with phone/email
- Location input or approximate area
- Save favorite workers
- Manual worker matching fallback
- Analytics dashboard for pitch

### Nice-to-Have Features

- Real map integration
- In-app chat
- Payment system
- Worker app
- Worker availability calendar
- Automated WhatsApp Business API integration

### Explicitly Out of Scope for Month 1

Do not build these unless core flow is already polished:

- Full payment gateway
- Full logistics/dispatch system
- Complex real-time chat
- Multi-city launch
- Complete worker mobile app
- Advanced fraud detection
- Native mobile app

---

## 7. Product Screens

### 1. Home Screen

Purpose: explain the product instantly.

Content:

- App name: Beresin
- Hero headline: “Rusak di rumah? Foto aja, Beresin bantu cari tukangnya.”
- Subheadline: “AI bantu analisis masalah, estimasi harga, dan rekomendasi tukang terpercaya di sekitar kamu.”
- CTA: “Cek Masalah Sekarang”
- Secondary CTA: “Lihat Tukang Terdekat”
- Service chips: AC Bocor, Pipa Mampet, Listrik Mati
- Trust indicators:
  - Estimasi harga transparan
  - Tukang terverifikasi
  - Rekomendasi dekat lokasi

### 2. Problem Upload Screen

Inputs:

- Photo upload
- Text description
- Category selector
- Urgency selector
- Location/area input

CTA:

- “Analisis dengan AI”

### 3. AI Loading Screen

Steps:

1. Membaca foto kerusakan
2. Mendeteksi pola masalah
3. Mencari estimasi harga wajar
4. Memilih tukang terdekat

### 4. AI Analysis Result Screen

Show:

- Detected problem
- Category
- Severity
- Urgency
- Confidence
- Explanation
- Estimated fair price range
- Estimated duration
- Recommended next step
- Safety note

CTA:

- “Cari Teknisi Terdekat”
- “Tanya AI Dulu”

### 5. Worker Recommendation Screen

Each worker card should show:

- Name
- Service type
- Rating
- Distance
- ETA
- Price range
- Trust badges
- Review snippet
- Why recommended
- Estimated price comparison
- Profile button
- Contact button

Example worker card:

```text
Pak Rudi
Teknisi AC · 328 pekerjaan
Rating 4.9 · 1.2 km · ETA 20 menit
Harga: Rp80.000–Rp130.000
Estimasi Beresin: Rp75.000–Rp150.000
Status harga: Dalam rentang wajar
Kenapa direkomendasikan: Sering menangani AC bocor di Tebet, rating tinggi untuk ketepatan waktu, dan harga sesuai estimasi.
```

### 6. Worker Profile Screen

Show:

- Worker photo/avatar
- Name
- Profession
- Rating
- Jobs completed
- Distance
- Verification badges
- Services and price list
- Reviews
- Complaint/safety note
- CTA: “Hubungi via WhatsApp”

### 7. Contact / Booking Screen

Show:

- Worker summary
- AI-generated WhatsApp message
- Editable message box
- Time preference
- Address input
- Safety reminder
- CTA: “Kirim ke WhatsApp”

### 8. History Screen

Show:

- Active requests
- Past services
- Actual price paid
- Rating status
- Saved workers

### 9. Post-Service Review Screen

Important for real validation and investor story.

Inputs:

- Did the worker arrive?
- Actual price paid
- Was the price within estimate?
- Rating
- Review text
- Would you recommend this worker?
- Upload proof/photo optional

This data improves trust scoring and price estimation.

### 10. Admin Dashboard

Minimum admin features:

- Worker list
- Add worker
- Edit worker
- Service categories
- Request list
- Review list
- Price estimate vs actual price table

---

## 8. Data Model

Use Supabase or Firebase. Supabase is recommended for relational queries.

### users

```ts
type User = {
  id: string;
  name: string;
  phone?: string;
  email?: string;
  default_area?: string;
  created_at: string;
};
```

### service_categories

```ts
type ServiceCategory = {
  id: string;
  name: string; // AC, Plumbing, Electrical
  slug: string;
  icon?: string;
  is_active: boolean;
};
```

### workers

```ts
type Worker = {
  id: string;
  name: string;
  phone: string;
  profession: string;
  category_ids: string[];
  area: string;
  distance_km?: number;
  eta_minutes?: number;
  rating: number;
  jobs_completed: number;
  years_experience?: number;
  bio?: string;
  avatar_url?: string;
  is_identity_verified: boolean;
  is_phone_verified: boolean;
  is_price_transparent: boolean;
  is_active: boolean;
  created_at: string;
};
```

### worker_services

```ts
type WorkerService = {
  id: string;
  worker_id: string;
  category_id: string;
  service_name: string;
  min_price: number;
  max_price: number;
  description?: string;
};
```

### service_requests

```ts
type ServiceRequest = {
  id: string;
  user_id?: string;
  problem_description: string;
  image_url?: string;
  area: string;
  category: string;
  urgency: 'normal' | 'soon' | 'emergency';
  ai_problem_title: string;
  ai_problem_summary: string;
  ai_severity: 'low' | 'medium' | 'high';
  ai_confidence: number;
  estimated_min_price: number;
  estimated_max_price: number;
  estimated_duration_minutes_min: number;
  estimated_duration_minutes_max: number;
  recommended_worker_type: string;
  status: 'draft' | 'analyzed' | 'contacted' | 'confirmed' | 'completed' | 'cancelled';
  selected_worker_id?: string;
  created_at: string;
};
```

### worker_recommendations

```ts
type WorkerRecommendation = {
  id: string;
  service_request_id: string;
  worker_id: string;
  match_score: number;
  reason: string;
  price_fit: 'below_estimate' | 'within_estimate' | 'above_estimate' | 'unknown';
  created_at: string;
};
```

### reviews

```ts
type Review = {
  id: string;
  service_request_id: string;
  worker_id: string;
  user_id?: string;
  rating: number;
  review_text?: string;
  actual_price?: number;
  was_price_within_estimate?: boolean;
  arrived_on_time?: boolean;
  would_recommend?: boolean;
  created_at: string;
};
```

---

## 9. AI Analysis Contract

AI must return structured JSON. Do not rely on unstructured prose for core app logic.

### Input

- Image file, optional
- Problem description, optional
- Category selected by user, optional
- Area/location
- Urgency

### System Behavior

The AI should:

- Identify the likely home repair problem
- Avoid making dangerous claims
- Avoid pretending to be a certified technician
- Provide likely causes, not definitive diagnosis
- Estimate fair price range based on common Indonesian service pricing
- Suggest worker category
- Suggest safety precautions
- Return JSON only

### JSON Schema

```json
{
  "problem_title": "Saluran drainase AC tersumbat",
  "category": "AC",
  "recommended_worker_type": "Teknisi AC",
  "severity": "medium",
  "urgency": "soon",
  "confidence": 0.87,
  "likely_causes": [
    "Saluran pembuangan air tersumbat",
    "Evaporator terlalu kotor"
  ],
  "explanation": "Gejala ini biasanya terjadi karena saluran pembuangan air kotor tersumbat atau evaporator terlalu kotor.",
  "estimated_price": {
    "currency": "IDR",
    "min": 75000,
    "max": 150000,
    "label": "Harga wajar untuk area lokal"
  },
  "estimated_duration_minutes": {
    "min": 30,
    "max": 60
  },
  "recommended_next_step": "Panggil teknisi AC untuk pengecekan dan pembersihan saluran drainase.",
  "safety_note": "Jangan membongkar unit AC sendiri jika tidak berpengalaman. Matikan AC jika air menetes dekat stop kontak.",
  "whatsapp_message": "Halo Pak, saya butuh bantuan untuk AC bocor. Berdasarkan analisis Beresin, kemungkinan saluran drainase tersumbat. Apakah bisa datang hari ini?"
}
```

### Prompt Template

```text
You are Beresin AI, an Indonesian home repair assistant.

Analyze the user's home repair issue using the provided image and/or text.

Important rules:
- Do not claim certainty. Use likely/probable language.
- Do not provide dangerous repair instructions.
- Recommend the correct type of local worker.
- Estimate a fair price range in Indonesian Rupiah.
- Return JSON only using the schema provided.
- Use Bahasa Indonesia for user-facing text.

User area: {{area}}
User selected category: {{category}}
User urgency: {{urgency}}
Problem description: {{description}}

Return JSON:
{
  "problem_title": string,
  "category": string,
  "recommended_worker_type": string,
  "severity": "low" | "medium" | "high",
  "urgency": "normal" | "soon" | "emergency",
  "confidence": number,
  "likely_causes": string[],
  "explanation": string,
  "estimated_price": {
    "currency": "IDR",
    "min": number,
    "max": number,
    "label": string
  },
  "estimated_duration_minutes": {
    "min": number,
    "max": number
  },
  "recommended_next_step": string,
  "safety_note": string,
  "whatsapp_message": string
}
```

---

## 10. Worker Matching Logic

For Month 1, matching can be rule-based with AI-generated explanation.

### Match Score Factors

```text
match_score =
  category_match * 40
+ distance_score * 20
+ rating_score * 15
+ price_fit_score * 15
+ availability_score * 10
```

### Category Match

- Exact category match: 1.0
- Related category: 0.5
- No match: 0.0

### Distance Score

- <= 2 km: 1.0
- <= 5 km: 0.7
- <= 10 km: 0.4
- > 10 km: 0.1

### Price Fit Score

- Worker price overlaps AI estimate: 1.0
- Worker price slightly above estimate: 0.6
- Unknown price: 0.4
- Far above estimate: 0.2

### Example Recommendation Explanation

> Pak Rudi direkomendasikan karena sering menangani AC bocor di area Tebet, rating tinggi untuk ketepatan waktu, dan rentang harganya masih sesuai estimasi wajar Beresin.

---

## 11. Suggested Tech Stack

### Frontend

- Next.js
- TypeScript
- Tailwind CSS
- shadcn/ui
- Framer Motion for polish

### Backend

- Supabase
  - Auth
  - Postgres database
  - Storage for uploaded images
  - Row-level security later

### AI

- Gemini API for multimodal image/text analysis

### Maps / Location

Month 1:

- Manual area input is enough.
- Use fake or seeded distance values.

Later:

- Google Maps API
- Geocoding
- Distance matrix

### WhatsApp

Month 1:

- Use `https://wa.me/{{phone}}?text={{encoded_message}}`

Later:

- WhatsApp Business API

---

## 12. Folder Structure

Recommended Next.js structure:

```text
/src
  /app
    /page.tsx
    /check/page.tsx
    /analysis/[id]/page.tsx
    /workers/page.tsx
    /workers/[id]/page.tsx
    /contact/[workerId]/page.tsx
    /history/page.tsx
    /review/[requestId]/page.tsx
    /admin/page.tsx
  /components
    /layout
    /ui
    /home
    /problem
    /analysis
    /workers
    /trust
    /admin
  /lib
    ai.ts
    matching.ts
    pricing.ts
    whatsapp.ts
    supabase.ts
    utils.ts
  /data
    seed-workers.ts
    service-categories.ts
  /types
    index.ts
```

---

## 13. Development Plan — 1 Month

### Week 1 — Foundation and Prototype Flow

Goal: make the core flow clickable and visually strong.

Tasks:

- Set up Next.js project
- Implement design system
- Build home screen
- Build upload screen
- Build AI result screen using mock data
- Build worker recommendation screen using seed data
- Build worker profile screen
- Build WhatsApp handoff screen

Deliverable:

- Fully clickable UI flow using mock data

### Week 2 — AI and Database

Goal: make the core flow functional.

Tasks:

- Set up Supabase
- Create tables
- Add seed workers
- Add image upload
- Integrate Gemini API
- Return structured AI result
- Save service request
- Generate worker recommendations

Deliverable:

- User can upload/describe problem and get AI analysis + matched workers

### Week 3 — Trust Layer and Admin

Goal: make the product feel real and useful.

Tasks:

- Build admin worker management page
- Add price comparison logic
- Add “Why recommended?” explanations
- Add review form
- Add actual price tracking
- Add service history
- Improve trust badges
- Add safety warnings

Deliverable:

- Product has trust, review, and operational feedback loop

### Week 4 — Validation, Polish, Pitch

Goal: prepare for users, judges, and potential investors.

Tasks:

- Test with 10–20 potential users
- Interview 5–10 local workers
- Collect testimonials or quotes
- Polish UI and mobile responsiveness
- Improve loading states and errors
- Add analytics dashboard for pitch
- Create demo script
- Create landing page section for waitlist
- Prepare pitch deck

Deliverable:

- Investor-ready prototype with validation signals

---

## 14. Validation Plan

This project should not only be built. It should be validated.

### User Validation Questions

Ask potential users:

1. When something breaks at home, how do you usually find a worker?
2. What was your worst experience with a home service worker?
3. What makes you trust or distrust a worker?
4. How do you know whether the price is fair?
5. Would you use an app that estimates the problem and recommends trusted nearby workers?
6. Would you still prefer contacting via WhatsApp?
7. What services do you need most often?

### Worker Validation Questions

Ask workers:

1. How do you usually get customers?
2. Do you want more customers from nearby areas?
3. Are you comfortable receiving structured requests via WhatsApp?
4. What information do you need before visiting?
5. Would transparent pricing help or hurt your business?
6. Would you pay commission, subscription, or lead fee?

### Validation Metrics

By the end of Month 1, aim for:

- 30+ user survey responses
- 10+ user interviews
- 10+ workers listed manually
- 5+ workers willing to be contacted through Beresin
- 20+ test service requests submitted
- 5+ real or simulated completed service flows
- Clear evidence that price transparency and trust are valuable

---

## 15. Business Model Options

Do not overcommit too early. Test multiple models.

### Option A — Lead Fee

Workers pay a small fee for qualified leads.

Example:

- Rp5.000–Rp15.000 per valid lead

### Option B — Commission

Beresin takes a commission from completed jobs.

Example:

- 5–10% per completed transaction

### Option C — Worker Subscription

Workers pay monthly to appear higher or access more leads.

Example:

- Rp49.000–Rp199.000/month

### Option D — B2B Residential Partnerships

Partner with:

- Kost operators
- Apartment managers
- Housing clusters
- Property managers

This may be stronger than direct consumer acquisition.

### Recommended Initial Model

Start with **manual lead generation + WhatsApp handoff**.

Then test whether workers prefer:

- pay per lead
- pay per successful job
- monthly subscription

---

## 16. Investor Narrative

### Problem

Finding trusted local home service workers in Indonesia is still fragmented, manual, and risky. People rely on neighbors, WhatsApp groups, or random contacts. Pricing is unclear, and trust is weak.

### Solution

Beresin uses AI to diagnose home issues from photos, estimate fair local prices, and match users with verified nearby workers.

### Market

Home maintenance is frequent, recurring, and hyperlocal. Millions of households and informal workers need a better trust and discovery system.

### Why Beresin Wins

- AI-powered diagnosis creates a strong entry point
- Price transparency solves a major trust issue
- WhatsApp handoff fits existing user behavior
- Hyperlocal trust data compounds over time
- Worker reputation and actual price history create defensibility

### Long-Term Vision

Beresin becomes the trust infrastructure for informal local services in Indonesia.

---

## 17. Product Principles

1. **Trust before transaction**
2. **Price transparency is a core feature, not a bonus**
3. **Use WhatsApp behavior instead of fighting it**
4. **Start hyperlocal, then expand**
5. **Help workers, do not exploit them**
6. **AI should reduce confusion, not pretend to replace experts**
7. **Every completed job should improve the system**

---

## 18. Copywriting Guidelines

Tone:

- Friendly
- Clear
- Local Indonesian
- Trustworthy
- Not too corporate

Avoid:

- Overclaiming AI certainty
- Overly technical language
- Scary language
- Promising guaranteed repair

Use phrases like:

- “Kemungkinan masalah”
- “Estimasi harga wajar”
- “Disarankan panggil teknisi”
- “Harga dapat berubah setelah pengecekan langsung”
- “Jangan bayar penuh sebelum pekerjaan dicek”

---

## 19. Safety and Trust Requirements

The app must include safety reminders.

Minimum safety messages:

- Do not pay full amount before inspection.
- Confirm price before work starts.
- Avoid DIY repair for electrical issues.
- Turn off electricity/water/AC if there is immediate risk.
- Report suspicious behavior.

AI must not provide dangerous instructions such as:

- detailed electrical repair steps
- gas-related repair steps
- instructions involving high-risk tools
- structural repair instructions beyond basic advice

---

## 20. Demo Script

Use this in presentation.

### Scenario

A user’s AC is leaking in their room. They do not know what the issue is, who to call, or what price is fair.

### Demo Steps

1. Open Beresin home screen.
2. Tap “Cek Masalah Sekarang.”
3. Upload AC leakage photo or use sample image.
4. Add description: “AC saya bocor dari dalam, sudah 2 hari.”
5. Tap “Analisis dengan AI.”
6. Show loading steps.
7. Show AI result:
   - likely clogged AC drain
   - medium severity
   - fair price Rp75.000–Rp150.000
   - duration 30–60 minutes
8. Tap “Cari Teknisi Terdekat.”
9. Show Pak Rudi as recommended worker.
10. Explain why recommended:
    - nearby
    - verified
    - rating high
    - price within fair estimate
11. Open worker profile.
12. Tap WhatsApp contact.
13. Show auto-generated message.
14. End with post-service feedback loop and price learning.

### Closing Line

> Beresin is not just helping users find workers. It is building a local trust network for home services.

---

## 21. Collaboration Rules for Codex and Claude Code

### Codex Role

Prioritize implementation:

- Next.js routes
- components
- TypeScript types
- database schema
- Supabase integration
- API routes
- AI integration
- matching logic

### Claude Code Role

Prioritize product quality:

- UI refinement
- copywriting
- component clarity
- edge cases
- accessibility
- user flow consistency
- README and documentation
- pitch/demo polish

### Shared Rules

- Keep the MVP focused on AC, plumbing, and electrical services.
- Do not expand categories unless core flow is complete.
- Use structured AI JSON.
- Make the UI mobile-first.
- Always include trust and price transparency.
- Prefer working features over fake complexity.
- Keep code readable and modular.
- Do not hardcode everything if it should later come from database.
- But seed data is acceptable for Month 1.

---

## 22. Immediate Next Tasks

Start here.

### Task 1 — Project Setup

- Create Next.js TypeScript app
- Add Tailwind
- Add shadcn/ui
- Set up basic routes
- Add global layout and bottom navigation

### Task 2 — Seed Data

Create seed workers for Tebet:

- Pak Rudi — Teknisi AC
- Pak Budi — Teknisi AC
- Mas Arif — Teknisi AC
- Pak Dedi — Plumbing
- Mas Hendra — Electrical

### Task 3 — Build Core Screens

- Home
- Check problem
- AI result
- Worker list
- Worker profile
- Contact WhatsApp

### Task 4 — Add AI Stub

Before real Gemini integration, create a mock AI response for AC leakage.

### Task 5 — Add Real AI

Integrate Gemini and map its JSON response to the UI.

### Task 6 — Add Admin

Build a simple `/admin` page to manage workers and requests.

### Task 7 — Add Review Loop

Add post-service review and actual price input.

---

## 23. Success Criteria for Month 1

The project is successful if by the end of 1 month:

- A user can complete the main flow on mobile.
- AI analysis works for at least 3 categories.
- There are at least 10 real or manually verified workers in one area.
- Users understand the product in under 5 seconds.
- The app clearly explains fair pricing.
- There is a trust mechanism beyond simple star ratings.
- The team has collected real validation data.
- The product can be demonstrated to investors or competition judges.

---

## 24. Final Product Thesis

Beresin wins by combining:

- AI diagnosis
- fair price estimation
- verified local workers
- WhatsApp-native behavior
- hyperlocal trust data

The first version should feel simple, useful, and trustworthy.

Do not build a generic marketplace.

Build the trust layer for local home services.
