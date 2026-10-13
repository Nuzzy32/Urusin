insert into storage.buckets (id, name, public)
values ('worker-assets', 'worker-assets', false)
on conflict (id) do nothing;
