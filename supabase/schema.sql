create extension if not exists "pgcrypto";

create table if not exists public.user_profiles (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid references auth.users(id) on delete cascade,
  role text not null check (role in ('customer', 'worker', 'admin')),
  name text not null,
  phone text,
  area text,
  created_at timestamptz not null default now()
);

create unique index if not exists user_profiles_auth_user_id_key
  on public.user_profiles(auth_user_id);

create table if not exists public.workers (
  id text primary key,
  user_id uuid references public.user_profiles(id) on delete set null,
  name text not null,
  phone text not null,
  service_kind text not null,
  rating numeric(2,1) not null default 0,
  reviews_count integer not null default 0,
  area text not null default '',
  badges text[] not null default '{}',
  verification_status text not null default 'pending'
    check (verification_status in ('draft', 'submitted', 'pending', 'approved', 'rejected')),
  price_min integer not null default 0,
  price_max integer not null default 0,
  availability text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.bookings (
  id text primary key,
  customer_id text not null,
  worker_id text not null,
  category text not null,
  problem text not null,
  ai_summary text not null default '',
  estimated_price_min integer not null default 0,
  estimated_price_max integer not null default 0,
  final_price integer,
  final_price_note text,
  status text not null default 'created'
    check (status in (
      'created',
      'accepted',
      'on_the_way',
      'in_progress',
      'final_price_pending',
      'completed',
      'reviewed',
      'cancelled',
      'disputed'
    )),
  schedule text not null default '',
  address text not null default '',
  access_note text not null default '',
  customer_note text not null default '',
  payment_method text not null default '',
  chat_channel text not null default 'whatsapp'
    check (chat_channel in ('whatsapp', 'in_app')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.complaints (
  id text primary key,
  booking_id text not null references public.bookings(id) on delete cascade,
  type text not null check (type in ('no_show', 'price_mismatch', 'poor_quality', 'safety', 'other')),
  description text not null default '',
  status text not null default 'open'
    check (status in ('open', 'in_review', 'resolved', 'rejected')),
  created_at timestamptz not null default now()
);

create table if not exists public.reviews (
  id text primary key,
  booking_id text not null references public.bookings(id) on delete cascade,
  worker_id text not null,
  user_name text not null default 'Customer Beresin',
  rating integer not null check (rating between 1 and 5),
  text text not null default '',
  actual_price integer,
  was_price_within_estimate boolean,
  would_recommend boolean,
  created_at timestamptz not null default now()
);

create table if not exists public.worker_applications (
  id text primary key,
  full_name text not null,
  business_name text not null,
  whatsapp text not null,
  domicile text not null default '',
  bio text not null default '',
  services text[] not null default '{}',
  sub_services text[] not null default '{}',
  areas text[] not null default '{}',
  days text[] not null default '{}',
  start_time text not null default '',
  end_time text not null default '',
  price_from jsonb not null default '{}',
  price_to jsonb not null default '{}',
  ktp_asset_path text not null default '',
  selfie_asset_path text not null default '',
  portfolio_asset_paths text[] not null default '{}',
  status text not null default 'pending'
    check (status in ('draft', 'submitted', 'pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_profiles enable row level security;
alter table public.workers enable row level security;
alter table public.bookings enable row level security;
alter table public.complaints enable row level security;
alter table public.reviews enable row level security;
alter table public.worker_applications enable row level security;

create policy "users can manage own profile"
  on public.user_profiles for all
  using (auth.uid() = auth_user_id)
  with check (auth.uid() = auth_user_id);

create policy "public workers readable"
  on public.workers for select
  using (true);

create policy "authenticated app data"
  on public.bookings for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "authenticated complaints"
  on public.complaints for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "authenticated reviews"
  on public.reviews for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "authenticated worker applications"
  on public.worker_applications for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

insert into storage.buckets (id, name, public)
values
  ('worker-verification', 'worker-verification', false),
  ('booking-photos', 'booking-photos', false)
on conflict (id) do nothing;
