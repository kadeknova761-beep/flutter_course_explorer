-- Tahap 11: Schema database Supabase
-- Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C

create table public.courses (
  id bigint generated always as identity primary key,
  code text not null,
  title text not null,
  credits int not null check (credits > 0),
  status text not null default 'planned'
    check (status in ('planned', 'active', 'done')),
  created_at timestamptz not null default now()
);

insert into public.courses (code, title, credits, status) values
  ('NOVA901', 'Pemrograman Mobile Flutter', 3, 'active'),
  ('NOVA902', 'Basis Data', 3, 'planned'),
  ('NOVA903', 'Rekayasa Perangkat Lunak', 3, 'done');

-- RLS + policy permisif: HANYA untuk laboratorium, bukan pola produksi
alter table public.courses enable row level security;

create policy "lab_select" on public.courses for select to anon using (true);
create policy "lab_insert" on public.courses for insert to anon with check (true);
create policy "lab_update" on public.courses for update to anon using (true) with check (true);
create policy "lab_delete" on public.courses for delete to anon using (true);