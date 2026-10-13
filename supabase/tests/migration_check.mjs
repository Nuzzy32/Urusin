// Uji migration + RLS di Postgres WASM (PGlite), tanpa Docker/Supabase.
// Jalankan dari root repo:
//   npm i --no-save --prefix /tmp/pgl @electric-sql/pglite@0.2.17
//   PGLITE_DIR=/tmp/pgl node supabase/tests/migration_check.mjs supabase/migrations/20261013120000_init.sql

import { createRequire } from "node:module";
import { readFileSync } from "node:fs";
import assert from "node:assert/strict";

const { PGlite } = await import(createRequire(import.meta.url)
  .resolve("@electric-sql/pglite", { paths: [process.env.PGLITE_DIR ?? process.cwd()] }));

const db = new PGlite();
const stub = `
create role anon nologin; create role authenticated nologin; create role service_role nologin bypassrls;
create schema auth;
create table auth.users (id uuid primary key);
create function auth.uid() returns uuid language sql stable as
  $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
grant usage on schema auth to anon, authenticated;
grant execute on function auth.uid() to anon, authenticated;
create schema storage;
create table storage.buckets (id text primary key, name text, public boolean, file_size_limit bigint, allowed_mime_types text[]);
create table storage.objects (id uuid primary key default gen_random_uuid(), bucket_id text, name text);
alter table storage.objects enable row level security;
create function storage.foldername(name text) returns text[] language sql immutable as
  $$ select (string_to_array(name, '/'))[1:array_length(string_to_array(name, '/'), 1) - 1] $$;
grant usage on schema storage to anon, authenticated;
grant all on storage.objects to anon, authenticated;
create publication supabase_realtime;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
grant usage on schema public to anon, authenticated;
`;
await db.exec(stub);
await db.exec(readFileSync(process.argv[2], "utf8"));
console.log("migration applied");

const A = "00000000-0000-0000-0000-00000000000a"; // calon mitra
const B = "00000000-0000-0000-0000-00000000000b"; // admin
const C = "00000000-0000-0000-0000-00000000000c"; // customer
const D = "00000000-0000-0000-0000-00000000000d"; // orang lain
await db.exec(`insert into auth.users values ('${A}'),('${B}'),('${C}'),('${D}')`);

async function as(uid, sql, params) {
  await db.exec(uid === "anon"
    ? `reset role; set role anon; select set_config('request.jwt.claim.sub','',false);`
    : `reset role; set role authenticated; select set_config('request.jwt.claim.sub','${uid}',false);`);
  try { return (await db.query(sql, params)).rows; } finally { await db.exec("reset role"); }
}
async function fails(uid, sql, re) {
  try { await as(uid, sql); } catch (e) { if (re) assert.match(e.message, re); return e.message; }
  throw new Error("expected failure: " + sql);
}

// _ensureUserProfile: upsert users (onConflict auth_user_id) → returning user_id
for (const [u, n] of [[A, "Rudi"], [B, "Admin"], [C, "Sinta"], [D, "Dodi"]]) {
  const r = await as(u, `insert into public.users (auth_user_id, name, role, area) values ($1,$2,'admin','Tebet')
    on conflict (auth_user_id) do update set name = excluded.name, role = excluded.role returning user_id`, [u, n]);
  assert.equal(r[0].user_id, u);
  await as(u, `insert into public.customers (customer_id, is_active) values ($1, true)
    on conflict (customer_id) do update set is_active = true`, [u]);
}
assert.equal((await db.query(`select role from public.users where user_id='${A}'`)).rows[0].role, "customer", "self-promote blocked");
await db.exec(`update public.users set role='admin' where user_id='${B}'`);
await as(B, `insert into public.users (auth_user_id, name, role) values ($1,'Admin','customer')
  on conflict (auth_user_id) do update set role = excluded.role`, [B]);
assert.equal((await db.query(`select role from public.users where user_id='${B}'`)).rows[0].role, "admin", "re-login keeps admin");
await fails(C, `select email from public.users`, /permission denied/);
assert.equal((await as(C, `select user_id from public.users`)).length, 1, "only own user row");
console.log("✓ users/customers");

// A mendaftar mitra
await as(A, `insert into public.worker_applications (id, full_name, whatsapp, bio, status) values ('wa-1','Rudi','0812','Teknisi AC 8 thn','pending')`);
await as(A, `insert into public.worker_application_services (application_id, service_name, is_sub_service) values ('wa-1','AC',false),('wa-1','Cuci AC',true)`);
await as(A, `insert into public.worker_application_prices (application_id, service_name, price_from, price_to) values ('wa-1','AC',80000,150000),('wa-1','Cuci AC',75000,null)`);
await as(A, `insert into public.worker_application_schedules (application_id, day_name, start_time, end_time) values ('wa-1','Senin','08:00','17:00'),('wa-1','Selasa','','')`);
await fails(A, `update public.worker_applications set status='approved' where id='wa-1'`, /hanya bisa di-set admin/);
await fails(D, `insert into public.worker_application_services (application_id, service_name) values ('wa-1','hack')`, /row-level security/);
assert.equal((await as(D, `select * from public.worker_applications`)).length, 0);
assert.equal((await as(B, `select * from public.worker_applications`)).length, 1, "admin sees queue");
await fails(A, `select public.admin_review_application('wa-1', true, 'ok')`, /hanya admin/);
console.log("✓ worker application");

await as(B, `select public.admin_review_application('wa-1', true, 'KTP valid')`);
const m = (await db.query(`select * from public.mitras where mitra_id='${A}'`)).rows[0];
assert.equal(m.verification_status, "approved");
assert.equal(m.price_min, 75000); assert.equal(m.price_max, 150000);
assert.ok(m.primary_category_id, "category mapped");
assert.equal((await db.query(`select * from public.mitra_services where mitra_id='${A}'`)).rows.length, 2);
assert.equal((await db.query(`select * from public.mitra_schedules where mitra_id='${A}'`)).rows.length, 2);
assert.equal((await db.query(`select * from public.mitra_quick_replies where mitra_id='${A}'`)).rows.length, 3);
const badges = async () => (await db.query(`select b.badge_key from public.mitra_badges mb join public.badges b using (badge_id) where mitra_id='${A}' order by 1`)).rows.map(r => r.badge_key);
assert.deepEqual(await badges(), ["verified"]);
await fails(A, `update public.worker_applications set full_name='x' where id='wa-1'`, /sudah direview/);
console.log("✓ admin approve → mitra, services, schedules, quick replies, badge");

// mitra tidak bisa ubah status sendiri, tapi bisa ubah bio
await as(A, `update public.mitras set verification_status='approved', avg_rating=5, bio='baru', is_available=false where mitra_id='${A}'`);
const m2 = (await db.query(`select * from public.mitras where mitra_id='${A}'`)).rows[0];
assert.equal(m2.bio, "baru"); assert.equal(Number(m2.avg_rating), 0); assert.equal(m2.is_available, false);
await as(A, `update public.mitras set is_available=true where mitra_id='${A}'`);
await as(A, `insert into public.mitra_locations (mitra_id, lat, lng) values ('${A}', -6.2265, 106.8560)`);

// anon: daftar tukang + embed users + nearby
const pub = await as("anon", `select m.mitra_id, u.name, u.phone_number from public.mitras m join public.users u on u.user_id = m.mitra_id`);
assert.equal(pub.length, 1); assert.equal(pub[0].name, "Rudi");
assert.equal((await as("anon", `select * from public.mitra_locations`)).length, 0, "locations hidden");
const near = await as("anon", `select * from public.nearby_mitras(-6.2300, 106.8500, null, 5)`);
assert.equal(near.length, 1); assert.ok(near[0].distance_km < 2);
assert.equal((await as("anon", `select * from public.nearby_mitras(-6.9, 107.6, null, 5)`)).length, 0, "Bandung out of range");
console.log("✓ public listing & nearby_mitras");

// booking C → A
const bk = (await as(C, `insert into public.bookings (customer_id, worker_id, category, problem) values ($1,$2,'AC','AC bocor') returning id, booking_code`, [C, A]))[0];
assert.match(bk.booking_code, /^BRS-[0-9A-F]{8}$/);
assert.equal((await as(A, `select id from public.bookings`)).length, 1, "mitra sees own booking");
assert.equal((await as(D, `select id from public.bookings`)).length, 0, "stranger sees nothing");
await fails(D, `insert into public.bookings (customer_id, worker_id) values ('${C}','${A}')`, /row-level security/);
await as(A, `update public.bookings set status='accepted' where id='${bk.id}'`);
assert.ok((await db.query(`select accepted_at from public.bookings where id='${bk.id}'`)).rows[0].accepted_at);
await as(A, `update public.bookings set status='completed' where id='${bk.id}'`);
assert.equal((await db.query(`select jobs_done from public.mitras where mitra_id='${A}'`)).rows[0].jobs_done, 1);

// chat
const room = (await as(C, `insert into public.chat_rooms (booking_id) values ('${bk.id}') on conflict (booking_id) do update set booking_id = excluded.booking_id returning room_id`))[0].room_id;
await as(A, `insert into public.chat_messages (room_id, sender_id, message_text) values ('${room}','${A}','Siap meluncur')`);
await fails(D, `insert into public.chat_messages (room_id, sender_id, message_text) values ('${room}','${D}','spam')`, /row-level security/);
assert.equal((await as(C, `select * from public.chat_messages`)).length, 1);
assert.equal((await as(D, `select * from public.chat_messages`)).length, 0);
console.log("✓ booking + chat");

// review → stats
await fails(D, `insert into public.reviews (id, booking_id, worker_id, rating) values ('r-x','${bk.id}','${A}',1)`, /row-level security/);
await as(C, `insert into public.reviews (id, booking_id, worker_id, rating, was_price_within_estimate) values ('review-1','${bk.id}','${A}',5,true)`);
const m3 = (await db.query(`select avg_rating, total_reviews from public.mitras where mitra_id='${A}'`)).rows[0];
assert.equal(Number(m3.avg_rating), 5); assert.equal(m3.total_reviews, 1);
assert.equal((await as("anon", `select * from public.reviews`)).length, 1);
console.log("✓ review → rating");

// complaint
const cp = (await as(C, `insert into public.complaints (booking_id, reporter_id, type, description, evidence_image_urls) values ('${bk.id}','${C}','price_mismatch','naik', array['x.jpg']) returning id`))[0].id;
await as(C, `update public.bookings set status='disputed' where id='${bk.id}'`);
await fails(C, `insert into public.complaints (booking_id, reporter_id, type, status) values ('${bk.id}','${C}','other','resolved')`, /row-level security/);
await as(C, `update public.complaints set status='resolved' where id='${cp}'`); // no-op for non-admin
assert.equal((await db.query(`select status from public.complaints where id='${cp}'`)).rows[0].status, "open");
await as(B, `update public.complaints set status='resolved', resolution_note='refund sebagian', resolved_at=now() where id='${cp}'`);
assert.equal((await db.query(`select status from public.complaints where id='${cp}'`)).rows[0].status, "resolved");
assert.equal((await as(A, `select * from public.complaints`)).length, 1, "mitra sees complaint on own booking");
console.log("✓ complaints");

// ai_diagnoses
await as(C, `insert into public.ai_diagnoses (customer_id, problem_summary) values ('${C}','AC bocor')`);
await fails(C, `insert into public.ai_diagnoses (customer_id) values ('${D}')`, /row-level security/);
assert.equal((await as(D, `select * from public.ai_diagnoses`)).length, 0);
console.log("✓ ai_diagnoses");

// storage
await as(C, `insert into storage.objects (bucket_id, name) values ('diagnoses','diagnoses/${C}/1.jpg')`);
await fails(C, `insert into storage.objects (bucket_id, name) values ('diagnoses','diagnoses/${D}/1.jpg')`, /row-level security/);
await as(C, `insert into storage.objects (bucket_id, name) values ('complaint-evidence','${bk.id}/1.jpg')`);
await fails(D, `insert into storage.objects (bucket_id, name) values ('complaint-evidence','${bk.id}/2.jpg')`, /row-level security/);
await as(A, `insert into storage.objects (bucket_id, name) values ('worker-verification','${A}/ktp.jpg')`);
await fails(C, `insert into storage.objects (bucket_id, name) values ('worker-verification','${A}/ktp2.jpg')`, /row-level security/);
assert.equal((await as(B, `select * from storage.objects where bucket_id='worker-verification'`)).length, 1, "admin reads KTP");
assert.equal((await as(D, `select * from storage.objects where bucket_id='worker-verification'`)).length, 0);
console.log("✓ storage policies");

// reject flow
await as(D, `insert into public.worker_applications (id, full_name, status) values ('wa-2','Dodi','pending')`);
await as(B, `select public.admin_review_application('wa-2', false, 'KTP buram')`);
assert.equal((await db.query(`select status, reviewer_note from public.worker_applications where id='wa-2'`)).rows[0].reviewer_note, "KTP buram");
assert.equal((await db.query(`select count(*)::int c from public.mitras where mitra_id='${D}'`)).rows[0].c, 0);
console.log("✓ reject flow\nALL OK");
