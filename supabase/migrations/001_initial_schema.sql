create table if not exists public.bookings (
  id text primary key,
  customer_id text not null,
  worker_id text not null,
  category text not null,
  problem text not null default '',
  ai_summary text not null default '',
  estimated_price_min integer not null default 0,
  estimated_price_max integer not null default 0,
  final_price integer,
  final_price_note text,
  status text not null default 'created'
    check (
      status in (
        'created',
        'accepted',
        'on_the_way',
        'in_progress',
        'final_price_pending',
        'completed',
        'reviewed',
        'cancelled',
        'disputed'
      )
    ),
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
  type text not null
    check (
      type in (
        'no_show',
        'price_mismatch',
        'poor_quality',
        'safety',
        'other'
      )
    ),
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
  full_name text not null default '',
  business_name text not null default '',
  whatsapp text not null default '',
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
  status text not null default 'draft'
    check (status in ('draft', 'submitted', 'pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists bookings_customer_id_idx
  on public.bookings(customer_id);

create index if not exists bookings_worker_id_idx
  on public.bookings(worker_id);

create index if not exists bookings_status_idx
  on public.bookings(status);

create index if not exists complaints_booking_id_idx
  on public.complaints(booking_id);

create index if not exists reviews_worker_id_idx
  on public.reviews(worker_id);

create index if not exists reviews_booking_id_idx
  on public.reviews(booking_id);

create index if not exists worker_applications_status_idx
  on public.worker_applications(status);

alter table public.bookings enable row level security;
alter table public.complaints enable row level security;
alter table public.reviews enable row level security;
alter table public.worker_applications enable row level security;

create policy "authenticated users can manage bookings"
  on public.bookings for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "authenticated users can manage complaints"
  on public.complaints for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "authenticated users can manage reviews"
  on public.reviews for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "authenticated users can manage worker applications"
  on public.worker_applications for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_bookings_updated_at on public.bookings;
create trigger set_bookings_updated_at
  before update on public.bookings
  for each row
  execute function public.set_updated_at();

drop trigger if exists set_worker_applications_updated_at on public.worker_applications;
create trigger set_worker_applications_updated_at
  before update on public.worker_applications
  for each row
  execute function public.set_updated_at();
